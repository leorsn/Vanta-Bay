shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.035, 0.34, 0.42, 0.78);
uniform vec4 deep_color : source_color = vec4(0.008, 0.10, 0.18, 0.90);
uniform vec4 sun_glint : source_color = vec4(0.72, 0.88, 0.95, 1.0);
uniform float wave_strength = 0.085;
uniform float wave_scale = 0.115;
uniform float wave_speed = 0.55;
uniform float metallic_amount = 0.18;
uniform float roughness_amount = 0.16;

void vertex() {
    float wave_a = sin((VERTEX.x + TIME * wave_speed * 6.0) * wave_scale);
    float wave_b = cos((VERTEX.z - TIME * wave_speed * 4.3) * wave_scale * 1.37);
    float wave_c = sin((VERTEX.x + VERTEX.z + TIME * wave_speed * 3.2) * wave_scale * 0.73);
    VERTEX.y += (wave_a * 0.52 + wave_b * 0.32 + wave_c * 0.16) * wave_strength;
}

void fragment() {
    float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 3.0);
    float ripple = sin((VERTEX.x * 0.21) + TIME * 1.3) * cos((VERTEX.z * 0.16) - TIME * 0.9);
    float depth_mix = clamp(0.42 + fresnel * 0.48 + ripple * 0.045, 0.0, 1.0);
    vec3 water_color = mix(shallow_color.rgb, deep_color.rgb, depth_mix);
    water_color = mix(water_color, sun_glint.rgb, fresnel * 0.17);
    ALBEDO = water_color;
    METALLIC = metallic_amount;
    ROUGHNESS = mix(roughness_amount, 0.28, 1.0 - fresnel);
    ALPHA = mix(shallow_color.a, deep_color.a, depth_mix);
}
