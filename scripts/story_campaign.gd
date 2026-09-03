extends Node
class_name StoryCampaign

signal chapter_changed(mission_id: String, title: String)

const MISSIONS := [
    {"id": "first_run", "title": "FIRST RUN"},
    {"id": "no_questions", "title": "NO QUESTIONS"},
    {"id": "after_midnight", "title": "AFTER MIDNIGHT"},
    {"id": "wrong_place", "title": "WRONG PLACE"},
    {"id": "black_glass", "title": "BLACK GLASS"},
    {"id": "lose_them", "title": "LOSE THEM"},
    {"id": "clean_slate", "title": "CLEAN SLATE"},
    {"id": "the_introduction", "title": "THE INTRODUCTION"},
    {"id": "terms_conditions", "title": "TERMS & CONDITIONS"},
    {"id": "overhead", "title": "OVERHEAD"}
]

@export var prototype_start_index := 4
var current_index := 4

func _ready() -> void:
    add_to_group("story_campaign")
    current_index = prototype_start_index
    call_deferred("_restore_campaign")

func _restore_campaign() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        current_index = int(saves.get_flag("campaign_index", prototype_start_index))
        if saves.get_flag("black_glass_complete", false) and current_index <= 4:
            current_index = 5
    _emit_current()

func complete_current() -> void:
    if current_index < MISSIONS.size() - 1:
        current_index += 1
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("campaign_index", current_index)
        saves.autosave()
    _emit_current()

func get_current_id() -> String:
    return str(MISSIONS[current_index]["id"])

func get_current_title() -> String:
    return str(MISSIONS[current_index]["title"])

func _emit_current() -> void:
    chapter_changed.emit(get_current_id(), get_current_title())
