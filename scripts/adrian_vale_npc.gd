extends StaticBody3D
class_name AdrianValeNPC

@export var interaction_radius := 4.0

var player: VantaPlayerController
var mission: TheIntroductionMission
var prompt: Label3D

func _ready() -> void:
    add_to_group("adrian_vale")
    _build_visual()
    call_deferred("_resolve")

func _process(_delta: float) -> void:
    _resolve()
    if player == null or mission == null:
        prompt.visible = false
        return
    var can_talk := mission.active and mission.step == 1 and global_position.distance_to(player.global_position) <= interaction_radius
    prompt.visible = can_talk
    if can_talk and Input.is_action_just_pressed("interact"):
        mission.start_adrian_conversation()

func _build_visual() -> void:
    var collider := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.42
    shape.height = 1.9
    collider.shape = shape
    collider.position = Vector3(0, 0.95, 0)
    add_child(collider)

    var body := MeshInstance3D.new()
    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.42
    body_mesh.height = 1.9
    body.mesh = body_mesh
    body.position = Vector3(0, 0.95, 0)
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.055, 0.06, 0.07, 1.0)
    material.roughness = 0.42
    body.material_override = material
    add_child(body)

    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.28
    head_mesh.height = 0.56
    head.mesh = head_mesh
    head.position = Vector3(0, 1.95, 0)
    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color(0.63, 0.48, 0.38, 1.0)
    skin.roughness = 0.72
    head.material_override = skin
    add_child(head)

    var nameplate := Label3D.new()
    nameplate.text = "ADRIAN VALE"
    nameplate.position = Vector3(0, 2.55, 0)
    nameplate.font_size = 28
    nameplate.outline_size = 7
    nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(nameplate)

    prompt = Label3D.new()
    prompt.text = "E  TALK"
    prompt.position = Vector3(0, 2.2, 0)
    prompt.font_size = 22
    prompt.outline_size = 6
    prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    prompt.visible = false
    add_child(prompt)

func _resolve() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
    if mission == null or not is_instance_valid(mission):
        mission = get_tree().get_first_node_in_group("the_introduction_mission") as TheIntroductionMission
