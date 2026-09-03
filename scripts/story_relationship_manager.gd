extends Node
class_name StoryRelationshipManager

signal relationship_changed(contact_id: String, value: int)
signal contact_unlocked(contact_id: String)

var relationships := {}
var unlocked_contacts := {}

func _ready() -> void:
    add_to_group("story_relationship_manager")
    call_deferred("_load_from_save")

func unlock_contact(contact_id: String) -> void:
    if bool(unlocked_contacts.get(contact_id, false)):
        return
    unlocked_contacts[contact_id] = true
    _persist(contact_id)
    contact_unlocked.emit(contact_id)

func is_contact_unlocked(contact_id: String) -> bool:
    return bool(unlocked_contacts.get(contact_id, false))

func adjust_relationship(contact_id: String, amount: int) -> int:
    var current := int(relationships.get(contact_id, 0))
    current = clamp(current + amount, -100, 100)
    relationships[contact_id] = current
    _persist(contact_id)
    relationship_changed.emit(contact_id, current)
    return current

func get_relationship(contact_id: String) -> int:
    return int(relationships.get(contact_id, 0))

func get_relationship_label(contact_id: String) -> String:
    var value := get_relationship(contact_id)
    if value >= 50:
        return "TRUSTED"
    if value >= 20:
        return "FAVORABLE"
    if value <= -40:
        return "HOSTILE"
    if value <= -15:
        return "WARY"
    return "NEUTRAL"

func _persist(contact_id: String) -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves == null:
        return
    saves.set_flag("contact_%s_unlocked" % contact_id, is_contact_unlocked(contact_id))
    saves.set_flag("relationship_%s" % contact_id, get_relationship(contact_id))
    saves.autosave()

func _load_from_save() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves == null:
        return
    for contact_id in ["adrian_vale", "mateo"]:
        unlocked_contacts[contact_id] = bool(saves.get_flag("contact_%s_unlocked" % contact_id, false))
        relationships[contact_id] = int(saves.get_flag("relationship_%s" % contact_id, 0))
