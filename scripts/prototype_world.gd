extends Node3D

const PedestrianAgent = preload("res://scripts/pedestrian_agent.gd")
const TrafficAgent = preload("res://scripts/traffic_agent.gd")
const StoryCampaignScript = preload("res://scripts/story_campaign.gd")
const LoseThemMissionScript = preload("res://scripts/lose_them_mission.gd")
const ApartmentStoryZoneScript = preload("res://scripts/apartment_story_zone.gd")
const VisualEnvironmentScript = preload("res://scripts/visual_environment.gd")

var asphalt := Color(0.045, 0.05, 0.055, 1.0)
var asphalt_light := Color(0.072, 0.076, 0.078, 1.0)
var concrete := Color(0.48, 0.47, 0.44, 1.0)
var concrete_light := Color(0.62, 0.61, 0.57, 1.0)
var sand := Color(0.72, 0.63, 0.47, 1.0)
var glass := Color(0.055, 0.13, 0.17, 0.82)
var water := Color(0.035, 0.22, 0.30, 0.86)
var lane_white := Color(0.88, 0.86, 0.78, 1.0)

func _ready() -> void:
    _ensure_visual_environment()
    _ensure_story_systems()
    _build_coastal_ground()
    _build_roads()
    _build_city_core()
    _build_old_bay()
    _build_marina_district()
    _build_port_vanta_workshop()
    _build_jace_apartment()
    _build_black_glass_garage()
    _build_beach_edge()
    _build_background_skyline()
    _build_street_furniture()
    _spawn_pedestrians()
    _spawn_traffic()

func _ensure_visual_environment() -> void:
    if get_tree().get_first_node_in_group("visual_environment") == null:
        var visual_environment := VisualEnvironmentScript.new()
        visual_environment.name = "VisualEnvironment"
        add_child(visual_environment)

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

func _build_coastal_ground() -> void:
    _add_box("CityBase", Vector3(-12.0, -0.16, 0.0), Vector3(112.0, 0.28, 124.0), Color(0.26, 0.27, 0.26, 1.0), false, 0.94)
    _add_box("Ocean", Vector3(70.0, -0.20, 0.0), Vector3(55.0, 0.20, 180.0), water, false, 0.08, 0.12, true)

func _build_roads() -> void:
    _road(Vector3(0.0, 0.015, 0.0), Vector3(18.0, 0.03, 124.0))
    _road(Vector3(0.0, 0.018, -26.0), Vector3(120.0, 0.035, 16.0))
    _road(Vector3(-38.0, 0.02, 12.0), Vector3(14.0, 0.04, 72.0))
    _road(Vector3(34.0, 0.02, -34.0), Vector3(12.0, 0.04, 45.0))

    _sidewalk(Vector3(-12.0, 0.12, 0.0), Vector3(6.0, 0.24, 124.0))
    _sidewalk(Vector3(12.0, 0.12, 0.0), Vector3(6.0, 0.24, 124.0))
    _sidewalk(Vector3(-38.0, 0.12, -25.5), Vector3(52.0, 0.24, 5.0))
    _sidewalk(Vector3(38.0, 0.12, -25.5), Vector3(52.0, 0.24, 5.0))

    for z in range(-56, 60, 10):
        _add_box("OceanDriveDash", Vector3(0.0, 0.045, float(z)), Vector3(0.16, 0.018, 4.2), lane_white, false, 0.55)
    for x in range(-52, 56, 10):
        _add_box("CrossStreetDash", Vector3(float(x), 0.047, -26.0), Vector3(4.2, 0.018, 0.16), lane_white, false, 0.55)

    _crosswalk(Vector3(0.0, 0.055, -18.5), false)
    _crosswalk(Vector3(0.0, 0.055, -33.5), false)
    _crosswalk(Vector3(-10.0, 0.055, -26.0), true)
    _crosswalk(Vector3(10.0, 0.055, -26.0), true)

    _curb_line(Vector3(-9.15, 0.17, 0.0), Vector3(0.25, 0.30, 124.0))
    _curb_line(Vector3(9.15, 0.17, 0.0), Vector3(0.25, 0.30, 124.0))

