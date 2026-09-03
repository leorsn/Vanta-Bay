extends Node
class_name MissionCheckpointManager

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

const STEP_FLAG_BY_ID := {
    "first_run": "first_run_step",
    "no_questions": "no_questions_step",
    "after_midnight": "after_midnight_step",
    "wrong_place": "wrong_place_step",
    "clean_slate": "clean_slate_step",
    "the_introduction": "the_introduction_step",
    "terms_conditions": "terms_conditions_step",
    "overhead": "overhead_step"
}

var campaign: StoryCampaign
var restarting := false

func _ready() -> void:
    add_to_group("mission_checkpoint_manager")
    call_deferred("_resolve")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("restart_mission") and not restarting:
        restart_from_checkpoint()

func restart_from_checkpoint() -> void:
    _resolve()
    if campaign == null:
        return
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves == null:
        return

    restarting = true
    var mission_id := campaign.get_current_id()
    var wanted := get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    if wanted != null:
        wanted.stars = 0
        wanted.target = null
        wanted.last_known_position = Vector3.ZERO
        wanted.state = "NONE"
        wanted.state_changed.emit("NONE", 0)

    var loaded := saves.load_story(saves.active_slot)
    if not loaded:
        restarting = false
        return

    var mission := get_tree().get_first_node_in_group(str(GROUP_BY_ID.get(mission_id, "")))
    if mission != null and mission_id != "black_glass" and mission_id != "lose_them":
        var flag_name := str(STEP_FLAG_BY_ID.get(mission_id, ""))
        if not flag_name.is_empty():
            var restored_step := int(saves.get_flag(flag_name, mission.get("step")))
            if mission.has_method("restore_step"):
                mission.call("restore_step", restored_step)
            else:
                mission.set("step", restored_step)
                if _has_property(mission, "completed"):
                    mission.set("completed", false)
                if _has_property(mission, "active"):
                    mission.set("active", true)

    var player := get_tree().get_first_node_in_group("player") as Node3D
    if player != null and player.global_position.y < -10.0:
        player.global_position = Vector3(-49.0, 1.1, -47.0)

    await get_tree().process_frame
    restarting = false

func _has_property(object: Object, property_name: String) -> bool:
    for property in object.get_property_list():
        if str(property.get("name")) == property_name:
            return true
    return false

func _resolve() -> void:
    if campaign == null or not is_instance_valid(campaign):
        campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
