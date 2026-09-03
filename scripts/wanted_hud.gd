extends CanvasLayer

@onready var label: Label = $WantedLabel
var wanted: WantedManager

func _ready() -> void:
    wanted = get_tree().get_first_node_in_group("wanted_manager") as WantedManager
    if wanted != null:
        wanted.state_changed.connect(_on_state_changed)
        _on_state_changed(wanted.state, wanted.stars)

func _on_state_changed(state: String, stars: int) -> void:
    if state == "NONE":
        label.text = ""
        return
    var star_text := ""
    for i in range(stars):
        star_text += "★"
    label.text = "%s\n%s" % [star_text, state]
