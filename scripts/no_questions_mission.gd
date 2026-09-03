extends Node
class_name NoQuestionsMission

@export var reward_cash := 700
@export var reward_rep := 4
@export var garage_center := Vector3(-22, 0, 43)
@export var workshop_center := Vector3(-4, 0, 48)

var active := false
var completed := false
var step := 0
var player: Node3D
var mission_label: Label
var objectives := [
    "GO TO OCEAN DRIVE GARAGE",
    "TAKE THE VEHICLE TO PORT VANTA",
    "MISSION COMPLETE"
]

func _ready() -> void:
    add_to_group("no_questions_mission")
    _ensure_hud()
    call_deferred("_bind_campaign")

func _process(_delta: float) -> void:
    if not active or completed:
        return
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node3D
    if player == null:
        return
    var flat := player.global_position
    flat.y = 0.0
    if step == 0 and flat.distance_to(garage_center) < 12.0:
        step = 1
        _checkpoint()
    elif step == 1 and flat.distance_to(workshop_center) < 11.0:
        _complete()

func _bind_campaign() -> void:
    var campaign := get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign == null:
        return
    if not campaign.chapter_changed.is_connected(_on_chapter_changed):
        campaign.chapter_changed.connect(_on_chapter_changed)
    _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "no_questions" and not completed
    _refresh_hud()

func _complete() -> void:
    if not active:
        return
    step = 2
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("NO QUESTIONS", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("no_questions_complete", true)
    var campaign := get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign != null and campaign.get_current_id() == "no_questions":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
    _refresh_hud()

func _checkpoint() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("no_questions_step", step)
        saves.autosave()
    _refresh_hud()

func _ensure_hud() -> void:
    var layer := CanvasLayer.new()
    layer.name = "MissionHUD"
    add_child(layer)
    mission_label = Label.new()
    mission_label.name = "Objective"
    mission_label.position = Vector2(56, 58)
    mission_label.size = Vector2(650, 130)
    mission_label.add_theme_font_size_override("font_size", 24)
    layer.add_child(mission_label)

func _refresh_hud() -> void:
    if mission_label == null:
        return
    if active or completed:
        mission_label.text = "NO QUESTIONS\n" + objectives[step]
        if completed:
            mission_label.text += "\n+$%d BANK   +%d REP" % [reward_cash, reward_rep]
    else:
        mission_label.text = ""
