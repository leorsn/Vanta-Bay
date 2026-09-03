extends CanvasLayer
class_name CombatHUD

var player: VantaPlayerController
var combat: CombatManager
var health_label: Label
var weapon_label: Label
var crosshair_label: Label
var hitmarker_label: Label
var _hitmarker_timer := 0.0

func _ready() -> void:
    add_to_group("combat_hud")
    layer = 5

    health_label = Label.new()
    health_label.position = Vector2(48, 1000)
    health_label.size = Vector2(300, 40)
    health_label.add_theme_font_size_override("font_size", 17)
    health_label.modulate = Color(0.92, 0.93, 0.91, 0.94)
    add_child(health_label)

    weapon_label = Label.new()
    weapon_label.position = Vector2(1450, 955)
    weapon_label.size = Vector2(390, 90)
    weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    weapon_label.add_theme_font_size_override("font_size", 17)
    weapon_label.modulate = Color(0.93, 0.94, 0.92, 0.94)
    add_child(weapon_label)

    crosshair_label = Label.new()
    crosshair_label.position = Vector2(945, 525)
    crosshair_label.size = Vector2(30, 30)
    crosshair_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    crosshair_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    crosshair_label.add_theme_font_size_override("font_size", 20)
    crosshair_label.modulate = Color(0.96, 0.96, 0.93, 0.80)
    crosshair_label.text = "+"
    add_child(crosshair_label)

    hitmarker_label = Label.new()
    hitmarker_label.position = Vector2(935, 510)
    hitmarker_label.size = Vector2(50, 50)
    hitmarker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hitmarker_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    hitmarker_label.add_theme_font_size_override("font_size", 26)
    hitmarker_label.text = "×"
    hitmarker_label.visible = false
    add_child(hitmarker_label)
    call_deferred("_bind_runtime")

func _process(delta: float) -> void:
    _bind_runtime()
    _hitmarker_timer = maxf(_hitmarker_timer - delta, 0.0)
    hitmarker_label.visible = _hitmarker_timer > 0.0
    if player == null:
        health_label.text = ""
        weapon_label.text = ""
        crosshair_label.visible = false
        return
    health_label.text = "HEALTH  %d" % int(round(player.get_health_percent() * 100.0))
    crosshair_label.visible = not player.driving
    crosshair_label.text = "•" if player.aiming else "+"
    if combat != null:
        weapon_label.text = "%s\n%s" % [combat.get_weapon_name(), combat.get_ammo_text()]
    else:
        weapon_label.text = ""

func _on_hit_confirmed(headshot: bool) -> void:
    _hitmarker_timer = 0.18 if not headshot else 0.28
    hitmarker_label.text = "✕" if headshot else "×"

func _bind_runtime() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
    if combat == null or not is_instance_valid(combat):
        combat = get_tree().get_first_node_in_group("combat_manager") as CombatManager
        if combat != null and not combat.hit_confirmed.is_connected(_on_hit_confirmed):
            combat.hit_confirmed.connect(_on_hit_confirmed)
