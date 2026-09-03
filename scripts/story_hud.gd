extends CanvasLayer
class_name StoryHUD

var campaign: StoryCampaign
var title_label: Label
var objective_label: Label
var hint_label: Label

const GROUP_BY_ID := {
    "first_run": "first_run_mission",
    "no_questions": "no_questions_mission",
    "after_midnight": "after_midnight_mission",
    "wrong_place": "wrong_place_mission",
    "black_glass": "black_glass_mission",
    "lose_them": "lose_them_mission",
    "clean_slate": "clean_slate_mission",
    "the_introduction": "the_introduction_mission",
    "terms_conditions": "terms_conditions_mission",
    "overhead": "overhead_mission"
}

func _ready() -> void:
    add_to_group("story_hud")
    layer = 20
    _build_ui()
    call_deferred("_bind_campaign")

func _process(_delta: float) -> void:
    _refresh()

func _build_ui() -> void:
    title_label = Label.new()
    title_label.position = Vector2(54, 52)
    title_label.size = Vector2(660, 34)
    title_label.add_theme_font_size_override("font_size", 18)
    add_child(title_label)

    objective_label = Label.new()
    objective_label.position = Vector2(54, 82)
    objective_label.size = Vector2(760, 80)
    objective_label.add_theme_font_size_override("font_size", 25)
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(objective_label)

    hint_label = Label.new()
    hint_label.position = Vector2(54, 158)
    hint_label.size = Vector2(700, 32)
    hint_label.add_theme_font_size_override("font_size", 15)
    hint_label.text = "R  RESTART FROM CHECKPOINT"
    add_child(hint_label)

func _bind_campaign() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    _hide_legacy_huds()
    _refresh()

func _hide_legacy_huds() -> void:
    for node in get_tree().get_nodes_in_group("black_glass_mission"):
        var legacy := node.get_node_or_null("MissionHUD") as CanvasLayer
        if legacy != null:
            legacy.visible = false
    for group_name in GROUP_BY_ID.values():
        for mission in get_tree().get_nodes_in_group(group_name):
            for child in mission.get_children():
                if child is CanvasLayer and child.name == "MissionHUD":
                    child.visible = false

func _refresh() -> void:
    if campaign == null or not is_instance_valid(campaign):
        campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign == null:
        visible = false
        return
    visible = true
    var mission_id := campaign.get_current_id()
    title_label.text = "STORY  /  " + campaign.get_current_title()
    objective_label.text = _objective_for(mission_id)
    hint_label.visible = mission_id != "overhead" or objective_label.text != "ARC COMPLETE"

func _objective_for(mission_id: String) -> String:
    var group_name := str(GROUP_BY_ID.get(mission_id, ""))
    if group_name.is_empty():
        return ""
    var mission := get_tree().get_first_node_in_group(group_name)
    if mission == null:
        return "LOADING OBJECTIVE..."

    if mission_id == "black_glass":
        var index := int(mission.get("objective_index"))
        var objectives = mission.get("objectives")
        if objectives is Array and index >= 0 and index < objectives.size():
            return str(objectives[index])
    if mission_id == "lose_them":
        return str(mission.get("objective"))

    var step_value = mission.get("step")
    var objectives_value = mission.get("objectives")
    if step_value != null and objectives_value is Array:
        var step := int(step_value)
        if step >= 0 and step < objectives_value.size():
            return str(objectives_value[step])

    if mission.has_method("get_objective"):
        return str(mission.call("get_objective"))
    return "CONTINUE THE STORY"
