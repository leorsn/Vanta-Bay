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
    var positions := [Vector3(-12.0, 1.0, -38.0), Vector3(-12.5, 1.0, -8.0), Vector3(-11.0, 1.0, 25.0), Vector3(12.0, 1.0, -44.0), Vector3(12.5, 1.0, 5.0), Vector3(12.0, 1.0, 38.0), Vector3(40.5, 1.0, -18.0), Vector3(40.5, 1.0, 24.0)]
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
