extends CharacterBody3D
class_name VantaVehicleController

@export_category("Vehicle")
@export var display_name := "Vellaro S1 Prototype"
@export var max_speed_kph: float = 185.0
@export var reverse_speed_kph: float = 42.0
@export var acceleration: float = 11.5
@export var braking: float = 20.0
@export var rolling_drag: float = 4.0
@export var steering_rate: float = 1.65
@export var steering_fade_speed_kph: float = 125.0
@export var grip: float = 9.0
@export var mission_target_vehicle := true

@export_category("Interaction")
@export var exit_offset := Vector3(-1.8, 0.4, 0.0)

@onready var camera: Camera3D = $CameraRig/SpringArm3D/Camera3D
@onready var interaction_label: Label = $VehicleHUD/Interaction
@onready var speed_label: Label = $VehicleHUD/Speed
@onready var name_label: Label = $VehicleHUD/VehicleName

var driver: VantaPlayerController
var speed_mps := 0.0
var steering_input := 0.0
var throttle_input := 0.0
var theft_registered := false

func _ready() -> void:
    add_to_group("vehicles")
    camera.current = false
    _set_hud_visible(false)

func _physics_process(delta: float) -> void:
    if driver == null:
        _coast_to_stop(delta)
        return

    if Input.is_action_just_pressed("interact"):
        exit_vehicle()
        return

    throttle_input = Input.get_axis("vehicle_brake", "vehicle_accelerate")
    steering_input = Input.get_axis("vehicle_steer_left", "vehicle_steer_right")
    _simulate_drive(delta)
    _update_hud()

func _simulate_drive(delta: float) -> void:
    var max_forward := max_speed_kph / 3.6
    var max_reverse := reverse_speed_kph / 3.6

    if throttle_input > 0.01:
        speed_mps = move_toward(speed_mps, max_forward, acceleration * throttle_input * delta)
    elif throttle_input < -0.01:
        if speed_mps > 1.5:
            speed_mps = move_toward(speed_mps, 0.0, braking * -throttle_input * delta)
        else:
            speed_mps = move_toward(speed_mps, -max_reverse, acceleration * 0.65 * -throttle_input * delta)
    else:
        speed_mps = move_toward(speed_mps, 0.0, rolling_drag * delta)

    if Input.is_action_pressed("vehicle_handbrake"):
        speed_mps = move_toward(speed_mps, 0.0, braking * 1.35 * delta)

    var abs_speed_kph := abs(speed_mps) * 3.6
    var steering_factor := clamp(1.0 - (abs_speed_kph / max(steering_fade_speed_kph, 1.0)) * 0.55, 0.38, 1.0)
    var direction_sign := 1.0 if speed_mps >= 0.0 else -1.0
    if abs(speed_mps) > 0.35:
        rotation.y -= steering_input * steering_rate * steering_factor * direction_sign * delta

    var forward := -global_transform.basis.z.normalized()
    var desired := forward * speed_mps
    velocity.x = move_toward(velocity.x, desired.x, grip * delta)
    velocity.z = move_toward(velocity.z, desired.z, grip * delta)

    if not is_on_floor():
        velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
    else:
        velocity.y = -0.2

    move_and_slide()

func _coast_to_stop(delta: float) -> void:
    if abs(speed_mps) < 0.01:
        speed_mps = 0.0
        velocity = Vector3.ZERO
        return
    speed_mps = move_toward(speed_mps, 0.0, rolling_drag * delta)
    var forward := -global_transform.basis.z.normalized()
    velocity.x = forward.x * speed_mps
    velocity.z = forward.z * speed_mps
    if not is_on_floor():
        velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
    move_and_slide()

func enter_vehicle(player: VantaPlayerController) -> void:
    if driver != null:
        return
    driver = player
    driver.set_driving_state(true, self)
    camera.current = true
    name_label.text = display_name
    _set_hud_visible(true)
    _update_hud()

    if mission_target_vehicle and not theft_registered:
        theft_registered = true
        var mission := get_tree().get_first_node_in_group("black_glass_mission") as BlackGlassMission
        if mission != null:
            mission.register_vehicle_theft(self)

func exit_vehicle() -> void:
    if driver == null:
        return
    var exiting_driver := driver
    driver = null
    camera.current = false
    _set_hud_visible(false)
    exiting_driver.global_position = global_position + global_transform.basis * exit_offset
    exiting_driver.set_driving_state(false, null)

func get_speed_kph() -> float:
    return abs(speed_mps) * 3.6

func _set_hud_visible(value: bool) -> void:
    speed_label.visible = value
    name_label.visible = value
    interaction_label.visible = value

func _update_hud() -> void:
    speed_label.text = "%03d km/h" % int(round(get_speed_kph()))
    interaction_label.text = "E  EXIT VEHICLE"
