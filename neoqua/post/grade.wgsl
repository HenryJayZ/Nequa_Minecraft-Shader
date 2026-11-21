override bloom_enabled: bool = true;
override bloom_strength: f32 = 0.22;
override grade_preset: u32 = 0u;

fn post(input: PostInput) -> vec4<f32> {
    var col = neoqua_sanitize_rgb(textureSampleLevel(scene_color, linear_sampler, input.uv, 0.0).rgb);

    if (bloom_enabled && bloom_strength > 0.001) {
        let b = neoqua_sanitize_rgb(textureSampleLevel(bloom_b, linear_sampler, input.uv, 0.0).rgb);
        col = col + b * bloom_strength;
    }

    if (frame.in_water > 0.001) {
        let uw_tint = vec3<f32>(0.76, 0.96, 1.06);
        col = mix(col, col * uw_tint, frame.in_water * 0.65);
    }

    let lum = neoqua_luma(col);
    if (grade_preset == 0u) {
        let sat = mix(vec3<f32>(lum), col, 1.12);
        let shadow_w = 1.0 - smoothstep(0.0, 0.45, lum);
        let hi_w = smoothstep(0.35, 1.4, lum);
        col = sat * (vec3<f32>(1.0) + vec3<f32>(-0.025, 0.005, 0.045) * shadow_w + vec3<f32>(0.045, 0.015, -0.025) * hi_w);
    } else if (grade_preset == 1u) {
        let sat = mix(vec3<f32>(lum), col, 1.24);
        col = sat * vec3<f32>(0.97, 1.03, 1.06);
    } else {
        col = mix(vec3<f32>(lum), col, 1.04);
    }

    let centered = input.uv - vec2<f32>(0.5);
    let vig = 1.0 - dot(centered, centered) * 0.28;
    col = col * clamp(vig, 0.72, 1.0);

    return vec4<f32>(neoqua_sanitize_rgb(col), 1.0);
}
