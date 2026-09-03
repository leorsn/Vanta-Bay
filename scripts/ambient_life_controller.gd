extends Node
class_name VantaAmbientLifeController

const VehicleVisualScript = preload("res://scripts/vehicle_visual.gd")
const PedestrianAgentScript = preload("res://scripts/pedestrian_agent.gd")

var _root: Node3D
var _built := false

func _ready() -> void:
    add_to_group("ambient_life_controller")
    call_deferred("_build")

func _build() -> void:
    if _built:
        return
    _root = get_tree().current_scene as Node3D
    if _root == null:
        return
    _built = true
    _build_parked_cars()
    _build_social_clusters()
    _build_road_microdetail()
    _build_shop_window_depth()

func _build_parked_cars() -> void:
    var placements: Array[Dictionary] = [
        {"p": Vector3(-15.5, 0.48, -45.0), "r": PI, "s": Vector3(0.92, 0.92, 1.03), "c": Color(0.08, 0.09, 0.10, 1.0)},
        {"p": Vector3(-15.5, 0.48, -36.0), "r": PI, "s": Vector3(1.00, 1.06, 1.10), "c": Color(0.38, 0.39, 0.40, 1.0)},
        {"p": Vector3(15.5, 0.48, 14.0), "r": 0.0, "s": Vector3(0.96, 0.92, 0.94), "c": Color(0.13, 0.21, 0.28, 1.0)},
        {"p": Vector3(15.5, 0.48, 24.0), "r": 0.0, "s": Vector3(1.03, 0.98, 1.12), "c": Color(0.43, 0.42, 0.39, 1.0)},
        {"p": Vector3(-31.5, 0.48, 39.0), "r": PI * 0.5, "s": Vector3(0.94, 0.90, 0.90), "c": Color(0.29, 0.055, 0.045, 1.0)},
        {"p": Vector3(31.0, 0.48, -20.0), "r": -PI * 0.5, "s": Vector3(1.05, 1.10, 1.08), "c": Color(0.055, 0.06, 0.065, 1.0)}
    ]
    for data in placements:
        var anchor := Node3D.new()
        anchor.name = "ParkedVehicle"
        anchor.position = data["p"] as Vector3
        anchor.rotation.y = float(data["r"])
        _root.add_child(anchor)
        var visual := VehicleVisualScript.new() as VantaVehicleVisual
        visual.body_color = data["c"] as Color
        visual.scale = data["s"] as Vector3
        visual.set_process(false)
        anchor.add_child(visual)

func _build_social_clusters() -> void:
    var clusters: Array[Vector3] = [
        Vector3(38.0, 1.0, -10.0),
        Vector3(41.0, 1.0, -31.0),
        Vector3(-40.0, 1.0, 19.0),
        Vector3(12.0, 1.0, 33.0)
    ]
    for center in clusters:
        for i in range(3):
            var pedestrian := PedestrianAgentScript.new() as VantaPedestrianAgent
            pedestrian.global_position = center + Vector3(float(i - 1) * 1.1, 0.0, float((i + 1) % 2) * 0.8)
            pedestrian.roam_radius = 2.8
            pedestrian.pause_min = 2.0
            pedestrian.pause_max = 5.0
            _root.add_child(pedestrian)

func _build_road_microdetail() -> void:
    for z: float in [-50.0, -28.0, -6.0, 17.0, 41.0]:
        _box("AsphaltPatch", Vector3(-3.1, 0.052, z), Vector3(2.0, 0.012, 3.6), Color(0.028, 0.031, 0.034, 1.0), 0.98)
        _box("RoadStud", Vector3(0.45, 0.07, z + 2.0), Vector3(0.10, 0.045, 0.18), Color(0.72, 0.68, 0.50, 1.0), 0.35, 0.18)
    for x: float in [-42.0, -20.0, 18.0, 43.0]:
        _box("DrainGrate", Vector3(x, 0.066, -31.9), Vector3(1.2, 0.025, 0.38), Color(0.08, 0.085, 0.09, 1.0), 0.55, 0.65)
    _box("OilStain", Vector3(-7.0, 0.061, 43.0), Vector3(2.7, 0.012, 1.5), Color(0.025, 0.028, 0.028, 0.62), 0.25, 0.04, true)
    _box("OilStain", Vector3(-38.0, 0.061, 25.0), Vector3(1.8, 0.012, 2.1), Color(0.025, 0.028, 0.028, 0.55), 0.25, 0.04, true)

func _build_shop_window_depth() -> void:
    _shop_interior(Vector3(24.9, 1.45, -32.25), Vector3(7.4, 2.25, 2.4), Color(0.56, 0.48, 0.37, 1.0))
    _shop_interior(Vector3(-27.0, 1.65, 20.05), Vector3(9.4, 2.40, 2.5), Color(0.31, 0.26, 0.22, 1.0))

func _shop_interior(position: Vector3, size: Vector3, warm_color: Color) -> void:
    _box("ShopInteriorVoid", position + Vector3(0.0, 0.0, 0.70), size, Color(0.045, 0.045, 0.048, 1.0), 0.88)
    _box("ShopShelf", position + Vector3(-size.x * 0.28, -0.45, -0.1), Vector3(1.2, 1.0, 0.45), Color(0.22, 0.18, 0.14, 1.0), 0.72)
    _box("ShopShelf", position + Vector3(size.x * 0.24, -0.45, 0.15), Vector3(1.0, 0.9, 0.5), Color(0.18, 0.18, 0.17, 1.0), 0.72)
    var light := OmniLight3D.new()
    light.name = "ShopWarmLight"
    light.position = position + Vector3(0.0, 0.65, 0.45)
    light.light_color = warm_color
    light.light_energy = 0.65
    light.omni_range = 5.0
    _root.add_child(light)

func _box(node_name: String, position: Vector3, size: Vector3, color: Color, roughness: float, metallic: float = 0.0, transparent: bool = false) -> Node3D:
    var root := Node3D.new()
    root.name = node_name
    root.position = position
    _root.add_child(root)
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    if transparent:
        material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mesh_instance.material_override = material
    root.add_child(mesh_instance)
    return root
