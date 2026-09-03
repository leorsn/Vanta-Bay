extends Node
class_name WantedManager

signal state_changed(state: String, stars: int)

@export var search_duration := 12.0
@export var pursuit_memory := 4.0

var state := "NONE"
var stars := 0
var last_known_position := Vector3.ZERO
var target: Node3D
var _time_without_sighting := 0.0
var _search_timer := 0.0

func _ready() -> void:
    add_to_group("wanted_manager")

func _process(delta: float) -> void:
    if state == "PURSUIT":
        _time_without_sighting += delta
        if _time_without_sighting >= pursuit_memory:
            _set_state("SEARCHING")
            _search_timer = search_duration
    elif state == "SEARCHING":
        _search_timer -= delta
        if _search_timer <= 0.0:
            clear_wanted()

func report_crime(crime_position: Vector3, severity: int = 1, suspect: Node3D = null) -> void:
    target = suspect
    last_known_position = crime_position
    stars = clamp(max(stars, severity), 1, 5)
    _time_without_sighting = 0.0
    _set_state("PURSUIT")

func confirm_sighting(position: Vector3, suspect: Node3D = null) -> void:
    if suspect != null:
        target = suspect
    last_known_position = position
    _time_without_sighting = 0.0
    if stars == 0:
        stars = 1
    _set_state("PURSUIT")

func clear_wanted() -> void:
    stars = 0
    target = null
    _search_timer = 0.0
    _time_without_sighting = 0.0
    _set_state("ESCAPED")
    await get_tree().create_timer(2.0).timeout
    if state == "ESCAPED":
        _set_state("NONE")

func get_search_position() -> Vector3:
    return last_known_position

func _set_state(new_state: String) -> void:
    if state == new_state:
        return
    state = new_state
    state_changed.emit(state, stars)
