extends Node3D
class_name VantaVehicleVisual

@export var police_variant := false
@export var body_color := Color(0.16, 0.17, 0.19, 1.0)

var body_material: StandardMaterial3D
var wheels: Array[Node3D] = []
var wheel_hubs: Array[Node3D] = []
var lightbar_red: MeshInstance3D
var lightbar_blue: MeshInstance3D
var motion_time := 0.0
var base_position := Vector3.ZERO
var base_rotation := Vector3.ZERO

func _ready() -> void:
    name = "VehicleVisual"
    base_position = position
    base_rotation = rotation
    _build_vehicle()

func _process(delta: float) -> void:
    motion_time += delta
    _animate_vehicle(delta)
    if police_variant:
        _animate_police_lights()

func set_body_color(color: Color) -> void:
    body_color = color
    if body_material != null:
        body_material.albedo_color = color

func _build_vehicle() -> void:
    body_material = _material(body_color, 0.22, 0.82)
    var trim := _material(Color(0.025, 0.028, 0.032, 1.0), 0.30, 0.38)
    var glass := _material(Color(0.035, 0.085, 0.11, 0.82), 0.12, 0.18)
    glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    var tire := _material(Color(0.012, 0.012, 0.014, 1.0), 0.96, 0.0)
    var rim := _material(Color(0.24, 0.25, 0.27, 1.0), 0.24, 0.9)

    _box("LowerBody", Vector3(0.0, 0.12, 0.0), Vector3(1.92, 0.44, 4.36), body_material)
    _box("Hood", Vector3(0.0, 0.48, -1.42), Vector3(1.78, 0.28, 1.38), body_material)
    _box("RearDeck", Vector3(0.0, 0.46, 1.55), Vector3(1.76, 0.25, 1.08), body_material)
    _box("Cabin", Vector3(0.0, 0.78, 0.15), Vector3(1.62, 0.76, 1.95), glass)
    _box("Roof", Vector3(0.0, 1.14, 0.18), Vector3(1.48, 0.10, 1.42), body_material)
    _box("FrontBumper", Vector3(0.0, 0.15, -2.22), Vector3(1.82, 0.22, 0.16), trim)
    _box("RearBumper", Vector3(0.0, 0.15, 2.22), Vector3(1.82, 0.22, 0.16), trim)
    _box("FrontGrille", Vector3(0.0, 0.36, -2.205), Vector3(0.96, 0.28, 0.05), trim)

    _light_panel("HeadlightL", Vector3(-0.58, 0.48, -2.205), Color(0.90, 0.96, 1.0, 1.0))
    _light_panel("HeadlightR", Vector3(0.58, 0.48, -2.205), Color(0.90, 0.96, 1.0, 1.0))
    _light_panel("TaillightL", Vector3(-0.58, 0.45, 2.205), Color(0.75, 0.03, 0.025, 1.0))
    _light_panel("TaillightR", Vector3(0.58, 0.45, 2.205), Color(0.75, 0.03, 0.025, 1.0))

    for x in [-0.92, 0.92]:
        for z in [-1.42, 1.42]:
            _wheel(Vector3(x, 0.02, z), tire, rim)

    if police_variant:
        _build_police_package()

func _wheel(position_value: Vector3, tire: StandardMaterial3D, rim: StandardMaterial3D) -> void:
    var wheel := MeshInstance3D.new()
    wheel.name = "Wheel"
    wheel.position = position_value
    wheel.rotation_degrees = Vector3(0.0, 0.0, 90.0)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.37
    mesh.bottom_radius = 0.37
    mesh.height = 0.22
    wheel.mesh = mesh
    wheel.material_override = tire
    add_child(wheel)
    wheels.append(wheel)

    var hub := MeshInstance3D.new()
    hub.name = "WheelHub"
    hub.position = position_value
    hub.rotation_degrees = Vector3(0.0, 0.0, 90.0)
    var hub_mesh := CylinderMesh.new()
    hub_mesh.top_radius = 0.19
    hub_mesh.bottom_radius = 0.19
    hub_mesh.height = 0.235
    hub.mesh = hub_mesh
    hub.material_override = rim
    add_child(hub)
    wheel_hubs.append(hub)

func _build_police_package() -> void:
    var bar_dark := _material(Color(0.025, 0.03, 0.04, 1.0), 0.30, 0.55)
    _box("LightBarBase", Vector3(0.0, 1.28, 0.16), Vector3(1.15, 0.08, 0.18), bar_dark)
    lightbar_red = _emissive_box("LightBarRed", Vector3(-0.29, 1.33, 0.16), Vector3(0.48, 0.08, 0.16), Color(0.85, 0.015, 0.02, 1.0))
    lightbar_blue = _emissive_box("LightBarBlue", Vector3(0.29, 1.33, 0.16), Vector3(0.48, 0.08, 0.16), Color(0.015, 0.20, 0.95, 1.0))

func _animate_vehicle(delta: float) -> void:
    var controller := get_parent()
    var speed_kph := 0.0
    var steering := 0.0
    var throttle := 0.0
    if controller != null:
        if controller.has_method("get_speed_kph"):
            speed_kph = float(controller.call("get_speed_kph"))
        var steering_value = controller.get("steering_input")
        if steering_value != null:
            steering = float(steering_value)
        var throttle_value = controller.get("throttle_input")
        if throttle_value != null:
            throttle = float(throttle_value)

    var wheel_speed := speed_kph * 0.045
    for wheel in wheels:
        if is_instance_valid(wheel):
            wheel.rotate_x(wheel_speed * delta)
    for hub in wheel_hubs:
        if is_instance_valid(hub):
            hub.rotate_x(wheel_speed * delta)

    var speed_amount := clampf(speed_kph / 180.0, 0.0, 1.0)
    var pitch_target := deg_to_rad(-1.5) * throttle + deg_to_rad(0.35) * speed_amount
    var roll_target := deg_to_rad(-2.3) * steering * speed_amount
    rotation.x = lerp_angle(rotation.x, base_rotation.x + pitch_target, clampf(delta * 4.5, 0.0, 1.0))
    rotation.z = lerp_angle(rotation.z, base_rotation.z + roll_target, clampf(delta * 5.0, 0.0, 1.0))
    var road_vibration := sin(motion_time * 18.0) * 0.006 * speed_amount
    position.y = lerpf(position.y, base_position.y + road_vibration, clampf(delta * 10.0, 0.0, 1.0))

func _animate_police_lights() -> void:
    if lightbar_red == null or lightbar_blue == null:
        return
    var phase := fmod(motion_time * 7.5, 2.0)
    var red_on := phase < 1.0
    lightbar_red.visible = red_on
    lightbar_blue.visible = not red_on

func _light_panel(node_name: String, position_value: Vector3, color: Color) -> void:
    _emissive_box(node_name, position_value, Vector3(0.38, 0.16, 0.045), color)

func _emissive_box(node_name: String, position_value: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var material := _material(color, 0.18, 0.15)
    material.emission_enabled = true
    material.emission = color
    material.emission_energy_multiplier = 2.0
    return _box(node_name, position_value, size, material)

func _box(node_name: String, position_value: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = material
    add_child(node)
    return node

func _material(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material
