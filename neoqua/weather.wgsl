fn weather(input: WeatherInput) -> vec4<f32> {
    let dist = length(input.position);
    let near_fade = smoothstep(0.6, 2.2, dist);
    let far_fade = 1.0 - smoothstep(18.0, 38.0, dist);
    let day = neoqua_day_factors().x;

    let sky_tint = mix(vec3<f32>(0.18, 0.24, 0.38), vec3<f32>(0.78, 0.86, 0.96), day);
    let torch_tint = NEOQUA_TORCH_COL * (input.light.x * input.light.x) * 0.85;
    let tint = sky_tint * (0.30 + 0.70 * input.light.y) + torch_tint;

    var col = input.color.rgb * tint;
    var alpha = input.color.a * near_fade * far_fade;

    if (input.snow == false) {
        col = col * vec3<f32>(0.85, 0.94, 1.08);
        alpha = alpha * 0.62;
    } else {
        alpha = alpha * 0.85;
    }

    return vec4<f32>(neoqua_sanitize_rgb(col), clamp(alpha, 0.0, 1.0));
}
