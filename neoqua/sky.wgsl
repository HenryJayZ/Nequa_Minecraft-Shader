override night_stars: bool = true;

fn neoqua_star_hash(p: vec3<f32>) -> f32 {
    let q = fract(p * 0.3183099 + vec3<f32>(0.11, 0.17, 0.23));
    let r = q * 17.0;
    return fract(r.x * r.y * r.z * (r.x + r.y + r.z));
}

fn neoqua_starfield(dir: vec3<f32>, visibility: f32) -> vec3<f32> {
    if (visibility <= 0.005) {
        return vec3<f32>(0.0);
    }
    let grid = dir * 135.0;
    let cell = floor(grid);
    let local = fract(grid) - vec3<f32>(0.5);
    let rnd = neoqua_star_hash(cell);

    var stars = vec3<f32>(0.0);
    if (rnd > 0.986) {
        let jitter = (vec3<f32>(
            fract(rnd * 73.1),
            fract(rnd * 137.7),
            fract(rnd * 211.3),
        ) - vec3<f32>(0.5)) * 0.55;
        let d = length(local - jitter);
        let core = smoothstep(0.24, 0.02, d);
        let twinkle = 0.72 + 0.28 * sin(frame.time * (1.8 + fract(rnd * 41.0) * 3.0) + rnd * 62.8);
        let temp = fract(rnd * 19.3);
        let tint = mix(vec3<f32>(0.72, 0.84, 1.0), vec3<f32>(1.0, 0.88, 0.72), temp);
        stars = tint * core * twinkle * (0.45 + 0.85 * fract(rnd * 97.0));
    }

    let band = exp(-abs(dir.x * 0.55 + dir.y * 0.45 - dir.z * 0.70) * 6.5);
    let dust = vec3<f32>(0.022, 0.032, 0.068) * band * smoothstep(0.05, 0.45, dir.y);

    return (stars + dust) * visibility;
}

fn sky(input: SkyInput) -> vec4<f32> {
    let dir = neoqua_safe_normalize(input.direction);

    if (frame.dimension == 2) {
        return vec4<f32>(neoqua_sanitize_rgb(input.color.rgb), 1.0);
    }

    var col = neoqua_sky_eval(dir, true);

    if (night_stars) {
        if (frame.dimension == 0) {
            let night = neoqua_day_factors().z;
            let clear = 1.0 - clamp(frame.rain * 0.85 + frame.thunder * 0.3, 0.0, 1.0);
            let horizon_mask = smoothstep(0.02, 0.28, dir.y);
            col = col + neoqua_starfield(dir, night * clear * horizon_mask);
        } else if (frame.dimension == 1) {
            col = col + neoqua_starfield(dir, 0.75);
        }
    }

    return vec4<f32>(neoqua_sanitize_rgb(col), 1.0);
}
