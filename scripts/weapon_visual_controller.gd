extends Node3D
class_name WeaponVisualController

var player: VantaPlayerController
var combat: CombatManager
var inventory: WeaponInventory
var weapon_root: Node3D
var muzzle_flash: MeshInstance3D
var muzzle_light: OmniLight3D
var flash_timer := 0.0

func _ready() -> void:
    add_to_group("weapon_visual_controller")
    call_deferred("_bind_runtime")

func _process(delta: float) -> void:
    _bind_runtime()
    if player == null or weapon_root == null:
        return
    weapon_root.visible = not player.driving
    weapon_root.position = Vector3(0.38, 1.02, -0.18)
    weapon_root.rotation = Vector3(0.0, 0.0, deg_to_rad(-4.0))
    if player.aiming:
        weapon_root.position = Vector3(0.31, 1.08, -0.22)
    flash_timer = max(flash_timer - delta, 0.0)
    var active := flash_timer > 0.0
    if muzzle_flash != null:
        muzzle_flash.visible = active
    if muzzle_light != null:
        muzzle_light.visible = active

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
    var body_mesh := MeshInstance3D.new()
    var body_box := BoxMesh.new()
    var barrel_mesh := MeshInstance3D.new()
    var barrel_box := BoxMesh.new()
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.08, 0.09, 0.1, 1.0)
    material.metallic = 0.72
    material.roughness = 0.28
    match weapon_id:
        "smg":
            body_box.size = Vector3(0.16, 0.18, 0.52)
            barrel_box.size = Vector3(0.075, 0.075, 0.34)
            barrel_mesh.position = Vector3(0.0, 0.02, -0.40)
        "rifle":
            body_box.size = Vector3(0.16, 0.18, 0.72)
            barrel_box.size = Vector3(0.065, 0.065, 0.55)
            barrel_mesh.position = Vector3(0.0, 0.02, -0.62)
        _:
            body_box.size = Vector3(0.13, 0.18, 0.28)
            barrel_box.size = Vector3(0.065, 0.065, 0.20)
            barrel_mesh.position = Vector3(0.0, 0.03, -0.22)
    body_mesh.mesh = body_box
    body_mesh.material_override = material
    barrel_mesh.mesh = barrel_box
    barrel_mesh.material_override = material
    weapon_root.add_child(body_mesh)
    weapon_root.add_child(barrel_mesh)

    muzzle_flash = MeshInstance3D.new()
    var flash_mesh := SphereMesh.new()
    flash_mesh.radius = 0.06
    flash_mesh.height = 0.12
    muzzle_flash.mesh = flash_mesh
    var flash_material := StandardMaterial3D.new()
    flash_material.albedo_color = Color(1.0, 0.72, 0.28, 1.0)
    flash_material.emission_enabled = true
    flash_material.emission = Color(1.0, 0.52, 0.12, 1.0)
    muzzle_flash.material_override = flash_material
    muzzle_flash.position = barrel_mesh.position + Vector3(0.0, 0.0, -barrel_box.size.z * 0.55)
    muzzle_flash.visible = false
    weapon_root.add_child(muzzle_flash)

    muzzle_light = OmniLight3D.new()
    muzzle_light.light_energy = 2.4
    muzzle_light.omni_range = 2.8
    muzzle_light.position = muzzle_flash.position
    muzzle_light.visible = false
    weapon_root.add_child(muzzle_light)

func _on_weapon_changed(weapon_id: String, _data: Dictionary) -> void:
    _rebuild_weapon(weapon_id)

func _on_shot_fired(_origin: Vector3, _direction: Vector3) -> void:
    flash_timer = 0.055

func _on_impact_created(position: Vector3, normal: Vector3, hit_damageable: bool) -> void:
    var root := get_tree().current_scene
    if root == null:
        return
    var marker := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.035 if hit_damageable else 0.025
    mesh.height = mesh.radius * 2.0
    marker.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.92, 0.92, 0.92, 1.0) if hit_damageable else Color(0.25, 0.25, 0.25, 1.0)
    material.roughness = 0.8
    marker.material_override = material
    marker.global_position = position + normal * 0.015
    root.add_child(marker)
    var timer := get_tree().create_timer(0.18 if hit_damageable else 0.5)
    timer.timeout.connect(func():
        if is_instance_valid(marker):
            marker.queue_free()
    )
