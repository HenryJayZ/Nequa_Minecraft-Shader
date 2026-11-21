// Neoqua - [material] stage (API 0.2). Water is the hero: refraction through
// `opaque_color`, depth absorption from `opaque_depth`, Fresnel sky reflection,
// optional planar mirror, sun glint, shoreline foam and rain ripples.
// `water_waves` is declared in common.wgsl (shared by this module and the
// vertex stage, which joins it).

override water_reflection: bool = true;
override water_clarity: f32 = 1.0;
override torch_warmth: f32 = 1.0;
override rain_ripples: bool = true;

const NEOQUA_WATER_ABSORB: vec3<f32> = vec3<f32>(0.42, 0.125, 0.072);
const NEOQUA_WATER_SCATTER: vec3<f32> = vec3<f32>(0.018, 0.095, 0.135);
const NEOQUA_FOAM_COL: vec3<f32> = vec3<f32>(0.84, 0.92, 0.96);

fn neoqua_water_normal(wp_xz: vec2<f32>, t: f32, dist: f32) -> vec3<f32> {
    if (water_waves == false) {
        return vec3<f32>(0.0, 1.0, 0.0);
    }

    let p1 = wp_xz.x * (NEOQUA_K_UNIT * 7.0) + wp_xz.y * (NEOQUA_K_UNIT * 4.0) + t * 1.45;
    let p2 = wp_xz.x * (NEOQUA_K_UNIT * -5.0) + wp_xz.y * (NEOQUA_K_UNIT * 9.0) - t * 1.90;
    let p3 = wp_xz.x * (NEOQUA_K_UNIT * 11.0) + wp_xz.y * (NEOQUA_K_UNIT * -6.0) + t * 2.55;

    let c1 = cos(p1) * 0.032;
    let c2 = cos(p2) * 0.024;
    let c3 = cos(p3) * 0.016;

    var gx = c1 * 0.70 - c2 * 0.50 + c3 * 1.10;
    var gz = c1 * 0.40 + c2 * 0.90 - c3 * 0.60;

    // Texture scales are exact multiples of 1/64 so the 64-block wrap stays seamless.
    let uv1 = wp_xz * 0.078125 + vec2<f32>(t * 0.028, t * 0.019);
    let uv2 = wp_xz * 0.171875 + vec2<f32>(-t * 0.035, t * 0.026);
    let n1 = textureSampleLevel(noise, noise_sampler, uv1, 0.0).r;
    let n2 = textureSampleLevel(noise, noise_sampler, uv2, 0.0).r;
    let n1_x = textureSampleLevel(noise, noise_sampler, uv1 + vec2<f32>(0.015, 0.0), 0.0).r;
    let n1_z = textureSampleLevel(noise, noise_sampler, uv1 + vec2<f32>(0.0, 0.015), 0.0).r;

    let detail_fade = 1.0 - smoothstep(14.0, 56.0, dist);
    gx = gx + ((n1_x - n1) * 4.2 + (n2 - 0.5) * 0.08) * detail_fade;
    gz = gz + ((n1_z - n1) * 4.2 + (n1 - 0.5) * 0.08) * detail_fade;

    if (rain_ripples && frame.rain > 0.02 && dist < 36.0) {
        let cell_uv = wp_xz * 1.34375;
        let cell_id = floor(cell_uv);
        let cell_f = fract(cell_uv) - vec2<f32>(0.5);
        let rnd = textureSampleLevel(noise, noise_sampler, (cell_id + vec2<f32>(0.5)) * 0.0625, 0.0).r;
        let cycle = fract(t * 1.15 + rnd);
        let r = length(cell_f);
        let ring = sin((r - cycle * 0.48) * 34.0) * exp(-abs(r - cycle * 0.48) * 14.0) * (1.0 - cycle);
        let r_dir = cell_f / max(r, 0.001);
        let ripple_strength = ring * frame.rain * 0.14 * (1.0 - smoothstep(12.0, 36.0, dist));
        gx = gx + r_dir.x * ripple_strength;
        gz = gz + r_dir.y * ripple_strength;
    }

    return neoqua_safe_normalize(vec3<f32>(-gx, 1.0, -gz));
}

fn neoqua_depth_to_dist(uv: vec2<f32>, depth: f32) -> f32 {
    if (depth <= 1e-5) {
        return frame.far;
    }
    let ndc = vec4<f32>(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, depth, 1.0);
    let view_h = frame.projection_inverse * ndc;
    let safe_w = select(view_h.w, 1.0, abs(view_h.w) < 1e-6);
    let view_pos = view_h.xyz / safe_w;
    return length(view_pos);
}

fn neoqua_clamp_texel(uv: vec2<f32>) -> vec2<i32> {
    let max_px = max(vec2<i32>(frame.resolution) - vec2<i32>(1, 1), vec2<i32>(0, 0));
    let raw_px = vec2<i32>(uv * frame.resolution);
    return clamp(raw_px, vec2<i32>(0, 0), max_px);
}

