extends Node
class_name AfterMidnightMission

@export var reward_cash := 1100
@export var reward_rep := 5
@export var club_position := Vector3(-42.0, 1.0, 18.0)
@export var marina_drop_position := Vector3(44.0, 1.0, -34.0)
@export var reach_radius := 7.0

var active := false
var completed := false
var step := 0
var player: Node3D
var campaign: StoryCampaign
var clock: WorldClock

func _ready() -> void:
    add_to_group("after_midnight_mission")
    call_deferred("_bind_runtime")

func _bind_runtime() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    player = get_tree().get_first_node_in_group("player") as Node3D
    clock = get_tree().get_first_node_in_group("world_clock") as WorldClock
    if campaign != null:
        campaign.chapter_changed.connect(_on_chapter_changed)
        _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _process(_delta: float) -> void:
    if not active:
        return
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node3D
        return
    if clock == null or not is_instance_valid(clock):
        clock = get_tree().get_first_node_in_group("world_clock") as WorldClock
    if step == 0 and (clock == null or clock.is_night()):
        step = 1
        _save_step()
    elif step == 1 and player.global_position.distance_to(club_position) <= reach_radius:
        step = 2
        _save_step()
    elif step == 2 and player.global_position.distance_to(marina_drop_position) <= reach_radius:
        _complete()

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "after_midnight" and not completed
    if active and clock != null and not clock.is_night():
        clock.set_hour(23.25)

func get_objective() -> String:
    match step:
        0: return "WAIT UNTIL NIGHT"
        1: return "MEET THE CONTACT IN OLD BAY"
        2: return "DELIVER THE PACKAGE TO MARINA DISTRICT"
        _: return "MISSION COMPLETE"

func _save_step() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("after_midnight_step", step)
        saves.autosave()

func _complete() -> void:
    step = 3
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("AFTER MIDNIGHT", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("after_midnight_complete", true)
        saves.set_flag("after_midnight_step", step)
    if campaign != null and campaign.get_current_id() == "after_midnight":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
