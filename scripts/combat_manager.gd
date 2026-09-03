extends Node
class_name CombatManager

@export var weapon_damage := 34.0
@export var weapon_range := 85.0
@export var fire_cooldown := 0.22

var player: VantaPlayerController
var _cooldown := 0.0

func _ready() -> void:
    add_to_group("combat_manager")
    call_deferred("_resolve")

func _process(delta: float) -> void:
    _cooldown = max(_cooldown - delta, 0.0)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("fire"):
        fire()

func fire() -> void:
    _resolve()
    if player == null or player.driving or _cooldown > 0.0:
        return
    var camera := player.player_camera
    if camera == null:
        return
    _cooldown = fire_cooldown
    var origin := camera.global_position
    var direction := -camera.global_transform.basis.z
    var end := origin + direction * weapon_range
    var query := PhysicsRayQueryParameters3D.create(origin, end)
    query.exclude = [player]
    query.collide_with_areas = true
    query.collide_with_bodies = true
    var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return
    var collider = hit.get("collider")
    if collider is Node:
        _apply_hit(collider as Node)

func _apply_hit(node: Node) -> void:
    var damage_target: Node = node
    while damage_target != null:
        if damage_target.has_method("apply_damage"):
            damage_target.call("apply_damage", weapon_damage, player)
            _report_weapon_crime(damage_target)
            return
        damage_target = damage_target.get_parent()

func _report_weapon_crime(target: Node) -> void:
    var wanted := get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    if wanted == null or player == null:
        return
    var severity := 2
    if target.is_in_group("police"):
        severity = 4
    wanted.report_crime(player.global_position, severity, player)

func _resolve() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
