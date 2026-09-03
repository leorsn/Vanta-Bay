extends Node
class_name VantaVisualEnvironment

const SurfaceStyleScript = preload("res://scripts/surface_style_controller.gd")

var world_environment: WorldEnvironment
var environment: Environment
var sky: Sky
var sky_material: ProceduralSkyMaterial
var sun: DirectionalLight3D

func _ready() -> void:
    add_to_group("visual_environment")
    call_deferred("_build_environment")

func _build_environment() -> void:
    var scene := get_tree().current_scene
    if scene == null:
        return

    world_environment = scene.get_node_or_null("WorldEnvironment") as WorldEnvironment
    if world_environment == null:
        world_environment = WorldEnvironment.new()
        world_environment.name = "WorldEnvironment"
        scene.add_child(world_environment)

    environment = Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    environment.ambient_light_energy = 0.72
    environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
    environment.tonemap_mode = Environment.TONE_MAPPER_ACES
    environment.tonemap_exposure = 1.06
    environment.adjustment_enabled = true
    environment.adjustment_brightness = 1.01
    environment.adjustment_contrast = 1.08
    environment.adjustment_saturation = 0.94
    environment.fog_enabled = true
    environment.fog_light_color = Color(0.72, 0.79, 0.82, 1.0)
    environment.fog_light_energy = 0.35
    environment.fog_density = 0.0045
    environment.fog_sky_affect = 0.22

    sky_material = ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color(0.12, 0.29, 0.47, 1.0)
    sky_material.sky_horizon_color = Color(0.74, 0.82, 0.85, 1.0)
    sky_material.ground_bottom_color = Color(0.055, 0.07, 0.075, 1.0)
    sky_material.ground_horizon_color = Color(0.46, 0.50, 0.48, 1.0)
    sky_material.sun_angle_max = 18.0
    sky_material.sun_curve = 0.08

    sky = Sky.new()
    sky.sky_material = sky_material
    environment.sky = sky
    world_environment.environment = environment

    sun = scene.get_node_or_null("Sun") as DirectionalLight3D
    if sun == null:
        sun = DirectionalLight3D.new()
        sun.name = "Sun"
        scene.add_child(sun)
    sun.rotation_degrees = Vector3(-38.0, -28.0, 0.0)
    sun.light_color = Color(1.0, 0.92, 0.82, 1.0)
    sun.light_energy = 1.75
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 140.0

    var fill := DirectionalLight3D.new()
    fill.name = "SkyFill"
    fill.rotation_degrees = Vector3(-22.0, 142.0, 0.0)
    fill.light_color = Color(0.48, 0.62, 0.78, 1.0)
    fill.light_energy = 0.20
    fill.shadow_enabled = false
    scene.add_child(fill)

    if get_tree().get_first_node_in_group("surface_style_controller") == null:
        var surfaces := SurfaceStyleScript.new()
        surfaces.name = "SurfaceStyleController"
        surfaces.add_to_group("surface_style_controller")
        scene.add_child(surfaces)
