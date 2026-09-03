extends Node
class_name StoryCampaign

signal chapter_changed(mission_id: String, title: String)
signal arc_completed

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

@export var new_game_start_index := 0
var current_index := 0
var arc_complete := false

func _ready() -> void:
    add_to_group("story_campaign")
    current_index = new_game_start_index
    call_deferred("_bind_save_manager")
    call_deferred("_restore_campaign")

func _bind_save_manager() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null and not saves.load_completed.is_connected(_on_save_loaded):
        saves.load_completed.connect(_on_save_loaded)

func _on_save_loaded(_slot: int) -> void:
    _restore_campaign()

func _restore_campaign() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        current_index = int(saves.get_flag("campaign_index", new_game_start_index))
        arc_complete = bool(saves.get_flag("story_arc_one_complete", false))
        if saves.get_flag("black_glass_complete", false) and current_index <= 4:
            current_index = 5
    current_index = clamp(current_index, 0, MISSIONS.size() - 1)
    _emit_current()
    if arc_complete:
        arc_completed.emit()

func complete_current() -> void:
    if current_index < MISSIONS.size() - 1:
        current_index += 1
        var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
        if saves != null:
            saves.set_flag("campaign_index", current_index)
            saves.autosave()
        _emit_current()
    else:
        arc_complete = true
        var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
        if saves != null:
            saves.set_flag("story_arc_one_complete", true)
            saves.autosave()
        arc_completed.emit()

func set_current_by_id(mission_id: String) -> bool:
    for i in range(MISSIONS.size()):
        if str(MISSIONS[i]["id"]) == mission_id:
            current_index = i
            arc_complete = false
            var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
            if saves != null:
                saves.set_flag("campaign_index", current_index)
                saves.set_flag("story_arc_one_complete", false)
                saves.autosave()
            _emit_current()
            return true
    return false

func get_current_id() -> String:
    return str(MISSIONS[current_index]["id"])

func get_current_title() -> String:
    return str(MISSIONS[current_index]["title"])

func is_arc_complete() -> bool:
    return arc_complete

func _emit_current() -> void:
    chapter_changed.emit(get_current_id(), get_current_title())
