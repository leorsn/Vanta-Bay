extends Node
class_name VantaRenderQualityController

func _ready() -> void:
    add_to_group("render_quality_controller")
    call_deferred("_apply_high_quality_profile")

func _apply_high_quality_profile() -> void:
    var viewport := get_viewport()
    if viewport == null:
        return
    viewport.scaling_3d_scale = 1.0
    viewport.msaa_3d = Viewport.MSAA_4X
    viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
    viewport.anisotropic_filtering_level = Viewport.ANISOTROPY_8X
    # Keep HDR 2D disabled for Web/GL Compatibility stability.
    # The 3D scene still uses ACES tonemapping through WorldEnvironment.
    viewport.use_hdr_2d = false
