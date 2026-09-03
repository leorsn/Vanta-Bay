extends CharacterBody3D
class_name VantaPoliceAgent

const HealthComponentScript = preload("res://scripts/health_component.gd")
const VehicleVisualScript = preload("res://scripts/vehicle_visual.gd")

@export var patrol_speed := 6.0
@export var pursuit_speed := 13.0
@export var turn_speed := 3.4
@export var sight_distance := 34.0
@export var stop_distance := 3.5
@export var unit_index := 0
@export var fire_range := 28.0
@export var fire_damage := 8.0
@export var fire_interval := 0.9

var wanted: WantedManager
var search_offset := Vector3.ZERO
var health_component: HealthComponent
var _fire_cooldown := 0.0
var visual_root: VantaVehicleVisual

func _ready() -> void:
    add_to_group("police")
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    search_offset = _make_search_offset(unit_index)
    var body := get_node_or_null("Body") as MeshInstance3D
    if body != null:
        body.visible = false
    visual_root = VehicleVisualScript.new() as VantaVehicleVisual
    visual_root.police_variant = true
    visual_root.body_color = Color(0.025, 0.04, 0.065, 1.0)
    add_child(visual_root)
    health_component = HealthComponentScript.new()
    health_component.name = "Health"
    health_component.max_health = 120.0
    add_child(health_component)
    health_component.died.connect(_on_died)

func _physics_process(delta: float) -> void:
    _fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
    if health_component != null and health_component.is_dead():
        velocity = Vector3.ZERO
        return
    if wanted == null or wanted.state == "NONE" or wanted.state == "ESCAPED" or not _is_unit_active():
        velocity = velocity.move_toward(Vector3.ZERO, patrol_speed * delta)
        move_and_slide()
        return

    var destination: Vector3 = wanted.get_search_position() + search_offset
    var target: Node3D = wanted.target
    if wanted.state == "PURSUIT" and target != null and is_instance_valid(target):
        if _has_line_of_sight(target):
            destination = target.global_position
            wanted.confirm_sighting(target.global_position, target)
            _try_fire(target)
        else:
            destination = wanted.get_search_position() + search_offset

    var flat: Vector3 = destination - global_position
    flat.y = 0.0
    if flat.length() <= stop_distance:
        velocity = velocity.move_toward(Vector3.ZERO, pursuit_speed * delta)
        move_and_slide()
        return

    var direction: Vector3 = flat.normalized()
    var desired_angle: float = atan2(direction.x, direction.z)
    rotation.y = lerp_angle(rotation.y, desired_angle, turn_speed * delta)
    var speed: float = pursuit_speed if wanted.state == "PURSUIT" else patrol_speed
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    if not is_on_floor():
        velocity.y -= float(ProjectSettings.get_setting("physics/3d/default_gravity")) * delta
    else:
        velocity.y = -0.2
    move_and_slide()

func apply_damage(amount: float, source: Node = null) -> void:
    if health_component == null:
        return
    if health_component.apply_damage(amount, source) and source is Node3D and wanted != null:
        wanted.report_crime((source as Node3D).global_position, 4, source as Node3D)

func _try_fire(target: Node3D) -> void:
    if _fire_cooldown > 0.0:
        return
    var distance: float = global_position.distance_to(target.global_position)
    if distance > fire_range or not _has_line_of_sight(target):
        return
    _fire_cooldown = fire_interval + float(unit_index) * 0.08
    if target.has_method("apply_damage"):
        var distance_factor: float = clampf(distance / fire_range, 0.0, 1.0)
        var damage: float = fire_damage * lerpf(1.0, 0.72, distance_factor)
        target.call("apply_damage", damage, self)

func _on_died(source: Node) -> void:
    set_physics_process(false)
    velocity = Vector3.ZERO
    collision_layer = 0
    collision_mask = 0
    visible = false
    if source is Node3D and wanted != null:
        wanted.report_crime((source as Node3D).global_position, 5, source as Node3D)

func _is_unit_active() -> bool:
    if wanted == null:
        return false
    var required_units: int = 1
    if wanted.stars >= 2:
        required_units = 2
    if wanted.stars >= 3:
        required_units = 3
    return unit_index < required_units

func _has_line_of_sight(target: Node3D) -> bool:
    var origin: Vector3 = global_position + Vector3.UP * 1.2
    var target_point: Vector3 = target.global_position + Vector3.UP * 1.0
    if origin.distance_to(target_point) > sight_distance:
        return false
    var query := PhysicsRayQueryParameters3D.create(origin, target_point)
    query.exclude = [self]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit.is_empty():
        return true
    var collider = hit.get("collider")
    return collider == target or (collider is Node and target.is_ancestor_of(collider))

func _make_search_offset(index: int) -> Vector3:
    var offsets: Array[Vector3] = [
        Vector3.ZERO,
        Vector3(12.0, 0.0, 8.0),
        Vector3(-11.0, 0.0, 10.0),
        Vector3(8.0, 0.0, -13.0),
        Vector3(-14.0, 0.0, -7.0)
    ]
    return offsets[index % offsets.size()]
