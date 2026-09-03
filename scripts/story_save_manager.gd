extends Node
class_name StorySaveManager

signal save_completed(slot: int)
signal load_completed(slot: int)

const SAVE_VERSION := 4
const SLOT_COUNT := 3

@export var active_slot := 1
@export var auto_resume := false
var story_flags: Dictionary = {}

func _ready() -> void:
    add_to_group("story_save_manager")
    if auto_resume:
        call_deferred("_autoload_active_slot")

func _autoload_active_slot() -> void:
    await get_tree().process_frame
    if has_story_save(active_slot):
        load_story(active_slot)

func save_story(slot: int = active_slot) -> bool:
    slot = clamp(slot, 1, SLOT_COUNT)
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    var black_glass := get_tree().get_first_node_in_group("black_glass_mission") as BlackGlassMission
    var first_run := get_tree().get_first_node_in_group("first_run_mission") as FirstRunMission
    var player := get_tree().get_first_node_in_group("player") as Node3D
    var payload := {
        "version": SAVE_VERSION,
        "slot": slot,
        "story_flags": story_flags,
        "economy": {
            "cash": economy.cash if economy != null else 0,
            "bank": economy.bank if economy != null else 0,
            "rep": economy.rep if economy != null else 0
        },
        "missions": {
            "first_run_step": first_run.step if first_run != null else 0,
            "black_glass_objective": black_glass.objective_index if black_glass != null else 0
        },
        "player_position": _vec3_to_array(player.global_position) if player != null else [0.0, 1.2, 18.0]
    }
    var file := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(payload))
    file.close()
    active_slot = slot
    save_completed.emit(slot)
    return true

func load_story(slot: int = active_slot) -> bool:
    slot = clamp(slot, 1, SLOT_COUNT)
    var path := _slot_path(slot)
    if not FileAccess.file_exists(path):
        return false
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        return false
    if int(parsed.get("version", 0)) < SAVE_VERSION:
        return false

    story_flags = parsed.get("story_flags", {})
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    var econ: Dictionary = parsed.get("economy", {})
    if economy != null:
        economy.cash = int(econ.get("cash", economy.cash))
        economy.bank = int(econ.get("bank", economy.bank))
        economy.rep = int(econ.get("rep", economy.rep))
        economy.refresh_balances()

    var missions: Dictionary = parsed.get("missions", {})
    var legacy_black_glass := int(parsed.get("black_glass_objective", 0))
    var first_run := get_tree().get_first_node_in_group("first_run_mission") as FirstRunMission
    if first_run != null:
        first_run.restore_step(int(missions.get("first_run_step", story_flags.get("first_run_step", 0))))
    var black_glass := get_tree().get_first_node_in_group("black_glass_mission") as BlackGlassMission
    if black_glass != null:
        black_glass.restore_objective(int(missions.get("black_glass_objective", legacy_black_glass)))

    var player := get_tree().get_first_node_in_group("player") as Node3D
    if player != null:
        player.global_position = _array_to_vec3(parsed.get("player_position", [0.0, 1.2, 18.0]))
    active_slot = slot
    load_completed.emit(slot)
    return true

func autosave() -> void:
    save_story(active_slot)

func set_flag(key: String, value = true) -> void:
    story_flags[key] = value

func get_flag(key: String, fallback = false):
    return story_flags.get(key, fallback)

func has_story_save(slot: int = active_slot) -> bool:
    return FileAccess.file_exists(_slot_path(clamp(slot, 1, SLOT_COUNT)))

func delete_story_save(slot: int = active_slot) -> bool:
    var path := _slot_path(clamp(slot, 1, SLOT_COUNT))
    if not FileAccess.file_exists(path):
        return true
    return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK

func _slot_path(slot: int) -> String:
    return "user://story_slot_%d.json" % slot

func _vec3_to_array(value: Vector3) -> Array:
    return [value.x, value.y, value.z]

func _array_to_vec3(value: Array) -> Vector3:
    if value.size() < 3:
        return Vector3.ZERO
    return Vector3(float(value[0]), float(value[1]), float(value[2]))
