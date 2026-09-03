extends Node
class_name VantaWaterVisualController

const WaterShader = preload("res://shaders/coastal_water.gdshader")

var water_meshes: Array[MeshInstance3D] = []
var _scan_timer := 0.0

func _ready() -> void:
    add_to_group("water_visual_controller")
    call_deferred("_scan_and_apply")

func _process(delta: float) -> void:
    _scan_timer -= delta
    if _scan_timer <= 0.0 and water_meshes.is_empty():
        _scan_timer = 2.0
        _scan_and_apply()

func _scan_and_apply() -> void:
    var scene := get_tree().current_scene
    if scene == null:
        return
    water_meshes.clear()
    _walk(scene)
    for mesh in water_meshes:
        _apply_water_material(mesh)

func _walk(node: Node) -> void:
    if node.name == "Ocean":
        for child in node.get_children():
            if child is MeshInstance3D:
                water_meshes.append(child as MeshInstance3D)
    for child in node.get_children():
        _walk(child)

func _apply_water_material(mesh: MeshInstance3D) -> void:
    var material := ShaderMaterial.new()
    material.shader = WaterShader
    material.set_shader_parameter("wave_strength", 0.075)
    material.set_shader_parameter("wave_scale", 0.12)
    material.set_shader_parameter("wave_speed", 0.52)
    mesh.material_override = material
