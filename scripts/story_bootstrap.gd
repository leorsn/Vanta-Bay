extends Node

const StoryCampaignScript = preload("res://scripts/story_campaign.gd")
const FirstRunMissionScript = preload("res://scripts/first_run_mission.gd")
const NoQuestionsMissionScript = preload("res://scripts/no_questions_mission.gd")
const AfterMidnightMissionScript = preload("res://scripts/after_midnight_mission.gd")
const WrongPlaceMissionScript = preload("res://scripts/wrong_place_mission.gd")
const LoseThemMissionScript = preload("res://scripts/lose_them_mission.gd")
const CleanSlateMissionScript = preload("res://scripts/clean_slate_mission.gd")
const TheIntroductionMissionScript = preload("res://scripts/the_introduction_mission.gd")
const WorldClockScript = preload("res://scripts/world_clock.gd")

func _ready() -> void:
    get_tree().node_added.connect(_on_node_added)
    call_deferred("_ensure_story_runtime")

func _on_node_added(_node: Node) -> void:
    call_deferred("_ensure_story_runtime")

func _ensure_story_runtime() -> void:
    var root := get_tree().current_scene
    if root == null:
        return
    if get_tree().get_first_node_in_group("world_clock") == null:
        var clock := WorldClockScript.new()
        clock.name = "WorldClock"
        root.add_child(clock)
    if get_tree().get_first_node_in_group("story_campaign") == null:
        var campaign := StoryCampaignScript.new()
        campaign.name = "StoryCampaign"
        root.add_child(campaign)
    if get_tree().get_first_node_in_group("first_run_mission") == null:
        var first_run := FirstRunMissionScript.new()
        first_run.name = "FirstRunMission"
        root.add_child(first_run)
    if get_tree().get_first_node_in_group("no_questions_mission") == null:
        var no_questions := NoQuestionsMissionScript.new()
        no_questions.name = "NoQuestionsMission"
        root.add_child(no_questions)
    if get_tree().get_first_node_in_group("after_midnight_mission") == null:
        var after_midnight := AfterMidnightMissionScript.new()
        after_midnight.name = "AfterMidnightMission"
        root.add_child(after_midnight)
    if get_tree().get_first_node_in_group("wrong_place_mission") == null:
        var wrong_place := WrongPlaceMissionScript.new()
        wrong_place.name = "WrongPlaceMission"
        root.add_child(wrong_place)
    if get_tree().get_first_node_in_group("lose_them_mission") == null:
        var lose_them := LoseThemMissionScript.new()
        lose_them.name = "LoseThemMission"
        root.add_child(lose_them)
    if get_tree().get_first_node_in_group("clean_slate_mission") == null:
        var clean_slate := CleanSlateMissionScript.new()
        clean_slate.name = "CleanSlateMission"
        root.add_child(clean_slate)
    if get_tree().get_first_node_in_group("the_introduction_mission") == null:
        var introduction := TheIntroductionMissionScript.new()
        introduction.name = "TheIntroductionMission"
        root.add_child(introduction)
