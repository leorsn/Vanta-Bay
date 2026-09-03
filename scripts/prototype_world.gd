extends Node3D

const PedestrianAgent = preload("res://scripts/pedestrian_agent.gd")
const TrafficAgent = preload("res://scripts/traffic_agent.gd")
const StoryCampaignScript = preload("res://scripts/story_campaign.gd")
const LoseThemMissionScript = preload("res://scripts/lose_them_mission.gd")
const ApartmentStoryZoneScript = preload("res://scripts/apartment_story_zone.gd")

var asphalt := Color(0.055, 0.06, 0.065, 1.0)
var concrete := Color(0.34, 0.35, 0.34, 1.0)
var sand := Color(0.58, 0.50, 0.37, 1.0)
var glass := Color(0.16, 0.23, 0.28, 1.0)

func _ready() -> void:
    _ensure_story_systems()
    _build_roads()
    _build_blocks()
    _build_old_bay()
    _build_marina_district()
    _build_port_vanta_workshop()
    _build_jace_apartment()
    _build_black_glass_garage()
    _build_beach_edge()
    _build_street_furniture()
    _spawn_pedestrians()
    _spawn_traffic()

func _ensure_story_systems() -> void:
    if get_tree().get_first_node_in_group("story_campaign") == null:
        var campaign := StoryCampaignScript.new()
        campaign.name = "StoryCampaign"
        add_child(campaign)
    if get_tree().get_first_node_in_group("lose_them_mission") == null:
        var mission := LoseThemMissionScript.new()
        mission.name = "LoseThemMission"
        var hud := CanvasLayer.new()
        hud.name = "MissionHUD"
        mission.add_child(hud)
        var label := Label.new()
        label.name = "Objective"
        label.offset_left = 56.0
        label.offset_top = 200.0
        label.offset_right = 760.0
        label.offset_bottom = 320.0
        label.add_theme_font_size_override("font_size", 24)
        hud.add_child(label)
        add_child(mission)

func _build_roads() -> void:
    _add_box("OceanDrive", Vector3(0, 0.015, 0), Vector3(18, 0.03, 120), asphalt, false)
    _add_box("CrossStreet", Vector3(0, 0.02, -26), Vector3(120, 0.04, 16), asphalt, false)
    _add_box("WestSidewalk", Vector3(-12, 0.13, 0), Vector3(6, 0.26, 120), concrete, true)
    _add_box("EastSidewalk", Vector3(12, 0.13, 0), Vector3(6, 0.26, 120), concrete, true)
    for z in range(-54, 58, 12):
        _add_box("LaneMark", Vector3(0, 0.045, float(z)), Vector3(0.22, 0.025, 5.0), Color(0.82, 0.80, 0.68, 1), false)

func _build_blocks() -> void:
    _building(Vector3(-28, 7.0, -42), Vector3(22, 14, 24), Color(0.18, 0.18, 0.17, 1))
    _building(Vector3(-31, 11.0, -5), Vector3(25, 22, 30), Color(0.12, 0.14, 0.15, 1))
    _building(Vector3(-27, 5.5, 31), Vector3(20, 11, 25), Color(0.24, 0.22, 0.20, 1))
    _building(Vector3(29, 8.5, -44), Vector3(20, 17, 20), Color(0.16, 0.18, 0.19, 1))
    _building(Vector3(31, 13.0, -2), Vector3(23, 26, 30), Color(0.11, 0.13, 0.14, 1))
    _building(Vector3(29, 6.0, 36), Vector3(21, 12, 22), Color(0.26, 0.24, 0.21, 1))

