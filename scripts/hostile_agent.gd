extends CharacterBody3D
class_name VantaHostileAgent

signal defeated(agent: Node)

const HealthComponentScript = preload("res://scripts/health_component.gd")
const PlayerVisualScript = preload("res://scripts/player_visual.gd")

@export var move_speed := 4.6
@export var strafe_speed := 3.6
@export var engagement_range := 24.0
@export var preferred_range := 13.0
@export var fire_damage := 7.0
@export var fire_interval := 1.0
@export var max_health := 85.0
@export var flank_distance := 8.0
@export var cover_seek_duration := 3.0

var target: Node3D
var health_component: HealthComponent
var _fire_cooldown := 0.0
var _strafe_direction := 1.0
var _strafe_timer := 0.0
var _cover_timer := 0.0
var _cover_point: CombatCoverPoint = null
var _weapon_root: Node3D
var _muzzle_flash: MeshInstance3D
var _muzzle_light: OmniLight3D
var _muzzle_timer := 0.0
var _visual_root: Node3D
var _motion_time := 0.0
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _ready() -> void:
    add_to_group("hostiles")
    _build_character_visual()
    health_component = HealthComponentScript.new()
    health_component.name = "Health"
    health_component.max_health = max_health
    add_child(health_component)
    health_component.died.connect(_on_died)
    _strafe_direction = -1.0 if randf() < 0.5 else 1.0
    _strafe_timer = randf_range(1.2, 2.8)
    _build_weapon_visual()
    call_deferred("_resolve_target")

