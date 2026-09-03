extends Node3D
class_name VantaPlayerVisual

var cloth_dark := Color(0.055, 0.06, 0.07, 1.0)
var cloth_mid := Color(0.12, 0.13, 0.14, 1.0)
var trouser_color := Color(0.072, 0.078, 0.088, 1.0)
var shoe_color := Color(0.025, 0.025, 0.028, 1.0)
var skin_color := Color(0.63, 0.47, 0.36, 1.0)

func _ready() -> void:
    name = "PlayerVisual"
    _build_body()

func _build_body() -> void:
    _mesh_box("Torso", Vector3(0.0, 1.22, 0.0), Vector3(0.60, 0.70, 0.34), cloth_dark, 0.72)
    _mesh_box("JacketLower", Vector3(0.0, 0.84, 0.0), Vector3(0.52, 0.24, 0.30), cloth_mid, 0.78)
    _mesh_capsule("Neck", Vector3(0.0, 1.62, 0.0), 0.105, 0.22, skin_color, 0.80)
    _mesh_capsule("Head", Vector3(0.0, 1.94, 0.0), 0.235, 0.48, skin_color, 0.78)
    _mesh_box("Hair", Vector3(0.0, 2.15, -0.01), Vector3(0.40, 0.13, 0.33), Color(0.025, 0.02, 0.018, 1.0), 0.88)

    _mesh_capsule("LeftUpperArm", Vector3(-0.39, 1.29, 0.0), 0.095, 0.46, cloth_dark, 0.76)
    _mesh_capsule("RightUpperArm", Vector3(0.39, 1.29, 0.0), 0.095, 0.46, cloth_dark, 0.76)
    _mesh_capsule("LeftForearm", Vector3(-0.40, 0.94, -0.01), 0.085, 0.40, cloth_mid, 0.78)
    _mesh_capsule("RightForearm", Vector3(0.40, 0.94, -0.01), 0.085, 0.40, cloth_mid, 0.78)
    _mesh_capsule("LeftHand", Vector3(-0.40, 0.69, -0.01), 0.075, 0.18, skin_color, 0.82)
    _mesh_capsule("RightHand", Vector3(0.40, 0.69, -0.01), 0.075, 0.18, skin_color, 0.82)

    _mesh_capsule("LeftLeg", Vector3(-0.16, 0.34, 0.0), 0.11, 0.92, trouser_color, 0.80)
    _mesh_capsule("RightLeg", Vector3(0.16, 0.34, 0.0), 0.11, 0.92, trouser_color, 0.80)
    _mesh_box("LeftShoe", Vector3(-0.16, -0.17, -0.09), Vector3(0.24, 0.16, 0.43), shoe_color, 0.48)
    _mesh_box("RightShoe", Vector3(0.16, -0.17, -0.09), Vector3(0.24, 0.16, 0.43), shoe_color, 0.48)

func _mesh_box(node_name: String, position: Vector3, size: Vector3, color: Color, roughness: float) -> void:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = _material(color, roughness, 0.0)
    add_child(node)

func _mesh_capsule(node_name: String, position: Vector3, radius: float, height: float, color: Color, roughness: float) -> void:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    node.mesh = mesh
    node.material_override = _material(color, roughness, 0.0)
    add_child(node)

func _material(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material
