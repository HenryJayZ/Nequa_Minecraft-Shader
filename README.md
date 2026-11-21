# Neoqua

WIP shader pack for [Horizon](https://github.com/horizon-rust/horizon) (the Rust/wgpu rewrite of
Minecraft 26.3), targeting Intel HD 4600 @ 768p / 60 fps on DDR3. Written against **Shader API 0.2**
(linear light, HDR-safe); WGSL only — no GLSL, no preprocessor.

Water is the hero feature; the look is a clean "neoqua" aqua grade with FXAA-style post and no
shadows or ray tracing in v0.1.

## Layout

```
neoqua/                  the shader pack (folder form of a .hshader)
  horizon-shaders.toml   manifest (schema = 1, api = "0.2")  <- Gemini Neon writes this
  common.wgsl            shared helpers                       <- Gemini Neon
  *.wgsl, post/*.wgsl    stage files                          <- Gemini Neon
  textures/noise.png     seamless tileable 64x64 value noise ([[textures]] id = "noise", data texture)
tools/
  check.sh               horizon-shader check neoqua --json
  bench.sh               horizon-ctl bench 5
  shots.sh               horizon-ctl screenshot-sequence (HORIZON_STILL, deterministic PNGs)
docs? no — see upstream: https://github.com/horizon-rust/horizon/blob/main/docs/api/shaders-reference-0.2.md
```

## Division of labour

- **Gemini Neon**: all `.wgsl` stage code and `neoqua/horizon-shaders.toml`.
- **Qwen Coder**: repo scaffolding, `noise.png`, helper scripts, running `horizon-shader check`,
  commits & pushes. No `.wgsl` is written here until Gemini's code lands.

## Usage

```sh
./tools/check.sh          # validate the pack (needs horizon-shader on PATH)
./tools/bench.sh          # benchmark (needs horizon-ctl on PATH)
./tools/shots.sh 60 16.666667 shots/ref.png   # deterministic reference shot
```

Point Horizon at the pack with `HORIZON_SHADER_PACK=$PWD/neoqua` during development; hot reload
watches the folder.
