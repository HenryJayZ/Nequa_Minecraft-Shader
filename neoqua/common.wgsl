// Neoqua - shared helpers, prepended to every stage (Shader API 0.2, linear light).
// Pure math and `frame` helpers only: the prelude owns every binding.

const NEOQUA_PI: f32 = 3.14159265;
const NEOQUA_TAU: f32 = 6.28318530;
const NEOQUA_WRAP: f32 = 64.0;
const NEOQUA_K_UNIT: f32 = 0.09817477;

// BT.709 luminance weights. API 0.2 has no `frame.luminance`; this is the same
// dot product the reference documents.
const NEOQUA_LUMA: vec3<f32> = vec3<f32>(0.2126, 0.7152, 0.0722);

const NEOQUA_DAY_ZENITH: vec3<f32> = vec3<f32>(0.075, 0.245, 0.680);
const NEOQUA_DAY_HORIZON: vec3<f32> = vec3<f32>(0.420, 0.690, 0.960);
const NEOQUA_SUNSET_ZENITH: vec3<f32> = vec3<f32>(0.090, 0.120, 0.340);
const NEOQUA_SUNSET_HORIZON: vec3<f32> = vec3<f32>(0.980, 0.340, 0.110);
const NEOQUA_NIGHT_ZENITH: vec3<f32> = vec3<f32>(0.005, 0.011, 0.032);
const NEOQUA_NIGHT_HORIZON: vec3<f32> = vec3<f32>(0.018, 0.034, 0.075);
const NEOQUA_RAIN_SKY: vec3<f32> = vec3<f32>(0.180, 0.210, 0.250);
const NEOQUA_WATER_FOG: vec3<f32> = vec3<f32>(0.025, 0.160, 0.240);
const NEOQUA_LAVA_FOG: vec3<f32> = vec3<f32>(0.850, 0.180, 0.020);
const NEOQUA_SUN_COL: vec3<f32> = vec3<f32>(1.000, 0.910, 0.740);
const NEOQUA_SUNSET_COL: vec3<f32> = vec3<f32>(1.000, 0.420, 0.140);
const NEOQUA_MOON_COL: vec3<f32> = vec3<f32>(0.420, 0.560, 0.850);
const NEOQUA_TORCH_COL: vec3<f32> = vec3<f32>(1.000, 0.540, 0.190);

// Declared here because both the vertex stage (its own module) and the material
// stage (which appends vertex.wgsl) use it.
override water_waves: bool = true;

fn neoqua_sanitize_scalar(v: f32) -> f32 {
    let ok = (v >= 0.0) && (v <= 65504.0);
    return select(0.0, v, ok);
}

fn neoqua_sanitize_rgb(c: vec3<f32>) -> vec3<f32> {
    return vec3<f32>(
        neoqua_sanitize_scalar(c.r),
        neoqua_sanitize_scalar(c.g),
        neoqua_sanitize_scalar(c.b),
    );
}

fn neoqua_safe_normalize(v: vec3<f32>) -> vec3<f32> {
    let len_sq = dot(v, v);
    if (len_sq < 1e-10) {
        return vec3<f32>(0.0, 1.0, 0.0);
    }
    return v * inverseSqrt(len_sq);
}

fn neoqua_luma(c: vec3<f32>) -> f32 {
    return max(dot(c, NEOQUA_LUMA), 0.0);
}

// The wave phases are integer multiples of 2*pi over 64 blocks, so wrapping world
// positions keeps the pattern continuous across the wrap.
fn neoqua_wrap_pos(world_pos: vec3<f32>) -> vec3<f32> {
    return world_pos - floor(world_pos / NEOQUA_WRAP) * NEOQUA_WRAP;
}

fn neoqua_day_factors() -> vec3<f32> {
    let sun_y = frame.sun_direction.y;
    let day = smoothstep(-0.08, 0.22, sun_y);
    let sunset = smoothstep(-0.18, 0.02, sun_y) * (1.0 - smoothstep(0.06, 0.34, sun_y));
    let night = 1.0 - day;
    return vec3<f32>(day, sunset, night);
}