func _build_city_core() -> void:
    _modern_building("OceanResidences", Vector3(-27.5, 7.0, -43.0), Vector3(20.0, 14.0, 22.0), Color(0.48, 0.47, 0.43, 1.0), 5)
    _modern_building("VantaTowerWest", Vector3(-29.0, 12.0, -4.0), Vector3(22.0, 24.0, 28.0), Color(0.32, 0.34, 0.35, 1.0), 8)
    _modern_building("OceanHotel", Vector3(-27.0, 6.0, 32.0), Vector3(18.0, 12.0, 23.0), Color(0.57, 0.52, 0.45, 1.0), 4)
    _modern_building("MarinaLofts", Vector3(28.5, 8.0, -45.0), Vector3(18.0, 16.0, 18.0), Color(0.43, 0.46, 0.47, 1.0), 5)
    _modern_building("ValeCenter", Vector3(30.0, 14.0, -2.0), Vector3(21.0, 28.0, 27.0), Color(0.27, 0.31, 0.33, 1.0), 9)
    _modern_building("BeachHouseBlock", Vector3(28.0, 6.0, 36.0), Vector3(18.0, 12.0, 20.0), Color(0.62, 0.58, 0.50, 1.0), 4)

func _build_old_bay() -> void:
    var district := Node3D.new()
    district.name = "OldBay"
    district.add_to_group("old_bay")
    add_child(district)

    _warehouse(district, "WarehouseA", Vector3(-52.0, 3.8, -8.0), Vector3(11.0, 7.6, 20.0), Color(0.29, 0.26, 0.22, 1.0))
    _warehouse(district, "WarehouseB", Vector3(-52.0, 4.3, 20.0), Vector3(11.0, 8.6, 18.0), Color(0.33, 0.28, 0.23, 1.0))
    _warehouse(district, "ClubRear", Vector3(-29.5, 3.4, 17.0), Vector3(9.0, 6.8, 14.0), Color(0.12, 0.12, 0.13, 1.0))
    _sidewalk_to(district, Vector3(-48.5, 0.10, 30.0), Vector3(18.0, 0.20, 14.0), Color(0.34, 0.33, 0.30, 1.0))
    _add_box_to(district, "BrickWallA", Vector3(-44.5, 1.45, 7.0), Vector3(0.45, 2.9, 18.0), Color(0.34, 0.23, 0.19, 1.0), true, 0.92)
    _add_box_to(district, "BrickWallB", Vector3(-35.0, 1.45, 34.0), Vector3(15.0, 2.9, 0.45), Color(0.34, 0.23, 0.19, 1.0), true, 0.92)
    _add_box_to(district, "DumpsterA", Vector3(-38.0, 0.65, 23.0), Vector3(2.2, 1.3, 1.2), Color(0.075, 0.16, 0.11, 1.0), true, 0.75, 0.25)
    _add_box_to(district, "DumpsterB", Vector3(-47.0, 0.65, 31.0), Vector3(2.2, 1.3, 1.2), Color(0.075, 0.16, 0.11, 1.0), true, 0.75, 0.25)
    _add_box_to(district, "LoadingCrateA", Vector3(-34.0, 0.75, 26.0), Vector3(2.4, 1.5, 2.4), Color(0.38, 0.25, 0.12, 1.0), true, 0.88)
    _add_box_to(district, "LoadingCrateB", Vector3(-40.0, 0.75, 34.0), Vector3(3.0, 1.5, 1.8), Color(0.38, 0.25, 0.12, 1.0), true, 0.88)
    _district_label(district, "OLD BAY", Vector3(-43.0, 6.0, 12.0))

