extends Area3D
class_name FirstRunStoryZone

@export_enum("apartment_exit", "mateo_garage", "package_drop") var action := "apartment_exit"

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group("player"):
        return
    var mission := get_tree().get_first_node_in_group("first_run_mission") as FirstRunMission
    if mission == null or not mission.active:
        return
    match action:
        "apartment_exit":
            mission.notify_apartment_exited()
        "mateo_garage":
            mission.notify_mateo_garage_reached()
        "package_drop":
            mission.deliver_package()
