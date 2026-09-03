extends Node
class_name VantaCityDetailController

var _root: Node3D
var _built := false

func _ready() -> void:
    add_to_group("city_detail_controller")
    call_deferred("_build")

func _build() -> void:
    if _built:
        return
    _root = get_tree().current_scene as Node3D
    if _root == null:
        return
    _built = true
    _build_city_facade_details()
    _build_old_bay_details()
    _build_marina_details()
    _build_beach_details()
    _build_street_details()
    _build_rooftop_details()

func _build_city_facade_details() -> void:
    _balcony_stack(Vector3(-27.5, 2.9, -54.15), 4, 2.25, 10.0)
    _balcony_stack(Vector3(-27.0, 2.7, 20.35), 3, 2.4, 8.4)
    _balcony_stack(Vector3(28.0, 2.6, 25.85), 3, 2.5, 8.0)
    _awning(Vector3(-18.0, 2.35, 30.0), Vector3(5.4, 0.12, 1.7), Color(0.18, 0.20, 0.22, 1.0))
    _awning(Vector3(21.0, 2.1, -28.0), Vector3(5.0, 0.12, 1.6), Color(0.65, 0.61, 0.52, 1.0))
    _storefront(Vector3(24.9, 1.45, -32.55), Vector3(8.0, 2.4, 0.08))
    _storefront(Vector3(-27.0, 1.7, 20.35), Vector3(10.0, 2.6, 0.08))
    _vertical_fins(Vector3(19.46, 8.5, -45.0), 6, 2.4, 7.0)
    _vertical_fins(Vector3(19.46, 14.0, -2.0), 7, 2.5, 17.0)

func _build_old_bay_details() -> void:
    _fire_escape(Vector3(-46.25, 4.0, -8.0), 3, 2.0)
    _fire_escape(Vector3(-46.25, 4.4, 20.0), 3, 2.1)
    _pipe_run(Vector3(-57.6, 2.1, -8.0), 5.0)
    _pipe_run(Vector3(-57.6, 2.4, 20.0), 5.5)
    _loading_canopy(Vector3(-52.0, 3.1, -18.05), 6.2)
    _loading_canopy(Vector3(-52.0, 3.2, 29.05), 6.0)
    _chain_fence(Vector3(-43.0, 1.2, 35.2), Vector3(9.0, 2.4, 0.08))
    _chain_fence(Vector3(-49.5, 1.2, 29.0), Vector3(0.08, 2.4, 10.0))
    _industrial_barrel(Vector3(-36.5, 0.48, 30.5), Color(0.12, 0.20, 0.28, 1.0))
    _industrial_barrel(Vector3(-35.7, 0.48, 30.7), Color(0.42, 0.22, 0.08, 1.0))
    _industrial_barrel(Vector3(-44.0, 0.48, 25.8), Color(0.18, 0.19, 0.18, 1.0))

func _build_marina_details() -> void:
    for z: float in [-47.0, -34.0, -21.0]:
        _yacht(Vector3(61.0, 0.22, z - 4.2), 0.0)
        _mooring_rope(Vector3(55.5, 0.18, z - 1.0), Vector3(61.0, 0.32, z - 3.2))
    _marina_railing(Vector3(48.8, 0.70, -30.0), 44.0)
    _shade_sail(Vector3(39.0, 4.4, -12.0), 5.0)
    _planter_tree(Vector3(35.0, 0.0, -17.0), 2.7)
    _planter_tree(Vector3(42.0, 0.0, -18.0), 2.5)
    _cafe_table(Vector3(38.0, 0.0, -9.5))
    _cafe_table(Vector3(41.0, 0.0, -10.5))
    _cafe_table(Vector3(35.5, 0.0, -11.0))