fn neoqua_ggx_specular(n: vec3<f32>, v: vec3<f32>, l: vec3<f32>, roughness: f32) -> f32 {
    let ndl = max(dot(n, l), 0.0);
    let ndv = max(dot(n, v), 0.001);
    if (ndl <= 0.0001) {
        return 0.0;
    }
    let h = neoqua_safe_normalize(v + l);
    let ndh = max(dot(n, h), 0.0);
    let a = max(roughness * roughness, 0.002);
    let a2 = a * a;
    let denom = ndh * ndh * (a2 - 1.0) + 1.0;
    let d = a2 / max(NEOQUA_PI * denom * denom, 1e-5);
    let k = (roughness + 1.0) * (roughness + 1.0) * 0.125;
    let g = (ndv / (ndv * (1.0 - k) + k)) * (ndl / (ndl * (1.0 - k) + k));
    return min((d * g) / max(4.0 * ndv * ndl, 0.001), 12.0) * ndl;
}

fn neoqua_shade_water(input: MaterialInput) -> Surface {
    let water_dist = length(input.position);
    let view_dir = neoqua_safe_normalize(-input.position);
    let wp = neoqua_wrap_pos(input.position + frame.camera_position);

    let wave_n = neoqua_water_normal(wp.xz, frame.time, water_dist);
    let geo_n = neoqua_safe_normalize(input.normal);
    var n = neoqua_safe_normalize(mix(geo_n, wave_n, clamp(abs(geo_n.y), 0.25, 1.0)));

    let underwater_view = dot(view_dir, n) < 0.0;
    if (underwater_view) {
        n = -n;
    }

    let base_texel = neoqua_clamp_texel(input.screen);
    let base_depth = textureLoad(opaque_depth, base_texel, 0).r;
    let base_floor_dist = neoqua_depth_to_dist(input.screen, base_depth);
    let base_thickness = max(base_floor_dist - water_dist, 0.0);

    let refr_scale = clamp(base_thickness * 0.18, 0.0, 1.0) * (0.016 / max(water_dist * 0.12 + 0.6, 0.6));
    let refr_uv = clamp(input.screen + vec2<f32>(n.x, n.z) * refr_scale, vec2<f32>(0.001), vec2<f32>(0.999));
    let refr_texel = neoqua_clamp_texel(refr_uv);
    let refr_depth = textureLoad(opaque_depth, refr_texel, 0).r;
    let refr_floor_dist = neoqua_depth_to_dist(refr_uv, refr_depth);

    let use_refr = refr_floor_dist >= (water_dist - 0.05);
    let final_texel = select(base_texel, refr_texel, use_refr);
    let thickness = select(base_thickness, max(refr_floor_dist - water_dist, 0.0), use_refr);

    let raw_bg = neoqua_sanitize_rgb(textureLoad(opaque_color, final_texel, 0).rgb);
    let bg_valid = (raw_bg.r + raw_bg.g + raw_bg.b) > 1e-5;
    let bg_col = select(input.albedo.rgb * input.tint.rgb * input.lightmap, raw_bg, bg_valid);

    let clarity = max(water_clarity, 0.25);
    let absorb = exp(-NEOQUA_WATER_ABSORB * (thickness / clarity));
    let scatter_amt = 1.0 - exp(-thickness * 0.22 / clarity);

    let factors = neoqua_day_factors();
    let sky_open = smoothstep(0.12, 0.92, input.light.y);
    let ambient_scale = mix(0.18, 1.0, factors.x) * (1.0 - frame.rain * 0.35);
    let biome_tint = mix(vec3<f32>(0.55, 0.85, 1.0), clamp(input.tint.rgb * 1.4, vec3<f32>(0.2), vec3<f32>(1.2)), 0.55);
    let scatter_col = NEOQUA_WATER_SCATTER * biome_tint * (ambient_scale * sky_open + 0.14 + input.light.x * 0.35);

    var refracted = bg_col * absorb + scatter_col * scatter_amt;

    if (water_waves && thickness > 0.05 && thickness < 14.0 && water_dist < 42.0) {
        let caustics_uv = wp.xz * 0.1875 + vec2<f32>(frame.time * 0.04, -frame.time * 0.03);
        let c_a = textureSampleLevel(noise, noise_sampler, caustics_uv, 0.0).r;
        let c_b = textureSampleLevel(noise, noise_sampler, caustics_uv * 1.5 - vec2<f32>(frame.time * 0.05, frame.time * 0.03), 0.0).r;
        let caustics = pow(clamp(1.0 - abs(c_a - c_b) * 2.6, 0.0, 1.0), 4.0);
        let depth_window = smoothstep(0.05, 0.45, thickness) * exp(-thickness * 0.18);
        refracted = refracted + vec3<f32>(0.32, 0.58, 0.68) * caustics * depth_window * factors.x * sky_open * (1.0 - frame.rain * 0.7);
    }

    let ndv = clamp(dot(n, view_dir), 0.0, 1.0);
    let fresnel_base = select(0.02, 0.08, underwater_view);
    let fresnel = fresnel_base + (1.0 - fresnel_base) * pow(1.0 - ndv, 5.0);

    let refl_dir = reflect(-view_dir, n);
    let clamped_refl_dir = neoqua_safe_normalize(vec3<f32>(refl_dir.x, max(refl_dir.y, 0.02), refl_dir.z));
    var refl_col = neoqua_sky_eval(clamped_refl_dir, false) * (0.28 + 0.72 * sky_open);

    if (water_reflection && frame.has_reflection == 1u && underwater_view == false) {
        let refl_uv = clamp(input.screen + vec2<f32>(n.x, n.z) * 0.045, vec2<f32>(0.002), vec2<f32>(0.998));
        let mirror = textureSampleLevel(reflection, reflection_sampler, refl_uv, 0.0);
        let mirror_rgb = neoqua_sanitize_rgb(mirror.rgb);
        let mirror_blend = clamp(mirror.a, 0.0, 1.0) * 0.80;
        refl_col = mix(refl_col, mirror_rgb, mirror_blend);
    }

    let light_dir = neoqua_safe_normalize(frame.light_direction);
    let spec_tint = mix(NEOQUA_MOON_COL * 0.45, mix(NEOQUA_SUN_COL, NEOQUA_SUNSET_COL, factors.y), factors.x);
    let spec = neoqua_ggx_specular(n, view_dir, light_dir, 0.095) * (1.0 - frame.rain * 0.78) * sky_open;
    let glint = spec_tint * spec * 1.45;

    let foam_noise = textureSampleLevel(noise, noise_sampler, wp.xz * 0.453125 + vec2<f32>(frame.time * 0.02, 0.0), 0.0).r;
    let shore_mask = (1.0 - smoothstep(0.04, 0.52, thickness)) * smoothstep(0.005, 0.06, thickness);
    let foam = clamp(shore_mask * smoothstep(0.28, 0.78, foam_noise + 0.25), 0.0, 0.85) * (0.25 + 0.75 * ambient_scale);

    var final_col = mix(refracted, refl_col, clamp(fresnel * 0.92, 0.02, 0.94)) + glint;
    final_col = mix(final_col, NEOQUA_FOAM_COL * (0.35 + 0.65 * ambient_scale + input.light.x * 0.4), foam);
    final_col = neoqua_apply_fog(final_col, input.position);

    return Surface(vec4<f32>(neoqua_sanitize_rgb(final_col), 1.0));
}

