extends CharacterBody3D
class_name VantaPlayerController

@export_category("Movement")
@export var walk_speed: float = 4.2
@export var sprint_speed: float = 7.4
@export var acceleration: float = 18.0
@export var deceleration: float = 22.0
@export var jump_velocity: float = 5.8
@export var rotation_speed: float = 12.0

@export_category("Camera")
@export var mouse_sensitivity: float = 0.0025
@export var min_pitch: float = deg_to_rad(-55.0)
@export var max_pitch: float = deg_to_rad(65.0)

@onready var camera_pivot: Node3D = $CameraPivot

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_yaw := 0.0
var camera_pitch := deg_to_rad(-10.0)

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_yaw -= event.relative.x * mouse_sensitivity
        camera_pitch = clamp(camera_pitch - event.relative.y * mouse_sensitivity, min_pitch, max_pitch)
    elif event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    _update_camera()
    _apply_gravity(delta)
    _handle_jump()
    _handle_movement(delta)
    move_and_slide()

func _update_camera() -> void:
    camera_pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

func _handle_jump() -> void:
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

func _handle_movement(delta: float) -> void:
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var basis := Basis(Vector3.UP, camera_yaw)
    var direction := (basis * Vector3(input.x, 0.0, input.y)).normalized()
    var target_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
    var target_velocity := direction * target_speed
    var rate := acceleration if direction != Vector3.ZERO else deceleration

    velocity.x = move_toward(velocity.x, target_velocity.x, rate * delta)
    velocity.z = move_toward(velocity.z, target_velocity.z, rate * delta)

    if direction != Vector3.ZERO:
        var target_angle := atan2(direction.x, direction.z)
        rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
