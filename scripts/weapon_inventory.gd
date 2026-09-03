extends Node
class_name WeaponInventory

signal weapon_changed(weapon_id: String, data: Dictionary)

const WEAPONS := {
    "pistol": {
        "name": "V9 COMPACT",
        "damage": 34.0,
        "range": 85.0,
        "cooldown": 0.22,
        "magazine": 15,
        "reserve": 75,
        "reload": 1.25
    },
    "smg": {
        "name": "VX-9 SMG",
        "damage": 22.0,
        "range": 70.0,
        "cooldown": 0.09,
        "magazine": 30,
        "reserve": 120,
        "reload": 1.6
    },
    "rifle": {
        "name": "AR-12 RIFLE",
        "damage": 42.0,
        "range": 125.0,
        "cooldown": 0.14,
        "magazine": 30,
        "reserve": 90,
        "reload": 1.9
    }
}

var unlocked := ["pistol", "smg", "rifle"]
var equipped_id := "pistol"

func _ready() -> void:
    add_to_group("weapon_inventory")
    call_deferred("_emit_current")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("weapon_1"):
        equip("pistol")
    elif event.is_action_pressed("weapon_2"):
        equip("smg")
    elif event.is_action_pressed("weapon_3"):
        equip("rifle")

func equip(weapon_id: String) -> bool:
    if not WEAPONS.has(weapon_id) or not unlocked.has(weapon_id):
        return false
    if equipped_id == weapon_id:
        return true
    equipped_id = weapon_id
    _emit_current()
    return true

func get_current() -> Dictionary:
    return WEAPONS.get(equipped_id, WEAPONS["pistol"])

func get_current_name() -> String:
    return str(get_current().get("name", "WEAPON"))

func _emit_current() -> void:
    weapon_changed.emit(equipped_id, get_current())
