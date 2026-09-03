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

func _ready() -> void:
    add_to_group("mission_checkpoint_manager")
    call_deferred("_resolve")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("restart_mission"):
        restart_from_checkpoint()

func restart_from_checkpoint() -> void:
    _resolve()
    if campaign == null:
        return
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves == null:
        return

    var mission_id := campaign.get_current_id()
    var wanted := get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    if wanted != null and wanted.state != "NONE":
        wanted.clear_wanted()

    saves.load_story(saves.active_slot)

    var mission := get_tree().get_first_node_in_group(str(GROUP_BY_ID.get(mission_id, "")))
    if mission != null:
        if mission_id == "black_glass":
            mission.call("restore_objective", int(saves.get_flag("black_glass_checkpoint", mission.get("objective_index"))))
        else:
            var flag_name := str(STEP_FLAG_BY_ID.get(mission_id, ""))
            if not flag_name.is_empty() and mission.has_method("restore_step"):
                mission.call("restore_step", int(saves.get_flag(flag_name, mission.get("step"))))

    var player := get_tree().get_first_node_in_group("player") as Node3D
    if player != null and player.global_position.y < -10.0:
        player.global_position = Vector3(-49.0, 1.1, -47.0)

func _resolve() -> void:
    if campaign == null or not is_instance_valid(campaign):
        campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
