extends CanvasLayer
class_name StoryNavigation

@onready var label: Label = $NavLabel

var mission: BlackGlassMission
var player: Node3D
var garage_marker: Node3D
var workshop_marker: Node3D

func _ready() -> void:
    mission = get_tree().get_first_node_in_group("black_glass_mission") as BlackGlassMission
    player = get_tree().get_first_node_in_group("player") as Node3D
    garage_marker = get_tree().get_first_node_in_group("black_glass_garage") as Node3D
    workshop_marker = get_tree().get_first_node_in_group("workshop_delivery") as Node3D

func _process(_delta: float) -> void:
    if mission == null or player == null:
        label.text = ""
        return

    var target: Node3D = null
    var target_name := ""
    if mission.objective_index == 1:
        target = garage_marker
        target_name = "OCEAN DRIVE GARAGE"
    elif mission.objective_index == 4:
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
