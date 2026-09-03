extends Node
class_name OverheadMission

@export var reward_cash := 14000
@export var reward_rep := 25
@export var rooftop_position := Vector3(28.0, 1.0, -42.0)
@export var exit_position := Vector3(-6.0, 1.0, 48.0)
@export var reach_radius := 7.0

var active := false
var completed := false
var step := 0
var player: Node3D
var campaign: StoryCampaign
var dialogue: StoryDialogueUI
var combat_director: StoryCombatDirector
var relationships: StoryRelationshipManager
var sequence_running := false

func _ready() -> void:
    add_to_group("overhead_mission")
    call_deferred("_bind_runtime")

func _bind_runtime() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    player = get_tree().get_first_node_in_group("player") as Node3D
    dialogue = get_tree().get_first_node_in_group("story_dialogue_ui") as StoryDialogueUI
    combat_director = get_tree().get_first_node_in_group("story_combat_director") as StoryCombatDirector
    relationships = get_tree().get_first_node_in_group("story_relationship_manager") as StoryRelationshipManager
    if campaign != null:
        if not campaign.chapter_changed.is_connected(_on_chapter_changed):
            campaign.chapter_changed.connect(_on_chapter_changed)
        _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())
    if combat_director != null and not combat_director.encounter_cleared.is_connected(_on_encounter_cleared):
        combat_director.encounter_cleared.connect(_on_encounter_cleared)

func _process(_delta: float) -> void:
    if not active:
        return
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node3D
        return
    if step == 0 and not sequence_running and player.global_position.distance_to(rooftop_position) <= reach_radius:
        _start_rooftop_sequence()
    elif step == 3 and player.global_position.distance_to(exit_position) <= reach_radius:
        _complete()

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "overhead" and not completed
    if not active:
        return
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        step = int(saves.get_flag("overhead_step", step))
        completed = bool(saves.get_flag("overhead_complete", false))
        active = not completed
    if active and step == 2:
        call_deferred("_resume_combat")

func _resume_combat() -> void:
    _resolve_runtime()
    if combat_director != null:
        combat_director.begin_encounter("overhead")

func _start_rooftop_sequence() -> void:
    sequence_running = true
    step = 1
    _resolve_runtime()
    var trust := relationships.get_relationship("adrian_vale") if relationships != null else 0
    if dialogue != null:
        var line := "You made it further than Mateo expected. Keep your head down. We have one clean window out."
        if trust >= 20:
            line = "You have been consistent, Jace. That is rare here. When this is over, you will have access most people spend years chasing."
        elif trust < 0:
            line = "You are still here, which is useful. Do not mistake that for trust. Finish this cleanly."
        dialogue.show_line("ADRIAN VALE", line)
        await get_tree().create_timer(2.6).timeout
        dialogue.close_dialogue()
    step = 2
    _save_step()
    if combat_director != null:
        combat_director.begin_encounter("overhead")
    sequence_running = false

func _on_encounter_cleared(mission_id: String) -> void:
    if not active or mission_id != "overhead" or step != 2:
        return
    step = 3
    _save_step()

func get_objective() -> String:
    if completed:
        return "ARC COMPLETE"
    if not active:
        return ""
    match step:
        0: return "GET TO THE ROOFTOP MEETING"
        1: return "LISTEN TO ADRIAN"
        2:
            var remaining := combat_director.get_remaining_hostiles() if combat_director != null else 0
            return "SURVIVE THE AMBUSH  •  %d HOSTILES" % remaining
        3: return "REACH THE PORT VANTA EXIT"
        _: return "ARC COMPLETE"

func restore_step(value: int) -> void:
    step = clamp(value, 0, 3)
    completed = false
    active = true
    if step == 2:
        call_deferred("_resume_combat")

func _save_step() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("overhead_step", step)
        saves.autosave()

func _complete() -> void:
    if completed:
        return
    completed = true
    active = false
    step = 4
    var trust := relationships.get_relationship("adrian_vale") if relationships != null else 0
    var cash_reward := reward_cash + (2500 if trust >= 20 else 0)
    var rep_reward := reward_rep + (4 if trust >= 20 else 0)
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("OVERHEAD", cash_reward, rep_reward)
    if relationships != null:
        relationships.adjust_relationship("adrian_vale", 10)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("overhead_complete", true)
        saves.set_flag("story_arc_one_complete", true)
        saves.set_flag("overhead_step", step)
        saves.set_flag("vertical_slice_complete", true)
        saves.autosave()
    if campaign != null:
        campaign.complete_current()

func _resolve_runtime() -> void:
    if dialogue == null or not is_instance_valid(dialogue):
        dialogue = get_tree().get_first_node_in_group("story_dialogue_ui") as StoryDialogueUI
    if combat_director == null or not is_instance_valid(combat_director):
        combat_director = get_tree().get_first_node_in_group("story_combat_director") as StoryCombatDirector
        if combat_director != null and not combat_director.encounter_cleared.is_connected(_on_encounter_cleared):
            combat_director.encounter_cleared.connect(_on_encounter_cleared)
    if relationships == null or not is_instance_valid(relationships):
        relationships = get_tree().get_first_node_in_group("story_relationship_manager") as StoryRelationshipManager
