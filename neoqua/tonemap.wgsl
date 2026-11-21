override exposure: f32 = 1.05;

fn neoqua_filmic_curve(x: vec3<f32>) -> vec3<f32> {
    let a = 2.51;
    let b = 0.03;
    let c = 2.43;
    let d = 0.59;
    let e = 0.14;
    return clamp((x * (a * x + b)) / max(x * (c * x + d) + e, vec3<f32>(1e-5)), vec3<f32>(0.0), vec3<f32>(1.0));
}

fn tonemap(input: TonemapInput) -> vec3<f32> {
    let headroom = max(frame.headroom, 1.0);
    let bright_gain = mix(0.88, 1.16, clamp(frame.brightness, 0.0, 1.0));
    let cave_lift = mix(1.12, 1.0, clamp(frame.eye_light_smooth.y, 0.0, 1.0));
    var col = neoqua_sanitize_rgb(input.color) * exposure * bright_gain * cave_lift;

    let lum = neoqua_luma(col);
    let hi_desat = smoothstep(0.9, 4.2, lum) * 0.32;
    col = mix(col, vec3<f32>(lum), hi_desat);

    var mapped = vec3<f32>(0.0);
    if (headroom <= 1.01) {
        mapped = neoqua_filmic_curve(col);
    } else {
        let shoulder = headroom * 0.6;
        let scaled = col / max(headroom, 1.0);
        let roll = neoqua_filmic_curve(scaled * 1.15) * headroom;
        let t = smoothstep(shoulder * 0.5, headroom * 1.4, lum);
        mapped = mix(min(col, vec3<f32>(headroom)), roll, t);
    }

    return clamp(neoqua_sanitize_rgb(mapped), vec3<f32>(0.0), vec3<f32>(headroom));
}
