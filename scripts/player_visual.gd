extends Node3D
class_name VantaPlayerVisual

@export var cloth_dark := Color(0.055, 0.06, 0.07, 1.0)
@export var cloth_mid := Color(0.12, 0.13, 0.14, 1.0)
@export var trouser_color := Color(0.072, 0.078, 0.088, 1.0)
@export var shoe_color := Color(0.025, 0.025, 0.028, 1.0)
@export var skin_color := Color(0.63, 0.47, 0.36, 1.0)
@export var hair_color := Color(0.025, 0.02, 0.018, 1.0)

func _ready() -> void:
    name = "PlayerVisual"
    _build_body()

func configure_palette(primary: Color, secondary: Color, trousers: Color, skin: Color, hair: Color) -> void:
    cloth_dark = primary
    cloth_mid = secondary
    trouser_color = trousers
    skin_color = skin
    hair_color = hair

func _build_body() -> void:
    _mesh_box("Torso", Vector3(0.0, 1.22, 0.0), Vector3(0.60, 0.70, 0.34), cloth_dark, 0.72)
    _mesh_box("JacketLower", Vector3(0.0, 0.84, 0.0), Vector3(0.52, 0.24, 0.30), cloth_mid, 0.78)
    _mesh_box("ShirtCollar", Vector3(0.0, 1.52, -0.18), Vector3(0.24, 0.10, 0.035), cloth_mid.lightened(0.16), 0.72)
    _mesh_box("Belt", Vector3(0.0, 0.71, 0.0), Vector3(0.50, 0.08, 0.29), Color(0.035, 0.035, 0.038, 1.0), 0.48)
    _mesh_box("BeltBuckle", Vector3(0.0, 0.71, -0.155), Vector3(0.11, 0.07, 0.03), Color(0.36, 0.37, 0.36, 1.0), 0.22)

    _mesh_capsule("Neck", Vector3(0.0, 1.62, 0.0), 0.105, 0.22, skin_color, 0.80)
    _mesh_capsule("Head", Vector3(0.0, 1.94, 0.0), 0.235, 0.48, skin_color, 0.78)
    _mesh_box("Hair", Vector3(0.0, 2.15, -0.01), Vector3(0.40, 0.13, 0.33), hair_color, 0.88)
    _mesh_capsule("LeftEar", Vector3(-0.235, 1.95, 0.0), 0.045, 0.11, skin_color.darkened(0.03), 0.82)
    _mesh_capsule("RightEar", Vector3(0.235, 1.95, 0.0), 0.045, 0.11, skin_color.darkened(0.03), 0.82)
    _mesh_box("Nose", Vector3(0.0, 1.95, -0.235), Vector3(0.055, 0.09, 0.055), skin_color.lightened(0.02), 0.78)
    _mesh_box("LeftBrow", Vector3(-0.075, 2.035, -0.231), Vector3(0.075, 0.018, 0.016), hair_color, 0.84)
    _mesh_box("RightBrow", Vector3(0.075, 2.035, -0.231), Vector3(0.075, 0.018, 0.016), hair_color, 0.84)
    _mesh_box("LeftEye", Vector3(-0.073, 2.005, -0.241), Vector3(0.040, 0.020, 0.012), Color(0.05, 0.045, 0.04, 1.0), 0.50)
    _mesh_box("RightEye", Vector3(0.073, 2.005, -0.241), Vector3(0.040, 0.020, 0.012), Color(0.05, 0.045, 0.04, 1.0), 0.50)

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

func _mesh_box(node_name: String, position_value: Vector3, size: Vector3, color: Color, roughness: float) -> void:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = _material(color, roughness, 0.0)
    add_child(node)

func _mesh_capsule(node_name: String, position_value: Vector3, radius: float, height: float, color: Color, roughness: float) -> void:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
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
