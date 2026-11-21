#!/usr/bin/env python3
"""Static pre-check for the Neoqua pack against Horizon's Shader API 0.2.

The real gate is `horizon-shader check` (naga + SPIR-V/Metal/HLSL translation).
This script mirrors the documented manifest schema and stage contracts from
`crates/horizon-shader-api` so the obvious, expensive-to-discover failures are
caught without a Rust toolchain: unknown keys, missing files, option/override
drift, wrong input/frame fields, post-chain mistakes and stray files.
"""
from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PACK = ROOT / "neoqua"

TOP_KEYS = {
    "schema", "id", "name", "version", "api", "description", "authors", "license",
    "shared", "sky", "vertex", "material", "weather", "post", "tonemap", "frame",
    "options", "pages", "tags", "materials", "textures", "lights", "particle_lights",
    "budget", "reflection", "shadow", "displacement",
}
STAGE_KEYS = {"file", "files", "name", "fog", "clouds", "sun", "stars", "scale", "output"}
SKY_KEYS = {"file", "files", "name", "clouds", "sun", "stars"}
OPTION_KEYS = {"id", "name", "description", "type", "default", "min", "max", "step", "values"}
PAGE_KEYS = {"id", "name", "description", "columns", "items"}
MATERIAL_KEYS = {"id", "sprites", "blocks", "translucent"}
TEXTURE_KEYS = {"id", "file", "filter", "wrap"}
LIGHT_KEYS = {"color", "blocks"}
FRAME_KEYS = {"blend"}
BUDGET_KEYS = {"gpu_ms"}
REFLECTION_KEYS = {"option"}

FRAME_FIELDS = {
    "view", "projection", "view_inverse", "projection_inverse", "camera_position",
    "time", "sun_direction", "day_time", "moon_direction", "game_time", "sky_color",
    "rain", "fog_color", "thunder", "resolution", "eye_light", "fog_start", "fog_end",
    "render_distance", "far", "night_vision", "blindness", "darkness", "brightness",
    "eye_in", "dimension", "frame_index", "hide_gui", "precipitation", "temperature",
    "downfall", "wetness", "previous_view_projection", "camera_motion", "delta_time",
    "eye_light_smooth", "in_water", "in_lava", "water_plane", "has_reflection",
    "reflection_resolution", "mods", "light_direction", "has_shadow",
    "shadow_view_proj", "shadow_distance", "shadow_distortion", "shadow_resolution",
    "shadow_center_texel", "hdr", "headroom", "paper_white", "peak", "black_level",
}

INPUT_FIELDS = {
    "sky": {"direction", "color"},
    "vertex": {"position", "uv", "material", "light", "tint", "face", "fluid"},
    "material": {
        "albedo", "tint", "light", "lightmap", "position", "uv", "translucent",
        "tags", "material", "screen", "face", "fluid", "emission", "normal",
        "tangent", "colored_light", "displaced",
    },
    "weather": {"color", "light", "position", "snow"},
    "post": {"uv", "pixel", "color", "depth"},
    "tonemap": {"uv", "pixel", "color"},
}

ENTRY = {
    "sky": "fn sky(input: SkyInput) -> vec4<f32>",
    "vertex": "fn vertex(input: VertexInput) -> vec3<f32>",
    "material": "fn material(input: MaterialInput) -> Surface",
    "weather": "fn weather(input: WeatherInput) -> vec4<f32>",
    "post": "fn post(input: PostInput) -> vec4<f32>",
    "tonemap": "fn tonemap(input: TonemapInput) -> vec3<f32>",
}

OPTION_TYPES = {"bool": "bool", "float": "f32", "int": "i32", "choice": "u32"}
POST_SCALES = {1.0, 0.5, 0.25}
RESERVED_TARGETS = {
    "frame", "scene_color", "scene_depth", "previous", "linear_sampler",
    "nearest_sampler", "shadow_map", "shadow_sampler", "history",
    "shadow_map_translucent", "shadow_color", "scene_surface",
}
EXTRAS = {"README.md", "LICENSE", "LICENSE.md", "LICENSE.txt", "icon.png"}

errors: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def strip_comments(text: str) -> str:
    return re.sub(r"//[^\n]*", "", text)


