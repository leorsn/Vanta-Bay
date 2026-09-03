extends Node
class_name VantaCombatSceneDetailController

var _decorated: Dictionary = {}

func _ready() -> void:
    add_to_group("combat_scene_detail_controller")
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_scan")

func _scan() -> void:
    var root := get_tree().current_scene
    if root != null:
        _scan_node(root)

func _scan_node(node: Node) -> void:
    if node is StaticBody3D and node.name == "CombatBarrier":
        _decorate_barrier(node as StaticBody3D)
    for child in node.get_children():
        _scan_node(child)

func _on_node_added(node: Node) -> void:
    if node is StaticBody3D and node.name == "CombatBarrier":
        call_deferred("_decorate_barrier", node)

func _decorate_barrier(barrier: StaticBody3D) -> void:
    if not is_instance_valid(barrier):
        return
    var id := barrier.get_instance_id()
    if _decorated.has(id):
        return
    _decorated[id] = true

    var concrete := StandardMaterial3D.new()
    concrete.albedo_color = Color(0.27, 0.28, 0.28, 1.0)
    concrete.roughness = 0.94
    var dark := StandardMaterial3D.new()
    dark.albedo_color = Color(0.075, 0.08, 0.085, 1.0)
    dark.roughness = 0.82
    var reflective := StandardMaterial3D.new()
    reflective.albedo_color = Color(0.86, 0.72, 0.22, 1.0)
    reflective.roughness = 0.52
    reflective.metallic = 0.12

    _box_to(barrier, "BarrierTopCap", Vector3(0.0, 0.54, 0.0), Vector3(2.86, 0.12, 0.60), concrete)
    _box_to(barrier, "BarrierBase", Vector3(0.0, -0.48, 0.0), Vector3(3.02, 0.18, 0.70), dark)
    _box_to(barrier, "ReflectiveBand", Vector3(0.0, 0.06, -0.292), Vector3(1.65, 0.14, 0.025), reflective)
    for x in [-1.12, 1.12]:
        _bolt_to(barrier, Vector3(x, 0.28, -0.315))
        _bolt_to(barrier, Vector3(x, -0.24, -0.315))
    _box_to(barrier, "ScuffA", Vector3(-0.62, -0.18, -0.306), Vector3(0.48, 0.08, 0.018), dark)
    _box_to(barrier, "ScuffB", Vector3(0.48, 0.34, -0.306), Vector3(0.35, 0.06, 0.018), dark)

func _box_to(parent: Node3D, node_name: String, position_value: Vector3, size: Vector3, material: StandardMaterial3D) -> void:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = material
    parent.add_child(node)

func _bolt_to(parent: Node3D, position_value: Vector3) -> void:
    var bolt := MeshInstance3D.new()
    bolt.name = "BarrierBolt"
    bolt.position = position_value
    bolt.rotation_degrees.x = 90.0
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.045
    mesh.bottom_radius = 0.045
    mesh.height = 0.035
    bolt.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.16, 0.17, 0.18, 1.0)
    mat.metallic = 0.82
    mat.roughness = 0.32
    bolt.material_override = mat
    parent.add_child(bolt)