func _build_marina_district() -> void:
    var marina := Node3D.new()
    marina.name = "MarinaDistrict"
    marina.add_to_group("marina_district")
    add_child(marina)

    _sidewalk_to(marina, Vector3(45.0, 0.11, -30.0), Vector3(8.5, 0.22, 48.0), Color(0.58, 0.58, 0.55, 1.0))
    _sidewalk_to(marina, Vector3(39.0, 0.10, -12.0), Vector3(17.0, 0.20, 12.0), Color(0.64, 0.63, 0.59, 1.0))
    _modern_building_to(marina, "MarinaOffice", Vector3(26.5, 5.5, -53.0), Vector3(13.0, 11.0, 10.0), Color(0.38, 0.43, 0.45, 1.0), 4)
    _modern_building_to(marina, "MarinaRetail", Vector3(25.5, 3.2, -28.0), Vector3(11.0, 6.4, 9.0), Color(0.62, 0.58, 0.52, 1.0), 2)

    for z in [-47.0, -34.0, -21.0]:
        _add_box_to(marina, "Pier", Vector3(55.0, 0.04, z), Vector3(20.0, 0.18, 2.8), Color(0.42, 0.34, 0.24, 1.0), true, 0.82)
        _bollard(marina, Vector3(48.0, 0.0, z - 0.9))
        _bollard(marina, Vector3(48.0, 0.0, z + 0.9))

    _add_box_to(marina, "PlanterA", Vector3(42.0, 0.55, -18.0), Vector3(3.4, 1.1, 1.4), Color(0.32, 0.33, 0.29, 1.0), true, 0.86)
    _add_box_to(marina, "PlanterB", Vector3(35.0, 0.55, -17.0), Vector3(3.4, 1.1, 1.4), Color(0.32, 0.33, 0.29, 1.0), true, 0.86)
    _palm_to(marina, Vector3(43.0, 0.0, -12.0), 6.2)
    _palm_to(marina, Vector3(43.0, 0.0, -29.0), 6.6)
    _palm_to(marina, Vector3(43.0, 0.0, -45.0), 6.0)
    _district_label(marina, "MARINA DISTRICT", Vector3(38.0, 6.0, -36.0))

func _build_port_vanta_workshop() -> void:
    var workshop := Node3D.new()
    workshop.name = "PortVantaWorkshop"
    workshop.position = Vector3(-4.0, 0.0, 48.0)
    workshop.add_to_group("port_vanta_workshop")
    add_child(workshop)

    _add_box_to(workshop, "WorkshopFloor", Vector3.ZERO, Vector3(18.0, 0.20, 18.0), Color(0.20, 0.20, 0.20, 1.0), true, 0.88)
    _add_box_to(workshop, "WorkshopBack", Vector3(0.0, 3.2, 8.7), Vector3(18.0, 6.4, 0.45), Color(0.27, 0.27, 0.28, 1.0), true, 0.82)
    _add_box_to(workshop, "WorkshopLeft", Vector3(-8.75, 3.2, 2.5), Vector3(0.45, 6.4, 12.5), Color(0.27, 0.27, 0.28, 1.0), true, 0.82)
    _add_box_to(workshop, "WorkshopRight", Vector3(8.75, 3.2, 2.5), Vector3(0.45, 6.4, 12.5), Color(0.27, 0.27, 0.28, 1.0), true, 0.82)
    _add_box_to(workshop, "WorkshopRoof", Vector3(0.0, 6.35, 2.6), Vector3(18.0, 0.25, 12.6), Color(0.14, 0.14, 0.15, 1.0), true, 0.78)
    _add_box_to(workshop, "PaintBoothWall", Vector3(-4.6, 1.6, 3.0), Vector3(0.30, 3.2, 7.0), Color(0.66, 0.66, 0.63, 1.0), true, 0.65)
    _add_box_to(workshop, "ToolBench", Vector3(5.6, 0.65, 4.8), Vector3(4.2, 1.3, 1.0), Color(0.11, 0.11, 0.12, 1.0), true, 0.55, 0.35)
    _add_box_to(workshop, "ExitLane", Vector3(-14.0, 0.03, -7.0), Vector3(20.0, 0.06, 8.0), asphalt, false, 0.92)
    _work_light(workshop, Vector3(-5.0, 5.7, 2.0))
    _work_light(workshop, Vector3(4.5, 5.7, 2.0))
    _district_label(workshop, "PORT VANTA WORKSHOP", Vector3(0.0, 5.2, -7.6))