func _build_beach_details() -> void:
    for z: float in [-42.0, -24.0, -4.0, 17.0, 38.0]:
        _beach_umbrella(Vector3(50.0, 0.0, z), Color(0.80, 0.72, 0.55, 1.0))
        _beach_chair(Vector3(52.0, 0.0, z + 1.2), -0.18)
        _beach_chair(Vector3(53.2, 0.0, z - 0.4), 0.10)
    _boardwalk_rail(Vector3(42.0, 0.65, 18.0), 70.0)
    _bike_rack(Vector3(38.8, 0.0, 8.0))
    _bike_rack(Vector3(38.8, 0.0, 31.0))

func _build_street_details() -> void:
    for z: float in [-42.0, -12.0, 18.0, 46.0]:
        _hydrant(Vector3(-10.4, 0.0, z), Color(0.68, 0.12, 0.08, 1.0))
    for z: float in [-50.0, -22.0, 8.0, 36.0]:
        _trash_bin(Vector3(10.8, 0.0, z))
    _traffic_signal(Vector3(-9.7, 0.0, -18.5), -1.0)
    _traffic_signal(Vector3(9.7, 0.0, -33.5), 1.0)
    _parking_meter_row(Vector3(-10.5, 0.0, 4.0), 5, 7.0)
    _parking_meter_row(Vector3(10.5, 0.0, 23.0), 4, 7.0)

func _build_rooftop_details() -> void:
    _hvac_cluster(Vector3(-29.0, 24.45, -4.0), 3)
    _hvac_cluster(Vector3(30.0, 28.45, -2.0), 4)
    _hvac_cluster(Vector3(28.5, 16.45, -45.0), 2)
    _satellite_dish(Vector3(-27.5, 14.55, -43.0), 0.7)
    _satellite_dish(Vector3(-27.0, 12.55, 32.0), -0.6)

func _balcony_stack(position: Vector3, count: int, spacing: float, width: float) -> void:
    for i in range(count):
        var y: float = position.y + float(i) * spacing
        _box("BalconySlab", Vector3(position.x, y, position.z), Vector3(width, 0.12, 1.15), Color(0.40, 0.41, 0.40, 1.0), 0.76, 0.05)
        _box("BalconyRail", Vector3(position.x, y + 0.55, position.z - 0.54), Vector3(width, 0.74, 0.045), Color(0.12, 0.15, 0.16, 0.72), 0.18, 0.25, true)

func _awning(position: Vector3, size: Vector3, color: Color) -> void:
    var awning := _box("Awning", position, size, color, 0.72)
    awning.rotation_degrees.x = -10.0

func _storefront(position: Vector3, size: Vector3) -> void:
    _box("StorefrontGlass", position, size, Color(0.05, 0.11, 0.14, 0.78), 0.08, 0.12, true)
    _box("StorefrontHeader", position + Vector3(0.0, size.y * 0.55, 0.02), Vector3(size.x + 0.2, 0.18, 0.12), Color(0.08, 0.09, 0.10, 1.0), 0.42, 0.45)

func _vertical_fins(position: Vector3, count: int, spacing: float, height: float) -> void:
    for i in range(count):
        var z: float = position.z - float(count - 1) * spacing * 0.5 + float(i) * spacing
        _box("FacadeFin", Vector3(position.x, position.y, z), Vector3(0.20, height, 0.38), Color(0.18, 0.20, 0.21, 1.0), 0.48, 0.35)

func _fire_escape(position: Vector3, levels: int, spacing: float) -> void:
    for i in range(levels):
        var y: float = position.y + float(i) * spacing
        _box("EscapeDeck", Vector3(position.x, y, position.z), Vector3(1.4, 0.10, 3.3), Color(0.08, 0.085, 0.09, 1.0), 0.48, 0.65)
        _box("EscapeRail", Vector3(position.x - 0.66, y + 0.48, position.z), Vector3(0.07, 0.95, 3.3), Color(0.08, 0.085, 0.09, 1.0), 0.48, 0.65)

