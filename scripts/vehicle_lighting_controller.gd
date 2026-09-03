extends Node
class_name VantaVehicleLightingController

var scan_timer := 0.0

func _ready() -> void:
    add_to_group("vehicle_lighting_controller")
    call_deferred("_scan_vehicles")

func _process(delta: float) -> void:
    scan_timer -= delta
    if scan_timer <= 0.0:
        scan_timer = 1.0
        _scan_vehicles()
    _update_light_energy()

func _scan_vehicles() -> void:
    for vehicle in get_tree().get_nodes_in_group("vehicles"):
        if vehicle is Node3D:
            _ensure_vehicle_lights(vehicle as Node3D)
    for police in get_tree().get_nodes_in_group("police"):
        if police is Node3D:
            _ensure_vehicle_lights(police as Node3D)

func _ensure_vehicle_lights(vehicle: Node3D) -> void:
    if vehicle.has_node("RuntimeVehicleLights"):
        return
    var rig := Node3D.new()
    rig.name = "RuntimeVehicleLights"
    vehicle.add_child(rig)
    var is_police := vehicle.is_in_group("police")
    _headlight(rig, Vector3(-0.55,0.52,-2.0), -0.08)
    _headlight(rig, Vector3(0.55,0.52,-2.0), 0.08)
    if is_police:
        var red := OmniLight3D.new()
        red.name = "PoliceRedSpill"
        red.position = Vector3(-0.32,1.35,0.1)
        red.light_color = Color(0.95,0.03,0.04,1)
        red.light_energy = 0.0
        red.omni_range = 6.0
        rig.add_child(red)
        var blue := OmniLight3D.new()
        blue.name = "PoliceBlueSpill"
        blue.position = Vector3(0.32,1.35,0.1)
        blue.light_color = Color(0.03,0.22,1.0,1)
        blue.light_energy = 0.0
        blue.omni_range = 6.0
        rig.add_child(blue)

func _headlight(parent: Node3D, pos: Vector3, yaw: float) -> void:
    var light := SpotLight3D.new()
    light.name = "Headlight"
    light.position = pos
    light.rotation = Vector3(deg_to_rad(-4.0), yaw, 0.0)
    light.light_color = Color(0.88,0.94,1.0,1)
    light.light_energy = 0.0
    light.spot_range = 26.0
    light.spot_angle = 28.0
    parent.add_child(light)

func _update_light_energy() -> void:
    var time_manager := get_tree().get_first_node_in_group("world_time_manager") as WorldTimeManager
    var hour := 20.0
    if time_manager != null:
        hour = time_manager.time_hours
    var night := hour >= 18.5 or hour < 7.0
    var headlight_energy := 2.2 if night else 0.0
    var police_phase := fmod(Time.get_ticks_msec() / 1000.0 * 7.0, 2.0)
    for vehicle in get_tree().get_nodes_in_group("vehicles"):
        if vehicle is Node3D:
            _apply_vehicle_lights(vehicle as Node3D, headlight_energy, police_phase)
    for police in get_tree().get_nodes_in_group("police"):
        if police is Node3D:
            _apply_vehicle_lights(police as Node3D, headlight_energy, police_phase)

func _apply_vehicle_lights(vehicle: Node3D, headlight_energy: float, police_phase: float) -> void:
    var rig := vehicle.get_node_or_null("RuntimeVehicleLights") as Node3D
    if rig == null:
        return
    for child in rig.get_children():
        if child is SpotLight3D:
            (child as SpotLight3D).light_energy = headlight_energy
    var red := rig.get_node_or_null("PoliceRedSpill") as OmniLight3D
    var blue := rig.get_node_or_null("PoliceBlueSpill") as OmniLight3D
    if red != null and blue != null:
        var wanted := get_tree().get_first_node_in_group("wanted_manager") as WantedManager
        var active := wanted != null and wanted.stars > 0
        red.light_energy = 1.8 if active and police_phase < 1.0 else 0.0
        blue.light_energy = 1.8 if active and police_phase >= 1.0 else 0.0
