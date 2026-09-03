extends Node
class_name VantaEnvironmentDetailController

var root: Node3D
var built := false

func _ready() -> void:
    add_to_group("environment_detail_controller")
    call_deferred("_build")

func _build() -> void:
    if built:
        return
    root = get_tree().current_scene as Node3D
    if root == null:
        return
    built = true
    _build_apartment_interior_detail()
    _build_workshop_interior_detail()
    _build_marina_lounge_detail()
    _build_vegetation_clusters()
    _build_night_practical_lights()
    _build_skyline_depth()

func _build_apartment_interior_detail() -> void:
    var group := Node3D.new()
    group.name = "ApartmentInteriorDetail"
    root.add_child(group)
    _box_to(group, "ApartmentRug", Vector3(-49.0, 0.12, -47.0), Vector3(3.8, 0.035, 2.6), Color(0.10,0.095,0.09,1), 0.88)
    _box_to(group, "ApartmentSofa", Vector3(-51.0, 0.55, -48.5), Vector3(2.7, 0.72, 0.95), Color(0.16,0.17,0.18,1), 0.82)
    _box_to(group, "ApartmentCoffeeTable", Vector3(-48.5, 0.42, -48.0), Vector3(1.5, 0.18, 0.72), Color(0.22,0.17,0.12,1), 0.64)
    _box_to(group, "ApartmentTV", Vector3(-46.8, 1.55, -49.8), Vector3(1.9, 1.05, 0.10), Color(0.018,0.022,0.025,1), 0.18, 0.35)
    _box_to(group, "ApartmentConsole", Vector3(-46.8, 0.62, -49.8), Vector3(2.2, 0.54, 0.42), Color(0.14,0.12,0.10,1), 0.70)
    _floor_lamp(group, Vector3(-51.5,0.0,-45.8), Color(1.0,0.66,0.42,1), 1.25, 6.0)
    _plant(group, Vector3(-46.5,0.0,-45.7), 1.65)

func _build_workshop_interior_detail() -> void:
    var group := Node3D.new()
    group.name = "WorkshopInteriorDetail"
    root.add_child(group)
    for x: float in [-9.8, -6.6, -3.4, -0.2, 3.0, 6.2]:
        _ceiling_strip(group, Vector3(x, 5.7, 52.0), 2.5)
    _box_to(group, "HydraulicLiftLeft", Vector3(-6.6,0.24,50.0), Vector3(0.45,0.48,4.4), Color(0.13,0.14,0.15,1), 0.48, 0.55)
    _box_to(group, "HydraulicLiftRight", Vector3(-1.4,0.24,50.0), Vector3(0.45,0.48,4.4), Color(0.13,0.14,0.15,1), 0.48, 0.55)
    _tool_chest(group, Vector3(2.8,0.0,54.0))
    _tool_chest(group, Vector3(5.3,0.0,54.0))
    _box_to(group, "WorkshopMonitor", Vector3(3.6,2.0,55.8), Vector3(1.1,0.68,0.08), Color(0.035,0.09,0.12,1), 0.12, 0.18)
    _warning_stripe(group, Vector3(-4.0,0.13,46.0), 13.0)

func _build_marina_lounge_detail() -> void:
    var group := Node3D.new()
    group.name = "MarinaLoungeDetail"
    root.add_child(group)
    _box_to(group, "MarinaDeckInset", Vector3(39.0,0.16,-12.0), Vector3(10.0,0.05,8.0), Color(0.48,0.38,0.26,1), 0.75)
    _lounge_seat(group, Vector3(36.0,0.0,-12.0), 0.0)
    _lounge_seat(group, Vector3(42.0,0.0,-12.0), PI)
    _floor_lamp(group, Vector3(39.0,0.0,-15.0), Color(1.0,0.78,0.55,1), 1.05, 5.0)
    _planter(group, Vector3(34.8,0.0,-8.5))
    _planter(group, Vector3(43.2,0.0,-8.5))

