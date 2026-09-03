extends Node3D
class_name WeaponVisualController

var player: VantaPlayerController
var combat: CombatManager
var inventory: WeaponInventory
var weapon_root: Node3D
var muzzle_flash: Node3D
var muzzle_light: OmniLight3D
var flash_timer := 0.0
var recoil_kick := 0.0

func _ready() -> void:
    add_to_group("weapon_visual_controller")
    call_deferred("_bind_runtime")

func _process(delta: float) -> void:
    _bind_runtime()
    if player == null or weapon_root == null:
        return
    weapon_root.visible = not player.driving
    var base_position := Vector3(0.38, 1.02, -0.18)
    if player.aiming:
        base_position = Vector3(0.31, 1.08, -0.22)
    recoil_kick = lerpf(recoil_kick, 0.0, clampf(delta * 16.0, 0.0, 1.0))
    weapon_root.position = base_position + Vector3(0.0, 0.0, recoil_kick)
    weapon_root.rotation = Vector3(deg_to_rad(-recoil_kick * 26.0), 0.0, deg_to_rad(-4.0))
    flash_timer = maxf(flash_timer - delta, 0.0)
    var active := flash_timer > 0.0
    if muzzle_flash != null:
        muzzle_flash.visible = active
        if active:
            var flicker := randf_range(0.82, 1.22)
            muzzle_flash.scale = Vector3(flicker, flicker, flicker)
    if muzzle_light != null:
        muzzle_light.visible = active
        if active:
            muzzle_light.light_energy = randf_range(2.8, 4.8)

func _bind_runtime() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
        if player != null and weapon_root == null:
            _build_weapon_root()
    if combat == null or not is_instance_valid(combat):
        combat = get_tree().get_first_node_in_group("combat_manager") as CombatManager
        if combat != null:
            if not combat.shot_fired.is_connected(_on_shot_fired):
                combat.shot_fired.connect(_on_shot_fired)
            if not combat.impact_created.is_connected(_on_impact_created):
                combat.impact_created.connect(_on_impact_created)
    if inventory == null or not is_instance_valid(inventory):
        inventory = get_tree().get_first_node_in_group("weapon_inventory") as WeaponInventory
        if inventory != null:
            if not inventory.weapon_changed.is_connected(_on_weapon_changed):
                inventory.weapon_changed.connect(_on_weapon_changed)
            _on_weapon_changed(inventory.equipped_id, inventory.get_current())

func _build_weapon_root() -> void:
    weapon_root = Node3D.new()
    weapon_root.name = "WeaponVisual"
    player.add_child(weapon_root)
    _rebuild_weapon("pistol")

