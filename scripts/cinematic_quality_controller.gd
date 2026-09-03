extends Node
class_name VantaCinematicQualityController

var player: VantaPlayerController
var time_manager: WorldTimeManager
var visual_environment: VantaVisualEnvironment
var camera_pivot: Node3D
var spring_arm: SpringArm3D
var base_pivot_position := Vector3.ZERO
var base_spring_position := Vector3.ZERO
var motion_time := 0.0
var styled_windows: Array[MeshInstance3D] = []
var ambient_lights: Array[OmniLight3D] = []
var _scan_timer := 0.0

func _ready() -> void:
    add_to_group("cinematic_quality_controller")
    call_deferred("_resolve")
    call_deferred("_scan_world")

func _process(delta: float) -> void:
    _resolve()
    _scan_timer -= delta
    if _scan_timer <= 0.0:
        _scan_timer = 3.0
        _scan_world()
    _update_atmosphere()
    _update_city_lighting()
    _update_camera_motion(delta)

func _resolve() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
        if player != null:
            camera_pivot = player.get_node_or_null("CameraPivot") as Node3D
            spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
            if camera_pivot != null:
                base_pivot_position = camera_pivot.position
            if spring_arm != null:
                base_spring_position = spring_arm.position
    if time_manager == null or not is_instance_valid(time_manager):
        time_manager = get_tree().get_first_node_in_group("world_time_manager") as WorldTimeManager
    if visual_environment == null or not is_instance_valid(visual_environment):
        visual_environment = get_tree().get_first_node_in_group("visual_environment") as VantaVisualEnvironment

func _scan_world() -> void:
    styled_windows.clear()
    ambient_lights.clear()
    var scene := get_tree().current_scene
    if scene == null:
        return
    _collect_visual_nodes(scene)

func _collect_visual_nodes(node: Node) -> void:
    if node is MeshInstance3D:
        var mesh_node := node as MeshInstance3D
        if mesh_node.name.begins_with("GlassBand") or mesh_node.name.begins_with("SkylineGlass"):
            styled_windows.append(mesh_node)
    elif node is OmniLight3D:
        var light := node as OmniLight3D
        if not _is_transient_light(light):
            ambient_lights.append(light)
    for child in node.get_children():
        _collect_visual_nodes(child)

func _is_transient_light(light: OmniLight3D) -> bool:
    var parent := light.get_parent()
    if parent != null:
        var parent_name := str(parent.name).to_lower()
        if "weapon" in parent_name or "muzzle" in parent_name:
            return true
    return light.omni_range <= 3.0

func _update_atmosphere() -> void:
    if time_manager == null or visual_environment == null:
        return
    if visual_environment.sky_material == null or visual_environment.environment == null or visual_environment.sun == null:
        return
    var hour := time_manager.time_hours
    var sun_factor := _daylight_factor(hour)
    var sunset_factor := _sunset_factor(hour)

    var day_top := Color(0.10, 0.30, 0.53, 1.0)
    var night_top := Color(0.008, 0.014, 0.035, 1.0)
    var day_horizon := Color(0.72, 0.84, 0.91, 1.0)
    var night_horizon := Color(0.045, 0.065, 0.10, 1.0)
    var sunset := Color(0.95, 0.43, 0.20, 1.0)

    visual_environment.sky_material.sky_top_color = night_top.lerp(day_top, sun_factor)
    visual_environment.sky_material.sky_horizon_color = night_horizon.lerp(day_horizon, sun_factor).lerp(sunset, sunset_factor * 0.45)
    visual_environment.environment.ambient_light_energy = lerpf(0.22, 0.78, sun_factor)
    visual_environment.environment.tonemap_exposure = lerpf(0.90, 1.10, sun_factor)
    visual_environment.sun.light_color = Color(0.52, 0.61, 0.78, 1.0).lerp(Color(1.0, 0.94, 0.85, 1.0), sun_factor).lerp(Color(1.0, 0.50, 0.26, 1.0), sunset_factor * 0.55)

func _update_city_lighting() -> void:
    if time_manager == null:
        return
    var night_amount := 1.0 - _daylight_factor(time_manager.time_hours)
    for light in ambient_lights:
        if not is_instance_valid(light):
            continue
        var base_energy := 1.4 if light.omni_range >= 9.0 else 0.55
        light.light_energy = lerpf(0.03, base_energy, smoothstep(0.30, 0.85, night_amount))
        light.visible = night_amount > 0.18

    for window in styled_windows:
        if not is_instance_valid(window):
            continue
        var material := window.material_override as StandardMaterial3D
        if material == null:
            continue
        material.emission_enabled = night_amount > 0.28
        material.emission = Color(0.68, 0.78, 0.92, 1.0).lerp(Color(1.0, 0.72, 0.42, 1.0), _stable_window_warmth(window))
        material.emission_energy_multiplier = 0.18 + night_amount * 1.15

func _update_camera_motion(delta: float) -> void:
    if player == null or camera_pivot == null or spring_arm == null:
        return
    if player.driving:
        return
    var dialogue := get_tree().get_first_node_in_group("story_dialogue_ui") as StoryDialogueUI
    if dialogue != null and dialogue.active:
        camera_pivot.position = camera_pivot.position.lerp(base_pivot_position, clampf(delta * 8.0, 0.0, 1.0))
        spring_arm.position = spring_arm.position.lerp(base_spring_position, clampf(delta * 8.0, 0.0, 1.0))
        return

    var planar_speed := Vector2(player.velocity.x, player.velocity.z).length()
    var moving_amount := clampf(planar_speed / maxf(player.sprint_speed, 0.1), 0.0, 1.0)
    motion_time += delta * lerpf(2.2, 8.4, moving_amount)
    var bob := sin(motion_time * 2.0) * 0.022 * moving_amount
    var sway := sin(motion_time) * 0.032 * moving_amount
    if player.aiming:
        bob *= 0.30
        sway *= 0.25
    var target_pivot := base_pivot_position + Vector3(sway, bob, 0.0)
    var target_spring := base_spring_position + Vector3(sway * 0.28, bob * 0.22, 0.0)
    camera_pivot.position = camera_pivot.position.lerp(target_pivot, clampf(delta * 10.0, 0.0, 1.0))
    spring_arm.position = spring_arm.position.lerp(target_spring, clampf(delta * 8.0, 0.0, 1.0))

func _daylight_factor(hour: float) -> float:
    return clampf(sin((hour - 6.0) / 12.0 * PI), 0.0, 1.0)

func _sunset_factor(hour: float) -> float:
    var evening := 1.0 - clampf(absf(hour - 19.0) / 2.1, 0.0, 1.0)
    var morning := 1.0 - clampf(absf(hour - 6.3) / 1.6, 0.0, 1.0)
    return maxf(evening, morning)

func _stable_window_warmth(node: Node) -> float:
    return float(abs(hash(str(node.get_path()))) % 100) / 100.0
