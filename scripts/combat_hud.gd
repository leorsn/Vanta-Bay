extends CanvasLayer
class_name CombatHUD

var player: VantaPlayerController
var combat: CombatManager
var health_label: Label
var weapon_label: Label

func _ready() -> void:
    add_to_group("combat_hud")
    layer = 5
    health_label = Label.new()
    health_label.position = Vector2(60, 980)
    health_label.size = Vector2(340, 50)
    health_label.add_theme_font_size_override("font_size", 22)
    add_child(health_label)
    weapon_label = Label.new()
    weapon_label.position = Vector2(1450, 965)
    weapon_label.size = Vector2(390, 70)
    weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    weapon_label.add_theme_font_size_override("font_size", 22)
    add_child(weapon_label)
    call_deferred("_bind_runtime")

func _process(_delta: float) -> void:
    _bind_runtime()
    if player == null:
        health_label.text = ""
        weapon_label.text = ""
        return
    health_label.text = "HEALTH  %d%%" % int(round(player.get_health_percent() * 100.0))
    if combat != null:
        weapon_label.text = "V9 COMPACT\n%s  |  R RELOAD" % combat.get_ammo_text()
    else:
        weapon_label.text = "V9 COMPACT  |  LMB FIRE"

func _bind_runtime() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
    if combat == null or not is_instance_valid(combat):
        combat = get_tree().get_first_node_in_group("combat_manager") as CombatManager
