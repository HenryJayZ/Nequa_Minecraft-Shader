override bloom_enabled: bool = true;

fn post(input: PostInput) -> vec4<f32> {
    if (bloom_enabled == false) {
        return vec4<f32>(0.0);
    }

    let texel = vec2<f32>(1.0) / max(frame.resolution, vec2<f32>(1.0));
    let c0 = neoqua_sanitize_rgb(textureSampleLevel(scene_color, linear_sampler, input.uv + vec2<f32>(-texel.x, -texel.y), 0.0).rgb);
    let c1 = neoqua_sanitize_rgb(textureSampleLevel(scene_color, linear_sampler, input.uv + vec2<f32>(texel.x, -texel.y), 0.0).rgb);
    let c2 = neoqua_sanitize_rgb(textureSampleLevel(scene_color, linear_sampler, input.uv + vec2<f32>(-texel.x, texel.y), 0.0).rgb);
    let c3 = neoqua_sanitize_rgb(textureSampleLevel(scene_color, linear_sampler, input.uv + vec2<f32>(texel.x, texel.y), 0.0).rgb);

    let avg = min((c0 + c1 + c2 + c3) * 0.25, vec3<f32>(8.0));
    let lum = neoqua_luma(avg);

    let threshold = 0.85;
    let knee = 0.45;
    let soft = clamp(lum - threshold + knee, 0.0, 2.0 * knee);
    let soft_contrib = (soft * soft) / max(4.0 * knee, 1e-4);
    let contrib = max(lum - threshold, soft_contrib) / max(lum, 1e-4);

    return vec4<f32>(neoqua_sanitize_rgb(avg * contrib), 1.0);
}
