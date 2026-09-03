extends Node
class_name FirstRunMission

signal objective_changed(text: String)
signal mission_completed()

@export var reward_cash := 450
@export var reward_rep := 3

var active := false
var completed := false
var step := 0
var objectives := [
    "LEAVE JACE'S APARTMENT",
    "GET TO MATEO'S GARAGE",
    "DELIVER THE PACKAGE",
    "MISSION COMPLETE"
]

func _ready() -> void:
    add_to_group("first_run_mission")
    call_deferred("_bind_campaign")

func _bind_campaign() -> void:
    var campaign := get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign == null:
        return
    campaign.chapter_changed.connect(_on_chapter_changed)
    _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "first_run" and not completed
    if active:
        _emit_objective()

func notify_apartment_exited() -> void:
    if not active or step != 0:
        return
    step = 1
    _emit_objective()

func notify_mateo_garage_reached() -> void:
    if not active or step != 1:
        return
    step = 2
    _emit_objective()

func deliver_package() -> void:
    if not active or step != 2:
        return
    step = 3
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("FIRST RUN", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("first_run_complete", true)
    var campaign := get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign != null and campaign.get_current_id() == "first_run":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
    _emit_objective()
    mission_completed.emit()

func restore_step(value: int) -> void:
    step = clamp(value, 0, objectives.size() - 1)
    completed = step == objectives.size() - 1
    _emit_objective()

func get_objective() -> String:
    return objectives[step]

func _emit_objective() -> void:
    objective_changed.emit(get_objective())
