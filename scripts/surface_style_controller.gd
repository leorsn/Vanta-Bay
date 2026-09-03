extends Node
class_name VantaSurfaceStyleController

var asphalt_texture: Texture2D
var concrete_texture: Texture2D
var brick_texture: Texture2D
var sand_texture: Texture2D

func _ready() -> void:
    asphalt_texture = load("res://assets/textures/asphalt.svg") as Texture2D
    concrete_texture = load("res://assets/textures/concrete.svg") as Texture2D
    brick_texture = load("res://assets/textures/brick.svg") as Texture2D
    sand_texture = load("res://assets/textures/sand.svg") as Texture2D
    call_deferred("_apply_surface_pass")

func _apply_surface_pass() -> void:
    await get_tree().process_frame
    var scene := get_tree().current_scene
    if scene == null:
        return
    _walk(scene)

func _walk(node: Node) -> void:
    if node is MeshInstance3D:
        _style_mesh(node as MeshInstance3D)
    for child in node.get_children():
        _walk(child)

func _style_mesh(mesh_instance: MeshInstance3D) -> void:
    var parent := mesh_instance.get_parent()
    if parent == null:
        return
    var node_name := str(parent.name)
    var ancestor_name := ""
    if parent.get_parent() != null:
        ancestor_name = str(parent.get_parent().name)

    if node_name == "Road" or node_name == "ExitLane":
        mesh_instance.material_override = _surface_material(asphalt_texture, Color(0.74, 0.76, 0.77, 1.0), 0.92, Vector3(6.0, 6.0, 6.0))
    elif node_name == "Sidewalk" or node_name == "CityBase":
        mesh_instance.material_override = _surface_material(concrete_texture, Color(0.82, 0.82, 0.79, 1.0), 0.90, Vector3(5.0, 5.0, 5.0))
    elif node_name == "Beach":
        mesh_instance.material_override = _surface_material(sand_texture, Color(1.0, 0.96, 0.82, 1.0), 0.98, Vector3(7.0, 7.0, 7.0))
    elif node_name.begins_with("BrickWall"):
        mesh_instance.material_override = _surface_material(brick_texture, Color(0.90, 0.72, 0.62, 1.0), 0.93, Vector3(4.0, 4.0, 4.0))
    elif node_name == "Shell" and ancestor_name.begins_with("Warehouse"):
        mesh_instance.material_override = _surface_material(brick_texture, Color(0.72, 0.67, 0.60, 1.0), 0.94, Vector3(5.0, 5.0, 5.0))

func _surface_material(texture: Texture2D, tint: Color, roughness: float, uv_scale: Vector3) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.albedo_texture = texture
    material.roughness = roughness
    material.uv1_scale = uv_scale
    return material
