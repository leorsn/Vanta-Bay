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
    health_label.position = Vector2(60, 980)
    health_label.size = Vector2(340, 50)
    health_label.add_theme_font_size_override("font_size", 22)
    add_child(health_label)
    weapon_label = Label.new()
    weapon_label.position = Vector2(1390, 940)
    weapon_label.size = Vector2(450, 100)
    weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    weapon_label.add_theme_font_size_override("font_size", 21)
    add_child(weapon_label)
    crosshair_label = Label.new()
    crosshair_label.position = Vector2(940, 520)
    crosshair_label.size = Vector2(40, 40)
    crosshair_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    crosshair_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    crosshair_label.add_theme_font_size_override("font_size", 26)
    crosshair_label.text = "+"
    add_child(crosshair_label)
    hitmarker_label = Label.new()
    hitmarker_label.position = Vector2(930, 505)
    hitmarker_label.size = Vector2(60, 60)
    hitmarker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hitmarker_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    hitmarker_label.add_theme_font_size_override("font_size", 30)
    hitmarker_label.text = "×"
    hitmarker_label.visible = false
    add_child(hitmarker_label)
    call_deferred("_bind_runtime")

func _process(delta: float) -> void:
    _bind_runtime()
    _hitmarker_timer = max(_hitmarker_timer - delta, 0.0)
    hitmarker_label.visible = _hitmarker_timer > 0.0
    if player == null:
        health_label.text = ""
        weapon_label.text = ""
        crosshair_label.visible = false
        return
    health_label.text = "HEALTH  %d%%" % int(round(player.get_health_percent() * 100.0))
    crosshair_label.visible = not player.driving
    crosshair_label.text = "•" if player.aiming else "+"
    if combat != null:
        weapon_label.text = "%s\n%s  |  R RELOAD\n1 PISTOL   2 SMG   3 RIFLE" % [combat.get_weapon_name(), combat.get_ammo_text()]
    else:
        weapon_label.text = "LMB FIRE"

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