func _build_vegetation_clusters() -> void:
    var group := Node3D.new()
    group.name = "VegetationDetail"
    root.add_child(group)
    var palm_positions: Array[Vector3] = [
        Vector3(42.8,0.0,-52.0), Vector3(43.5,0.0,-38.0), Vector3(42.0,0.0,-23.0), Vector3(43.2,0.0,-6.0),
        Vector3(42.5,0.0,10.0), Vector3(43.0,0.0,28.0), Vector3(42.0,0.0,45.0)
    ]
    for i in range(palm_positions.size()):
        _palm(group, palm_positions[i], 5.6 + float(i % 3) * 0.65)
    for p: Vector3 in [Vector3(16.0,0.0,-49.0),Vector3(16.5,0.0,-3.0),Vector3(17.0,0.0,34.0),Vector3(-16.0,0.0,-36.0),Vector3(-16.5,0.0,12.0)]:
        _shrub_cluster(group, p)

func _build_night_practical_lights() -> void:
    var group := Node3D.new()
    group.name = "NightPracticalLights"
    group.add_to_group("night_practical_lights")
    root.add_child(group)
    var lights: Array[Vector3] = [
        Vector3(-28.0,3.0,-15.0), Vector3(-27.0,3.0,20.0), Vector3(25.0,3.0,-28.0), Vector3(28.0,3.0,25.0),
        Vector3(-52.0,3.0,2.0), Vector3(-52.0,3.0,29.0), Vector3(39.0,3.2,-12.0), Vector3(45.0,2.5,-35.0)
    ]
    for pos: Vector3 in lights:
        var light := OmniLight3D.new()
        light.position = pos
        light.light_color = Color(1.0,0.68,0.43,1)
        light.light_energy = 0.38
        light.omni_range = 7.5
        group.add_child(light)

func _build_skyline_depth() -> void:
    var group := Node3D.new()
    group.name = "DistantSkylineLayer"
    root.add_child(group)
    var data := [
        [Vector3(-76.0,19.0,-55.0), Vector3(15.0,38.0,16.0)],
        [Vector3(-82.0,14.0,-20.0), Vector3(20.0,28.0,18.0)],
        [Vector3(-73.0,23.0,18.0), Vector3(13.0,46.0,15.0)],
        [Vector3(-86.0,17.0,51.0), Vector3(18.0,34.0,20.0)],
        [Vector3(82.0,22.0,-55.0), Vector3(14.0,44.0,15.0)],
        [Vector3(88.0,16.0,18.0), Vector3(18.0,32.0,18.0)]
    ]
    for item in data:
        _box_to(group, "DistantTower", item[0], item[1], Color(0.095,0.115,0.13,1), 0.76, 0.08)
        for y in range(5, int(item[1].y) - 2, 6):
            _box_to(group, "DistantWindow", item[0] + Vector3(0.0,-item[1].y*0.5+float(y),-item[1].z*0.5-0.03), Vector3(item[1].x*0.55,0.55,0.05), Color(0.52,0.64,0.68,0.65), 0.15, 0.05, true)

func _floor_lamp(parent: Node3D, pos: Vector3, color: Color, energy: float, radius: float) -> void:
    _box_to(parent, "LampStem", pos + Vector3(0,1.0,0), Vector3(0.08,2.0,0.08), Color(0.08,0.08,0.08,1), 0.42, 0.55)
    _box_to(parent, "LampShade", pos + Vector3(0,2.0,0), Vector3(0.48,0.30,0.48), Color(0.75,0.63,0.48,1), 0.68)
    var light := OmniLight3D.new()
    light.position = pos + Vector3(0,1.85,0)
    light.light_color = color
    light.light_energy = energy
    light.omni_range = radius
    parent.add_child(light)

func _ceiling_strip(parent: Node3D, pos: Vector3, energy: float) -> void:
    var material := _material(Color(0.88,0.94,1.0,1),0.18,0.05)
    material.emission_enabled = true
    material.emission = Color(0.88,0.94,1.0,1)
    material.emission_energy_multiplier = energy
    _box_to_material(parent,"CeilingStrip",pos,Vector3(2.2,0.07,0.14),material)

