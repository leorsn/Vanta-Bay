extends Node
class_name TermsConditionsMission

@export var base_reward_cash := 9500
@export var trusted_bonus_cash := 2500
@export var reward_rep := 18
@export var trusted_bonus_rep := 3
@export var finance_tower_position := Vector3(22.0, 1.0, -8.0)
@export var contract_drop_position := Vector3(-18.0, 1.0, 34.0)
@export var private_handoff_position := Vector3(42.0, 1.0, -36.0)
@export var reach_radius := 7.0

var active := false
var completed := false
var step := 0
var player: Node3D
var campaign: StoryCampaign
var relationships: StoryRelationshipManager
var branch := "standard"
var adrian_trust := 0

func _ready() -> void:
    add_to_group("terms_conditions_mission")
    call_deferred("_bind_runtime")

func _bind_runtime() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    player = get_tree().get_first_node_in_group("player") as Node3D
    relationships = get_tree().get_first_node_in_group("story_relationship_manager") as StoryRelationshipManager
    if campaign != null:
        if not campaign.chapter_changed.is_connected(_on_chapter_changed):
            campaign.chapter_changed.connect(_on_chapter_changed)
        _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _process(_delta: float) -> void:
    if not active:
        return
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as Node3D
        return

    if step == 0 and player.global_position.distance_to(finance_tower_position) <= reach_radius:
        step = 1
        _save_step()
        return

    if step == 1:
        var target := private_handoff_position if branch == "trusted" else contract_drop_position
        if player.global_position.distance_to(target) <= reach_radius:
            step = 2
            _save_step()
            _complete()

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    active = mission_id == "terms_conditions" and not completed
    if not active:
        return
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        step = int(saves.get_flag("terms_conditions_step", step))
        branch = str(saves.get_flag("terms_conditions_branch", ""))
    _resolve_branch()

func _resolve_branch() -> void:
    if relationships == null or not is_instance_valid(relationships):
        relationships = get_tree().get_first_node_in_group("story_relationship_manager") as StoryRelationshipManager
    adrian_trust = relationships.get_relationship("adrian_vale") if relationships != null else 0
    if branch.is_empty():
        branch = "trusted" if adrian_trust >= 10 else "standard"
        var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
        if saves != null:
            saves.set_flag("terms_conditions_branch", branch)
            saves.set_flag("terms_conditions_adrian_trust", adrian_trust)
            saves.autosave()

func get_objective() -> String:
    if not active and not completed:
        return ""
    if completed:
        return "MISSION COMPLETE"
    match step:
        0:
            return "MEET ADRIAN'S LEGAL TEAM"
        1:
            if branch == "trusted":
                return "DELIVER THE FILES TO ADRIAN'S PRIVATE HANDOFF"
            return "DELIVER THE SIGNED PACKAGE"
        _:
            return "MISSION COMPLETE"

func get_branch_label() -> String:
    return "PRIVATE ACCESS" if branch == "trusted" else "STANDARD CONTRACT"

func get_effective_reward_cash() -> int:
    return base_reward_cash + (trusted_bonus_cash if branch == "trusted" else 0)

func get_effective_reward_rep() -> int:
    return reward_rep + (trusted_bonus_rep if branch == "trusted" else 0)

func _save_step() -> void:
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("terms_conditions_step", step)
        saves.set_flag("terms_conditions_branch", branch)
        saves.autosave()

func _complete() -> void:
    if completed:
        return
    completed = true
    active = false
    var economy := get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.award_mission("TERMS & CONDITIONS", get_effective_reward_cash(), get_effective_reward_rep())
    if relationships == null or not is_instance_valid(relationships):
        relationships = get_tree().get_first_node_in_group("story_relationship_manager") as StoryRelationshipManager
    if relationships != null:
        relationships.adjust_relationship("adrian_vale", 8 if branch == "trusted" else 4)
    var saves := get_tree().get_first_node_in_group("story_save_manager") as StorySaveManager
    if saves != null:
        saves.set_flag("terms_conditions_complete", true)
        saves.set_flag("adrian_network_access", true)
        saves.set_flag("adrian_private_access", branch == "trusted")
        saves.set_flag("terms_conditions_branch", branch)
        saves.set_flag("terms_conditions_step", 2)
    if campaign != null and campaign.get_current_id() == "terms_conditions":
        campaign.complete_current()
    elif saves != null:
        saves.autosave()
