extends Node
class_name FirstRunMission

signal objective_changed(text: String)
signal mission_completed()

@export var reward_cash := 450
@export var reward_rep := 3
@export var apartment_center := Vector3(-49, 0, -47)
@export var mateo_garage_center := Vector3(-22, 0, 43)
@export var package_drop_center := Vector3(-4, 0, 48)

var active := false
var completed := false
var step := 0
var player: Node3D
var mission_label: Label
var objectives := [
    "LEAVE JACE'S APARTMENT",
    "GET TO MATEO'S GARAGE",
    "DELIVER THE PACKAGE",
    "MISSION COMPLETE"
]

func _ready() -> void:
    add_to_group("first_run_mission")
    _ensure_hud()
    call_deferred("_bind_campaign")

func _process(_delta: float) -> void:
    if not active or completed:
        return
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node3D
    if player == null:
        return
    var flat_position := player.global_position
    flat_position.y = 0.0
    match step:
        0:
            if flat_position.distance_to(apartment_center) > 9.0:
                notify_apartment_exited()
        1:
            if flat_position.distance_to(mateo_garage_center) < 12.0:
                notify_mateo_garage_reached()
        2:
            if flat_position.distance_to(package_drop_center) < 11.0:
                deliver_package()

func _bind_campaign() -> void:
    var campaign := get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign == null:
        return
    if not campaign.chapter_changed.is_connected(_on_chapter_changed):
        campaign.chapter_changed.connect(_on_chapter_changed)
    _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "first_run" and not completed
    _refresh_hud()

func notify_apartment_exited() -> void:
    if not active or step != 0:
        return
    step = 1
    _checkpoint()

func notify_mateo_garage_reached() -> void:
    if not active or step != 1:
        return
    step = 2
    _checkpoint()

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
    _refresh_hud()
    mission_completed.emit()

func restore_step(value: int) -> void:
    step = clamp(value, 0, objectives.size() - 1)
    completed = step == objectives.size() - 1
    _refresh_hud()

func get_objective() -> String:
    return objectives[step]

func _checkpoint() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
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
        mission_label.text = "FIRST RUN\n" + get_objective()
        if completed:
            mission_label.text += "\n+$%d BANK   +%d REP" % [reward_cash, reward_rep]
    else:
        mission_label.text = ""
    objective_changed.emit(get_objective())
