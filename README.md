# Neoqua

A cinematic, water-first shader pack for [Horizon](https://github.com/horizon-rust/horizon)
(Minecraft: Java Edition 26.3 rewritten in Rust on wgpu), written against **Shader API 0.2**
(linear light, HDR-safe) and tuned for an Intel HD 4600 at 768p / 60 fps on DDR3.

WGSL only — no GLSL, no OptiFine/Iris files, no preprocessor, no ray tracing and no shadow maps.

## Requirements

- A Horizon build that carries **Shader API 0.2** (`api = "0.2"`). 0.1 was retired on Nov 13.
- Launch the game with **`HORIZON_HDR_FRAME=float`**: the game only draws 0.2 packs with it set.
- No LabPBR resource pack is required; the pack works from vanilla textures.

## Install

```sh
./tools/check.sh                 # static pre-check, then horizon-shader check --json
horizon-shader pack neoqua       # -> neoqua-0.1.1.hshader
cp neoqua-0.1.1.hshader ~/.local/share/horizon/shaderpacks/
```

Or point Horizon at the folder directly while developing:

```sh
ln -s "$PWD/neoqua" ~/.local/share/horizon/shaderpacks/neoqua
HORIZON_SHADER_PACK="$PWD/neoqua" HORIZON_HDR_FRAME=float horizon
```

Then **Options → Shader Packs → Neoqua**.

## What it does

| Area | Feature |
| --- | --- |
| Water | Rolling vertex swell, multi-sine + noise normals, depth absorption, refraction through `opaque_color`, shoreline foam, caustics, rain ripples, Fresnel sky reflection, GGX sun glint, optional planar mirror (`[reflection]`, toggleable) |
| World | Waving leaves and plants, warm torchlight tint from block light, emissive lava/glowstone/soul blocks, wet-surface sheen after rain |
| Sky | Analytic day/sunset/night gradient, sun and moon glow, optional star field, storm desaturation; vanilla sun and clouds still draw over it |
| Weather | Rain and snow streaks tinted by sky and block light |
| Post | Half-res threshold bloom (5-tap tent at quarter res), cinematic grade with three presets, vignette, HDR-safe FXAA |
| Display | Exposure, filmic curve and highlight roll-off in `[tonemap]`, driven by `frame.headroom` |

Twelve options, laid out on three pages (Water / Atmosphere & World / Post-Processing).

## Layout

```
neoqua/                     the pack (folder form of a .hshader)
  horizon-shaders.toml      manifest (schema = 1, api = "0.2")
  common.wgsl               shared math + frame helpers (prepended to every stage)
  sky.wgsl                  [sky]
  vertex.wgsl               [vertex]  (joins the material module)
  material.wgsl             [material] + water
  weather.wgsl              [weather]
  tonemap.wgsl              [tonemap]
  post/
    bloom_bright.wgsl       [[post]] -> bloom_a @ 0.5
    bloom_blur.wgsl         [[post]] -> bloom_b @ 0.25
    grade.wgsl              [[post]] (writes previous)
    fxaa.wgsl               [[post]] (last, draws the picture)
  textures/noise.png        seamless 64x64 value noise ([[textures]] id = "noise")
tools/
  check.sh                  validate_pack.py + horizon-shader check --json
  validate_pack.py          offline schema/contract check (no Rust needed)
  bench.sh                  horizon-ctl bench 5
  shots.sh                  horizon-ctl screenshot-sequence (HORIZON_STILL)
```

## API 0.2 rules this pack is built around

These are the traps that made earlier drafts fail against the real API:

- **Luminance** is `dot(c, vec3(0.2126, 0.7152, 0.0722))`; there is no `frame.luminance`.
- **`MaterialInput.tint`**, not `shaded_tint`, is the vertex colour (biome tint + face shade + AO).
- **`opaque_depth` / `scene_depth` are `texture_2d<f32>`**: load them and read `.r`.
- **No `[entity]` stage**: API 0.2 has sky, vertex, material, weather, post and tonemap only.
- **`[sky]` keys** are `clouds`, `sun`, `stars` (there is no `moon` key).
- **`[frame]`** accepts `blend` only (`gamma` or `linear`; the game serves `gamma`).
- **A post pass's alpha is ignored**, and `[[post]]` runs in linear HDR *before* `[tonemap]`.
- **`output` diverts the chain**: the next pass's `previous` is the picture before the diverting
  pass, so the grade pass here deliberately writes `previous`.
- The material stage applies its own fog (`[material] fog = false`).
- Every stage must stay under 20,000 naga expressions and 64 texture reads.

## Scripts

```sh
./tools/check.sh                              # static check + horizon-shader check --json
./tools/bench.sh                              # horizon-ctl bench 5
./tools/shots.sh 60 16.666667 shots/neoqua.png
```

`horizon-shader` and `horizon-ctl` come from a Horizon build
(`cargo build --release -p horizon-shader -p horizon-client`). Without them, `validate_pack.py`
still runs and catches manifest/WGSL contract drift.
