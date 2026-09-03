extends Area3D
class_name ApartmentStoryZone

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group("player"):
        return
    var mission := get_tree().get_first_node_in_group("lose_them_mission") as LoseThemMission
    if mission != null:
        mission.notify_apartment_reached()
