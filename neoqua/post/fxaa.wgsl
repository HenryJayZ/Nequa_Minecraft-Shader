override fxaa_enabled: bool = true;

fn neoqua_compress_hdr(c: vec3<f32>) -> vec3<f32> {
    let s = neoqua_sanitize_rgb(c);
    return s / (vec3<f32>(1.0) + s);
}

fn neoqua_expand_hdr(c: vec3<f32>) -> vec3<f32> {
    let clamped = clamp(c, vec3<f32>(0.0), vec3<f32>(0.998));
    return clamped / max(vec3<f32>(1.0) - clamped, vec3<f32>(0.002));
}

fn neoqua_perceptual_luma(compressed: vec3<f32>) -> f32 {
    return sqrt(max(dot(compressed, frame.luminance), 0.0));
}

fn post(input: PostInput) -> vec4<f32> {
    let center_lin = neoqua_sanitize_rgb(input.color.rgb);
    if (fxaa_enabled == false) {
        return vec4<f32>(center_lin, 1.0);
    }

    let dims = max(vec2<f32>(textureDimensions(previous, 0)), vec2<f32>(1.0));
    let px = vec2<f32>(1.0) / dims;

    let c_m = neoqua_compress_hdr(center_lin);
    let c_n = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + vec2<f32>(0.0, -px.y), 0.0).rgb);
    let c_s = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + vec2<f32>(0.0, px.y), 0.0).rgb);
    let c_w = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + vec2<f32>(-px.x, 0.0), 0.0).rgb);
    let c_e = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + vec2<f32>(px.x, 0.0), 0.0).rgb);

    let l_m = neoqua_perceptual_luma(c_m);
    let l_n = neoqua_perceptual_luma(c_n);
    let l_s = neoqua_perceptual_luma(c_s);
    let l_w = neoqua_perceptual_luma(c_w);
    let l_e = neoqua_perceptual_luma(c_e);

    let l_min = min(l_m, min(min(l_n, l_s), min(l_w, l_e)));
    let l_max = max(l_m, max(max(l_n, l_s), max(l_w, l_e)));
    let l_range = l_max - l_min;

    if (l_range < max(0.0312, l_max * 0.125)) {
        return vec4<f32>(center_lin, 1.0);
    }

    let c_nw = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + vec2<f32>(-px.x, -px.y), 0.0).rgb);
    let c_ne = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + vec2<f32>(px.x, -px.y), 0.0).rgb);
    let c_sw = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + vec2<f32>(-px.x, px.y), 0.0).rgb);
    let c_se = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + vec2<f32>(px.x, px.y), 0.0).rgb);

    let l_nw = neoqua_perceptual_luma(c_nw);
    let l_ne = neoqua_perceptual_luma(c_ne);
    let l_sw = neoqua_perceptual_luma(c_sw);
    let l_se = neoqua_perceptual_luma(c_se);

    var dir = vec2<f32>(
        -((l_nw + l_ne) - (l_sw + l_se)),
        ((l_nw + l_sw) - (l_ne + l_se)),
    );
    let dir_reduce = max((l_nw + l_ne + l_sw + l_se) * 0.03125, 0.0078125);
    let inv_dir_min = 1.0 / (min(abs(dir.x), abs(dir.y)) + dir_reduce);
    dir = clamp(dir * inv_dir_min, vec2<f32>(-4.0), vec2<f32>(4.0)) * px;

    let a0 = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + dir * -0.1667, 0.0).rgb);
    let a1 = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + dir * 0.1667, 0.0).rgb);
    let rgb_a = (a0 + a1) * 0.5;

    let b0 = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + dir * -0.5, 0.0).rgb);
    let b1 = neoqua_compress_hdr(textureSampleLevel(previous, linear_sampler, input.uv + dir * 0.5, 0.0).rgb);
    let rgb_b = rgb_a * 0.5 + (b0 + b1) * 0.25;

    let l_b = neoqua_perceptual_luma(rgb_b);
    let use_a = (l_b < l_min) || (l_b > l_max);
    let blended_comp = select(rgb_b, rgb_a, use_a);

    return vec4<f32>(neoqua_sanitize_rgb(neoqua_expand_hdr(blended_comp)), 1.0);
}
