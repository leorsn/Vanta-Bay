extends Node
class_name CombatManager

signal ammo_changed(current: int, reserve: int)
signal reloading_changed(active: bool)
signal weapon_changed(name: String)

var player: VantaPlayerController
var inventory: WeaponInventory
var ammo_in_mag := 0
var ammo_reserve := 0
var reloading := false
var _cooldown := 0.0
var _weapon := {}
var _ammo_state := {}

func _ready() -> void:
    add_to_group("combat_manager")
    call_deferred("_resolve")

func _process(delta: float) -> void:
    _cooldown = max(_cooldown - delta, 0.0)
    if inventory == null or not is_instance_valid(inventory):
        _resolve()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("fire"):
        fire()
    elif event.is_action_pressed("reload"):
        reload_weapon()

func fire() -> void:
    _resolve()
    if player == null or player.driving or _cooldown > 0.0 or reloading or _weapon.is_empty():
        return
    if ammo_in_mag <= 0:
        reload_weapon()
        return
    var camera := player.player_camera
    if camera == null:
        return
    ammo_in_mag -= 1
    _store_ammo_state()
    _emit_ammo()
    _cooldown = float(_weapon.get("cooldown", 0.22))
    var origin := camera.global_position
    var direction := -camera.global_transform.basis.z
    var end := origin + direction * float(_weapon.get("range", 85.0))
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
    if _weapon.is_empty():
        return
    var magazine_size := int(_weapon.get("magazine", 15))
    if reloading or ammo_in_mag >= magazine_size or ammo_reserve <= 0:
        return
    reloading = true
    reloading_changed.emit(true)
    await get_tree().create_timer(float(_weapon.get("reload", 1.25))).timeout
    var needed := magazine_size - ammo_in_mag
    var loaded := min(needed, ammo_reserve)
    ammo_in_mag += loaded
    ammo_reserve -= loaded
    _store_ammo_state()
    reloading = false
    reloading_changed.emit(false)
    _emit_ammo()

func _apply_hit(node: Node, impact_position: Vector3) -> void:
    var damage_target: Node = node
    while damage_target != null:
        if damage_target.has_method("apply_damage"):
            var base_damage := float(_weapon.get("damage", 34.0))
            var damage := base_damage * _damage_multiplier(damage_target, impact_position)
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

func get_weapon_name() -> String:
    return str(_weapon.get("name", "WEAPON"))

func _on_weapon_changed(weapon_id: String, data: Dictionary) -> void:
    _store_ammo_state()
    _weapon = data.duplicate(true)
    var state: Dictionary = _ammo_state.get(weapon_id, {})
    if state.is_empty():
        ammo_in_mag = int(_weapon.get("magazine", 15))
        ammo_reserve = int(_weapon.get("reserve", 60))
    else:
        ammo_in_mag = int(state.get("mag", _weapon.get("magazine", 15)))
        ammo_reserve = int(state.get("reserve", _weapon.get("reserve", 60)))
    _emit_ammo()
    weapon_changed.emit(get_weapon_name())

func _store_ammo_state() -> void:
    if inventory == null or _weapon.is_empty():
        return
    _ammo_state[inventory.equipped_id] = {"mag": ammo_in_mag, "reserve": ammo_reserve}

func _emit_ammo() -> void:
    ammo_changed.emit(ammo_in_mag, ammo_reserve)

func _resolve() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
    if inventory == null or not is_instance_valid(inventory):
        inventory = get_tree().get_first_node_in_group("weapon_inventory") as WeaponInventory
        if inventory != null:
            if not inventory.weapon_changed.is_connected(_on_weapon_changed):
                inventory.weapon_changed.connect(_on_weapon_changed)
            _on_weapon_changed(inventory.equipped_id, inventory.get_current())
