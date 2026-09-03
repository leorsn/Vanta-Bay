extends Node
class_name StoryCombatDirector

signal encounter_started(mission_id: String, enemy_count: int)
signal encounter_cleared(mission_id: String)

const HostileAgentScript = preload("res://scripts/hostile_agent.gd")
const CoverPointScript = preload("res://scripts/combat_cover_point.gd")

var campaign: StoryCampaign
var spawned_for_mission := ""
var active_hostiles: Array[Node] = []
var encounter_props: Array[Node] = []

func _ready() -> void:
    add_to_group("story_combat_director")
    call_deferred("_bind_campaign")

func _bind_campaign() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign == null:
        return
    if not campaign.chapter_changed.is_connected(_on_chapter_changed):
        campaign.chapter_changed.connect(_on_chapter_changed)

func _on_chapter_changed(_mission_id: String, _title: String) -> void:
    _clear_hostiles()
    _clear_encounter_props()
    spawned_for_mission = ""

func begin_encounter(mission_id: String) -> void:
    if spawned_for_mission == mission_id and not active_hostiles.is_empty():
        return
    _clear_hostiles()
    _clear_encounter_props()
    spawned_for_mission = mission_id
    match mission_id:
        "after_midnight":
            _spawn_cover_layout([
                [Vector3(-31.0, 0.6, 23.5), 0.15],
                [Vector3(-37.0, 0.6, 18.5), -0.25]
            ])
            _spawn_wave([
                Vector3(-34.0, 1.0, 22.0),
                Vector3(-27.0, 1.0, 27.0)
            ])
        "wrong_place":
            _spawn_cover_layout([
                [Vector3(24.0, 0.6, 31.0), 0.0],
                [Vector3(32.0, 0.6, 32.5), 0.3],
                [Vector3(29.5, 0.6, 25.5), -0.2]
            ])
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
        root.add_child(hostile)
        hostile.global_position = spawn_position
        hostile.defeated.connect(_on_hostile_defeated)
        active_hostiles.append(hostile)
    if not active_hostiles.is_empty():
        encounter_started.emit(spawned_for_mission, active_hostiles.size())

func _spawn_cover_layout(entries: Array) -> void:
    var root := get_tree().current_scene
    if root == null:
        return
    for entry in entries:
        var position: Vector3 = entry[0]
        var rotation_y: float = float(entry[1])
        var barrier := StaticBody3D.new()
        barrier.name = "CombatBarrier"
        barrier.global_position = position
        barrier.rotation.y = rotation_y

        var collider := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = Vector3(2.8, 1.2, 0.55)
        collider.shape = shape
        barrier.add_child(collider)

        var visual := MeshInstance3D.new()
        var mesh := BoxMesh.new()
        mesh.size = shape.size
        visual.mesh = mesh
        var material := StandardMaterial3D.new()
        material.albedo_color = Color(0.19, 0.2, 0.21, 1.0)
        material.roughness = 0.88
        visual.material_override = material
        barrier.add_child(visual)
        root.add_child(barrier)
        encounter_props.append(barrier)

        var forward := Vector3(sin(rotation_y), 0.0, cos(rotation_y))
        for side in [-1.0, 1.0]:
            var point := CoverPointScript.new() as CombatCoverPoint
            point.name = "CombatCoverPoint"
            root.add_child(point)
            point.global_position = position + forward * 0.85 + Vector3(cos(rotation_y), 0.0, -sin(rotation_y)) * side * 0.75
            encounter_props.append(point)

func _on_hostile_defeated(agent: Node) -> void:
    active_hostiles.erase(agent)
    if active_hostiles.is_empty() and not spawned_for_mission.is_empty():
        encounter_cleared.emit(spawned_for_mission)

func get_remaining_hostiles() -> int:
    var alive := 0
    for hostile in active_hostiles:
        if is_instance_valid(hostile) and hostile.visible:
            alive += 1
    return alive

func _clear_hostiles() -> void:
    for hostile in active_hostiles:
        if is_instance_valid(hostile):
            hostile.queue_free()
    active_hostiles.clear()

func _clear_encounter_props() -> void:
    for prop in encounter_props:
        if is_instance_valid(prop):
            prop.queue_free()
    encounter_props.clear()