fn neoqua_sky_eval(raw_dir: vec3<f32>, include_glare: bool) -> vec3<f32> {
    let dir = neoqua_safe_normalize(raw_dir);

    if (frame.dimension == -1) {
        let h = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);
        return mix(frame.fog_color * 1.15, frame.fog_color * 0.55, h);
    }
    if (frame.dimension == 1) {
        let h = pow(1.0 - abs(dir.y), 2.5);
        return vec3<f32>(0.012, 0.008, 0.026) + vec3<f32>(0.055, 0.028, 0.095) * h;
    }

    let factors = neoqua_day_factors();
    let day = factors.x;
    let sunset = factors.y;
    let night = factors.z;

    let up = clamp(dir.y, 0.0, 1.0);
    let sky_curve = pow(1.0 - up, 3.2);
    let lower_fade = smoothstep(-0.35, 0.02, dir.y);

    var zenith = mix(NEOQUA_NIGHT_ZENITH, NEOQUA_DAY_ZENITH, day);
    zenith = mix(zenith, NEOQUA_SUNSET_ZENITH, sunset * 0.72);

    var horizon = mix(NEOQUA_NIGHT_HORIZON, NEOQUA_DAY_HORIZON, day);
    horizon = mix(horizon, NEOQUA_SUNSET_HORIZON, sunset * 0.85);

    var sky = mix(zenith, horizon, sky_curve);

    let sun_dir = neoqua_safe_normalize(frame.sun_direction);
    let moon_dir = neoqua_safe_normalize(frame.moon_direction);
    let sun_dot = max(dot(dir, sun_dir), 0.0);
    let moon_dot = max(dot(dir, moon_dir), 0.0);

    let sunset_band = pow(sun_dot, 3.0) * pow(1.0 - up, 2.2) * sunset;
    sky = sky + NEOQUA_SUNSET_COL * sunset_band * 0.85;

    if (include_glare) {
        let sun_mie = (pow(sun_dot, 12.0) * 0.28 + pow(sun_dot, 96.0) * 1.35) * day;
        let sun_tint = mix(NEOQUA_SUN_COL, NEOQUA_SUNSET_COL, sunset);
        let moon_mie = (pow(moon_dot, 16.0) * 0.14 + pow(moon_dot, 96.0) * 0.45) * night;
        sky = sky + sun_tint * sun_mie + NEOQUA_MOON_COL * moon_mie;
    }

    let storm = clamp(frame.rain * 0.72 + frame.thunder * 0.35, 0.0, 0.92);
    let rain_tint = NEOQUA_RAIN_SKY * mix(0.14, 1.0, day) * (1.0 - frame.thunder * 0.45);
    sky = mix(sky, rain_tint, storm);

    let ground_col = horizon * mix(0.32, 0.55, storm);
    sky = mix(ground_col, sky, lower_fade);

    return neoqua_sanitize_rgb(sky);
}

fn neoqua_fog_factor(cam_rel_pos: vec3<f32>) -> f32 {
    let dist = length(cam_rel_pos);
    let cyl_dist = max(length(cam_rel_pos.xz), abs(cam_rel_pos.y));

    var env_fog = 0.0;
    if (frame.fog_end > frame.fog_start + 0.01) {
        let span = frame.fog_end - frame.fog_start;
        env_fog = clamp((dist - frame.fog_start) / span, 0.0, 1.0);
    }

    var ren_fog = 0.0;
    if (frame.render_distance > frame.fog_start + 1.0) {
        let span = frame.render_distance - frame.fog_start;
        ren_fog = clamp((cyl_dist - frame.fog_start) / span, 0.0, 1.0);
    }

    var fog = max(env_fog * env_fog * (3.0 - 2.0 * env_fog), ren_fog * ren_fog);

    if (frame.in_water > 0.001) {
        let uw = 1.0 - exp(-dist * 0.055);
        fog = max(fog, uw * frame.in_water);
    }
    if (frame.in_lava > 0.001) {
        let lv = 1.0 - exp(-dist * 0.65);
        fog = max(fog, lv * frame.in_lava);
    }

    let dark_fx = max(frame.blindness, frame.darkness);
    if (dark_fx > 0.001) {
        let df = clamp(dist / 12.0, 0.0, 1.0) * dark_fx;
        fog = max(fog, df);
    }

    return clamp(fog, 0.0, 1.0);
}