func _build_old_bay() -> void:
    var district := Node3D.new()
    district.name = "OldBayBlockout"
    district.add_to_group("old_bay")
    add_child(district)

    _add_box_to(district, "OldBayServiceRoad", Vector3(-38, 0.03, 15), Vector3(16, 0.06, 66), asphalt, false)
    _add_box_to(district, "OldBayLane", Vector3(-49, 0.035, 4), Vector3(7, 0.07, 42), asphalt, false)
    _add_box_to(district, "OldBayCourtyard", Vector3(-43, 0.08, 29), Vector3(17, 0.16, 15), concrete, true)
    _add_box_to(district, "WarehouseA", Vector3(-52, 3.5, -11), Vector3(12, 7, 21), Color(0.16, 0.15, 0.14, 1), true)
    _add_box_to(district, "WarehouseB", Vector3(-52, 4.0, 21), Vector3(11, 8, 19), Color(0.20, 0.18, 0.16, 1), true)
    _add_box_to(district, "ClubRear", Vector3(-30, 3.0, 17), Vector3(10, 6, 15), Color(0.10, 0.10, 0.11, 1), true)
    _add_box_to(district, "AlleyWallA", Vector3(-45, 1.3, 7), Vector3(1, 2.6, 17), Color(0.22, 0.21, 0.19, 1), true)
    _add_box_to(district, "AlleyWallB", Vector3(-34, 1.3, 34), Vector3(14, 2.6, 1), Color(0.22, 0.21, 0.19, 1), true)
    _add_box_to(district, "DumpsterA", Vector3(-38, 0.65, 23), Vector3(2.2, 1.3, 1.2), Color(0.10, 0.17, 0.12, 1), true)
    _add_box_to(district, "DumpsterB", Vector3(-47, 0.65, 31), Vector3(2.2, 1.3, 1.2), Color(0.10, 0.17, 0.12, 1), true)
    _add_box_to(district, "LoadingCrateA", Vector3(-34, 0.75, 26), Vector3(2.4, 1.5, 2.4), Color(0.30, 0.22, 0.13, 1), true)
    _add_box_to(district, "LoadingCrateB", Vector3(-40, 0.75, 34), Vector3(3.0, 1.5, 1.8), Color(0.30, 0.22, 0.13, 1), true)
    _district_label(district, "OLD BAY", Vector3(-40, 5.7, 12))

func _build_marina_district() -> void:
    var marina := Node3D.new()
    marina.name = "MarinaDistrictBlockout"
    marina.add_to_group("marina_district")
    add_child(marina)

    _add_box_to(marina, "MarinaPromenade", Vector3(45, 0.10, -28), Vector3(9, 0.2, 46), Color(0.43, 0.44, 0.42, 1), true)
    _add_box_to(marina, "MarinaServiceRoad", Vector3(34, 0.03, -35), Vector3(12, 0.06, 39), asphalt, false)
    _add_box_to(marina, "MarinaPlaza", Vector3(39, 0.08, -12), Vector3(18, 0.16, 13), concrete, true)
    _add_box_to(marina, "MarinaOffice", Vector3(27, 5.0, -53), Vector3(14, 10, 11), Color(0.14, 0.16, 0.17, 1), true)
    _add_box_to(marina, "MarinaRetail", Vector3(26, 3.0, -28), Vector3(12, 6, 10), Color(0.21, 0.20, 0.19, 1), true)
    for z in [-47.0, -34.0, -21.0]:
        _add_box_to(marina, "Pier", Vector3(53, 0.10, z), Vector3(17, 0.2, 3.2), Color(0.32, 0.28, 0.22, 1), true)
    _add_box_to(marina, "PlanterA", Vector3(42, 0.55, -18), Vector3(3.4, 1.1, 1.4), Color(0.25, 0.27, 0.23, 1), true)
    _add_box_to(marina, "PlanterB", Vector3(35, 0.55, -17), Vector3(3.4, 1.1, 1.4), Color(0.25, 0.27, 0.23, 1), true)
    _add_box_to(marina, "ServiceBarrier", Vector3(31, 0.65, -39), Vector3(1.2, 1.3, 5.0), Color(0.52, 0.50, 0.46, 1), true)
    _district_label(marina, "MARINA DISTRICT", Vector3(38, 5.8, -35))

func _build_port_vanta_workshop() -> void:
    var workshop := Node3D.new()
    workshop.name = "PortVantaWorkshopBlockout"
    workshop.position = Vector3(-4, 0, 48)
    workshop.add_to_group("port_vanta_workshop")
    add_child(workshop)

    _add_box_to(workshop, "WorkshopFloor", Vector3.ZERO, Vector3(18, 0.22, 18), Color(0.13, 0.13, 0.135, 1), true)
    _add_box_to(workshop, "WorkshopBack", Vector3(0, 3.2, 8.7), Vector3(18, 6.4, 0.5), Color(0.16, 0.16, 0.17, 1), true)
    _add_box_to(workshop, "WorkshopLeft", Vector3(-8.75, 3.2, 2.5), Vector3(0.5, 6.4, 12.5), Color(0.16, 0.16, 0.17, 1), true)
    _add_box_to(workshop, "WorkshopRight", Vector3(8.75, 3.2, 2.5), Vector3(0.5, 6.4, 12.5), Color(0.16, 0.16, 0.17, 1), true)
    _add_box_to(workshop, "PaintBoothWall", Vector3(-4.6, 1.6, 3.0), Vector3(0.35, 3.2, 7.0), Color(0.52, 0.52, 0.50, 1), true)
    _add_box_to(workshop, "ToolBench", Vector3(5.6, 0.65, 4.8), Vector3(4.2, 1.3, 1.0), Color(0.12, 0.12, 0.13, 1), true)
    _add_box_to(workshop, "PartsRack", Vector3(6.8, 1.6, -1.8), Vector3(1.0, 3.2, 4.0), Color(0.18, 0.18, 0.19, 1), true)
    _add_box_to(workshop, "ExitLane", Vector3(-14, 0.03, -7), Vector3(20, 0.06, 8), asphalt, false)
    _district_label(workshop, "PORT VANTA WORKSHOP", Vector3(0, 5.3, -7.7))

