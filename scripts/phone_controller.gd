extends CanvasLayer
class_name VantaPhoneController

signal mateo_message_read()
signal black_glass_followup_read()

@onready var panel: Control = $PhonePanel
@onready var header: Label = $PhonePanel/Header
@onready var content: Label = $PhonePanel/Content
@onready var balance: Label = $PhonePanel/Balance

var economy: EconomyManager
var opened := false
var message_read := false
var followup_pending := false
var followup_read := false

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
        if opened:
            if followup_pending and not followup_read:
                followup_read = true
                black_glass_followup_read.emit()
            elif not message_read:
                message_read = true
                mateo_message_read.emit()

func show_black_glass_followup() -> void:
    followup_pending = true
    followup_read = false
    header.text = "VANTA OS  /  SECURE MESSAGE"
    content.text = "UNKNOWN DEVICE DETECTED\nEncrypted storage module recovered from the vehicle.\n\nMATEO\nDo not plug that thing into anything.\nBring it when I call.\nAnd Jace... nobody was supposed to know about that car."

func restore_initial_message() -> void:
    followup_pending = false
    header.text = "VANTA OS  /  MESSAGES"
    content.text = "MATEO\nGot something for you.\nGarage off Ocean Drive.\nBring the car to Port Vanta.\nNo questions."

func _on_balances_changed(cash: int, bank: int, rep: int) -> void:
    balance.text = "CASH  $%d\nBANK  $%d\nREP   %d" % [cash, bank, rep]
