extends CharacterBody3D
class_name VantaPedestrianAgent

@export var walk_speed: float = 1.55
@export var roam_radius: float = 11.0
@export var pause_min: float = 0.8
@export var pause_max: float = 3.0

var origin := Vector3.ZERO
var target := Vector3.ZERO
var pause_timer := 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
    origin = global_position
    _build_visual()
    _pick_target()

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.1

    if pause_timer > 0.0:
        pause_timer -= delta
        velocity.x = move_toward(velocity.x, 0.0, 5.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 5.0 * delta)
        move_and_slide()
        return

    var flat_target := Vector3(target.x, global_position.y, target.z)
    var direction := global_position.direction_to(flat_target)
    if global_position.distance_to(flat_target) < 0.7:
        pause_timer = randf_range(pause_min, pause_max)
        _pick_target()
        return

    velocity.x = direction.x * walk_speed
    velocity.z = direction.z * walk_speed
    if Vector2(direction.x, direction.z).length() > 0.1:
        rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), 7.0 * delta)
    move_and_slide()

func flee_from(world_position: Vector3) -> void:
    var away := (global_position - world_position)
    away.y = 0.0
    if away.length_squared() < 0.01:
        away = Vector3.FORWARD
    target = global_position + away.normalized() * roam_radius * 1.4
    pause_timer = 0.0

func _pick_target() -> void:
    target = origin + Vector3(randf_range(-roam_radius, roam_radius), 0.0, randf_range(-roam_radius, roam_radius))

func _build_visual() -> void:
    var collider := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.34
    shape.height = 1.72
    collider.shape = shape
    add_child(collider)

    var mesh_instance := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.34
    mesh.height = 1.72
    mesh_instance.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(randf_range(0.18, 0.72), randf_range(0.18, 0.72), randf_range(0.18, 0.72), 1.0)
    material.roughness = 0.8
    mesh_instance.material_override = material
    add_child(mesh_instance)
