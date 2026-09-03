extends StaticBody3D
class_name AdrianValeNPC

const PlayerVisualScript = preload("res://scripts/player_visual.gd")

@export var interaction_radius := 4.0

var player: VantaPlayerController
var mission: TheIntroductionMission
var prompt: Label3D
var visual_root: Node3D
var _idle_time := 0.0

func _ready() -> void:
    add_to_group("adrian_vale")
    _build_visual()
    call_deferred("_resolve")

func _process(delta: float) -> void:
    _idle_time += delta
    _animate_idle()
    _resolve()
    if player == null or mission == null:
        prompt.visible = false
        return
    var can_talk := mission.active and mission.step == 1 and global_position.distance_to(player.global_position) <= interaction_radius
    prompt.visible = can_talk
    if can_talk:
        var toward := player.global_position - global_position
        toward.y = 0.0
        if toward.length_squared() > 0.1:
            rotation.y = lerp_angle(rotation.y, atan2(toward.x, toward.z), clampf(delta * 3.5, 0.0, 1.0))
    if can_talk and Input.is_action_just_pressed("interact"):
        mission.start_adrian_conversation()

func _build_visual() -> void:
    var collider := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.36
    shape.height = 1.82
    collider.shape = shape
    collider.position = Vector3(0.0, 0.82, 0.0)
    add_child(collider)

    visual_root = Node3D.new()
    visual_root.name = "AdrianVisual"
    visual_root.position.y = 0.16
    add_child(visual_root)

    var humanoid := PlayerVisualScript.new() as VantaPlayerVisual
    humanoid.configure_palette(
        Color(0.035, 0.04, 0.052, 1.0),
        Color(0.10, 0.105, 0.12, 1.0),
        Color(0.045, 0.05, 0.062, 1.0),
        Color(0.69, 0.53, 0.42, 1.0),
        Color(0.075, 0.055, 0.045, 1.0)
    )
    humanoid.scale = Vector3(1.02, 1.03, 1.02)
    visual_root.add_child(humanoid)

    _box_to(visual_root, "LeftLapel", Vector3(-0.12, 1.34, -0.19), Vector3(0.18, 0.34, 0.028), Color(0.075, 0.08, 0.095, 1.0), 0.58, Vector3(0.0, 0.0, deg_to_rad(-11.0)))
    _box_to(visual_root, "RightLapel", Vector3(0.12, 1.34, -0.19), Vector3(0.18, 0.34, 0.028), Color(0.075, 0.08, 0.095, 1.0), 0.58, Vector3(0.0, 0.0, deg_to_rad(11.0)))
    _box_to(visual_root, "DressShirt", Vector3(0.0, 1.31, -0.205), Vector3(0.16, 0.38, 0.025), Color(0.82, 0.82, 0.79, 1.0), 0.78)
    _box_to(visual_root, "Tie", Vector3(0.0, 1.22, -0.225), Vector3(0.055, 0.38, 0.018), Color(0.13, 0.035, 0.03, 1.0), 0.48)
    _box_to(visual_root, "PocketSquare", Vector3(0.19, 1.38, -0.205), Vector3(0.10, 0.055, 0.018), Color(0.74, 0.74, 0.70, 1.0), 0.72)
    _watch_to(visual_root, Vector3(-0.40, 0.75, -0.02))

    var nameplate := Label3D.new()
    nameplate.text = "ADRIAN VALE"
    nameplate.position = Vector3(0, 2.62, 0)
    nameplate.font_size = 25
    nameplate.outline_size = 7
    nameplate.modulate = Color(0.90, 0.90, 0.87, 0.90)
    nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(nameplate)

    prompt = Label3D.new()
    prompt.text = "E  TALK"
    prompt.position = Vector3(0, 2.30, 0)
    prompt.font_size = 21
    prompt.outline_size = 6
    prompt.modulate = Color(0.95, 0.93, 0.86, 1.0)
    prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    prompt.visible = false
    add_child(prompt)

func _animate_idle() -> void:
    if visual_root == null:
        return
    visual_root.position.y = 0.16 + sin(_idle_time * 1.55) * 0.006
    visual_root.rotation.z = sin(_idle_time * 0.62) * deg_to_rad(0.25)

func _watch_to(parent: Node3D, position_value: Vector3) -> void:
    var watch := MeshInstance3D.new()
    watch.name = "Watch"
    watch.position = position_value
    watch.rotation_degrees.z = 90.0
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.087
    mesh.bottom_radius = 0.087
    mesh.height = 0.035
    watch.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.42, 0.43, 0.44, 1.0)
    mat.metallic = 0.92
    mat.roughness = 0.16
    watch.material_override = mat
    parent.add_child(watch)

func _box_to(parent: Node3D, node_name: String, position_value: Vector3, size: Vector3, color: Color, roughness: float, rotation_value: Vector3 = Vector3.ZERO) -> void:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
    node.rotation = rotation_value
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = roughness
    node.material_override = mat
    parent.add_child(node)

func _resolve() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
    if mission == null or not is_instance_valid(mission):
        mission = get_tree().get_first_node_in_group("the_introduction_mission") as TheIntroductionMission
