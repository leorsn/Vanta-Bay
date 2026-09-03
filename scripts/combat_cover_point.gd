extends Marker3D
class_name CombatCoverPoint

@export var cover_height := 1.2
var reserved_by: Node = null

func _ready() -> void:
    add_to_group("combat_cover")

func is_available_for(agent: Node) -> bool:
    return reserved_by == null or reserved_by == agent or not is_instance_valid(reserved_by)

func reserve(agent: Node) -> void:
    reserved_by = agent

func release(agent: Node) -> void:
    if reserved_by == agent:
        reserved_by = null
