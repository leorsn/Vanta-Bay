extends Node
class_name VantaStartupSafetyController

@export var safe_spawn := Vector3(0.0, 1.2, 18.0)
@export var safe_time_hour := 14.5

var _applied := false

func _ready() -> void:
    add_to_group("startup_safety_controller")
    call_deferred("_apply_safe_start")

func _apply_safe_start() -> void:
    if _applied:
        return
    await get_tree().process_frame
    await get_tree().process_frame

    var player := get_tree().get_first_node_in_group("player") as VantaPlayerController
    if player != null:
        player.global_position = safe_spawn
        player.rotation = Vector3.ZERO
        player.velocity = Vector3.ZERO
        player.camera_yaw = 0.0
        player.camera_pitch = deg_to_rad(-7.0)
        if player.player_camera != null:
            player.player_camera.current = true
            player.player_camera.fov = player.normal_fov
        if player.spring_arm != null:
            player.spring_arm.spring_length = 5.25

    var time_manager := get_tree().get_first_node_in_group("world_time_manager") as WorldTimeManager
    if time_manager != null:
        time_manager.set_time(safe_time_hour)

    var visual_environment := get_tree().get_first_node_in_group("visual_environment") as VantaVisualEnvironment
    if visual_environment != null and visual_environment.environment != null:
        visual_environment.environment.ambient_light_energy = maxf(visual_environment.environment.ambient_light_energy, 0.72)
        visual_environment.environment.tonemap_exposure = maxf(visual_environment.environment.tonemap_exposure, 1.02)

    _applied = true
