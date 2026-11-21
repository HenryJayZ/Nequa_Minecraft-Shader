// Neoqua - post pass 2: quarter-res 5-tap tent blur of `bloom_a` into `bloom_b`.

override bloom_enabled: bool = true;

fn post(input: PostInput) -> vec4<f32> {
    if (bloom_enabled == false) {
        return vec4<f32>(0.0);
    }

    let dims = max(vec2<f32>(textureDimensions(bloom_a, 0)), vec2<f32>(1.0));
    let off = vec2<f32>(1.5) / dims;

    let c = neoqua_sanitize_rgb(textureSampleLevel(bloom_a, linear_sampler, input.uv, 0.0).rgb) * 4.0;
    let t0 = neoqua_sanitize_rgb(textureSampleLevel(bloom_a, linear_sampler, input.uv + vec2<f32>(-off.x, -off.y), 0.0).rgb);
    let t1 = neoqua_sanitize_rgb(textureSampleLevel(bloom_a, linear_sampler, input.uv + vec2<f32>(off.x, -off.y), 0.0).rgb);
    let t2 = neoqua_sanitize_rgb(textureSampleLevel(bloom_a, linear_sampler, input.uv + vec2<f32>(-off.x, off.y), 0.0).rgb);
    let t3 = neoqua_sanitize_rgb(textureSampleLevel(bloom_a, linear_sampler, input.uv + vec2<f32>(off.x, off.y), 0.0).rgb);

    let blurred = (c + t0 + t1 + t2 + t3) * 0.125;
    return vec4<f32>(neoqua_sanitize_rgb(blurred), 1.0);
}
