extends Node
class_name VantaCombatVFXController

var combat: CombatManager
var _root: Node3D

func _ready() -> void:
    add_to_group("combat_vfx_controller")
    call_deferred("_bind")

func _process(_delta: float) -> void:
    if combat == null or not is_instance_valid(combat):
        _bind()

func _bind() -> void:
    _root = get_tree().current_scene as Node3D
    combat = get_tree().get_first_node_in_group("combat_manager") as CombatManager
    if combat == null:
        return
    if not combat.shot_fired.is_connected(_on_shot_fired):
        combat.shot_fired.connect(_on_shot_fired)
    if not combat.impact_created.is_connected(_on_impact_created):
        combat.impact_created.connect(_on_impact_created)

func _on_shot_fired(origin: Vector3, direction: Vector3) -> void:
    if _root == null:
        return
    var start := origin + direction * 0.65
    var finish := origin + direction * 9.5
    _spawn_tracer(start, finish)

func _on_impact_created(position: Vector3, normal: Vector3, hit_damageable: bool) -> void:
    if _root == null:
        return
    if hit_damageable:
        _spawn_hit_puff(position, normal, Color(0.42, 0.08, 0.055, 0.72))
    else:
        _spawn_bullet_mark(position, normal)
        _spawn_sparks(position, normal)
        _spawn_hit_puff(position, normal, Color(0.43, 0.40, 0.34, 0.42))

func _spawn_tracer(start: Vector3, finish: Vector3) -> void:
    var length := start.distance_to(finish)
    var tracer := MeshInstance3D.new()
    tracer.name = "BulletTracer"
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.009
    mesh.bottom_radius = 0.009
    mesh.height = length
    tracer.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.72, 0.28, 0.82)
    mat.emission_enabled = true
    mat.emission = Color(1.0, 0.46, 0.10, 1.0)
    mat.emission_energy_multiplier = 4.0
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    tracer.material_override = mat
    var midpoint := (start + finish) * 0.5
    tracer.global_position = midpoint
    tracer.look_at_from_position(midpoint, finish, Vector3.UP)
    tracer.rotate_x(PI * 0.5)
    _root.add_child(tracer)
    var tween := tracer.create_tween()
    tween.tween_property(tracer, "scale", Vector3(0.25, 0.08, 0.25), 0.055)
    tween.tween_callback(tracer.queue_free)

func _spawn_bullet_mark(position: Vector3, normal: Vector3) -> void:
    var mark := MeshInstance3D.new()
    mark.name = "BulletMark"
    var mesh := SphereMesh.new()
    mesh.radius = 0.055
    mesh.height = 0.018
    mark.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.035, 0.032, 0.028, 0.96)
    mat.roughness = 0.95
    mark.material_override = mat
    mark.global_position = position + normal * 0.012
    mark.scale = Vector3(1.0, 0.22, 1.0)
    _root.add_child(mark)
    var timer := get_tree().create_timer(20.0)
    timer.timeout.connect(func():
        if is_instance_valid(mark):
            mark.queue_free()
    )

func _spawn_sparks(position: Vector3, normal: Vector3) -> void:
    for i in range(7):
        var spark := MeshInstance3D.new()
        spark.name = "ImpactSpark"
        var mesh := BoxMesh.new()
        mesh.size = Vector3(0.012, 0.012, 0.18)
        spark.mesh = mesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(1.0, 0.68, 0.22, 1.0)
        mat.emission_enabled = true
        mat.emission = Color(1.0, 0.36, 0.06, 1.0)
        mat.emission_energy_multiplier = 3.5
        spark.material_override = mat
        spark.global_position = position + normal * 0.035
        var side := Vector3(randf_range(-1.0, 1.0), randf_range(0.1, 1.0), randf_range(-1.0, 1.0)).normalized()
        var direction := (normal * randf_range(0.5, 1.4) + side * randf_range(0.5, 1.2)).normalized()
        spark.look_at(position + direction, Vector3.UP)
        _root.add_child(spark)
        var target := spark.global_position + direction * randf_range(0.35, 0.85)
        var tween := spark.create_tween()
        tween.set_parallel(true)
        tween.tween_property(spark, "global_position", target, randf_range(0.10, 0.18))
        tween.tween_property(spark, "scale", Vector3(0.10, 0.10, 0.10), 0.18)
        tween.chain().tween_callback(spark.queue_free)

func _spawn_hit_puff(position: Vector3, normal: Vector3, color: Color) -> void:
    var puff := MeshInstance3D.new()
    puff.name = "ImpactPuff"
    var mesh := SphereMesh.new()
    mesh.radius = 0.09
    mesh.height = 0.18
    puff.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 1.0
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    puff.material_override = mat
    puff.global_position = position + normal * 0.06
    _root.add_child(puff)
    var tween := puff.create_tween()
    tween.set_parallel(true)
    tween.tween_property(puff, "scale", Vector3(2.6, 2.6, 2.6), 0.20)
    tween.tween_property(puff, "global_position", puff.global_position + normal * 0.18 + Vector3.UP * 0.10, 0.20)
    tween.chain().tween_callback(puff.queue_free)
