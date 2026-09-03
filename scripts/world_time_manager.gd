extends Node
class_name WorldTimeManager

signal time_changed(hour: int, minute: int)

@export var real_seconds_per_game_day := 2880.0
@export var start_hour := 14.5

var time_hours := 14.5
var sun: DirectionalLight3D
var _last_minute := -1

func _ready() -> void:
    add_to_group("world_time_manager")
    time_hours = start_hour
    call_deferred("_resolve_world_nodes")

func _process(delta: float) -> void:
    if real_seconds_per_game_day <= 0.0:
        return
    time_hours = fmod(time_hours + delta * (24.0 / real_seconds_per_game_day), 24.0)
    if sun == null or not is_instance_valid(sun):
        _resolve_world_nodes()
    _update_sun()
    var minute: int = int(floor(fmod(time_hours, 1.0) * 60.0))
    if minute != _last_minute:
        _last_minute = minute
        time_changed.emit(int(floor(time_hours)), minute)

func set_time(hour: float) -> void:
    time_hours = fmod(maxf(hour, 0.0), 24.0)
    _update_sun()

func is_night() -> bool:
    return time_hours >= 20.0 or time_hours < 6.0

func get_clock_text() -> String:
    var hour: int = int(floor(time_hours))
    var minute: int = int(floor(fmod(time_hours, 1.0) * 60.0))
    return "%02d:%02d" % [hour, minute]

func _resolve_world_nodes() -> void:
    var scene := get_tree().current_scene
    if scene == null:
        return
    sun = scene.get_node_or_null("Sun") as DirectionalLight3D

func _update_sun() -> void:
    if sun == null:
        return
    var normalized: float = time_hours / 24.0
    sun.rotation_degrees.x = normalized * 360.0 - 90.0
    sun.rotation_degrees.y = -32.0
    var daylight: float = clampf(sin((time_hours - 6.0) / 12.0 * PI), 0.0, 1.0)
    sun.light_energy = lerpf(0.08, 1.25, daylight)