func _build_jace_apartment() -> void:
    var apartment := Node3D.new()
    apartment.name = "JaceApartment"
    apartment.position = Vector3(-49, 0, -47)
    apartment.add_to_group("jace_apartment")
    add_child(apartment)

    _add_box_to(apartment, "Floor", Vector3.ZERO, Vector3(12, 0.25, 11), Color(0.16, 0.15, 0.14, 1), true)
    _add_box_to(apartment, "BackWall", Vector3(0, 2.6, 5.35), Vector3(12, 5.2, 0.3), Color(0.24, 0.23, 0.22, 1), true)
    _add_box_to(apartment, "LeftWall", Vector3(-5.85, 2.6, 0), Vector3(0.3, 5.2, 11), Color(0.24, 0.23, 0.22, 1), true)
    _add_box_to(apartment, "RightWall", Vector3(5.85, 2.6, 0), Vector3(0.3, 5.2, 11), Color(0.24, 0.23, 0.22, 1), true)
    _add_box_to(apartment, "FrontWallL", Vector3(-4.1, 2.6, -5.35), Vector3(3.5, 5.2, 0.3), Color(0.24, 0.23, 0.22, 1), true)
    _add_box_to(apartment, "FrontWallR", Vector3(4.1, 2.6, -5.35), Vector3(3.5, 5.2, 0.3), Color(0.24, 0.23, 0.22, 1), true)
    _add_box_to(apartment, "Bed", Vector3(-3.2, 0.65, 2.6), Vector3(3.4, 1.0, 5.2), Color(0.17, 0.18, 0.20, 1), true)
    _add_box_to(apartment, "Counter", Vector3(3.4, 0.85, 2.6), Vector3(3.0, 1.5, 1.2), Color(0.10, 0.10, 0.10, 1), true)
    _add_box_to(apartment, "Sofa", Vector3(2.4, 0.75, -1.2), Vector3(4.0, 1.2, 1.8), Color(0.20, 0.19, 0.18, 1), true)

    var zone := ApartmentStoryZoneScript.new()
    zone.name = "StoryZone"
    zone.position = Vector3(0, 1.5, 0)
    var collider := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(10, 3, 9)
    collider.shape = shape
    zone.add_child(collider)
    apartment.add_child(zone)

    var label := Label3D.new()
    label.text = "JACE'S APARTMENT"
    label.position = Vector3(0, 4.1, -5.6)
    label.font_size = 30
    label.outline_size = 8
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    apartment.add_child(label)

func _build_black_glass_garage() -> void:
    var garage := Node3D.new()
    garage.name = "BlackGlassGarage"
    garage.position = Vector3(-22, 0, 43)
    garage.add_to_group("black_glass_garage")
    add_child(garage)
    _add_box_to(garage, "GarageFloor", Vector3.ZERO, Vector3(15, 0.3, 18), Color(0.12, 0.12, 0.12, 1), true)
    _add_box_to(garage, "BackWall", Vector3(0, 3.0, 8.7), Vector3(15, 6, 0.5), Color(0.15, 0.15, 0.16, 1), true)
    _add_box_to(garage, "LeftWall", Vector3(-7.25, 3.0, 0), Vector3(0.5, 6, 18), Color(0.15, 0.15, 0.16, 1), true)
    _add_box_to(garage, "RightWall", Vector3(7.25, 3.0, 0), Vector3(0.5, 6, 18), Color(0.15, 0.15, 0.16, 1), true)
    _add_box_to(garage, "Roof", Vector3(0, 6.0, 0), Vector3(15, 0.35, 18), Color(0.08, 0.08, 0.09, 1), true)
    var label := Label3D.new()
    label.text = "OCEAN DRIVE PRIVATE GARAGE"
    label.position = Vector3(0, 4.7, -9.3)
    label.font_size = 32
    label.outline_size = 8
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    garage.add_child(label)