func _build_jace_apartment() -> void:
    var apartment := Node3D.new()
    apartment.name = "JaceApartment"
    apartment.position = Vector3(-49.0, 0.0, -47.0)
    apartment.add_to_group("jace_apartment")
    add_child(apartment)

    _add_box_to(apartment, "Floor", Vector3.ZERO, Vector3(12.0, 0.25, 11.0), Color(0.23, 0.21, 0.18, 1.0), true, 0.80)
    _add_box_to(apartment, "BackWall", Vector3(0.0, 2.6, 5.35), Vector3(12.0, 5.2, 0.30), Color(0.53, 0.50, 0.45, 1.0), true, 0.92)
    _add_box_to(apartment, "LeftWall", Vector3(-5.85, 2.6, 0.0), Vector3(0.30, 5.2, 11.0), Color(0.53, 0.50, 0.45, 1.0), true, 0.92)
    _add_box_to(apartment, "RightWall", Vector3(5.85, 2.6, 0.0), Vector3(0.30, 5.2, 11.0), Color(0.53, 0.50, 0.45, 1.0), true, 0.92)
    _add_box_to(apartment, "FrontWallL", Vector3(-4.1, 2.6, -5.35), Vector3(3.5, 5.2, 0.30), Color(0.53, 0.50, 0.45, 1.0), true, 0.92)
    _add_box_to(apartment, "FrontWallR", Vector3(4.1, 2.6, -5.35), Vector3(3.5, 5.2, 0.30), Color(0.53, 0.50, 0.45, 1.0), true, 0.92)
    _add_box_to(apartment, "Bed", Vector3(-3.2, 0.65, 2.6), Vector3(3.4, 1.0, 5.2), Color(0.18, 0.19, 0.21, 1.0), true, 0.70)
    _add_box_to(apartment, "Counter", Vector3(3.4, 0.85, 2.6), Vector3(3.0, 1.5, 1.2), Color(0.08, 0.08, 0.085, 1.0), true, 0.42, 0.25)
    _add_box_to(apartment, "Sofa", Vector3(2.4, 0.75, -1.2), Vector3(4.0, 1.2, 1.8), Color(0.24, 0.23, 0.22, 1.0), true, 0.82)
    _warm_light(apartment, Vector3(0.0, 4.6, 0.0), 3.4)

    var zone := ApartmentStoryZoneScript.new()
    zone.name = "StoryZone"
    zone.position = Vector3(0.0, 1.5, 0.0)
    var collider := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(10.0, 3.0, 9.0)
    collider.shape = shape
    zone.add_child(collider)
    apartment.add_child(zone)
    _district_label(apartment, "JACE'S APARTMENT", Vector3(0.0, 4.1, -5.6), 24)

func _build_black_glass_garage() -> void:
    var garage := Node3D.new()
    garage.name = "BlackGlassGarage"
    garage.position = Vector3(-22.0, 0.0, 43.0)
    garage.add_to_group("black_glass_garage")
    add_child(garage)
    _add_box_to(garage, "GarageFloor", Vector3.ZERO, Vector3(15.0, 0.30, 18.0), Color(0.17, 0.17, 0.18, 1.0), true, 0.86)
    _add_box_to(garage, "BackWall", Vector3(0.0, 3.0, 8.7), Vector3(15.0, 6.0, 0.50), Color(0.31, 0.31, 0.32, 1.0), true, 0.82)
    _add_box_to(garage, "LeftWall", Vector3(-7.25, 3.0, 0.0), Vector3(0.50, 6.0, 18.0), Color(0.31, 0.31, 0.32, 1.0), true, 0.82)
    _add_box_to(garage, "RightWall", Vector3(7.25, 3.0, 0.0), Vector3(0.50, 6.0, 18.0), Color(0.31, 0.31, 0.32, 1.0), true, 0.82)
    _add_box_to(garage, "Roof", Vector3(0.0, 6.0, 0.0), Vector3(15.0, 0.35, 18.0), Color(0.10, 0.10, 0.11, 1.0), true, 0.72)
    _work_light(garage, Vector3(-3.4, 5.5, 0.0))
    _work_light(garage, Vector3(3.4, 5.5, 0.0))
    _district_label(garage, "PRIVATE GARAGE", Vector3(0.0, 4.7, -9.3), 24)

