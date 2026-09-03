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
    if player == null or campaign == null or campaign.is_arc_complete():
        label.text = ""
        return

    var target_info := _get_target()
    if target_info.is_empty():
        label.text = ""
        return

    var target_position: Vector3 = target_info["position"]
    var target_name: String = target_info["name"]
    var distance := player.global_position.distance_to(target_position)
    var flat := target_position - player.global_position
    flat.y = 0.0
    var heading := atan2(flat.x, flat.z) - player.global_rotation.y
    var arrow := _arrow_for_angle(heading)
    label.text = "%s  %s  %dm" % [arrow, target_name, int(distance)]

func _get_target() -> Dictionary:
    var mission_id := campaign.get_current_id()
    match mission_id:
        "first_run":
            var first_run = get_tree().get_first_node_in_group("first_run_mission")
            if first_run == null:
                return {}
            var step := int(first_run.get("step"))
            if step == 1:
                return _target(first_run.get("mateo_garage_center"), "MATEO'S GARAGE")
            if step == 2:
                return _target(first_run.get("package_drop_center"), "PORT VANTA")
        "no_questions":
            var no_questions = get_tree().get_first_node_in_group("no_questions_mission")
            if no_questions == null:
                return {}
            var step := int(no_questions.get("step"))
            if step == 0:
                return _target(no_questions.get("garage_center"), "OCEAN DRIVE GARAGE")
            if step == 1:
                return _target(no_questions.get("workshop_center"), "PORT VANTA")
        "after_midnight":
            var after_midnight = get_tree().get_first_node_in_group("after_midnight_mission")
            if after_midnight == null:
                return {}
            var step := int(after_midnight.get("step"))
            if step == 1:
                return _target(after_midnight.get("club_position"), "OLD BAY CONTACT")
            if step == 3:
                return _target(after_midnight.get("marina_drop_position"), "MARINA DROP")
        "wrong_place":
            var wrong_place = get_tree().get_first_node_in_group("wrong_place_mission")
            if wrong_place == null:
                return {}
            var step := int(wrong_place.get("step"))
            if step == 0:
                return _target(wrong_place.get("meeting_position"), "MATEO'S CONTACT")
            if step == 3:
                return _target(wrong_place.get("escape_position"), "OLD BAY SAFE POINT")
        "black_glass":
            if mission != null and mission.objective_index == 1 and garage_marker != null:
                return _target(garage_marker.global_position, "OCEAN DRIVE GARAGE")
            if mission != null and mission.objective_index == 4 and workshop_marker != null:
                return _target(workshop_marker.global_position, "PORT VANTA WORKSHOP")
        "lose_them":
            if apartment_marker != null:
                return _target(apartment_marker.global_position, "JACE'S APARTMENT")
        "clean_slate":
            var clean_slate = get_tree().get_first_node_in_group("clean_slate_mission")
            if clean_slate == null:
                return {}
            var step := int(clean_slate.get("step"))
            if step <= 2:
                return _target(clean_slate.get("workshop_position"), "PORT VANTA WORKSHOP")
            if step == 3:
                return _target(clean_slate.get("exit_position"), "WORKSHOP EXIT")
        "the_introduction":
            var introduction = get_tree().get_first_node_in_group("the_introduction_mission")
            if introduction == null:
                return {}
            var step := int(introduction.get("step"))
            if step == 0:
                return _target(introduction.get("marina_position"), "MARINA DISTRICT")
            if step == 1:
                return _target(introduction.get("adrian_office_position"), "ADRIAN VALE")
        "terms_conditions":
            var terms = get_tree().get_first_node_in_group("terms_conditions_mission")
            if terms == null:
                return {}
            var step := int(terms.get("step"))
            if step == 0:
                return _target(terms.get("finance_tower_position"), "VALE LEGAL")
            if step == 1:
                var branch := str(terms.get("branch"))
                if branch == "trusted":
                    return _target(terms.get("private_handoff_position"), "ADRIAN PRIVATE HANDOFF")
                return _target(terms.get("contract_drop_position"), "SIGNED PACKAGE DROP")
        "overhead":
            var overhead = get_tree().get_first_node_in_group("overhead_mission")
            if overhead == null:
                return {}
            var step := int(overhead.get("step"))
            if step == 0:
                return _target(overhead.get("rooftop_position"), "ROOFTOP MEETING")
            if step == 3:
                return _target(overhead.get("exit_position"), "PORT VANTA EXIT")
    return {}

func _target(position_value, target_name: String) -> Dictionary:
    if position_value is Vector3:
        return {"position": position_value, "name": target_name}
    return {}

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
