extends CharacterBody3D
class_name VantaPoliceAgent

@export var patrol_speed := 6.0
@export var pursuit_speed := 13.0
@export var turn_speed := 3.4
@export var sight_distance := 34.0
@export var stop_distance := 3.5

var wanted: WantedManager

func _ready() -> void:
    add_to_group("police")
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager

func _physics_process(delta: float) -> void:
    if wanted == null or wanted.state == "NONE" or wanted.state == "ESCAPED":
        velocity = velocity.move_toward(Vector3.ZERO, patrol_speed * delta)
        move_and_slide()
        return

    var destination := wanted.get_search_position()
    var target := wanted.target
    if wanted.state == "PURSUIT" and target != null and is_instance_valid(target):
        destination = target.global_position
        if global_position.distance_to(target.global_position) <= sight_distance:
            wanted.confirm_sighting(target.global_position, target)

    var flat := destination - global_position
    flat.y = 0.0
    if flat.length() <= stop_distance:
        velocity = velocity.move_toward(Vector3.ZERO, pursuit_speed * delta)
        move_and_slide()
        return

    var direction := flat.normalized()
    var desired_angle := atan2(direction.x, direction.z)
    rotation.y = lerp_angle(rotation.y, desired_angle, turn_speed * delta)
    var speed := pursuit_speed if wanted.state == "PURSUIT" else patrol_speed
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    if not is_on_floor():
        velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
    else:
        velocity.y = -0.2
    move_and_slide()