func _rebuild_weapon(weapon_id: String) -> void:
    if weapon_root == null:
        return
    for child in weapon_root.get_children():
        child.queue_free()
    var gunmetal := _material(Color(0.055, 0.06, 0.068, 1.0), 0.22, 0.82)
    var black_polymer := _material(Color(0.025, 0.028, 0.032, 1.0), 0.60, 0.18)
    var steel := _material(Color(0.23, 0.24, 0.26, 1.0), 0.18, 0.92)
    var muzzle_z := -0.34

    match weapon_id:
        "smg":
            _box("Receiver", Vector3(0.0, 0.0, -0.12), Vector3(0.17, 0.19, 0.55), gunmetal)
            _box("Handguard", Vector3(0.0, 0.0, -0.46), Vector3(0.14, 0.16, 0.28), black_polymer)
            _box("Grip", Vector3(0.0, -0.18, -0.02), Vector3(0.12, 0.31, 0.15), black_polymer, Vector3(deg_to_rad(-12.0), 0.0, 0.0))
            _box("Magazine", Vector3(0.0, -0.20, -0.22), Vector3(0.11, 0.33, 0.14), steel, Vector3(deg_to_rad(7.0), 0.0, 0.0))
            _box("Stock", Vector3(0.0, 0.01, 0.27), Vector3(0.13, 0.15, 0.32), black_polymer)
            _box("TopRail", Vector3(0.0, 0.115, -0.17), Vector3(0.09, 0.035, 0.44), steel)
            _box("Sight", Vector3(0.0, 0.17, -0.17), Vector3(0.07, 0.075, 0.10), black_polymer)
            _cylinder("Barrel", Vector3(0.0, 0.0, -0.72), 0.035, 0.32, steel)
            muzzle_z = -0.90
        "rifle":
            _box("Receiver", Vector3(0.0, 0.0, -0.14), Vector3(0.18, 0.20, 0.68), gunmetal)
            _box("Handguard", Vector3(0.0, 0.0, -0.61), Vector3(0.15, 0.17, 0.43), black_polymer)
            _box("Grip", Vector3(0.0, -0.19, -0.02), Vector3(0.12, 0.33, 0.15), black_polymer, Vector3(deg_to_rad(-14.0), 0.0, 0.0))
            _box("Magazine", Vector3(0.0, -0.22, -0.27), Vector3(0.12, 0.39, 0.17), steel, Vector3(deg_to_rad(9.0), 0.0, 0.0))
            _box("Stock", Vector3(0.0, -0.01, 0.35), Vector3(0.15, 0.18, 0.42), black_polymer)
            _box("TopRail", Vector3(0.0, 0.125, -0.28), Vector3(0.09, 0.035, 0.74), steel)
            _box("Optic", Vector3(0.0, 0.19, -0.18), Vector3(0.10, 0.10, 0.18), black_polymer)
            _cylinder("Barrel", Vector3(0.0, 0.0, -0.98), 0.032, 0.50, steel)
            muzzle_z = -1.24
        _:
            _box("Slide", Vector3(0.0, 0.05, -0.10), Vector3(0.14, 0.16, 0.36), gunmetal)
            _box("Frame", Vector3(0.0, -0.055, -0.06), Vector3(0.13, 0.12, 0.28), black_polymer)
            _box("Grip", Vector3(0.0, -0.20, 0.02), Vector3(0.12, 0.31, 0.16), black_polymer, Vector3(deg_to_rad(-13.0), 0.0, 0.0))
            _box("FrontSight", Vector3(0.0, 0.155, -0.24), Vector3(0.025, 0.04, 0.035), steel)
            _box("RearSight", Vector3(0.0, 0.155, 0.02), Vector3(0.08, 0.035, 0.035), steel)
            _cylinder("Barrel", Vector3(0.0, 0.045, -0.34), 0.026, 0.18, steel)
            muzzle_z = -0.44

    muzzle_flash = Node3D.new()
    muzzle_flash.name = "MuzzleFlash"
    muzzle_flash.position = Vector3(0.0, 0.02, muzzle_z)
    muzzle_flash.visible = false
    weapon_root.add_child(muzzle_flash)
    _flash_cone(muzzle_flash, Vector3.ZERO, 0.075, 0.22)
    _flash_cone(muzzle_flash, Vector3.ZERO, 0.050, 0.14, Vector3(0.0, 0.0, deg_to_rad(90.0)))

    muzzle_light = OmniLight3D.new()
    muzzle_light.light_color = Color(1.0, 0.55, 0.20, 1.0)
    muzzle_light.light_energy = 3.4
    muzzle_light.omni_range = 3.4
    muzzle_light.position = muzzle_flash.position
    muzzle_light.visible = false
    weapon_root.add_child(muzzle_light)

func _on_weapon_changed(weapon_id: String, _data: Dictionary) -> void:
    _rebuild_weapon(weapon_id)

func _on_shot_fired(_origin: Vector3, _direction: Vector3) -> void:
    flash_timer = 0.06
    recoil_kick = 0.055 if player != null and player.aiming else 0.085

func _on_impact_created(_position: Vector3, _normal: Vector3, _hit_damageable: bool) -> void:
    pass

func _box(node_name: String, position_value: Vector3, size: Vector3, material: StandardMaterial3D, rotation_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
    node.rotation = rotation_value
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = material
    weapon_root.add_child(node)
    return node

func _cylinder(node_name: String, position_value: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = node_name
    node.position = position_value
    node.rotation_degrees.x = 90.0
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    node.mesh = mesh
    node.material_override = material
    weapon_root.add_child(node)
    return node

func _flash_cone(parent: Node3D, position_value: Vector3, radius: float, height: float, rotation_value: Vector3 = Vector3.ZERO) -> void:
    var flash := MeshInstance3D.new()
    flash.position = position_value
    flash.rotation = rotation_value + Vector3(deg_to_rad(90.0), 0.0, 0.0)
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = radius
    mesh.height = height
    flash.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.72, 0.28, 0.96)
    mat.emission_enabled = true
    mat.emission = Color(1.0, 0.40, 0.08, 1.0)
    mat.emission_energy_multiplier = 5.0
    flash.material_override = mat
    parent.add_child(flash)

func _material(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material
