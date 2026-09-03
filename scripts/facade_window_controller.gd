extends Node
class_name VantaFacadeWindowController

var _root: Node3D
var _built := false
var _time_manager: Node
var _window_materials: Array[StandardMaterial3D] = []

func _ready() -> void:
    add_to_group("facade_window_controller")
    call_deferred("_build")

func _process(_delta: float) -> void:
    if _time_manager == null:
        _time_manager = get_tree().get_first_node_in_group("world_time_manager")
    var hour := 20.0
    if _time_manager != null:
        var value = _time_manager.get("time_hours")
        if value != null:
            hour = float(value)
    var night_amount := 1.0 if hour >= 18.5 or hour <= 6.5 else 0.0
    for material in _window_materials:
        if material == null:
            continue
        material.emission_energy_multiplier = lerpf(0.08, 1.8, night_amount)

func _build() -> void:
    if _built:
        return
    _root = get_tree().current_scene as Node3D
    if _root == null:
        return
    _built = true
    _window_grid(Vector3(-29.0, 11.5, -18.08), Vector2(18.0, 20.0), 6, 7, 1)
    _window_grid(Vector3(30.0, 13.5, -15.58), Vector2(17.0, 23.0), 6, 8, 2)
    _window_grid(Vector3(-27.5, 6.8, -54.08), Vector2(15.5, 10.0), 5, 4, 0)
    _window_grid(Vector3(28.5, 7.8, -54.08), Vector2(14.0, 12.0), 5, 5, 3)
    _window_grid(Vector3(-27.0, 6.0, 20.45), Vector2(13.5, 8.5), 5, 4, 4)
    _window_grid(Vector3(28.0, 5.8, 25.95), Vector2(13.0, 8.0), 5, 4, 5)

func _window_grid(center: Vector3, area: Vector2, columns: int, rows: int, pattern_seed: int) -> void:
    var spacing_x := area.x / float(columns)
    var spacing_y := area.y / float(rows)
    for row in range(rows):
        for column in range(columns):
            var state := (column * 3 + row * 5 + pattern_seed * 7) % 6
            if state == 0:
                continue
            var x := center.x - area.x * 0.5 + spacing_x * (float(column) + 0.5)
            var y := center.y - area.y * 0.5 + spacing_y * (float(row) + 0.5)
            var panel := MeshInstance3D.new()
            panel.name = "FacadeWindowUnit"
            panel.position = Vector3(x, y, center.z)
            var mesh := BoxMesh.new()
            mesh.size = Vector3(spacing_x * 0.62, spacing_y * 0.52, 0.055)
            panel.mesh = mesh
            var color := Color(0.07, 0.13, 0.16, 0.92)
            if state == 2 or state == 4:
                color = Color(0.47, 0.31, 0.18, 0.94)
            elif state == 3:
                color = Color(0.16, 0.24, 0.29, 0.94)
            elif state == 5:
                color = Color(0.72, 0.55, 0.32, 0.96)
            var material := StandardMaterial3D.new()
            material.albedo_color = color.darkened(0.45)
            material.roughness = 0.12
            material.metallic = 0.12
            material.emission_enabled = true
            material.emission = color
            material.emission_energy_multiplier = 0.08
            material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
            panel.material_override = material
            _window_materials.append(material)
            _root.add_child(panel)
            if column < columns - 1:
                _mullion(Vector3(x + spacing_x * 0.43, y, center.z - 0.015), spacing_y * 0.70)

func _mullion(position: Vector3, height: float) -> void:
    var node := MeshInstance3D.new()
    node.name = "FacadeMullion"
    node.position = position
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.045, height, 0.07)
    node.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.07, 0.08, 0.085, 1.0)
    material.roughness = 0.35
    material.metallic = 0.62
    node.material_override = material
    _root.add_child(node)