func _tool_chest(parent: Node3D, pos: Vector3) -> void:
    _box_to(parent,"ToolChest",pos+Vector3(0,0.55,0),Vector3(1.4,1.1,0.55),Color(0.13,0.16,0.18,1),0.38,0.48)
    for y in [0.28,0.52,0.76]:
        _box_to(parent,"ToolDrawer",pos+Vector3(0,y, -0.29),Vector3(1.15,0.08,0.04),Color(0.36,0.39,0.41,1),0.28,0.68)

func _warning_stripe(parent: Node3D, pos: Vector3, width: float) -> void:
    for i in range(10):
        var x := pos.x - width*0.5 + float(i)*width/9.0
        _box_to(parent,"FloorStripe",Vector3(x,pos.y,pos.z),Vector3(0.45,0.02,2.6),Color(0.82,0.62,0.09,1),0.58)

func _lounge_seat(parent: Node3D, pos: Vector3, rot: float) -> void:
    var seat := Node3D.new()
    seat.position = pos
    seat.rotation.y = rot
    parent.add_child(seat)
    _box_to(seat,"Seat",Vector3(0,0.42,0),Vector3(2.4,0.35,0.85),Color(0.75,0.72,0.66,1),0.84)
    _box_to(seat,"SeatBack",Vector3(0,0.92,0.34),Vector3(2.4,0.70,0.18),Color(0.75,0.72,0.66,1),0.84)

func _planter(parent: Node3D, pos: Vector3) -> void:
    _box_to(parent,"Planter",pos+Vector3(0,0.45,0),Vector3(1.4,0.9,1.4),Color(0.22,0.23,0.22,1),0.86)
    _shrub_cluster(parent,pos+Vector3(0,0.9,0))

func _plant(parent: Node3D, pos: Vector3, height: float) -> void:
    _box_to(parent,"PlantPot",pos+Vector3(0,0.32,0),Vector3(0.62,0.64,0.62),Color(0.23,0.18,0.13,1),0.84)
    _shrub_cluster(parent,pos+Vector3(0,height*0.48,0))

func _shrub_cluster(parent: Node3D, pos: Vector3) -> void:
    for offset: Vector3 in [Vector3(-0.32,0.38,0),Vector3(0.28,0.46,0.12),Vector3(0,0.62,-0.25),Vector3(0.18,0.30,-0.30)]:
        var leaf := MeshInstance3D.new()
        leaf.position = pos + offset
        var mesh := SphereMesh.new()
        mesh.radius = 0.45
        mesh.height = 0.7
        leaf.mesh = mesh
        leaf.material_override = _material(Color(0.055,0.19,0.075,1),0.90,0.0)
        parent.add_child(leaf)

func _palm(parent: Node3D, pos: Vector3, height: float) -> void:
    var trunk := MeshInstance3D.new()
    trunk.position = pos + Vector3(0,height*0.5,0)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.12
    mesh.bottom_radius = 0.24
    mesh.height = height
    trunk.mesh = mesh
    trunk.material_override = _material(Color(0.27,0.17,0.085,1),0.92,0.0)
    parent.add_child(trunk)
    for i in range(8):
        var leaf := MeshInstance3D.new()
        leaf.position = pos + Vector3(0,height+0.1,0)
        leaf.rotation_degrees = Vector3(-18.0-float(i%2)*7.0,float(i)*45.0,0)
        var lm := BoxMesh.new()
        lm.size = Vector3(0.20,0.05,3.8)
        leaf.mesh = lm
        leaf.material_override = _material(Color(0.045,0.20,0.085,1),0.86,0.0)
        parent.add_child(leaf)

func _box_to(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color, roughness: float, metallic: float = 0.0, transparent: bool = false) -> MeshInstance3D:
    var mat := _material(color,roughness,metallic)
    if transparent:
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    return _box_to_material(parent,node_name,pos,size,mat)

func _box_to_material(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = pos
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = material
    parent.add_child(node)
    return node

func _material(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material