func _building(position: Vector3, size: Vector3, color: Color) -> void:
    _add_box("Building", position, size, color, true)
    for level in range(2, int(size.y) - 1, 3):
        var front_z := position.z - size.z * 0.5 - 0.015
        _add_box("WindowBand", Vector3(position.x, float(level), front_z), Vector3(size.x * 0.72, 1.15, 0.03), glass, false)

func _build_beach_edge() -> void:
    _add_box("Beach", Vector3(51, 0.03, 20), Vector3(18, 0.06, 80), sand, false)
    _add_box("Promenade", Vector3(40.5, 0.11, 20), Vector3(3, 0.22, 80), Color(0.42, 0.42, 0.39, 1), true)

func _build_street_furniture() -> void:
    for z in range(-48, 56, 16):
        _lamp(Vector3(14.7, 0, float(z)))
        _lamp(Vector3(-14.7, 0, float(z + 8)))
    for z in [-42.0, -12.0, 18.0, 46.0]:
        _palm(Vector3(42.5, 0, z))

func _spawn_pedestrians() -> void:
    var positions := [Vector3(-12.0, 1.0, -38.0), Vector3(-12.5, 1.0, -8.0), Vector3(-11.0, 1.0, 25.0), Vector3(12.0, 1.0, -44.0), Vector3(12.5, 1.0, 5.0), Vector3(12.0, 1.0, 38.0), Vector3(40.5, 1.0, -18.0), Vector3(40.5, 1.0, 24.0), Vector3(-42.0, 1.0, 17.0), Vector3(-47.0, 1.0, 29.0), Vector3(39.0, 1.0, -30.0), Vector3(45.0, 1.0, -42.0)]
    for position in positions:
        var pedestrian := PedestrianAgent.new()
        pedestrian.global_position = position
        pedestrian.roam_radius = 7.0
        add_child(pedestrian)

func _spawn_traffic() -> void:
    var starts := [-48.0, -18.0, 15.0, 44.0]
    for i in range(starts.size()):
        var car := TrafficAgent.new()
        car.northbound = i % 2 == 0
        car.lane_x = 3.8 if car.northbound else -3.8
        car.global_position = Vector3(car.lane_x, 0.75, starts[i])
        car.cruise_speed_kph = 34.0 + float(i) * 4.0
        add_child(car)

func _district_label(parent_node: Node3D, text_value: String, position: Vector3) -> void:
    var label := Label3D.new()
    label.text = text_value
    label.position = position
    label.font_size = 34
    label.outline_size = 8
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    parent_node.add_child(label)

func _lamp(position: Vector3) -> void:
    _add_box("LampPost", position + Vector3(0, 2.5, 0), Vector3(0.16, 5.0, 0.16), Color(0.08, 0.08, 0.08, 1), false)
    _add_box("LampHead", position + Vector3(0, 5.0, -0.25), Vector3(0.7, 0.12, 0.35), Color(0.12, 0.12, 0.11, 1), false)

func _palm(position: Vector3) -> void:
    var trunk := MeshInstance3D.new()
    trunk.name = "PalmTrunk"
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = 0.16
    cylinder.bottom_radius = 0.28
    cylinder.height = 5.8
    trunk.mesh = cylinder
    trunk.position = position + Vector3(0, 2.9, 0)
    trunk.material_override = _material(Color(0.24, 0.15, 0.08, 1), 0.9)
    add_child(trunk)
    for i in range(5):
        var leaf := MeshInstance3D.new()
        var leaf_mesh := BoxMesh.new()
        leaf_mesh.size = Vector3(0.32, 0.07, 3.8)
        leaf.mesh = leaf_mesh
        leaf.position = position + Vector3(0, 5.9, 0)
        leaf.rotation_degrees = Vector3(-17, float(i) * 72.0, 0)
        leaf.material_override = _material(Color(0.08, 0.22, 0.11, 1), 0.82)
        add_child(leaf)

func _add_box(node_name: String, position: Vector3, size: Vector3, color: Color, collision: bool) -> Node3D:
    return _add_box_to(self, node_name, position, size, color, collision)

func _add_box_to(parent_node: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color, collision: bool) -> Node3D:
    var root: Node3D
    if collision:
        var body := StaticBody3D.new()
        root = body
        var collider := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collider.shape = shape
        body.add_child(collider)
    else:
        root = Node3D.new()
    root.name = node_name
    root.position = position
    parent_node.add_child(root)
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.material_override = _material(color, 0.78)
    root.add_child(mesh_instance)
    return root

func _material(color: Color, roughness: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    return material
