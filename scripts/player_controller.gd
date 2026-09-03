extends CharacterBody3D
class_name VantaPlayerController

const HealthComponentScript = preload("res://scripts/health_component.gd")

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

@export_category("Interaction")
@export var vehicle_interaction_radius: float = 3.2

@onready var camera_pivot: Node3D = $CameraPivot
@onready var player_camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var body: MeshInstance3D = $Body
@onready var prompt: Label = $PlayerHUD/InteractionPrompt

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_yaw := 0.0
var camera_pitch := deg_to_rad(-10.0)
var driving := false
var current_vehicle: Node = null
var nearby_vehicle: VantaVehicleController = null
var health_component: HealthComponent

func _ready() -> void:
    add_to_group("player")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    prompt.visible = false
    health_component = HealthComponentScript.new()
    health_component.name = "Health"
    health_component.max_health = 100.0
    health_component.invulnerability_seconds = 0.25
    add_child(health_component)
    health_component.died.connect(_on_died)

func _unhandled_input(event: InputEvent) -> void:
    if driving:
        return
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_yaw -= event.relative.x * mouse_sensitivity
        camera_pitch = clamp(camera_pitch - event.relative.y * mouse_sensitivity, min_pitch, max_pitch)
    elif event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    if driving:
        velocity = Vector3.ZERO
        return

    _update_camera()
    _apply_gravity(delta)
    _handle_jump()
    _handle_movement(delta)
    move_and_slide()
    _update_vehicle_interaction()

    if Input.is_action_just_pressed("interact") and nearby_vehicle != null:
        nearby_vehicle.enter_vehicle(self)

func apply_damage(amount: float, source: Node = null) -> void:
    if health_component != null:
        health_component.apply_damage(amount, source)

func heal(amount: float) -> void:
    if health_component != null:
        health_component.heal(amount)

func get_health_percent() -> float:
    if health_component == null or health_component.max_health <= 0.0:
        return 1.0
    return health_component.health / health_component.max_health

func _on_died(_source: Node) -> void:
    var checkpoint := get_tree().get_first_node_in_group("mission_checkpoint_manager") as MissionCheckpointManager
    if checkpoint != null:
        checkpoint.restart_from_checkpoint()
    if health_component != null:
        health_component.reset_health()

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

func _update_vehicle_interaction() -> void:
    nearby_vehicle = null
    var closest_distance := vehicle_interaction_radius
    for node in get_tree().get_nodes_in_group("vehicles"):
        if node is VantaVehicleController:
            var distance := global_position.distance_to(node.global_position)
            if distance <= closest_distance and node.driver == null:
                closest_distance = distance
                nearby_vehicle = node

    prompt.visible = nearby_vehicle != null
    if nearby_vehicle != null:
        prompt.text = "E  DRIVE  %s" % nearby_vehicle.display_name

func set_driving_state(value: bool, vehicle: Node) -> void:
    driving = value
    current_vehicle = vehicle
    body.visible = not value
    collision_shape.disabled = value
    prompt.visible = false
    set_physics_process(true)
    if value:
        player_camera.current = false
    else:
        player_camera.current = true
        camera_yaw = rotation.y
