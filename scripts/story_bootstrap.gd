extends Node

const StoryCampaignScript = preload("res://scripts/story_campaign.gd")
const FirstRunMissionScript = preload("res://scripts/first_run_mission.gd")
const LoseThemMissionScript = preload("res://scripts/lose_them_mission.gd")

func _ready() -> void:
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_ensure_story_runtime")

func _on_node_added(_node: Node) -> void:
    call_deferred("_ensure_story_runtime")

func _ensure_story_runtime() -> void:
    var root := get_tree().current_scene
    if root == null:
        return
    if get_tree().get_first_node_in_group("story_campaign") == null:
        var campaign := StoryCampaignScript.new()
        campaign.name = "StoryCampaign"
        root.add_child(campaign)
    if get_tree().get_first_node_in_group("first_run_mission") == null:
        var first_run := FirstRunMissionScript.new()
        first_run.name = "FirstRunMission"
        root.add_child(first_run)
    if get_tree().get_first_node_in_group("lose_them_mission") == null:
        var lose_them := LoseThemMissionScript.new()
        lose_them.name = "LoseThemMission"
        root.add_child(lose_them)
