extends Node
class_name CleanSlateMission

@export var reward_cash := 5200
@export var reward_rep := 10
@export var safehouse_position := Vector3(-48.0, 1.0, -46.0)
@export var burner_drop_position := Vector3(34.0, 1.0, 30.0)
@export var reach_radius := 7.0

var active := false
var completed := false
var step := 0
var player: Node3D
var campaign: StoryCampaign

func _ready() -> void:
    add_to_group("clean_slate_mission")
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
    if step == 0 and player.global_position.distance_to(safehouse_position) <= reach_radius:
        step = 1
        _save_step()
    elif step == 1 and player.global_position.distance_to(burner_drop_position) <= reach_radius:
        _complete()

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "clean_slate" and not completed
    if active:
        var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
        if saves != null:
            step = int(saves.get_flag("clean_slate_step", step))

func get_objective() -> String:
    if not active and not completed:
        return ""
    if completed:
        return "MISSION COMPLETE"
    if step == 0:
        return "RETURN TO JACE'S APARTMENT"
    return "DUMP THE BURNER PHONE"

func _save_step() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("clean_slate_step", step)
        saves.autosave()

func _complete() -> void:
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("CLEAN SLATE", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("clean_slate_complete", true)
        saves.set_flag("clean_slate_step", 2)
    if campaign != null and campaign.get_current_id() == "clean_slate":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