def check_unknown(table: dict, allowed: set[str], where: str) -> None:
    for key in table:
        if key not in allowed:
            err(f"{where}: unknown key {key!r} (allowed: {sorted(allowed)})")


def main() -> int:
    manifest_path = PACK / "horizon-shaders.toml"
    if not manifest_path.is_file():
        print("error: neoqua/horizon-shaders.toml missing")
        return 1
    m = tomllib.loads(read(manifest_path))
    check_unknown(m, TOP_KEYS, "manifest")

    if m.get("schema") != 1:
        err("manifest: schema must be 1")
    if not re.fullmatch(r"[a-z0-9_]{1,64}", str(m.get("id", ""))):
        err("manifest: id must match [a-z0-9_]{1,64}")
    if m.get("api") != "0.2":
        err('manifest: api must be "0.2"')

    shared = m.get("shared", [])
    stages: dict[str, dict] = {}
    for key in ("sky", "vertex", "material", "weather", "tonemap"):
        if key in m:
            stages[key] = m[key]
            check_unknown(m[key], SKY_KEYS if key == "sky" else STAGE_KEYS, f"[{key}]")
    post = m.get("post", [])
    for i, p in enumerate(post):
        check_unknown(p, STAGE_KEYS, f"[[post]] #{i + 1}")

    if "frame" in m:
        check_unknown(m["frame"], FRAME_KEYS, "[frame]")
        if m["frame"].get("blend", "gamma") not in ("gamma", "linear"):
            err("[frame] blend must be gamma or linear")
    if "budget" in m:
        check_unknown(m["budget"], BUDGET_KEYS, "[budget]")
        if not 0.0 <= float(m["budget"].get("gpu_ms", 0)) <= 16.0:
            err("[budget] gpu_ms must be 0..16")
    if "reflection" in m:
        check_unknown(m["reflection"], REFLECTION_KEYS, "[reflection]")

    options = m.get("options", [])
    if len(options) > 64:
        err("manifest: more than 64 [[options]]")
    option_types: dict[str, str] = {}
    for o in options:
        check_unknown(o, OPTION_KEYS, f"option {o.get('id')!r}")
        oid = o.get("id")
        if not isinstance(oid, str) or not re.fullmatch(r"[A-Za-z_]\w*", oid):
            err(f"option {oid!r}: id is not a WGSL identifier")
            continue
        if oid in option_types:
            err(f"option {oid!r}: duplicate id")
        kind = o.get("type")
        if kind not in OPTION_TYPES:
            err(f"option {oid!r}: type must be bool, float, int or choice")
            continue
        option_types[oid] = OPTION_TYPES[kind]
        if kind in ("float", "int"):
            if not {"min", "max"} <= set(o):
                err(f"option {oid!r}: {kind} needs min and max")
            if kind == "float" and "step" not in o:
                err(f"option {oid!r}: float needs step")
        if kind == "choice":
            values = o.get("values")
            if not values:
                err(f"option {oid!r}: choice needs values")
            elif o.get("default") not in values:
                err(f"option {oid!r}: default must be one of values")
        if "default" not in o:
            err(f"option {oid!r}: missing default")

    pages = m.get("pages", [])
    page_ids = {p.get("id") for p in pages}
    for p in pages:
        check_unknown(p, PAGE_KEYS, f"page {p.get('id')!r}")
        if p.get("columns", 2) not in (1, 2):
            err(f"page {p.get('id')!r}: columns must be 1 or 2")
        for item in p.get("items", []):
            if item == "":
                continue
            if item.startswith("page:"):
                if item[5:] not in page_ids:
                    err(f"page {p.get('id')!r}: links unknown page {item!r}")
            elif item not in option_types:
                err(f"page {p.get('id')!r}: unknown option {item!r}")

    textures = m.get("textures", [])
    if len(textures) > 8:
        err("manifest: more than 8 [[textures]]")
    texture_ids = set()
    for t in textures:
        check_unknown(t, TEXTURE_KEYS, f"texture {t.get('id')!r}")
        if not re.fullmatch(r"[A-Za-z_]\w*", str(t.get("id", ""))):
            err(f"texture {t.get('id')!r}: id is not a WGSL identifier")
        texture_ids.add(t.get("id"))
        if t.get("filter", "linear") not in ("linear", "nearest"):
            err(f"texture {t.get('id')!r}: filter must be linear or nearest")
        if t.get("wrap", "repeat") not in ("repeat", "clamp"):
            err(f"texture {t.get('id')!r}: wrap must be repeat or clamp")

    materials = m.get("materials", [])
    if len(materials) > 1024:
        err("manifest: more than 1024 [[materials]]")
    material_ids = set()
    for mat in materials:
        check_unknown(mat, MATERIAL_KEYS, f"material {mat.get('id')!r}")
        mid = mat.get("id")
        if not isinstance(mid, int) or not 1 <= mid <= 65535:
            err(f"material {mid!r}: id must be 1..65535")
        elif mid in material_ids:
            err(f"material {mid!r}: duplicate id")
        material_ids.add(mid)
        if not mat.get("sprites") and not mat.get("blocks"):
            err(f"material {mid!r}: needs sprites or blocks")

    for light in m.get("lights", []):
        check_unknown(light, LIGHT_KEYS, "[[lights]]")

    # ---- files the pack may hold -------------------------------------------
    named: set[str] = {"horizon-shaders.toml", *shared}
    for stage in stages.values():
        named.add(stage.get("file", ""))
        named.update(stage.get("files", []))
    for p in post:
        named.add(p.get("file", ""))
        named.update(p.get("files", []))
    for t in textures:
        named.add(t.get("file", ""))
    named.discard("")

    for name in sorted(named):
        if not name or not (PACK / name).is_file():
            err(f"manifest names missing file {name!r}")
    for path in sorted(PACK.rglob("*")):
        if path.is_dir():
            continue
        rel = path.relative_to(PACK).as_posix()
        if any(part.startswith(".") for part in path.relative_to(PACK).parts):
            continue
        if rel not in named and rel not in EXTRAS:
            err(f"pack holds {rel!r}, which the manifest does not name (the check refuses it)")

    # ---- WGSL static checks ------------------------------------------------
    def composed(kind: str) -> list[tuple[str, str]]:
        files = [(name, read(PACK / name)) for name in shared if (PACK / name).is_file()]
        stage = stages.get(kind)
        if stage:
            for extra in stage.get("files", []):
                if extra not in shared and (PACK / extra).is_file():
                    files.append((extra, read(PACK / extra)))
            if (PACK / stage["file"]).is_file():
                files.append((stage["file"], read(PACK / stage["file"])))
        if kind == "material" and "vertex" in stages:
            for extra in stages["vertex"].get("files", []) + [stages["vertex"]["file"]]:
                if extra not in shared and (PACK / extra).is_file():
                    files.append((extra, read(PACK / extra)))
        return files

    def scan(kind: str, label: str, own_file: str) -> None:
        files = composed(kind)
        text = "\n".join(strip_comments(t) for _, t in files)
        for field in set(re.findall(r"\bframe\.(\w+)", text)):
            if field not in FRAME_FIELDS:
                err(f"{label}: frame.{field} is not a Frame field")
        for field in set(re.findall(r"\binput\.(\w+)", text)):
            if field not in INPUT_FIELDS[kind]:
                err(f"{label}: input.{field} is not a {kind} input field")
        for name, body in files:
            clean = strip_comments(body)
            if name == own_file and "fn " + ENTRY[kind].split("(")[0][3:] + "(" not in clean:
                err(f"{name}: missing `{ENTRY[kind]}`")
            if re.search(r"@(group|binding|vertex|fragment)\b", clean):
                err(f"{name}: pack files declare no bindings or entry points")
            if re.search(r"\bhorizon_\w+", clean):
                err(f"{name}: names starting with horizon_ are reserved")
            for line in clean.splitlines():
                if "textureLoad(opaque_depth" in line and ").r" not in line:
                    err(f"{name}: textureLoad(opaque_depth, ...) must read `.r`")
                if "textureLoad(scene_depth" in line and ").r" not in line:
                    err(f"{name}: textureLoad(scene_depth, ...) must read `.r`")
            for open_ch, close_ch in ("{}", "()", "[]"):
                if clean.count(open_ch) != clean.count(close_ch):
                    err(f"{name}: unbalanced {open_ch}{close_ch}")

    if "sky" in stages:
        scan("sky", "sky", stages["sky"]["file"])
    if "vertex" in stages:
        scan("vertex", "vertex", stages["vertex"]["file"])
    if "material" in stages:
        scan("material", "material", stages["material"]["file"])
    if "weather" in stages:
        scan("weather", "weather", stages["weather"]["file"])
    for i, p in enumerate(post):
        if (PACK / p["file"]).is_file():
            scan("post", f"post #{i + 1}", p["file"])
    if "tonemap" in stages:
        scan("tonemap", "tonemap", stages["tonemap"]["file"])

    # duplicate top-level names inside the material + vertex module
    if "material" in stages:
        names: dict[str, str] = {}
        for name, body in composed("material"):
            for kind, ident in re.findall(r"(?m)^(fn|const|override|struct|var)\s+([A-Za-z_]\w*)", strip_comments(body)):
                if ident in names and names[ident] != name:
                    err(f"material module: {kind} {ident!r} defined in both {names[ident]} and {name}")
                names[ident] = name

    # overrides vs options
    all_wgsl = "\n".join(strip_comments(read(p)) for p in PACK.rglob("*.wgsl"))
    overrides = {name: ty for name, ty in re.findall(r"\boverride\s+(\w+)\s*:\s*(\w+)", all_wgsl)}
    for oid, ty in option_types.items():
        if oid not in overrides:
            err(f"option {oid!r}: no stage declares `override {oid}: {ty}`")
        elif overrides[oid] != ty:
            err(f"option {oid!r}: declared as {overrides[oid]}, option is {ty}")
    for name, ty in overrides.items():
        if name not in option_types and not re.search(
            rf"\boverride\s+{name}\s*:\s*{ty}\s*=", all_wgsl
        ):
            err(f"override {name!r}: no option of that name, so it needs a default")

    # textures actually declared before use
    for tex in texture_ids:
        if tex and not re.search(rf"\bvar {tex}: texture_2d<f32>", all_wgsl):
            pass  # the prelude declares it; nothing to check in pack files

    # ---- post chain ---------------------------------------------------------
    if len(post) > 12:
        err("manifest: more than 12 [[post]] passes")
    outputs = [p.get("output") for p in post if p.get("output")]
    if len(outputs) != len(set(outputs)):
        err("[[post]]: duplicate output target names")
    if len(outputs) > 4:
        err("[[post]]: more than 4 targets")
    for out in outputs:
        if out in RESERVED_TARGETS:
            err(f"[[post]]: output {out!r} collides with a prelude resource")
    for i, p in enumerate(post):
        scale = float(p.get("scale", 1.0))
        if scale not in POST_SCALES:
            err(f"[[post]] #{i + 1}: scale {scale} is not 1, 0.5 or 0.25")
        if i + 1 == len(post) and (p.get("output") or scale != 1.0):
            err(f"[[post]] #{i + 1}: the last pass draws the picture; no output or scale")
        if scale != 1.0 and not p.get("output"):
            err(f"[[post]] #{i + 1}: a pass below full size needs an output")
        if p.get("output") and scale == 1.0 and i + 1 != len(post):
            # legal, but the chain's `previous` keeps going, so the next pass sees the
            # pass before this one, not this one: almost always a mistake.
            err(f"[[post]] #{i + 1}: output at full size diverts the chain; drop `output`")

    # reflection option must exist and be a bool
    if "reflection" in m:
        opt = m["reflection"].get("option")
        if opt not in option_types:
            err(f"[reflection] option {opt!r} is not an [[options]] id")
        elif option_types.get(opt) != "bool":
            err(f"[reflection] option {opt!r} must be a bool")

    # sky-only keys
    for key in ("clouds", "sun", "stars"):
        for name, stage in stages.items():
            if name != "sky" and key in stage:
                err(f"[{name}] {key}: only a key of [sky]")

    if errors:
        print(f"FAIL: {len(errors)} problem(s)")
        for e in errors:
            print(f"  - {e}")
        return 1
    print(
        "OK: manifest, files, stages, options/overrides, inputs, post chain and "
        f"textures consistent ({len(options)} options, {len(post)} post passes, "
        f"{len(materials)} materials)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
