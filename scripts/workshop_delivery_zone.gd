extends Area3D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
    if not body.is_in_group("vehicles"):
        return
    var mission := get_tree().get_first_node_in_group("black_glass_mission") as BlackGlassMission
    if mission != null:
        mission.try_deliver(body)
