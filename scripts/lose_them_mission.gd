extends Node
class_name LoseThemMission

@export var reward_cash := 3500
@export var reward_rep := 8

var active := false
var completed := false
var objective := "WAIT FOR MATEO"
var mission_label: Label
var wanted: WantedManager

func _ready() -> void:
    add_to_group("lose_them_mission")
    mission_label = get_node_or_null("MissionHUD/Objective") as Label
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    call_deferred("_bind_campaign")

func _bind_campaign() -> void:
    var campaign := get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign == null:
        return
    campaign.chapter_changed.connect(_on_chapter_changed)
    _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    if mission_id != "lose_them" or completed:
        active = false
        _refresh_hud()
        return
    active = true
    objective = "RETURN TO JACE'S APARTMENT"
    _refresh_hud()

func notify_apartment_reached() -> void:
    if not active or completed:
        return
    objective = "MATEO: THEY KNOW ABOUT THE DEVICE. KEEP MOVING."
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("LOSE THEM", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("lose_them_complete", true)
    var campaign := get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign != null and campaign.get_current_id() == "lose_them":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
    _refresh_hud()

func _refresh_hud() -> void:
    if mission_label == null:
        return
    if active or completed:
        mission_label.text = "LOSE THEM\n" + objective
        if completed:
            mission_label.text += "\n+$%d BANK   +%d REP" % [reward_cash, reward_rep]
    else:
        mission_label.text = ""
