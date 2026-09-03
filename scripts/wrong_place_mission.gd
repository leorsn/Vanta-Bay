extends Node
class_name WrongPlaceMission

@export var reward_cash := 1800
@export var reward_rep := 7
@export var meeting_position := Vector3(28.0, 1.0, 30.0)
@export var escape_position := Vector3(-46.0, 1.0, -36.0)
@export var reach_radius := 8.0

var active := false
var completed := false
var step := 0
var player: Node3D
var campaign: StoryCampaign
var wanted: WantedManager

func _ready() -> void:
    add_to_group("wrong_place_mission")
    call_deferred("_bind_runtime")

func _bind_runtime() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    player = get_tree().get_first_node_in_group("player") as Node3D
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    if campaign != null:
        campaign.chapter_changed.connect(_on_chapter_changed)
        _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())
    if wanted != null:
        wanted.state_changed.connect(_on_wanted_state_changed)

func _process(_delta: float) -> void:
    if not active:
        return
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node3D
        return
    if step == 0 and player.global_position.distance_to(meeting_position) <= reach_radius:
        step = 1
        if wanted != null:
            wanted.report_crime(player.global_position, 2, player)
        _save_step()
    elif step == 2 and player.global_position.distance_to(escape_position) <= reach_radius:
        _complete()

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "wrong_place" and not completed

func _on_wanted_state_changed(state: String, _stars: int) -> void:
    if active and step == 1 and state == "ESCAPED":
        step = 2
        _save_step()

func get_objective() -> String:
    match step:
        0: return "MEET MATEO'S CONTACT"
        1: return "LOSE THE POLICE"
        2: return "GET BACK TO OLD BAY"
        _: return "MISSION COMPLETE"

func _save_step() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("wrong_place_step", step)
        saves.autosave()

func _complete() -> void:
    step = 3
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("WRONG PLACE", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("wrong_place_complete", true)
        saves.set_flag("wrong_place_step", step)
    if campaign != null and campaign.get_current_id() == "wrong_place":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
