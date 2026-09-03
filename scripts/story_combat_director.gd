extends Node
class_name StoryCombatDirector

const HostileAgentScript = preload("res://scripts/hostile_agent.gd")

var campaign: StoryCampaign
var spawned_for_mission := ""
var active_hostiles: Array[Node] = []

func _ready() -> void:
    add_to_group("story_combat_director")
    call_deferred("_bind_campaign")

func _bind_campaign() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign == null:
        return
    if not campaign.chapter_changed.is_connected(_on_chapter_changed):
        campaign.chapter_changed.connect(_on_chapter_changed)
    _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    _clear_hostiles()
    spawned_for_mission = mission_id
    match mission_id:
        "after_midnight":
            _spawn_wave([
                Vector3(-34.0, 1.0, 22.0),
                Vector3(-27.0, 1.0, 27.0)
            ])
        "wrong_place":
            _spawn_wave([
                Vector3(21.0, 1.0, 34.0),
                Vector3(34.0, 1.0, 35.0),
                Vector3(31.0, 1.0, 24.0)
            ])

func _spawn_wave(positions: Array) -> void:
    var root := get_tree().current_scene
    if root == null:
        return
    for spawn_position in positions:
        var hostile := HostileAgentScript.new()
        hostile.name = "StoryHostile"
        hostile.global_position = spawn_position
        root.add_child(hostile)
        active_hostiles.append(hostile)

func _clear_hostiles() -> void:
    for hostile in active_hostiles:
        if is_instance_valid(hostile):
            hostile.queue_free()
    active_hostiles.clear()