func _physics_process(delta: float) -> void:
    _motion_time += delta
    _fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
    _cover_timer = maxf(_cover_timer - delta, 0.0)
    _muzzle_timer = maxf(_muzzle_timer - delta, 0.0)
    if _muzzle_flash != null:
        _muzzle_flash.visible = _muzzle_timer > 0.0
    if _muzzle_light != null:
        _muzzle_light.visible = _muzzle_timer > 0.0
        if _muzzle_timer > 0.0:
            _muzzle_light.light_energy = randf_range(1.8, 3.6)
    _strafe_timer -= delta
    if _strafe_timer <= 0.0:
        _strafe_direction *= -1.0
        _strafe_timer = randf_range(1.2, 2.8)
    if health_component != null and health_component.is_dead():
        velocity = Vector3.ZERO
        return
    _resolve_target()
    if target == null:
        velocity = velocity.move_toward(Vector3.ZERO, move_speed * delta)
        move_and_slide()
        _animate_visual(delta)
        return

    if _cover_point != null and not is_instance_valid(_cover_point):
        _cover_point = null

    var flat: Vector3 = target.global_position - global_position
    flat.y = 0.0
    var distance: float = flat.length()
    var has_los: bool = distance <= engagement_range and _has_line_of_sight(target)
    if has_los:
        _try_fire(target)

    var desired := Vector3.ZERO
    if _cover_point != null and _cover_timer > 0.0:
        var cover_flat: Vector3 = _cover_point.global_position - global_position
        cover_flat.y = 0.0
        if cover_flat.length() > 0.8:
            desired = cover_flat.normalized() * move_speed
        else:
            desired = Vector3.ZERO
            if has_los:
                desired = _peek_direction(flat) * strafe_speed * 0.45
    else:
        _release_cover()
        var forward: Vector3 = flat.normalized() if flat.length_squared() > 0.01 else Vector3.FORWARD
        var lateral: Vector3 = Vector3(-forward.z, 0.0, forward.x) * _strafe_direction
        if not has_los:
            desired = (forward + lateral * 0.65).normalized() * move_speed
        elif distance > preferred_range + 3.0:
            desired = (forward + lateral * 0.25).normalized() * move_speed
        elif distance < preferred_range - 3.0:
            desired = (-forward + lateral * 0.35).normalized() * move_speed
        else:
            desired = lateral * strafe_speed

    velocity.x = move_toward(velocity.x, desired.x, 10.0 * delta)
    velocity.z = move_toward(velocity.z, desired.z, 10.0 * delta)
    if flat.length_squared() > 0.01:
        var forward_to_target: Vector3 = flat.normalized()
        rotation.y = lerp_angle(rotation.y, atan2(forward_to_target.x, forward_to_target.z), 7.5 * delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.2
    move_and_slide()
    _animate_visual(delta)

func apply_damage(amount: float, source: Node = null) -> void:
    if health_component != null:
        health_component.apply_damage(amount, source)
        if not health_component.is_dead():
            _seek_cover()

func _seek_cover() -> void:
    var best: CombatCoverPoint = null
    var best_score: float = INF
    for node in get_tree().get_nodes_in_group("combat_cover"):
        if node is CombatCoverPoint:
            var point := node as CombatCoverPoint
            if not point.is_available_for(self):
                continue
            var point_distance: float = global_position.distance_to(point.global_position)
            if point_distance > 18.0:
                continue
            var hidden_bonus: float = -8.0 if _point_blocks_target(point.global_position) else 0.0
            var score: float = point_distance + hidden_bonus
            if score < best_score:
                best_score = score
                best = point
    if best != null:
        _release_cover()
        _cover_point = best
        _cover_point.reserve(self)
        _cover_timer = cover_seek_duration + randf_range(-0.4, 1.0)

func _point_blocks_target(point: Vector3) -> bool:
    if target == null:
        return false
    var origin := point + Vector3.UP * 1.05
    var target_point := target.global_position + Vector3.UP * 1.0
    var query := PhysicsRayQueryParameters3D.create(origin, target_point)
    query.exclude = [self]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return false
    var collider = hit.get("collider")
    return collider != target and not (collider is Node and target.is_ancestor_of(collider))

func _peek_direction(flat: Vector3) -> Vector3:
    if flat.length_squared() < 0.01:
        return Vector3.ZERO
    var forward := flat.normalized()
    return Vector3(-forward.z, 0.0, forward.x) * _strafe_direction

func _release_cover() -> void:
    if _cover_point != null and is_instance_valid(_cover_point):
        _cover_point.release(self)
    _cover_point = null

func _try_fire(victim: Node3D) -> void:
    if _fire_cooldown > 0.0 or not victim.has_method("apply_damage"):
        return
    _fire_cooldown = fire_interval + randf_range(-0.15, 0.2)
    _muzzle_timer = 0.06
    var distance_factor: float = clampf(global_position.distance_to(victim.global_position) / engagement_range, 0.0, 1.0)
    var damage: float = fire_damage * lerpf(1.0, 0.7, distance_factor)
    _spawn_enemy_tracer(victim.global_position + Vector3.UP * 1.0)
    victim.call("apply_damage", damage, self)

func _has_line_of_sight(victim: Node3D) -> bool:
    var origin := global_position + Vector3.UP * 1.2
    var target_point := victim.global_position + Vector3.UP * 1.0
    var query := PhysicsRayQueryParameters3D.create(origin, target_point)
    query.exclude = [self]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return true
    var collider = hit.get("collider")
    return collider == victim or (collider is Node and victim.is_ancestor_of(collider))

func _build_character_visual() -> void:
    var collider := CollisionShape3D.new()
    collider.name = "CollisionShape3D"
    var shape := CapsuleShape3D.new()
    shape.radius = 0.34
    shape.height = 1.75
    collider.shape = shape
    collider.position.y = 0.74
    add_child(collider)

    _visual_root = Node3D.new()
    _visual_root.name = "HostileVisual"
    _visual_root.position.y = 0.16
    add_child(_visual_root)

    var humanoid := PlayerVisualScript.new() as VantaPlayerVisual
    var variant := randi() % 3
    if variant == 0:
        humanoid.configure_palette(Color(0.07, 0.075, 0.08, 1.0), Color(0.12, 0.13, 0.14, 1.0), Color(0.055, 0.06, 0.065, 1.0), Color(0.56, 0.40, 0.31, 1.0), Color(0.025, 0.025, 0.028, 1.0))
    elif variant == 1:
        humanoid.configure_palette(Color(0.12, 0.13, 0.105, 1.0), Color(0.16, 0.17, 0.13, 1.0), Color(0.075, 0.075, 0.065, 1.0), Color(0.68, 0.52, 0.40, 1.0), Color(0.055, 0.045, 0.035, 1.0))
    else:
        humanoid.configure_palette(Color(0.10, 0.085, 0.075, 1.0), Color(0.15, 0.12, 0.10, 1.0), Color(0.065, 0.06, 0.055, 1.0), Color(0.42, 0.29, 0.22, 1.0), Color(0.018, 0.018, 0.02, 1.0))
    humanoid.scale = Vector3(randf_range(0.96, 1.04), randf_range(0.97, 1.04), randf_range(0.96, 1.04))
    _visual_root.add_child(humanoid)

    var tactical := StandardMaterial3D.new()
    tactical.albedo_color = Color(0.045, 0.05, 0.052, 1.0)
    tactical.roughness = 0.82
    _box_visual("TacticalVest", Vector3(0.0, 1.24, -0.19), Vector3(0.49, 0.48, 0.12), tactical)
    _box_visual("VestPouchL", Vector3(-0.13, 1.08, -0.27), Vector3(0.16, 0.16, 0.08), tactical)
    _box_visual("VestPouchR", Vector3(0.13, 1.08, -0.27), Vector3(0.16, 0.16, 0.08), tactical)

func _animate_visual(delta: float) -> void:
    if _visual_root == null:
        return
    var speed := Vector2(velocity.x, velocity.z).length()
    var amount := clampf(speed / move_speed, 0.0, 1.0)
    var bob := sin(_motion_time * 9.0) * 0.018 * amount
    _visual_root.position.y = lerpf(_visual_root.position.y, 0.16 + bob, clampf(delta * 10.0, 0.0, 1.0))
    _visual_root.rotation.z = lerpf(_visual_root.rotation.z, sin(_motion_time * 5.0) * deg_to_rad(0.8) * amount, clampf(delta * 8.0, 0.0, 1.0))

func _build_weapon_visual() -> void:
    _weapon_root = Node3D.new()
    _weapon_root.name = "WeaponVisual"
    _weapon_root.position = Vector3(0.34, 1.12, -0.18)
    add_child(_weapon_root)

    var weapon_material := StandardMaterial3D.new()
    weapon_material.albedo_color = Color(0.055, 0.06, 0.067, 1.0)
    weapon_material.metallic = 0.76
    weapon_material.roughness = 0.26
    var polymer := StandardMaterial3D.new()
    polymer.albedo_color = Color(0.022, 0.025, 0.028, 1.0)
    polymer.roughness = 0.66

    _weapon_box("Receiver", Vector3(0.0, 0.0, -0.08), Vector3(0.15, 0.17, 0.52), weapon_material)
    _weapon_box("Handguard", Vector3(0.0, 0.0, -0.42), Vector3(0.13, 0.15, 0.28), polymer)
    _weapon_box("Grip", Vector3(0.0, -0.18, -0.02), Vector3(0.11, 0.30, 0.14), polymer)
    _weapon_box("Magazine", Vector3(0.0, -0.20, -0.21), Vector3(0.11, 0.34, 0.14), weapon_material)
    _weapon_box("Stock", Vector3(0.0, 0.0, 0.27), Vector3(0.13, 0.15, 0.30), polymer)

    _muzzle_flash = MeshInstance3D.new()
    var flash_mesh := CylinderMesh.new()
    flash_mesh.top_radius = 0.0
    flash_mesh.bottom_radius = 0.065
    flash_mesh.height = 0.18
    _muzzle_flash.mesh = flash_mesh
    _muzzle_flash.rotation_degrees.x = 90.0
    var flash_material := StandardMaterial3D.new()
    flash_material.albedo_color = Color(1.0, 0.7, 0.25, 1.0)
    flash_material.emission_enabled = true
    flash_material.emission = Color(1.0, 0.42, 0.07, 1.0)
    flash_material.emission_energy_multiplier = 4.0
    _muzzle_flash.material_override = flash_material
    _muzzle_flash.position = Vector3(0.0, 0.01, -0.66)
    _muzzle_flash.visible = false
    _weapon_root.add_child(_muzzle_flash)

    _muzzle_light = OmniLight3D.new()
    _muzzle_light.light_color = Color(1.0, 0.52, 0.17, 1.0)
    _muzzle_light.light_energy = 2.4
    _muzzle_light.omni_range = 2.8
    _muzzle_light.position = _muzzle_flash.position
    _muzzle_light.visible = false
    _weapon_root.add_child(_muzzle_light)

func _spawn_enemy_tracer(target_position: Vector3) -> void:
    var root := get_tree().current_scene as Node3D
    if root == null:
        return
    var start := global_position + Vector3.UP * 1.18 + -global_transform.basis.z * 0.55
    var finish := target_position
    var length := start.distance_to(finish)
    var tracer := MeshInstance3D.new()
    tracer.name = "EnemyTracer"
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.008
    mesh.bottom_radius = 0.008
    mesh.height = length
    tracer.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.38, 0.12, 0.78)
    mat.emission_enabled = true
    mat.emission = Color(1.0, 0.18, 0.035, 1.0)
    mat.emission_energy_multiplier = 3.5
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    tracer.material_override = mat
    var midpoint := (start + finish) * 0.5
    tracer.global_position = midpoint
    tracer.look_at_from_position(midpoint, finish, Vector3.UP)
    tracer.rotate_x(PI * 0.5)
    root.add_child(tracer)
    var tween := tracer.create_tween()
    tween.tween_property(tracer, "scale", Vector3(0.2, 0.05, 0.2), 0.07)
    tween.tween_callback(tracer.queue_free)

func _weapon_box(node_name: String, position_value: Vector3, size: Vector3, material: StandardMaterial3D) -> void:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = material
    _weapon_root.add_child(node)

func _box_visual(node_name: String, position_value: Vector3, size: Vector3, material: StandardMaterial3D) -> void:
    if _visual_root == null:
        return
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = material
    _visual_root.add_child(node)

func _on_died(_source: Node) -> void:
    _release_cover()
    set_physics_process(false)
    collision_layer = 0
    collision_mask = 0
    if _visual_root != null:
        var tween := _visual_root.create_tween()
        tween.tween_property(_visual_root, "rotation_degrees", Vector3(82.0, 0.0, 7.0), 0.24)
        tween.parallel().tween_property(_visual_root, "position", Vector3(0.0, 0.04, 0.15), 0.24)
    if _weapon_root != null:
        _weapon_root.visible = false
    defeated.emit(self)

func _resolve_target() -> void:
    if target == null or not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player") as Node3D
