extends CanvasLayer
class_name VantaPhoneController

signal mateo_message_read()
signal black_glass_followup_read()

@onready var panel: Control = $PhonePanel
@onready var header: Label = $PhonePanel/Header
@onready var content: Label = $PhonePanel/Content
@onready var balance: Label = $PhonePanel/Balance

var economy: EconomyManager
var campaign: StoryCampaign
var opened := false
var message_read := false
var followup_pending := false
var followup_read := false
var current_mission_id := ""

func _ready() -> void:
    add_to_group("phone_controller")
    panel.visible = false
    economy = get_tree().get_first_node_in_group("economy_manager") as EconomyManager
    if economy != null:
        economy.balances_changed.connect(_on_balances_changed)
        _on_balances_changed(economy.cash, economy.bank, economy.rep)
    call_deferred("_bind_campaign")
    _show_default_screen()

func _bind_campaign() -> void:
    campaign = get_tree().get_first_node_in_group("story_campaign") as StoryCampaign
    if campaign == null:
        return
    if not campaign.chapter_changed.is_connected(_on_chapter_changed):
        campaign.chapter_changed.connect(_on_chapter_changed)
    _on_chapter_changed(campaign.get_current_id(), campaign.get_current_title())

func _on_chapter_changed(mission_id: String, _title: String) -> void:
    current_mission_id = mission_id
    if mission_id == "black_glass" and not followup_pending:
        message_read = false
        restore_initial_message()
    elif not followup_pending:
        _show_default_screen()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("phone"):
        opened = not opened
        panel.visible = opened
        if opened:
            if followup_pending and not followup_read:
                followup_read = true
                black_glass_followup_read.emit()
            elif current_mission_id == "black_glass" and not message_read:
                message_read = true
                mateo_message_read.emit()

func show_black_glass_followup() -> void:
    followup_pending = true
    followup_read = false
    header.text = "VANTA OS  /  SECURE MESSAGE"
    content.text = "UNKNOWN DEVICE DETECTED\nEncrypted storage module recovered from the vehicle.\n\nMATEO\nDo not plug that thing into anything.\nBring it when I call.\nAnd Jace... nobody was supposed to know about that car."

func restore_initial_message() -> void:
    followup_pending = false
    followup_read = false
    header.text = "VANTA OS  /  MESSAGES"
    content.text = "MATEO\nGot something for you.\nGarage off Ocean Drive.\nBring the car to Port Vanta.\nNo questions."

func _show_default_screen() -> void:
    header.text = "VANTA OS  /  HOME"
    match current_mission_id:
        "first_run":
            content.text = "JACE MERCER\nNo new messages.\n\nCurrent job: FIRST RUN\nMeet Mateo and make the delivery."
        "no_questions":
            content.text = "MATEO\nYou did fine. Keep your phone close. I've got another run."
        "after_midnight":
            content.text = "VANTA OS\nCurrent job: AFTER MIDNIGHT"
        "wrong_place":
            content.text = "VANTA OS\nCurrent job: WRONG PLACE"
        "lose_them":
            content.text = "MATEO\nGet home. Stay off the main roads."
        _:
            content.text = "VANTA OS\nMessages  •  Map  •  Bank  •  Contacts"

func _on_balances_changed(cash: int, bank: int, rep: int) -> void:
    balance.text = "CASH  $%d\nBANK  $%d\nREP   %d" % [cash, bank, rep]
