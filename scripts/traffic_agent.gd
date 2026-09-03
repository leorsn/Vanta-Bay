extends CharacterBody3D
class_name VantaTrafficAgent

@export var cruise_speed_kph: float = 42.0
@export var lane_x: float = 3.8
@export var northbound := true
@export var wrap_min_z: float = -56.0
@export var wrap_max_z: float = 56.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
    _build_visual()
    global_position.x = lane_x
    rotation.y = 0.0 if northbound else PI

func _physics_process(delta: float) -> void:
    var speed := cruise_speed_kph / 3.6
    var direction := Vector3(0, 0, -1) if northbound else Vector3(0, 0, 1)
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
    shape.size = Vector3(1.8, 1.35, 4.2)
    collider.shape = shape
    add_child(collider)

    var body_mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(1.8, 1.35, 4.2)
    body_mesh.mesh = box
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(randf_range(0.08, 0.5), randf_range(0.08, 0.5), randf_range(0.08, 0.5), 1.0)
    material.metallic = 0.45
    material.roughness = 0.32
    body_mesh.material_override = material
    add_child(body_mesh)
