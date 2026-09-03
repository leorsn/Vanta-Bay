extends Node
class_name WorldClock

signal time_changed(hour: float)

@export var start_hour := 20.0
@export var real_seconds_per_game_day := 2880.0

var hour := 20.0

func _ready() -> void:
    add_to_group("world_clock")
    hour = start_hour

func _process(delta: float) -> void:
    if real_seconds_per_game_day <= 0.0:
        return
    hour = fmod(hour + delta * 24.0 / real_seconds_per_game_day, 24.0)
    time_changed.emit(hour)

func is_night() -> bool:
    return hour >= 21.0 or hour < 5.0

func set_hour(value: float) -> void:
    hour = fmod(value + 24.0, 24.0)
    time_changed.emit(hour)
