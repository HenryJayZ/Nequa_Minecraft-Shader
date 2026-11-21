override water_waves: bool = true;
override waving_foliage: bool = true;

fn neoqua_water_wave_height(wp_xz: vec2<f32>, t: f32) -> f32 {
    let p1 = wp_xz.x * (NEOQUA_K_UNIT * 7.0) + wp_xz.y * (NEOQUA_K_UNIT * 4.0) + t * 1.45;
    let p2 = wp_xz.x * (NEOQUA_K_UNIT * -5.0) + wp_xz.y * (NEOQUA_K_UNIT * 9.0) - t * 1.90;
    let p3 = wp_xz.x * (NEOQUA_K_UNIT * 11.0) + wp_xz.y * (NEOQUA_K_UNIT * -6.0) + t * 2.55;
    return (sin(p1) * 0.50 + sin(p2) * 0.32 + sin(p3) * 0.18) * 0.042;
}

fn vertex(input: VertexInput) -> vec3<f32> {
    var pos = input.position;
    let dist = length(pos);
    if (dist > 64.0) {
        return pos;
    }

    let wp = neoqua_wrap_pos(pos + frame.camera_position);
    let fade = 1.0 - smoothstep(24.0, 62.0, dist);

    if (water_waves && input.material == 1u) {
        let swell = neoqua_water_wave_height(wp.xz, frame.time);
        pos.y = pos.y + (swell - 0.028) * fade;
        return pos;
    }

    if (waving_foliage && (input.material == 2u || input.material == 3u)) {
        let sky_mask = smoothstep(0.25, 0.90, input.light.y);
        if (sky_mask > 0.001) {
            let wind = 1.0 + frame.rain * 1.15 + frame.thunder * 0.65;
            let amp = select(0.032, 0.016, input.material == 2u) * wind * fade * sky_mask;
            let phase = wp.x * (NEOQUA_K_UNIT * 5.0) + wp.z * (NEOQUA_K_UNIT * 4.0) + wp.y * 0.7 + frame.time * 2.1;
            let gust = sin(phase) + 0.45 * sin(phase * 1.7 + 1.3);
            pos.x = pos.x + gust * amp;
            pos.z = pos.z + cos(phase * 0.85) * amp * 0.7;
        }
    }

    return pos;
}
