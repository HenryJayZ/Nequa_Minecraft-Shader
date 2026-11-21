override torch_warmth: f32 = 1.0;

fn entity(input: EntityInput) -> Surface {
    let base = max(input.albedo.rgb * input.tint.rgb * input.shade, vec3<f32>(0.0));
    let base_gamma = pow(max(base, vec3<f32>(1e-6)), NEOQUA_GAMMA_INV);
    let over_gamma = pow(max(input.overlay.rgb, vec3<f32>(1e-6)), NEOQUA_GAMMA_INV);
    let flashed = pow(max(mix(base_gamma, over_gamma, clamp(input.overlay.a, 0.0, 1.0)), vec3<f32>(1e-6)), NEOQUA_GAMMA_FWD);

    var lit = vec3<f32>(1.0);
    if (input.full_light == false) {
        lit = neoqua_eval_lighting(input.normal, input.light, input.lightmap, input.colored_light, torch_warmth);
        let custom_light = block_light_color(input.position);
        lit = lit + neoqua_sanitize_rgb(custom_light.rgb) * clamp(custom_light.a, 0.0, 1.0) * 0.35;
    }

    var col = flashed * lit;
    col = neoqua_apply_fog(col, input.position);

    return Surface(vec4<f32>(neoqua_sanitize_rgb(col), input.albedo.a * input.tint.a));
}