func _build_beach_edge() -> void:
    _add_box("Beach", Vector3(52.0, -0.02, 22.0), Vector3(17.0, 0.10, 82.0), sand, false, 0.98)
    _sidewalk(Vector3(41.0, 0.10, 21.0), Vector3(3.2, 0.20, 82.0))
    for z in [-45.0, -22.0, 2.0, 26.0, 49.0]:
        _palm(Vector3(43.5, 0.0, z), 6.2 + fmod(absf(z), 1.4))
    for z in [-36.0, -4.0, 30.0]:
        _lifeguard_marker(Vector3(54.0, 0.0, z))

func _build_background_skyline() -> void:
    var positions: Array[Vector3] = [
        Vector3(-70.0, 14.0, -68.0), Vector3(-49.0, 20.0, -72.0), Vector3(-22.0, 17.0, -74.0),
        Vector3(4.0, 25.0, -76.0), Vector3(28.0, 19.0, -72.0), Vector3(54.0, 15.0, -68.0)
    ]
    var heights: Array[float] = [28.0, 40.0, 34.0, 50.0, 38.0, 30.0]
    for i in range(positions.size()):
        _background_tower(positions[i], heights[i], i)

func _build_street_furniture() -> void:
    for z in range(-52, 58, 14):
        _lamp(Vector3(13.8, 0.0, float(z)))
        _lamp(Vector3(-13.8, 0.0, float(z + 7)))
    _bench(Vector3(39.5, 0.0, -9.0), 0.0)
    _bench(Vector3(39.5, 0.0, 14.0), 0.0)
    _bench(Vector3(39.5, 0.0, 38.0), 0.0)

func _spawn_pedestrians() -> void:
    var positions: Array[Vector3] = [Vector3(-12.0, 1.0, -38.0), Vector3(-12.5, 1.0, -8.0), Vector3(-11.0, 1.0, 25.0), Vector3(12.0, 1.0, -44.0), Vector3(12.5, 1.0, 5.0), Vector3(12.0, 1.0, 38.0), Vector3(40.5, 1.0, -18.0), Vector3(40.5, 1.0, 24.0), Vector3(-42.0, 1.0, 17.0), Vector3(-47.0, 1.0, 29.0), Vector3(39.0, 1.0, -30.0), Vector3(45.0, 1.0, -42.0)]
    for position in positions:
        var pedestrian := PedestrianAgent.new()
        pedestrian.global_position = position
        pedestrian.roam_radius = 7.0
        add_child(pedestrian)

func _spawn_traffic() -> void:
    var starts: Array[float] = [-48.0, -18.0, 15.0, 44.0]
    for i in range(starts.size()):
        var car := TrafficAgent.new()
        car.northbound = i % 2 == 0
        car.lane_x = 3.8 if car.northbound else -3.8
        car.global_position = Vector3(car.lane_x, 0.75, starts[i])
        car.cruise_speed_kph = 34.0 + float(i) * 4.0
        add_child(car)

func _modern_building(node_name: String, position: Vector3, size: Vector3, color: Color, floors: int) -> void:
    _modern_building_to(self, node_name, position, size, color, floors)

func _modern_building_to(parent_node: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color, floors: int) -> void:
    var building := Node3D.new()
    building.name = node_name
    building.position = position
    parent_node.add_child(building)
    _add_box_to(building, "Structure", Vector3.ZERO, size, color, true, 0.72)
    _add_box_to(building, "Podium", Vector3(0.0, -size.y * 0.5 + 0.55, 0.0), Vector3(size.x + 0.8, 1.1, size.z + 0.8), color.lightened(0.08), false, 0.80)
    var front_z: float = -size.z * 0.5 - 0.018
    var floor_step: float = size.y / maxf(float(floors), 1.0)
    for floor_index in range(floors):
        var y: float = -size.y * 0.5 + floor_step * (float(floor_index) + 0.58)
        _add_box_to(building, "GlassBand", Vector3(0.0, y, front_z), Vector3(size.x * 0.78, floor_step * 0.45, 0.04), glass, false, 0.12, 0.18, true)
    _add_box_to(building, "RoofCap", Vector3(0.0, size.y * 0.5 + 0.22, 0.0), Vector3(size.x * 0.72, 0.44, size.z * 0.72), Color(0.17, 0.18, 0.19, 1.0), false, 0.60, 0.25)

