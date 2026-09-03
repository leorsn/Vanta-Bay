extends Node
class_name BlackGlassMission

@export var reward_cash := 12000
@export var reward_rep := 18

var objective_index := 0
var objectives := [
    "STEAL THE VEHICLE",
    "LOSE THE POLICE",
    "DELIVER THE VEHICLE TO THE WORKSHOP",
    "MISSION COMPLETE"
]
var stolen_vehicle: Node3D
var wanted: WantedManager
var economy: EconomyManager
var mission_label: Label

func _ready() -> void:
    add_to_group("black_glass_mission")
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    economy = get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    mission_label = get_node_or_null("MissionHUD/Objective") as Label
    if wanted != null:
        wanted.state_changed.connect(_on_wanted_state_changed)
    _refresh_hud()

func register_vehicle_theft(vehicle: Node3D) -> void:
    if objective_index != 0:
        return
    stolen_vehicle = vehicle
    objective_index = 1
    if wanted != null:
        wanted.report_crime(vehicle.global_position, 3, vehicle)
    _refresh_hud()

func _on_wanted_state_changed(state: String, _stars: int) -> void:
    if objective_index == 1 and state == "ESCAPED":
        objective_index = 2
        _refresh_hud()

func try_deliver(vehicle: Node3D) -> bool:
    if objective_index != 2 or vehicle != stolen_vehicle:
        return false
    objective_index = 3
    if economy != null:
        economy.award_mission("BLACK GLASS", reward_cash, reward_rep)
    _refresh_hud()
    return true

func _refresh_hud() -> void:
    if mission_label == null:
        return
    mission_label.text = "BLACK GLASS\n" + objectives[objective_index]
    if objective_index == 3:
        mission_label.text += "\n+$%d BANK   +%d REP" % [reward_cash, reward_rep]