func _pipe_run(position: Vector3, length: float) -> void:
    var pipe := MeshInstance3D.new()
    pipe.name = "IndustrialPipe"
    pipe.position = position
    pipe.rotation_degrees.z = 90.0
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.13
    mesh.bottom_radius = 0.13
    mesh.height = length
    pipe.mesh = mesh
    pipe.material_override = _material(Color(0.16, 0.17, 0.17, 1.0), 0.52, 0.62)
    _root.add_child(pipe)

func _loading_canopy(position: Vector3, width: float) -> void:
    var canopy := _box("LoadingCanopy", position, Vector3(width, 0.16, 2.1), Color(0.10, 0.11, 0.12, 1.0), 0.55, 0.45)
    canopy.rotation_degrees.x = -4.0

func _chain_fence(position: Vector3, size: Vector3) -> void:
    _box("ChainFence", position, size, Color(0.46, 0.49, 0.48, 0.48), 0.45, 0.70, true)

func _industrial_barrel(position: Vector3, color: Color) -> void:
    var barrel := MeshInstance3D.new()
    barrel.name = "IndustrialBarrel"
    barrel.position = position
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.35
    mesh.bottom_radius = 0.35
    mesh.height = 0.95
    barrel.mesh = mesh
    barrel.material_override = _material(color, 0.68, 0.28)
    _root.add_child(barrel)

func _yacht(position: Vector3, rotation_y: float) -> void:
    var yacht := Node3D.new()
    yacht.name = "MarinaYacht"
    yacht.position = position
    yacht.rotation.y = rotation_y
    _root.add_child(yacht)
    _box_to(yacht, "Hull", Vector3.ZERO, Vector3(2.3, 0.50, 7.5), Color(0.86, 0.87, 0.84, 1.0), 0.34, 0.08)
    _box_to(yacht, "Cabin", Vector3(0.0, 0.55, -0.25), Vector3(1.75, 0.80, 2.7), Color(0.10, 0.18, 0.22, 0.84), 0.10, 0.12, true)
    _box_to(yacht, "Deck", Vector3(0.0, 0.36, 1.7), Vector3(1.85, 0.14, 2.0), Color(0.62, 0.48, 0.30, 1.0), 0.66)

func _mooring_rope(start: Vector3, finish: Vector3) -> void:
    var midpoint: Vector3 = (start + finish) * 0.5
    var distance: float = start.distance_to(finish)
    var rope := MeshInstance3D.new()
    rope.name = "MooringRope"
    rope.position = midpoint
    rope.look_at_from_position(midpoint, finish, Vector3.UP)
    rope.rotate_x(PI * 0.5)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.025
    mesh.bottom_radius = 0.025
    mesh.height = distance
    rope.mesh = mesh
    rope.material_override = _material(Color(0.10, 0.08, 0.055, 1.0), 0.90)
    _root.add_child(rope)

func _marina_railing(position: Vector3, length: float) -> void:
    _box("MarinaRailTop", position + Vector3(0.0, 0.55, 0.0), Vector3(0.08, 0.07, length), Color(0.20, 0.22, 0.22, 1.0), 0.32, 0.72)
    for z in range(-20, 21, 4):
        _box("MarinaRailPost", position + Vector3(0.0, 0.28, float(z)), Vector3(0.08, 0.58, 0.08), Color(0.20, 0.22, 0.22, 1.0), 0.32, 0.72)

func _shade_sail(position: Vector3, size: float) -> void:
    _box("ShadeSail", position, Vector3(size, 0.06, size), Color(0.82, 0.80, 0.72, 0.92), 0.74, 0.0, true)
    for offset: Vector3 in [Vector3(-size * 0.45, -2.0, -size * 0.45), Vector3(size * 0.45, -2.0, -size * 0.45), Vector3(-size * 0.45, -2.0, size * 0.45), Vector3(size * 0.45, -2.0, size * 0.45)]:
        _box("ShadePost", position + offset, Vector3(0.09, 4.0, 0.09), Color(0.18, 0.19, 0.19, 1.0), 0.38, 0.65)

