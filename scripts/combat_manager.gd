extends Node
class_name CombatManager

signal ammo_changed(current: int, reserve: int)
signal reloading_changed(active: bool)

@export var weapon_damage := 34.0
@export var weapon_range := 85.0
@export var fire_cooldown := 0.22
@export var magazine_size := 15
@export var reserve_ammo := 75
@export var reload_time := 1.25

var player: VantaPlayerController
var ammo_in_mag := 15
var ammo_reserve := 75
var reloading := false
var _cooldown := 0.0

func _ready() -> void:
    add_to_group("combat_manager")
    ammo_in_mag = magazine_size
    ammo_reserve = reserve_ammo
    call_deferred("_resolve")
    call_deferred("_emit_ammo")

func _process(delta: float) -> void:
    _cooldown = max(_cooldown - delta, 0.0)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("fire"):
        fire()
    elif event.is_action_pressed("reload"):
        reload_weapon()

func fire() -> void:
    _resolve()
    if player == null or player.driving or _cooldown > 0.0 or reloading:
        return
    if ammo_in_mag <= 0:
        reload_weapon()
        return
    var camera := player.player_camera
    if camera == null:
        return
    ammo_in_mag -= 1
    _emit_ammo()
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
        var impact_position: Vector3 = hit.get("position", Vector3.ZERO)
        _apply_hit(collider as Node, impact_position)

func reload_weapon() -> void:
    if reloading or ammo_in_mag >= magazine_size or ammo_reserve <= 0:
        return
    reloading = true
    reloading_changed.emit(true)
    await get_tree().create_timer(reload_time).timeout
    var needed := magazine_size - ammo_in_mag
    var loaded := min(needed, ammo_reserve)
    ammo_in_mag += loaded
    ammo_reserve -= loaded
    reloading = false
    reloading_changed.emit(false)
    _emit_ammo()

func _apply_hit(node: Node, impact_position: Vector3) -> void:
    var damage_target: Node = node
    while damage_target != null:
        if damage_target.has_method("apply_damage"):
            var damage := weapon_damage * _damage_multiplier(damage_target, impact_position)
            damage_target.call("apply_damage", damage, player)
            _report_weapon_crime(damage_target)
            return
        damage_target = damage_target.get_parent()

func _damage_multiplier(target: Node, impact_position: Vector3) -> float:
    if target is Node3D:
        var local_y := impact_position.y - (target as Node3D).global_position.y
        if local_y > 1.35:
            return 2.0
        if local_y < 0.55:
            return 0.72
    return 1.0

func _report_weapon_crime(target: Node) -> void:
    var wanted := get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    if wanted == null or player == null:
        return
    var severity := 2
    if target.is_in_group("police"):
        severity = 4
    wanted.report_crime(player.global_position, severity, player)

func get_ammo_text() -> String:
    if reloading:
        return "RELOADING"
    return "%02d / %02d" % [ammo_in_mag, ammo_reserve]

func _emit_ammo() -> void:
    ammo_changed.emit(ammo_in_mag, ammo_reserve)

func _resolve() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
