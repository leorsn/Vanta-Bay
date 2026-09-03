extends Node
class_name CleanSlateMission

@export var reward_cash := 5200
@export var reward_rep := 10
@export var workshop_position := Vector3(-4.0, 1.0, 48.0)
@export var exit_position := Vector3(-18.0, 1.0, 31.0)
@export var reach_radius := 8.0
@export var interaction_radius := 6.5

var active := false
var completed := false
var step := 0
var player: VantaPlayerController
var campaign: StoryCampaign
var target_vehicle: VantaVehicleController

func _ready() -> void:
    add_to_group("clean_slate_mission")
    call_deferred("_bind_runtime")

func _bind_runtime() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    player = get_tree().get_first_node_in_group("player") as VantaPlayerController
    _resolve_vehicle()
    if campaign != null:
        if not campaign.chapter_changed.is_connected(_on_chapter_changed):
            campaign.chapter_changed.connect(_on_chapter_changed)
        _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _process(_delta: float) -> void:
    if not active:
        return
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
        return
    _resolve_vehicle()
    if step == 0:
        if _vehicle_at_workshop():
            step = 1
            _save_step()
    elif step == 1:
        if _can_modify_vehicle() and Input.is_action_just_pressed("interact"):
            target_vehicle.repaint_vehicle()
            _set_flag("vehicle_repainted", true)
            step = 2
            _save_step()
    elif step == 2:
        if _can_modify_vehicle() and Input.is_action_just_pressed("interact"):
            target_vehicle.change_plates()
            _set_flag("plates_changed", true)
            target_vehicle.clear_identity_heat()
            _set_flag("vehicle_heat_cleared", target_vehicle.is_identity_clean())
            step = 3
            _save_step()
    elif step == 3:
        if target_vehicle != null and target_vehicle.global_position.distance_to(exit_position) <= reach_radius:
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
    match step:
        0: return "BRING THE VEHICLE TO PORT VANTA WORKSHOP"
        1: return "E  REPAINT THE VEHICLE"
        2: return "E  CHANGE THE PLATES"
        3: return "LEAVE THE WORKSHOP WITH THE CLEAN VEHICLE"
    return "MISSION COMPLETE"

func _vehicle_at_workshop() -> bool:
    return target_vehicle != null and target_vehicle.global_position.distance_to(workshop_position) <= reach_radius

func _can_modify_vehicle() -> bool:
    if target_vehicle == null or player == null:
        return false
    if not _vehicle_at_workshop():
        return false
    if player.driving:
        return false
    return player.global_position.distance_to(target_vehicle.global_position) <= interaction_radius

func _resolve_vehicle() -> void:
    if target_vehicle != null and is_instance_valid(target_vehicle):
        return
    for node in get_tree().get_nodes_in_group("vehicles"):
        if node is VantaVehicleController and node.mission_target_vehicle:
            target_vehicle = node
            return
    var vehicles := get_tree().get_nodes_in_group("vehicles")
    if not vehicles.is_empty() and vehicles[0] is VantaVehicleController:
        target_vehicle = vehicles[0]

func _set_flag(flag_name: String, value) -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag(flag_name, value)

func _save_step() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("clean_slate_step", step)
        saves.autosave()

func _complete() -> void:
    step = 4
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("CLEAN SLATE", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("clean_slate_complete", true)
        saves.set_flag("clean_slate_step", step)
        saves.set_flag("vehicle_repainted", true)
        saves.set_flag("plates_changed", true)
        saves.set_flag("vehicle_heat_cleared", true)
    if campaign != null and campaign.get_current_id() == "clean_slate":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
