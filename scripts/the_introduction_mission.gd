extends Node
class_name TheIntroductionMission

@export var reward_cash := 7500
@export var reward_rep := 14
@export var marina_position := Vector3(40.0, 1.0, -28.0)
@export var adrian_office_position := Vector3(46.0, 1.0, -42.0)
@export var reach_radius := 7.0

var active := false
var completed := false
var step := 0
var player: Node3D
var campaign: StoryCampaign
var dialogue: StoryDialogueUI
var relationships: StoryRelationshipManager
var conversation_active := false
var selected_choice := -1

func _ready() -> void:
    add_to_group("the_introduction_mission")
    call_deferred("_bind_runtime")

func _bind_runtime() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    player = get_tree().get_first_node_in_group("player") as Node3D
    dialogue = get_tree().get_first_node_in_group("story_dialogue_ui") as StoryDialogueUI
    relationships = get_tree().get_first_node_in_group("story_relationship_manager") as StoryRelationshipManager
    if campaign != null:
        if not campaign.chapter_changed.is_connected(_on_chapter_changed):
            campaign.chapter_changed.connect(_on_chapter_changed)
        _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())
    if dialogue != null and not dialogue.choice_selected.is_connected(_on_choice_selected):
        dialogue.choice_selected.connect(_on_choice_selected)

func _process(_delta: float) -> void:
    if not active:
        return
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node3D
        return
    if step == 0 and player.global_position.distance_to(marina_position) <= reach_radius:
        step = 1
        _save_step()

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "the_introduction" and not completed
    if active:
        var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
        if saves != null:
            step = int(saves.get_flag("the_introduction_step", step))
            selected_choice = int(saves.get_flag("adrian_intro_choice", selected_choice))

func start_adrian_conversation() -> void:
    if not active or step != 1 or conversation_active:
        return
    if dialogue == null or not is_instance_valid(dialogue):
        dialogue = get_tree().get_first_node_in_group("story_dialogue_ui") as StoryDialogueUI
    if dialogue == null:
        return
    conversation_active = true
    dialogue.show_choices(
        "ADRIAN VALE",
        "Mateo says you can move quietly when it matters. I do not pay for noise. I pay for control. So tell me, Jace — what exactly are you looking for?",
        [
            "Money. Enough to stop taking small jobs.",
            "Access. I want to know who actually runs this city.",
            "Leverage. Money follows once people need you."
        ]
    )

func _on_choice_selected(index: int) -> void:
    if not conversation_active:
        return
    selected_choice = index
    var trust_delta := 0
    var response := ""
    match index:
        0:
            trust_delta = -5
            response = "Money is useful. Wanting only money makes you predictable. That can still be useful to me."
        1:
            trust_delta = 8
            response = "Good. Access is worth more than cash if you know what to do with it."
        2:
            trust_delta = 15
            response = "That answer will either make you valuable or dangerous. I can work with both."
    if relationships == null or not is_instance_valid(relationships):
        relationships = get_tree().get_first_node_in_group("story_relationship_manager") as StoryRelationshipManager
    if relationships != null:
        relationships.unlock_contact("adrian_vale")
        relationships.adjust_relationship("adrian_vale", trust_delta)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("adrian_intro_choice", selected_choice)
        saves.set_flag("adrian_vale_unlocked", true)
        saves.autosave()
    dialogue.show_line("ADRIAN VALE", response + "\n\nWe start small. Do the next job exactly as agreed and we can discuss what comes after.")
    await get_tree().create_timer(2.8).timeout
    dialogue.close_dialogue()
    conversation_active = false
    step = 2
    _save_step()
    _complete()

func get_objective() -> String:
    if not active and not completed:
        return ""
    if completed:
        return "MISSION COMPLETE"
    match step:
        0: return "GO TO MARINA DISTRICT"
        1: return "TALK TO ADRIAN VALE"
        _: return "MISSION COMPLETE"

func _save_step() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("the_introduction_step", step)
        saves.autosave()

func _complete() -> void:
    if completed:
        return
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("THE INTRODUCTION", reward_cash, reward_rep)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("the_introduction_complete", true)
        saves.set_flag("adrian_vale_unlocked", true)
        saves.set_flag("the_introduction_step", 2)
    if campaign != null and campaign.get_current_id() == "the_introduction":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
