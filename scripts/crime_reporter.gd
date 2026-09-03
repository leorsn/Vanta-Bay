extends Node
class_name CrimeReporter

signal report_started(seconds: float)
signal report_completed()

@export var vehicle_theft_delay := 3.5

var wanted: WantedManager
var _report_token := 0

func _ready() -> void:
    add_to_group("crime_reporter")
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager

func report_vehicle_theft(vehicle: Node3D, severity: int = 3) -> void:
    if wanted == null or vehicle == null:
        return
    _report_token += 1
    var token := _report_token
    report_started.emit(vehicle_theft_delay)
    await get_tree().create_timer(vehicle_theft_delay).timeout
    if token != _report_token or not is_instance_valid(vehicle):
        return
    wanted.report_crime(vehicle.global_position, severity, vehicle)
    report_completed.emit()

func cancel_pending_report() -> void:
    _report_token += 1
