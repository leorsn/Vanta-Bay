extends Node
class_name StorySaveManager

signal save_completed(slot: int)
signal load_completed(slot: int)

const SAVE_VERSION := 1
const SLOT_COUNT := 3

@export var active_slot := 1
var story_flags: Dictionary = {}

func _ready() -> void:
    add_to_group("story_save_manager")

func save_story(slot: int = active_slot) -> bool:
    slot = clamp(slot, 1, SLOT_COUNT)
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    var mission := get_tree().get_first_node_in_group("black_glass_mission") as BlackGlassMission
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
        "black_glass_objective": mission.objective_index if mission != null else 0,
        "player_position": _vec3_to_array(player.global_position) if player != null else [0.0, 1.0, 0.0]
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
    story_flags = parsed.get("story_flags", {})
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    var econ: Dictionary = parsed.get("economy", {})
    if economy != null:
        economy.cash = int(econ.get("cash", economy.cash))
        economy.bank = int(econ.get("bank", economy.bank))
        economy.rep = int(econ.get("rep", economy.rep))
        economy.refresh_balances()
    var mission := get_tree().get_first_node_in_group("black_glass_mission") as BlackGlassMission
    if mission != null:
        mission.restore_objective(int(parsed.get("black_glass_objective", 0)))
    var player := get_tree().get_first_node_in_group("player") as Node3D
    if player != null:
        player.global_position = _array_to_vec3(parsed.get("player_position", [0.0, 1.0, 0.0]))
    active_slot = slot
    load_completed.emit(slot)
    return true

func autosave() -> void:
    save_story(active_slot)

func set_flag(key: String, value = true) -> void:
    story_flags[key] = value

func get_flag(key: String, fallback = false):
    return story_flags.get(key, fallback)

func _slot_path(slot: int) -> String:
    return "user://story_slot_%d.json" % slot

func _vec3_to_array(value: Vector3) -> Array:
    return [value.x, value.y, value.z]

func _array_to_vec3(value: Array) -> Vector3:
    if value.size() < 3:
        return Vector3.ZERO
    return Vector3(float(value[0]), float(value[1]), float(value[2]))