func _planter_tree(position: Vector3, height: float) -> void:
    var trunk := MeshInstance3D.new()
    trunk.name = "PlanterTree"
    trunk.position = position + Vector3(0.0, height * 0.5 + 0.65, 0.0)
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.08
    trunk_mesh.bottom_radius = 0.12
    trunk_mesh.height = height
    trunk.mesh = trunk_mesh
    trunk.material_override = _material(Color(0.25, 0.15, 0.07, 1.0), 0.88)
    _root.add_child(trunk)
    var crown := MeshInstance3D.new()
    crown.name = "TreeCrown"
    crown.position = position + Vector3(0.0, height + 0.9, 0.0)
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 0.95
    crown_mesh.height = 1.7
    crown.mesh = crown_mesh
    crown.material_override = _material(Color(0.07, 0.25, 0.10, 1.0), 0.86)
    _root.add_child(crown)

func _cafe_table(position: Vector3) -> void:
    var top := MeshInstance3D.new()
    top.position = position + Vector3(0.0, 0.72, 0.0)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.52
    mesh.bottom_radius = 0.52
    mesh.height = 0.07
    top.mesh = mesh
    top.material_override = _material(Color(0.18, 0.18, 0.17, 1.0), 0.50, 0.48)
    _root.add_child(top)
    _box("CafeTableLeg", position + Vector3(0.0, 0.35, 0.0), Vector3(0.10, 0.70, 0.10), Color(0.12, 0.12, 0.12, 1.0), 0.40, 0.60)

func _beach_umbrella(position: Vector3, color: Color) -> void:
    _box("UmbrellaPole", position + Vector3(0.0, 1.2, 0.0), Vector3(0.06, 2.4, 0.06), Color(0.25, 0.22, 0.17, 1.0), 0.80)
    var canopy := MeshInstance3D.new()
    canopy.name = "BeachUmbrella"
    canopy.position = position + Vector3(0.0, 2.35, 0.0)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.10
    mesh.bottom_radius = 1.4
    mesh.height = 0.22
    canopy.mesh = mesh
    canopy.material_override = _material(color, 0.72)
    _root.add_child(canopy)

func _beach_chair(position: Vector3, rotation_y: float) -> void:
    var chair := Node3D.new()
    chair.position = position
    chair.rotation.y = rotation_y
    _root.add_child(chair)
    var seat := _box_to(chair, "BeachChair", Vector3(0.0, 0.28, 0.0), Vector3(0.62, 0.08, 1.45), Color(0.77, 0.74, 0.66, 1.0), 0.76)
    seat.rotation_degrees.x = -8.0
    var back := _box_to(chair, "BeachChairBack", Vector3(0.0, 0.70, 0.58), Vector3(0.62, 0.90, 0.08), Color(0.77, 0.74, 0.66, 1.0), 0.76)
    back.rotation_degrees.x = -22.0

func _boardwalk_rail(position: Vector3, length: float) -> void:
    _box("BoardwalkRail", position + Vector3(0.0, 0.42, 0.0), Vector3(0.09, 0.09, length), Color(0.38, 0.29, 0.19, 1.0), 0.78)
    for z in range(-32, 33, 4):
        _box("BoardwalkPost", position + Vector3(0.0, 0.20, float(z)), Vector3(0.09, 0.48, 0.09), Color(0.38, 0.29, 0.19, 1.0), 0.78)

func _bike_rack(position: Vector3) -> void:
    for i in range(4):
        var rack := MeshInstance3D.new()
        rack.position = position + Vector3(float(i) * 0.42, 0.35, 0.0)
        rack.rotation_degrees.z = 90.0
        var mesh := TorusMesh.new()
        mesh.inner_radius = 0.22
        mesh.outer_radius = 0.28
        rack.mesh = mesh
        rack.material_override = _material(Color(0.20, 0.21, 0.21, 1.0), 0.34, 0.74)
        _root.add_child(rack)

