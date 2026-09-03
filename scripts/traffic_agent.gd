extends CharacterBody3D
class_name VantaTrafficAgent

const VehicleVisualScript = preload("res://scripts/vehicle_visual.gd")

@export var cruise_speed_kph: float = 42.0
@export var lane_x: float = 3.8
@export var northbound := true
@export var wrap_min_z: float = -56.0
@export var wrap_max_z: float = 56.0

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _ready() -> void:
    _build_visual()
    global_position.x = lane_x
    rotation.y = 0.0 if northbound else PI

func _physics_process(delta: float) -> void:
    var speed: float = cruise_speed_kph / 3.6
    var direction := Vector3(0.0, 0.0, -1.0) if northbound else Vector3(0.0, 0.0, 1.0)
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.2
    move_and_slide()

    if northbound and global_position.z < wrap_min_z:
        global_position.z = wrap_max_z
    elif not northbound and global_position.z > wrap_max_z:
        global_position.z = wrap_min_z

func _build_visual() -> void:
    var collider := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.9, 1.25, 4.4)
    collider.shape = shape
    collider.position.y = 0.30
    add_child(collider)

    var visual := VehicleVisualScript.new() as VantaVehicleVisual
    var palettes: Array[Color] = [
        Color(0.045, 0.05, 0.06, 1.0),
        Color(0.30, 0.31, 0.32, 1.0),
        Color(0.48, 0.47, 0.43, 1.0),
        Color(0.10, 0.18, 0.24, 1.0),
        Color(0.31, 0.07, 0.055, 1.0)
    ]
    visual.body_color = palettes[randi() % palettes.size()]
    visual.scale = Vector3(0.94, 0.94, 0.96)
    add_child(visual)