func _warehouse(parent_node: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color) -> void:
    var warehouse := Node3D.new()
    warehouse.name = node_name
    warehouse.position = position
    parent_node.add_child(warehouse)
    _add_box_to(warehouse, "Shell", Vector3.ZERO, size, color, true, 0.92)
    _add_box_to(warehouse, "Roof", Vector3(0.0, size.y * 0.5 + 0.18, 0.0), Vector3(size.x + 0.6, 0.36, size.z + 0.6), Color(0.13, 0.13, 0.14, 1.0), false, 0.76, 0.20)
    _add_box_to(warehouse, "LoadingDoor", Vector3(0.0, -size.y * 0.18, -size.z * 0.5 - 0.03), Vector3(size.x * 0.56, size.y * 0.48, 0.06), Color(0.16, 0.16, 0.17, 1.0), false, 0.68, 0.15)

func _road(position: Vector3, size: Vector3) -> void:
    _add_box("Road", position, size, asphalt, false, 0.93)

func _sidewalk(position: Vector3, size: Vector3) -> void:
    _sidewalk_to(self, position, size, concrete)

func _sidewalk_to(parent_node: Node3D, position: Vector3, size: Vector3, color: Color) -> void:
    _add_box_to(parent_node, "Sidewalk", position, size, color, true, 0.91)

func _crosswalk(position: Vector3, rotate: bool) -> void:
    for i in range(-4, 5):
        var offset := float(i) * 1.05
        var stripe_position := position + (Vector3(offset, 0.0, 0.0) if not rotate else Vector3(0.0, 0.0, offset))
        var stripe_size := Vector3(0.58, 0.016, 4.2) if not rotate else Vector3(4.2, 0.016, 0.58)
        _add_box("CrosswalkStripe", stripe_position, stripe_size, Color(0.88, 0.87, 0.82, 1.0), false, 0.62)

func _curb_line(position: Vector3, size: Vector3) -> void:
    _add_box("Curb", position, size, Color(0.58, 0.57, 0.54, 1.0), true, 0.90)

func _lamp(position: Vector3) -> void:
    _add_box("LampPost", position + Vector3(0.0, 2.6, 0.0), Vector3(0.12, 5.2, 0.12), Color(0.055, 0.06, 0.065, 1.0), false, 0.38, 0.55)
    _add_box("LampArm", position + Vector3(0.0, 5.16, -0.35), Vector3(0.12, 0.12, 0.82), Color(0.055, 0.06, 0.065, 1.0), false, 0.38, 0.55)
    var light := OmniLight3D.new()
    light.position = position + Vector3(0.0, 5.0, -0.72)
    light.light_color = Color(1.0, 0.78, 0.52, 1.0)
    light.light_energy = 0.42
    light.omni_range = 8.0
    add_child(light)

func _palm(position: Vector3, height: float) -> void:
    _palm_to(self, position, height)

func _palm_to(parent_node: Node3D, position: Vector3, height: float) -> void:
    var trunk := MeshInstance3D.new()
    trunk.name = "PalmTrunk"
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = 0.13
    cylinder.bottom_radius = 0.25
    cylinder.height = height
    trunk.mesh = cylinder
    trunk.position = position + Vector3(0.0, height * 0.5, 0.0)
    trunk.rotation_degrees.z = -3.5
    trunk.material_override = _material(Color(0.28, 0.18, 0.09, 1.0), 0.92)
    parent_node.add_child(trunk)
    for i in range(7):
        var leaf := MeshInstance3D.new()
        var leaf_mesh := BoxMesh.new()
        leaf_mesh.size = Vector3(0.23, 0.055, 3.6)
        leaf.mesh = leaf_mesh
        leaf.position = position + Vector3(0.0, height + 0.18, 0.0)
        leaf.rotation_degrees = Vector3(-17.0 - float(i % 2) * 8.0, float(i) * 51.4, 0.0)
        leaf.material_override = _material(Color(0.055, 0.22, 0.10, 1.0), 0.84)
        parent_node.add_child(leaf)

