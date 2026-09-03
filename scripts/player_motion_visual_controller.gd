extends Node
class_name VantaPlayerMotionVisualController

var player: VantaPlayerController
var visual: Node3D
var torso: Node3D
var head: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var left_hand: Node3D
var right_hand: Node3D
var cycle := 0.0

func _ready() -> void:
    add_to_group("player_motion_visual_controller")
    call_deferred("_resolve")

func _process(delta: float) -> void:
    _resolve()
    if player == null or visual == null:
        return
    if player.driving:
        visual.visible = false
        return
    visual.visible = true
    _animate(delta)

func _resolve() -> void:
    if player == null or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player") as VantaPlayerController
    if player == null:
        return
    if visual == null or not is_instance_valid(visual):
        visual = player.get_node_or_null("PlayerVisual") as Node3D
        if visual == null:
            return
        torso = visual.get_node_or_null("Torso") as Node3D
        head = visual.get_node_or_null("Head") as Node3D
        left_arm = visual.get_node_or_null("LeftArm") as Node3D
        right_arm = visual.get_node_or_null("RightArm") as Node3D
        left_leg = visual.get_node_or_null("LeftLeg") as Node3D
        right_leg = visual.get_node_or_null("RightLeg") as Node3D
        left_hand = visual.get_node_or_null("LeftHand") as Node3D
        right_hand = visual.get_node_or_null("RightHand") as Node3D

func _animate(delta: float) -> void:
    var planar_speed := Vector2(player.velocity.x, player.velocity.z).length()
    var move_amount := clampf(planar_speed / maxf(player.sprint_speed, 0.1), 0.0, 1.0)
    var grounded := player.is_on_floor()
    cycle += delta * lerpf(3.0, 10.2, move_amount)

    var leg_swing := sin(cycle) * deg_to_rad(34.0) * move_amount
    var arm_swing := -sin(cycle) * deg_to_rad(27.0) * move_amount
    var torso_roll := sin(cycle) * deg_to_rad(2.4) * move_amount
    var torso_pitch := -deg_to_rad(4.0) * move_amount

    if not grounded:
        leg_swing = deg_to_rad(10.0)
        arm_swing = deg_to_rad(-8.0)
        torso_pitch = deg_to_rad(-4.0)

    if player.aiming:
        leg_swing *= 0.32
        arm_swing = deg_to_rad(-38.0)
        torso_pitch = deg_to_rad(-5.0)
        torso_roll *= 0.25

    _lerp_rotation(left_leg, Vector3(leg_swing, 0.0, 0.0), delta, 12.0)
    _lerp_rotation(right_leg, Vector3(-leg_swing, 0.0, 0.0), delta, 12.0)

    if player.aiming:
        _lerp_rotation(left_arm, Vector3(deg_to_rad(-58.0), 0.0, deg_to_rad(-7.0)), delta, 14.0)
        _lerp_rotation(right_arm, Vector3(deg_to_rad(-62.0), 0.0, deg_to_rad(8.0)), delta, 14.0)
    else:
        _lerp_rotation(left_arm, Vector3(arm_swing, 0.0, deg_to_rad(-2.0)), delta, 12.0)
        _lerp_rotation(right_arm, Vector3(-arm_swing, 0.0, deg_to_rad(2.0)), delta, 12.0)

    _lerp_rotation(torso, Vector3(torso_pitch, 0.0, torso_roll), delta, 10.0)
    _lerp_rotation(head, Vector3(-torso_pitch * 0.35, 0.0, -torso_roll * 0.5), delta, 9.0)

    var hand_bob := sin(cycle) * 0.015 * move_amount
    if left_hand != null:
        left_hand.position.y = 0.77 + hand_bob
    if right_hand != null:
        right_hand.position.y = 0.77 - hand_bob

func _lerp_rotation(node: Node3D, target: Vector3, delta: float, speed: float) -> void:
    if node == null:
        return
    var weight := clampf(delta * speed, 0.0, 1.0)
    node.rotation.x = lerp_angle(node.rotation.x, target.x, weight)
    node.rotation.y = lerp_angle(node.rotation.y, target.y, weight)
    node.rotation.z = lerp_angle(node.rotation.z, target.z, weight)
