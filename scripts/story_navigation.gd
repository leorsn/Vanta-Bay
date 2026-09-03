extends CanvasLayer
class_name StoryNavigation

@onready var label: Label = $NavLabel

var mission: BlackGlassMission
var campaign: StoryCampaign
var player: Node3D
var garage_marker: Node3D
var workshop_marker: Node3D
var apartment_marker: Node3D

func _ready() -> void:
    _resolve_nodes()

func _process(_delta: float) -> void:
    _resolve_nodes()
    if player == null:
        label.text = ""
        return

    var target: Node3D = null
    var target_name := ""
    if campaign != null and campaign.get_current_id() == "lose_them":
        target = apartment_marker
        target_name = "JACE'S APARTMENT"
    elif mission != null and mission.objective_index == 1:
        target = garage_marker
        target_name = "OCEAN DRIVE GARAGE"
    elif mission != null and mission.objective_index == 4:
        target = workshop_marker
        target_name = "PORT VANTA WORKSHOP"

    if target == null or not is_instance_valid(target):
        label.text = ""
        return

    var distance := player.global_position.distance_to(target.global_position)
    var flat := target.global_position - player.global_position
    flat.y = 0.0
    var heading := atan2(flat.x, flat.z) - player.global_rotation.y
    var arrow := _arrow_for_angle(heading)
    label.text = "%s  %s  %dm" % [arrow, target_name, int(distance)]

func _resolve_nodes() -> void:
    if mission == null or not is_instance_valid(mission):
        mission = get_tree().get_first_node_in_group("black_glass_mission") as BlackGlassMission
    if campaign == null or not is_instance_valid(campaign):
        campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node3D
    if garage_marker == null or not is_instance_valid(garage_marker):
        garage_marker = get_tree().get_first_node_in_group("black_glass_garage") as Node3D
    if workshop_marker == null or not is_instance_valid(workshop_marker):
        workshop_marker = get_tree().get_first_node_in_group("workshop_delivery") as Node3D
    if apartment_marker == null or not is_instance_valid(apartment_marker):
        apartment_marker = get_tree().get_first_node_in_group("jace_apartment") as Node3D

func _arrow_for_angle(angle: float) -> String:
    angle = wrapf(angle, -PI, PI)
    if abs(angle) < PI / 8.0:
        return "↑"
    if angle > 0.0 and angle < 3.0 * PI / 8.0:
        return "↗"
    if angle >= 3.0 * PI / 8.0 and angle < 5.0 * PI / 8.0:
        return "→"
    if angle >= 5.0 * PI / 8.0:
        return "↘"
    if angle < 0.0 and angle > -3.0 * PI / 8.0:
        return "↖"
    if angle <= -3.0 * PI / 8.0 and angle > -5.0 * PI / 8.0:
        return "←"
    return "↙"