func _bench(position: Vector3, rotation_y: float) -> void:
    var bench := Node3D.new()
    bench.position = position
    bench.rotation.y = rotation_y
    add_child(bench)
    _add_box_to(bench, "Seat", Vector3(0.0, 0.48, 0.0), Vector3(1.8, 0.14, 0.52), Color(0.27, 0.18, 0.10, 1.0), false, 0.84)
    _add_box_to(bench, "Back", Vector3(0.0, 0.86, 0.22), Vector3(1.8, 0.62, 0.12), Color(0.27, 0.18, 0.10, 1.0), false, 0.84)

func _bollard(parent_node: Node3D, position: Vector3) -> void:
    var bollard := MeshInstance3D.new()
    bollard.position = position + Vector3(0.0, 0.42, 0.0)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.13
    mesh.bottom_radius = 0.16
    mesh.height = 0.84
    bollard.mesh = mesh
    bollard.material_override = _material(Color(0.10, 0.11, 0.12, 1.0), 0.46, 0.60)
    parent_node.add_child(bollard)

func _work_light(parent_node: Node3D, position: Vector3) -> void:
    var light := OmniLight3D.new()
    light.position = position
    light.light_color = Color(0.90, 0.95, 1.0, 1.0)
    light.light_energy = 1.4
    light.omni_range = 9.0
    parent_node.add_child(light)

func _warm_light(parent_node: Node3D, position: Vector3, energy: float) -> void:
    var light := OmniLight3D.new()
    light.position = position
    light.light_color = Color(1.0, 0.73, 0.48, 1.0)
    light.light_energy = energy
    light.omni_range = 9.0
    parent_node.add_child(light)

func _lifeguard_marker(position: Vector3) -> void:
    _add_box("LifeguardDeck", position + Vector3(0.0, 1.2, 0.0), Vector3(2.1, 0.18, 2.1), Color(0.70, 0.69, 0.62, 1.0), false, 0.82)
    _add_box("LifeguardCab", position + Vector3(0.0, 2.0, 0.0), Vector3(1.7, 1.3, 1.7), Color(0.82, 0.40, 0.23, 1.0), false, 0.74)

func _background_tower(position: Vector3, height: float, index: int) -> void:
    var width: float = 12.0 + float(index % 3) * 4.0
    var depth: float = 12.0 + float((index + 1) % 3) * 3.0
    _add_box("SkylineTower", position, Vector3(width, height, depth), Color(0.16, 0.19, 0.21, 1.0), false, 0.76, 0.15)
    for y in range(5, int(height) - 2, 5):
        _add_box("SkylineGlass", Vector3(position.x, position.y - height * 0.5 + float(y), position.z - depth * 0.5 - 0.02), Vector3(width * 0.65, 1.5, 0.04), Color(0.08, 0.18, 0.23, 0.85), false, 0.12, 0.10, true)

func _district_label(parent_node: Node3D, text_value: String, position: Vector3, font_size: int = 28) -> void:
    var label := Label3D.new()
    label.text = text_value
    label.position = position
    label.font_size = font_size
    label.outline_size = 6
    label.modulate = Color(0.92, 0.92, 0.88, 0.92)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    parent_node.add_child(label)

func _add_box(node_name: String, position: Vector3, size: Vector3, color: Color, collision: bool, roughness: float = 0.78, metallic: float = 0.0, transparent: bool = false) -> Node3D:
    return _add_box_to(self, node_name, position, size, color, collision, roughness, metallic, transparent)

func _add_box_to(parent_node: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color, collision: bool, roughness: float = 0.78, metallic: float = 0.0, transparent: bool = false) -> Node3D:
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