func _hydrant(position: Vector3, color: Color) -> void:
    var body := MeshInstance3D.new()
    body.position = position + Vector3(0.0, 0.42, 0.0)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.18
    mesh.bottom_radius = 0.22
    mesh.height = 0.70
    body.mesh = mesh
    body.material_override = _material(color, 0.52, 0.36)
    _root.add_child(body)

func _trash_bin(position: Vector3) -> void:
    _box("TrashBin", position + Vector3(0.0, 0.48, 0.0), Vector3(0.72, 0.96, 0.72), Color(0.09, 0.11, 0.10, 1.0), 0.72, 0.28)

func _traffic_signal(position: Vector3, side: float) -> void:
    _box("SignalPole", position + Vector3(0.0, 2.8, 0.0), Vector3(0.12, 5.6, 0.12), Color(0.08, 0.09, 0.09, 1.0), 0.42, 0.60)
    _box("SignalArm", position + Vector3(side * 2.0, 5.35, 0.0), Vector3(4.0, 0.12, 0.12), Color(0.08, 0.09, 0.09, 1.0), 0.42, 0.60)
    _box("SignalHead", position + Vector3(side * 3.65, 4.8, 0.0), Vector3(0.42, 1.0, 0.34), Color(0.05, 0.055, 0.055, 1.0), 0.50, 0.35)

func _parking_meter_row(start: Vector3, count: int, spacing: float) -> void:
    for i in range(count):
        var position: Vector3 = start + Vector3(0.0, 0.0, float(i) * spacing)
        _box("ParkingMeterPole", position + Vector3(0.0, 0.65, 0.0), Vector3(0.06, 1.3, 0.06), Color(0.15, 0.16, 0.16, 1.0), 0.38, 0.66)
        _box("ParkingMeter", position + Vector3(0.0, 1.35, 0.0), Vector3(0.22, 0.30, 0.16), Color(0.19, 0.20, 0.20, 1.0), 0.32, 0.72)

func _hvac_cluster(position: Vector3, count: int) -> void:
    for i in range(count):
        var offset: Vector3 = Vector3(float(i % 2) * 2.2, 0.0, float(i / 2) * 2.0)
        _box("RooftopHVAC", position + offset, Vector3(1.7, 1.0, 1.45), Color(0.30, 0.31, 0.31, 1.0), 0.58, 0.42)
        _box("HVACVent", position + offset + Vector3(0.0, 0.56, 0.0), Vector3(1.3, 0.10, 1.0), Color(0.12, 0.13, 0.13, 1.0), 0.42, 0.58)

func _satellite_dish(position: Vector3, rotation_y: float) -> void:
    var dish := MeshInstance3D.new()
    dish.position = position
    dish.rotation = Vector3(deg_to_rad(-28.0), rotation_y, 0.0)
    var mesh := SphereMesh.new()
    mesh.radius = 0.72
    mesh.height = 0.22
    dish.mesh = mesh
    dish.material_override = _material(Color(0.68, 0.69, 0.67, 1.0), 0.48, 0.35)
    _root.add_child(dish)

func _box(node_name: String, position: Vector3, size: Vector3, color: Color, roughness: float, metallic: float = 0.0, transparent: bool = false) -> Node3D:
    return _box_to(_root, node_name, position, size, color, roughness, metallic, transparent)

func _box_to(parent: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color, roughness: float, metallic: float = 0.0, transparent: bool = false) -> Node3D:
    var root := Node3D.new()
    root.name = node_name
    root.position = position
    parent.add_child(root)
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    var material := _material(color, roughness, metallic)
    if transparent:
        material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mesh_instance.material_override = material
    root.add_child(mesh_instance)
    return root

func _material(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material
