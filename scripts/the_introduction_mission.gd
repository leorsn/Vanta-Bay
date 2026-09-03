extends Node
class_name TheIntroductionMission

@export var reward_cash := 7500
@export var reward_rep := 14
@export var marina_position := Vector3(40.0, 1.0, -28.0)
@export var adrian_office_position := Vector3(46.0, 1.0, -42.0)
@export var reach_radius := 7.0

var active := false
var completed := false
var step := 0
var player: Node3D
var campaign: StoryCampaign

func _ready() -> void:
    add_to_group("the_introduction_mission")
    call_deferred("_bind_runtime")

func _bind_runtime() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    player = get_tree().get_first_node_in_group("player") as Node3D
    if campaign != null:
        campaign.chapter_changed.connect(_on_chapter_changed)
        _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _process(_delta: float) -> void:
    if not active or player == null:
        return
    if step == 0 and player.global_position.distance_to(marina_position) <= reach_radius:
        step = 1
        _save_step()
    elif step == 1 and player.global_position.distance_to(adrian_office_position) <= reach_radius:
        _complete()

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "the_introduction" and not completed
    if active:
        var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
        if saves != null:
            step = int(saves.get_flag("the_introduction_step", step))

func get_objective() -> String:
    if not active and not completed:
        return ""
    if completed:
        return "MISSION COMPLETE"
    if step == 0:
        return "GO TO MARINA DISTRICT"
    return "MEET ADRIAN VALE"

func _save_step() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("the_introduction_step", step)
        saves.autosave()

func _complete() -> void:
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("THE INTRODUCTION", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("the_introduction_complete", true)
        saves.set_flag("adrian_vale_unlocked", true)
        saves.set_flag("the_introduction_step", 2)
    if campaign != null and campaign.get_current_id() == "the_introduction":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