fn material(input: MaterialInput) -> Surface {
    if (input.material == 1u || input.fluid == 1u) {
        return neoqua_shade_water(input);
    }

    let base_albedo = input.albedo.rgb * input.tint.rgb;
    let n = neoqua_safe_normalize(input.normal);
    let view_dir = neoqua_safe_normalize(-input.position);
    let dist = length(input.position);

    var lit = neoqua_eval_lighting(n, input.light, input.lightmap, input.colored_light, torch_warmth);
    let custom_light = block_light_color(input.position);
    lit = lit + neoqua_sanitize_rgb(custom_light.rgb) * clamp(custom_light.a, 0.0, 1.0) * 0.42;

    var col = base_albedo * lit;

    if (rain_ripples && frame.wetness > 0.01 && input.translucent == false && dist < 44.0) {
        let up_mask = smoothstep(0.65, 0.92, n.y) * smoothstep(0.70, 0.95, input.light.y);
        if (up_mask > 0.01) {
            let wp = neoqua_wrap_pos(input.position + frame.camera_position);
            let puddle_n = textureSampleLevel(noise, noise_sampler, wp.xz * 0.140625, 0.0).r;
            let puddle = smoothstep(0.38, 0.72, puddle_n) * frame.wetness * up_mask;
            col = col * (1.0 - puddle * 0.24);

            let refl_dir = reflect(-view_dir, n);
            let ndv = clamp(dot(n, view_dir), 0.0, 1.0);
            let wet_fresnel = (0.03 + 0.97 * pow(1.0 - ndv, 5.0)) * puddle * 0.55;
            let sky_refl = neoqua_sky_eval(neoqua_safe_normalize(vec3<f32>(refl_dir.x, max(refl_dir.y, 0.05), refl_dir.z)), false);
            col = mix(col, sky_refl, wet_fresnel);
        }
    }

    if (input.material == 4u) {
        let em_strength = 0.65 + 0.45 * torch_warmth;
        col = col + base_albedo * vec3<f32>(1.15, 0.78, 0.42) * em_strength;
    } else if (input.material == 5u) {
        col = col + base_albedo * vec3<f32>(0.55, 0.95, 1.15) * 0.85;
    }

    col = neoqua_apply_fog(col, input.position);
    return Surface(vec4<f32>(neoqua_sanitize_rgb(col), input.albedo.a));
}
