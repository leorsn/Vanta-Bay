extends Node
class_name BlackGlassMission

signal mission_completed()

@export var reward_cash := 12000
@export var reward_rep := 18

var objective_index := 0
var objectives := [
    "READ MATEO'S MESSAGE",
    "STEAL THE VEHICLE",
    "WITNESS REPORTING",
    "LOSE THE POLICE",
    "DELIVER THE VEHICLE TO THE WORKSHOP",
    "CHECK THE ENCRYPTED DEVICE",
    "MISSION COMPLETE"
]
var stolen_vehicle: Node3D
var wanted: WantedManager
var economy: EconomyManager
var crime_reporter: CrimeReporter
var phone: VantaPhoneController
var mission_label: Label

func _ready() -> void:
    add_to_group("black_glass_mission")
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    economy = get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    crime_reporter = get_tree().get_first_node_in_group("crime_reporter") as CrimeReporter
    phone = get_tree().get_first_node_in_group("phone_controller") as VantaPhoneController
    mission_label = get_node_or_null("MissionHUD/Objective") as Label
    if wanted != null:
        wanted.state_changed.connect(_on_wanted_state_changed)
    if crime_reporter != null:
        crime_reporter.report_completed.connect(_on_report_completed)
    if phone != null:
        phone.mateo_message_read.connect(_on_mateo_message_read)
        phone.black_glass_followup_read.connect(_on_followup_read)
    _refresh_hud()

func _on_mateo_message_read() -> void:
    if objective_index == 0:
        objective_index = 1
        _refresh_hud()

func register_vehicle_theft(vehicle: Node3D) -> void:
    if objective_index != 1:
        return
    stolen_vehicle = vehicle
    objective_index = 2
    if crime_reporter != null:
        crime_reporter.report_vehicle_theft(vehicle, 3)
    elif wanted != null:
        wanted.report_crime(vehicle.global_position, 3, vehicle)
        _on_report_completed()
    _refresh_hud()

func _on_report_completed() -> void:
    if objective_index == 2:
        objective_index = 3
        _refresh_hud()

func _on_wanted_state_changed(state: String, _stars: int) -> void:
    if objective_index == 3 and state == "ESCAPED":
        objective_index = 4
        _refresh_hud()

func try_deliver(vehicle: Node3D) -> bool:
    if objective_index != 4 or vehicle != stolen_vehicle:
        return false
    objective_index = 5
    if economy != null:
        economy.award_mission("BLACK GLASS", reward_cash, reward_rep)
    if phone != null:
        phone.show_black_glass_followup()
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("black_glass_storage_device_found", true)
        saves.autosave()
    _refresh_hud()
    return true

func _on_followup_read() -> void:
    if objective_index != 5:
        return
    objective_index = 6
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("black_glass_complete", true)
        saves.set_flag("network_thread_started", true)
    var campaign := get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign != null and campaign.get_current_id() == "black_glass":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
    mission_completed.emit()
    _refresh_hud()

func restore_objective(value: int) -> void:
    objective_index = clamp(value, 0, objectives.size() - 1)
    if phone != null and objective_index == 5:
        phone.show_black_glass_followup()
    _refresh_hud()

func _refresh_hud() -> void:
    if mission_label == null:
        return
    mission_label.text = "BLACK GLASS\n" + objectives[objective_index]
    if objective_index == 0:
        mission_label.text += "\nPRESS P TO OPEN VANTA OS"
    elif objective_index == 2:
        mission_label.text += "\nA WITNESS IS CALLING POLICE..."
    elif objective_index == 5:
        mission_label.text += "\nPRESS P TO READ THE SECURE MESSAGE"
    elif objective_index == 6:
        mission_label.text += "\n+$%d BANK   +%d REP\nNEXT: LOSE THEM" % [reward_cash, reward_rep]
