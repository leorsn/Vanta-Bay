extends Node

const StoryCampaignScript = preload("res://scripts/story_campaign.gd")
const FirstRunMissionScript = preload("res://scripts/first_run_mission.gd")
const NoQuestionsMissionScript = preload("res://scripts/no_questions_mission.gd")
const AfterMidnightMissionScript = preload("res://scripts/after_midnight_mission.gd")
const WrongPlaceMissionScript = preload("res://scripts/wrong_place_mission.gd")
const LoseThemMissionScript = preload("res://scripts/lose_them_mission.gd")
const CleanSlateMissionScript = preload("res://scripts/clean_slate_mission.gd")
const TheIntroductionMissionScript = preload("res://scripts/the_introduction_mission.gd")
const TermsConditionsMissionScript = preload("res://scripts/terms_conditions_mission.gd")
const OverheadMissionScript = preload("res://scripts/overhead_mission.gd")
const WorldClockScript = preload("res://scripts/world_clock.gd")
const StoryHUDScript = preload("res://scripts/story_hud.gd")
const MissionCheckpointManagerScript = preload("res://scripts/mission_checkpoint_manager.gd")
const WeaponInventoryScript = preload("res://scripts/weapon_inventory.gd")
const CombatManagerScript = preload("res://scripts/combat_manager.gd")
const CombatHUDScript = preload("res://scripts/combat_hud.gd")
const WeaponVisualControllerScript = preload("res://scripts/weapon_visual_controller.gd")
const StoryCombatDirectorScript = preload("res://scripts/story_combat_director.gd")
const StoryRelationshipManagerScript = preload("res://scripts/story_relationship_manager.gd")
const StoryDialogueUIScript = preload("res://scripts/story_dialogue_ui.gd")
const AdrianValeNPCScript = preload("res://scripts/adrian_vale_npc.gd")
const CinematicQualityControllerScript = preload("res://scripts/cinematic_quality_controller.gd")
const PlayerMotionVisualControllerScript = preload("res://scripts/player_motion_visual_controller.gd")
const RenderQualityControllerScript = preload("res://scripts/render_quality_controller.gd")
const WaterVisualControllerScript = preload("res://scripts/water_visual_controller.gd")
const CityDetailControllerScript = preload("res://scripts/city_detail_controller.gd")

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
    if get_tree().get_first_node_in_group("story_relationship_manager") == null:
        var relationships := StoryRelationshipManagerScript.new()
        relationships.name = "StoryRelationshipManager"
        root.add_child(relationships)
    if get_tree().get_first_node_in_group("story_dialogue_ui") == null:
        var dialogue := StoryDialogueUIScript.new()
        dialogue.name = "StoryDialogueUI"
        root.add_child(dialogue)
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
    if get_tree().get_first_node_in_group("terms_conditions_mission") == null:
        var terms := TermsConditionsMissionScript.new()
        terms.name = "TermsConditionsMission"
        root.add_child(terms)
    if get_tree().get_first_node_in_group("overhead_mission") == null:
        var overhead := OverheadMissionScript.new()
        overhead.name = "OverheadMission"
        root.add_child(overhead)
    if get_tree().get_first_node_in_group("adrian_vale") == null:
        var adrian := AdrianValeNPCScript.new()
        adrian.name = "AdrianVale"
        adrian.global_position = Vector3(46.0, 1.0, -42.0)
        root.add_child(adrian)
    if get_tree().get_first_node_in_group("story_hud") == null:
        var hud := StoryHUDScript.new()
        hud.name = "StoryHUD"
        root.add_child(hud)
    if get_tree().get_first_node_in_group("mission_checkpoint_manager") == null:
        var checkpoints := MissionCheckpointManagerScript.new()
        checkpoints.name = "MissionCheckpointManager"
        root.add_child(checkpoints)
    if get_tree().get_first_node_in_group("weapon_inventory") == null:
        var inventory := WeaponInventoryScript.new()
        inventory.name = "WeaponInventory"
        root.add_child(inventory)
    if get_tree().get_first_node_in_group("combat_manager") == null:
        var combat := CombatManagerScript.new()
        combat.name = "CombatManager"
        root.add_child(combat)
    if get_tree().get_first_node_in_group("combat_hud") == null:
        var combat_hud := CombatHUDScript.new()
        combat_hud.name = "CombatHUD"
        root.add_child(combat_hud)
    if get_tree().get_first_node_in_group("weapon_visual_controller") == null:
        var weapon_visuals := WeaponVisualControllerScript.new()
        weapon_visuals.name = "WeaponVisualController"
        root.add_child(weapon_visuals)
    if get_tree().get_first_node_in_group("story_combat_director") == null:
        var combat_director := StoryCombatDirectorScript.new()
        combat_director.name = "StoryCombatDirector"
        root.add_child(combat_director)
    if get_tree().get_first_node_in_group("cinematic_quality_controller") == null:
        var cinematic := CinematicQualityControllerScript.new()
        cinematic.name = "CinematicQualityController"
        root.add_child(cinematic)
    if get_tree().get_first_node_in_group("player_motion_visual_controller") == null:
        var motion := PlayerMotionVisualControllerScript.new()
        motion.name = "PlayerMotionVisualController"
        root.add_child(motion)
    if get_tree().get_first_node_in_group("render_quality_controller") == null:
        var render_quality := RenderQualityControllerScript.new()
        render_quality.name = "RenderQualityController"
        root.add_child(render_quality)
    if get_tree().get_first_node_in_group("water_visual_controller") == null:
        var water_visual := WaterVisualControllerScript.new()
        water_visual.name = "WaterVisualController"
        root.add_child(water_visual)
    if get_tree().get_first_node_in_group("city_detail_controller") == null:
        var city_detail := CityDetailControllerScript.new()
        city_detail.name = "CityDetailController"
        root.add_child(city_detail)