fn neoqua_apply_fog(color: vec3<f32>, cam_rel_pos: vec3<f32>) -> vec3<f32> {
    let fog = neoqua_fog_factor(cam_rel_pos);
    if (fog <= 0.0001) {
        return color;
    }

    let dir = neoqua_safe_normalize(cam_rel_pos);
    var fog_col = frame.fog_color;
    if (frame.dimension == 0) {
        let fog_dir = neoqua_safe_normalize(vec3<f32>(dir.x, max(dir.y, 0.04), dir.z));
        fog_col = mix(neoqua_sky_eval(fog_dir, true), frame.fog_color, 0.22);
    }
    if (frame.in_water > 0.001) {
        let day = neoqua_day_factors().x;
        let uw_col = NEOQUA_WATER_FOG * mix(0.22, 1.0, day);
        fog_col = mix(fog_col, uw_col, frame.in_water);
    }
    if (frame.in_lava > 0.001) {
        fog_col = mix(fog_col, NEOQUA_LAVA_FOG, frame.in_lava);
    }

    let dark_fx = max(frame.blindness, frame.darkness);
    fog_col = fog_col * (1.0 - dark_fx * 0.95);

    return neoqua_sanitize_rgb(mix(color, fog_col, fog));
}

fn neoqua_eval_lighting(
    normal: vec3<f32>,
    light: vec2<f32>,
    lightmap: vec3<f32>,
    colored_light: vec3<f32>,
    torch_warmth: f32,
) -> vec3<f32> {
    let n = neoqua_safe_normalize(normal);
    let light_dir = neoqua_safe_normalize(frame.light_direction);
    let factors = neoqua_day_factors();
    let day = factors.x;
    let sunset = factors.y;
    let night = factors.z;

    let storm_damp = 1.0 - clamp(frame.rain * 0.55 + frame.thunder * 0.25, 0.0, 0.78);
    let sky_open = smoothstep(0.15, 0.95, light.y);

    let ndl = max(dot(n, light_dir), 0.0);
    let wrap_ndl = clamp((dot(n, light_dir) + 0.35) / 1.35, 0.0, 1.0);
    let hemi = n.y * 0.5 + 0.5;

    let direct_tint = mix(
        NEOQUA_MOON_COL * 0.42,
        mix(NEOQUA_SUN_COL, NEOQUA_SUNSET_COL, sunset * 0.85),
        day,
    );
    let direct = direct_tint * (ndl * 0.62 + wrap_ndl * 0.18) * sky_open * storm_damp;

    let sky_ambient_tint = mix(vec3<f32>(0.22, 0.30, 0.52), vec3<f32>(0.68, 0.82, 1.0), day);
    let sky_hemi = mix(0.76, 1.14, hemi);

    let block_sq = light.x * light.x;
    let warm_tint = mix(vec3<f32>(1.0, 0.96, 0.90), NEOQUA_TORCH_COL, clamp(torch_warmth * 0.72, 0.0, 1.0));
    let torch_boost = warm_tint * block_sq * (0.28 + 0.44 * torch_warmth);

    var lit = lightmap * mix(1.0, sky_hemi, sky_open * 0.65);
    if (frame.dimension == 0) {
        lit = lit * mix(vec3<f32>(1.0), sky_ambient_tint, sky_open * (0.18 + 0.16 * night));
        lit = lit + direct;
    }

    lit = lit + torch_boost + max(colored_light, vec3<f32>(0.0)) * 0.35;

    if (frame.night_vision > 0.001) {
        lit = max(lit, vec3<f32>(0.42, 0.44, 0.48) * frame.night_vision);
    }

    return neoqua_sanitize_rgb(max(lit, vec3<f32>(0.004)));
}
