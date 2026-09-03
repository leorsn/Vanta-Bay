extends CanvasLayer
class_name StoryDialogueUI

signal choice_selected(index: int)
signal dialogue_closed

var panel: Panel
var speaker_label: Label
var body_label: Label
var option_labels: Array[Label] = []
var active := false
var accepting_choices := false
var selected_index := 0

func _ready() -> void:
    add_to_group("story_dialogue_ui")
    layer = 40
    _build_ui()
    visible = false

func _unhandled_input(event: InputEvent) -> void:
    if not active:
        return
    if accepting_choices and (event.is_action_pressed("move_left") or event.is_action_pressed("move_forward")):
        _move_selection(-1)
        get_viewport().set_input_as_handled()
    elif accepting_choices and (event.is_action_pressed("move_right") or event.is_action_pressed("move_back")):
        _move_selection(1)
        get_viewport().set_input_as_handled()
    elif accepting_choices and event.is_action_pressed("interact"):
        accepting_choices = false
        choice_selected.emit(selected_index)
        get_viewport().set_input_as_handled()

func show_choices(speaker: String, body: String, choices: Array[String]) -> void:
    active = true
    accepting_choices = true
    visible = true
    selected_index = 0
    speaker_label.text = speaker
    body_label.text = body
    for i in range(option_labels.size()):
        var label := option_labels[i]
        label.visible = i < choices.size()
        if i < choices.size():
            label.text = str(choices[i])
    _refresh_selection()

func show_line(speaker: String, body: String) -> void:
    active = true
    accepting_choices = false
    visible = true
    speaker_label.text = speaker
    body_label.text = body
    for label in option_labels:
        label.visible = false

func close_dialogue() -> void:
    active = false
    accepting_choices = false
    visible = false
    dialogue_closed.emit()

func _move_selection(direction: int) -> void:
    var visible_count := 0
    for label in option_labels:
        if label.visible:
            visible_count += 1
    if visible_count <= 0:
        return
    selected_index = wrapi(selected_index + direction, 0, visible_count)
    _refresh_selection()

func _refresh_selection() -> void:
    for i in range(option_labels.size()):
        if option_labels[i].visible:
            option_labels[i].modulate = Color(1.0, 1.0, 0.97, 1.0) if i == selected_index else Color(0.52, 0.55, 0.56, 1.0)

func _build_ui() -> void:
    panel = Panel.new()
    panel.position = Vector2(260, 710)
    panel.size = Vector2(1400, 250)
    panel.modulate = Color(0.045, 0.05, 0.055, 0.95)
    add_child(panel)

    speaker_label = Label.new()
    speaker_label.position = Vector2(46, 24)
    speaker_label.size = Vector2(500, 34)
    speaker_label.add_theme_font_size_override("font_size", 20)
    speaker_label.modulate = Color(0.70, 0.74, 0.75, 1.0)
    panel.add_child(speaker_label)

    body_label = Label.new()
    body_label.position = Vector2(46, 62)
    body_label.size = Vector2(1305, 72)
    body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body_label.add_theme_font_size_override("font_size", 20)
    body_label.modulate = Color(0.96, 0.96, 0.93, 1.0)
    panel.add_child(body_label)

    for i in range(3):
        var option := Label.new()
        option.position = Vector2(46 + i * 440, 158)
        option.size = Vector2(410, 62)
        option.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        option.add_theme_font_size_override("font_size", 17)
        panel.add_child(option)
        option_labels.append(option)
