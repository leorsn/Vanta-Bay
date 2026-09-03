extends Node
class_name VantaAmbientMotionController

var _root: Node3D
var _time := 0.0
var _wind_nodes: Array[Node3D] = []
var _boat_nodes: Array[Node3D] = []
var _base_rotations: Dictionary = {}
var _base_positions: Dictionary = {}
var _gulls: Array[Node3D] = []

func _ready() -> void:
    add_to_group("ambient_motion_controller")
    call_deferred("_setup")

func _setup() -> void:
    _root = get_tree().current_scene as Node3D
    if _root == null:
        return
    _collect_nodes(_root)
    _spawn_gulls()

func _process(delta: float) -> void:
    _time += delta
    if _root == null:
        return
    if _wind_nodes.is_empty() and _boat_nodes.is_empty():
        _collect_nodes(_root)
    _animate_wind()
    _animate_boats()
    _animate_gulls(delta)

func _collect_nodes(node: Node) -> void:
    for child in node.get_children():
        if child is Node3D:
            var spatial := child as Node3D
            var lower := spatial.name.to_lower()
            if lower.contains("palm") or lower.contains("leaf") or lower.contains("frond") or lower.contains("shadesail") or lower.contains("canopy"):
                if not _wind_nodes.has(spatial):
                    _wind_nodes.append(spatial)
                    _base_rotations[spatial.get_instance_id()] = spatial.rotation
            if lower.contains("yacht") or lower.contains("boat"):
                if not _boat_nodes.has(spatial):
                    _boat_nodes.append(spatial)
                    _base_positions[spatial.get_instance_id()] = spatial.position
                    _base_rotations[spatial.get_instance_id()] = spatial.rotation
        _collect_nodes(child)

func _animate_wind() -> void:
    var index := 0
    for node in _wind_nodes:
        if not is_instance_valid(node):
            continue
        var id := node.get_instance_id()
        var base: Vector3 = _base_rotations.get(id, node.rotation)
        var phase := _time * 1.15 + float(index) * 0.63
        var sway := sin(phase) * deg_to_rad(1.6) + sin(phase * 0.43) * deg_to_rad(0.7)
        node.rotation.x = base.x + sway * 0.42
        node.rotation.z = base.z + sway
        index += 1

func _animate_boats() -> void:
    var index := 0
    for node in _boat_nodes:
        if not is_instance_valid(node):
            continue
        var id := node.get_instance_id()
        var base_pos: Vector3 = _base_positions.get(id, node.position)
        var base_rot: Vector3 = _base_rotations.get(id, node.rotation)
        var phase := _time * 0.72 + float(index) * 1.3
        node.position.y = base_pos.y + sin(phase) * 0.055
        node.rotation.z = base_rot.z + sin(phase * 0.73) * deg_to_rad(0.8)
        node.rotation.x = base_rot.x + sin(phase * 0.51) * deg_to_rad(0.45)
        index += 1

func _spawn_gulls() -> void:
    if _root == null or not _gulls.is_empty():
        return
    for i in range(5):
        var gull := Node3D.new()
        gull.name = "CoastalGull"
        gull.position = Vector3(42.0 + float(i) * 8.0, 10.0 + float(i % 2) * 2.5, -35.0 + float(i) * 15.0)
        _root.add_child(gull)
        var material := StandardMaterial3D.new()
        material.albedo_color = Color(0.80, 0.82, 0.82, 1.0)
        material.roughness = 0.92
        for side in [-1.0, 1.0]:
            var wing := MeshInstance3D.new()
            var mesh := BoxMesh.new()
            mesh.size = Vector3(0.42, 0.025, 0.12)
            wing.mesh = mesh
            wing.position = Vector3(side * 0.20, 0.0, 0.0)
            wing.rotation_degrees.z = side * 12.0
            wing.material_override = material
            gull.add_child(wing)
        _gulls.append(gull)

func _animate_gulls(delta: float) -> void:
    var index := 0
    for gull in _gulls:
        if not is_instance_valid(gull):
            continue
        var radius := 20.0 + float(index) * 3.5
        var angle := _time * (0.08 + float(index) * 0.006) + float(index) * 1.15
        var center := Vector3(58.0, 10.5 + float(index % 2) * 2.0, 2.0)
        var target := center + Vector3(cos(angle) * radius, sin(_time * 0.5 + float(index)) * 0.6, sin(angle) * radius)
        var previous := gull.global_position
        gull.global_position = gull.global_position.lerp(target, clampf(delta * 0.85, 0.0, 1.0))
        var direction := target - previous
        if direction.length_squared() > 0.001:
            gull.rotation.y = lerp_angle(gull.rotation.y, atan2(direction.x, direction.z), clampf(delta * 3.0, 0.0, 1.0))
        var flap := sin(_time * 5.5 + float(index)) * 18.0
        if gull.get_child_count() >= 2:
            (gull.get_child(0) as Node3D).rotation_degrees.z = -12.0 + flap
            (gull.get_child(1) as Node3D).rotation_degrees.z = 12.0 - flap
        index += 1
