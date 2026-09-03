extends CanvasLayer
class_name CombatHUD

var player: VantaPlayerController
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
    weapon_label.position = Vector2(1510, 980)
    weapon_label.size = Vector2(330, 50)
    weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    weapon_label.add_theme_font_size_override("font_size", 22)
    add_child(weapon_label)
    call_deferred("_bind_player")

func _process(_delta: float) -> void:
    if player == null or not is_instance_valid(player):
        _bind_player()
    if player == null:
        health_label.text = ""
        weapon_label.text = ""
        return
    health_label.text = "HEALTH  %d%%" % int(round(player.get_health_percent() * 100.0))
    weapon_label.text = "V9 COMPACT  |  LMB FIRE"

func _bind_player() -> void:
    player = get_tree().get_first_node_in_group("player") as VantaPlayerController
