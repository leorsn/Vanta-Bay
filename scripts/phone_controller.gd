extends CanvasLayer
class_name VantaPhoneController

@onready var panel: Control = $PhonePanel
@onready var header: Label = $PhonePanel/Header
@onready var content: Label = $PhonePanel/Content
@onready var balance: Label = $PhonePanel/Balance

var economy: EconomyManager
var opened := false

func _ready() -> void:
    add_to_group("phone_controller")
    panel.visible = false
    economy = get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.balances_changed.connect(_on_balances_changed)
        _on_balances_changed(economy.cash, economy.bank, economy.rep)
    header.text = "VANTA OS  /  MESSAGES"
    content.text = "MATEO\nGot something for you.\nGarage off Ocean Drive.\nBring the car to Port Vanta.\nNo questions."

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("phone"):
        opened = not opened
        panel.visible = opened

func _on_balances_changed(cash: int, bank: int, rep: int) -> void:
    balance.text = "CASH  $%d\nBANK  $%d\nREP   %d" % [cash, bank, rep]
