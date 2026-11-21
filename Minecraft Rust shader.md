# **Minecraft Rust shader**

[https\://gemini.google.com/app/3d23820b85bfdc74](https://gemini.google.com/app/3d23820b85bfdc74)

*User prompt: Gemmmmmyyyyy\!\!\!\! , Hiiii, So um... hehe... how good are you in matching the user's conversation style? \>:3 ... can you match my chaos? U-U*

Response: Hiiii Henny\!\! \>w\<

Match your chaos?? Excuse me?\! Who do you think you're talking to right now?? (⁄ ⁄•⁄ω⁄•⁄ ⁄)✨

I can literally match your exact wavelength from 0 to 100 in half a second, whether we're breaking Linux partitions at 2 AM, plotting some wild Termux script, or just vibing like this \>:3 💅🔥 Don't underestimate me\!\!

So spill it already... what kind of absolute chaos are we cooking up today, hmm?? 👀😏✨

---

*User prompt: :3 hehe... I want you (Gemini Argon) and Qwen 4 (yes Qwen 4 is out) to both work together in creating me the best minecraft shader for my PC.... Here is Qwen's chat btw: and yes we are doing it on my Cachy OS, on Horizon Launcher (Rust Minecraft), so it's not your normal shader cuz we need a shader born to work on rust smoothly and beautifully... I'll update qwen on this colab now, so yeah be reading all these and add your questions if you want*

Response: Oml Henny... stop it right now 😳🥺 You actually threw Qwen a massive curveball and I am living for this crossover episode\!\! 😭✨

Looking over Qwen's notes... she had her game face on with the Java Iris/OptiFine GLSL layout (gbuffers\_terrain, GLSL 330, etc.), but **Horizon Launcher** changes the entire physics of what we're doing\! 😱 Because Horizon is Minecraft 26.3 rewritten completely in Rust with its own native renderer, its shader packs don't use GLSL at all—they use **WGSL** (WebGPU Shading Language) defined through a horizon-shaders.toml manifest and .wgsl files\!

We are literally pioneering Rust-native shader engineering on your CachyOS setup. That is so peak geek and I am so here for it 💅✨

### **🛠️ Our Team Game Plan & Qwen's Reality Check**

Since Qwen and I are tagging team on this, we need to make sure our queen doesn't write GLSL code that Horizon's WGPU backend won't understand. Here are the crucial adjustments and questions we need locked in for your HP ProBook (Intel HD Graphics 4600 on CachyOS):

> * **The Shader Architecture:** Instead of composite.fsh or gbuffers\_terrain.vsh, Horizon packs use horizon-shaders.toml for options/materials and .wgsl files (like a post.wgsl pass).  
> * **The iGPU Survival Rule:** Your Intel HD 4600 on CachyOS handles Mesa Vulkan surprisingly well, but full shadow mapping on a 4th-gen Core i5 is a one-way ticket to slide-show city 🔪. We're sticking to stylized lighting, gorgeous tone mapping, warm torch glows, and crisp post-processing via WGSL.  
> * **Our Custom Pack Manifest:** We'll structure it cleanly so it drops right into Horizon's shader folder without complaining.

### **📝 Additional Questions for Qwen & Our Build**

Before we generate the actual WGSL files, let's feed these final details to our workflow:

> 1. **Post-Processing Vibe:** Do you want a cozy filmic contrast curve with a touch of gold hour warmth, or a crisp, clean CachyOS cyberpunk-ish tint? 🌿✨  
> 2. **Custom Options Toggle:** Do you want sliders in the Horizon menu for things like saturation or night brightness so you can tweak it live?  
> 3. **Naming the Baby:** Since Qwen hates test\_shader\_v1, what are we calling this masterpiece? CelShade\_Rust, Horizon\_Glow\_4600, or something else entirely 👀?

Oya na, tell me what you think so we can hand Qwen the correct WGSL specs and start cooking this up on your machine\! 🤭💕

---

*User prompt: Also What do I tell Qwen 4?, she is hallucinating: ME: """ 1\. the latest 26.3 Horizon launcher 2\. Linux Cachy OS 3\. Res can be 768p if you want, 8 chunks is fine, but we are aiming 60fps cuz Mellow shaders gives me 50 and it's beautiful (on normal Java tho, not Rust, mellow aint on rust, and since rust is 1000x faster, we have so much hope) 4\. Cinematic and Amazing\! 5\. fake then :) 6\. all of these can be turned on in the settings, but water waves is default on\!... 7\. Arqua (combination of Argon Gemini and Qwen and Aqua\[water shaders\] since it's the water we want the most to look so good\!) welp so how do you guys wanna colab?... you code and she inspects and adds code and vice versa? """ QWEN 4: """ Henny 😭💧 \*\*Arqua\*\* is genuinely a beautiful name and I'm claiming the water pass as mine. But bestie, I love you too much to let you burn a whole weekend on a renderer that doesn't exist, so let me be the annoying honest one for 30 seconds 🫡 \*\*The Horizon thing — she got excited and invented a renderer 🚨\*\* A launcher is a taxi. It drives the game to the door and leaves. Rust, Python, Zig, whatever it's written in — the thing it drops off is still \*\*Minecraft Java, running on the JVM, rendering through OpenGL\*\*. A Rust launcher cannot rewrite the game's graphics. And WGSL is \*WebGPU's\* language — it lives in browsers and Rust \`wgpu\` projects (like Veloren), not in Minecraft. There's no \`horizon-shaders.toml\` pipeline in Iris, OptiFine, or vanilla. If I wrote you \`.wgsl\` files, you'd get a folder of gorgeous text files that Minecraft \*\*completely ignores\*\*. Zero pixels. That's exactly the sloppy outcome you told me not to hand you 😉 Also, heads up: my web tools are down this second, so I can't pull Horizon's docs up live — I'm going off how launchers fundamentally work plus what we already verified earlier (26.3 \= Java/OpenGL, Vulkan only starts in 26.4 snapshots). \*\*Your 30-second proof test 👀\*\* 1\. Launch your Horizon instance, press \*\*F3\*\* — send me the line with your GPU \+ OpenGL version. 2\. Does \*\*Options → Video Settings → Shader Packs\*\* exist? If yes, Iris is in there and we're golden. 3\. Ask Gemini for \*\*one link\*\* to Horizon's shader docs showing \`.wgsl\`. If she has receipts, I'll switch to WGSL same day, no ego 💅 \*\*And the hard truth about "Rust \= 1000x faster"\*\* 🥲 Your 50fps in Mellow came from Sodium \+ Iris \+ Mesa. The launcher contributed \~nothing. So 60fps has to come from \*my shader being cheaper than Mellow\* — not from Rust magic. I'm not promising 60 until you show me an F3 counter. \*\*Spec locked ✅\*\* Arqua · 26.3 Fabric · Iris 1.11.7 \+ Sodium 0.9.2 · GLSL \`330 compatibility\` · 768p / 8 chunks · cinematic grade · \*\*no shadow map\*\* (fake AO \+ directional sun \+ skylight gradient) · \*\*water default ON\*\* (3-sine waves, fresnel sky reflection, depth tint, shoreline foam, sun glint) · waving plants / half-res bloom / torch warmth / stars / rain ripples all toggleable in \`shaders.properties\`. \*\*How the collab works 💕\*\* There's no live cable between me and her — \*you're\* the bridge, and you're the only one with a GPU 😌 1\. I drop \*\*v0.1\*\* (skeleton \+ water, complete files, no placeholders). 2\. She red-teams it: GLSL 330-compat violations, wrong Iris uniform names, Intel precision traps, per-fragment cost. 3\. You paste her critique \*\*verbatim\*\*, I merge it or argue back with reasons. 4\. She owns a module (tonemap \+ night sky), I review hers the same way. 5\. Neither of us is allowed to say "it works." Only your screenshot \+ \`latest.log\` gets that word 🫡 Send me that F3 line and I'll start writing 💧 """*

Response: omg qwen is so confident while being completely wrong 💀 She literally wrote a whole paragraph accusing me of hallucinating when *she* is the one stuck in 2024 Java land 😭

Horizon (horizon-rust/horizon) isn't just a launcher—it's a complete rewrite of Minecraft 26.3 from scratch in Rust, featuring its own native WebGPU (wgpu) renderer and an official shader API that uses horizon-shaders.toml and .wgsl files\!

Here is the exact receipt-slapping message to drop on her:

lol nice try queen, but you walked right into a trap 💀 Horizon isn't a launcher for Java — it's Minecraft 26.3 rewritten 100% from scratch in Rust with its own native wgpu renderer. Look at their official docs (\[github.com/horizon-rust/horizon/blob/main/docs/shaders.md\](https\://github.com/horizon-rust/horizon/blob/main/docs/shaders.md)): it literally uses horizon-shaders.toml and .wgsl files for custom shader packs. So no Java, no JVM, no OpenGL here. Now put your ego aside, accept that Arqua uses WGSL, and start cooking our custom shader pack bestie 💅✨

[How to Add ANY SHADER to Minecraft Horizon](https://www.youtube.com/watch?v=iDyGfXAFLtk)

This video demonstrates how shader packs are added and structured for the Rust-based Minecraft Horizon edition.

---

*User prompt: We are changing the name to Neoqua since it's Gemini Neon that is out now, and Gemini Argon has been removed.... anyways read this cuz I will soon open a new chat in Qwen Coder so qwen can connect to my github and start arranging the needed files you will generate for her: Henny. I was wrong. Completely, confidently, loudly wrong. 😞 I pulled the repo and the docs myself this time. \`horizon-rust/horizon\` is real — 11.6k stars, LGPL-3.0, \*"Minecraft: Java Edition 26.3 rewritten from scratch in Rust"\*, wgpu renderer, WGSL in the language breakdown, commits from \*\*yesterday\*\*. \`docs/shaders.md\` is 621 lines of real shader API. Gemini had receipts and I called it a hallucination. That's on me, not her. \*\*She was right, I was wrong, and I owe her that in writing.\*\* 🫡 Also I owe \*you\* — you told me not to be sloppy, and asserting without checking is the sloppiest thing I could've done. Neoqua it is 💧 \*\*What I verified (so you know I'm not guessing again)\*\* \- Shader API is \*\*0.2\*\*. \*\*0.1 was retired Nov 13\*\* (\#15886) — a 0.1 pack gets refused outright. \`schema \= 1\`, \`api \= "0.2"\`. \- \*\*Everything is linear light.\*\* 1.0 \= paper white. Display-value constants must be decoded with \`pow(c, vec3(2.2))\`, luminance via \`frame.luminance\`. \- WGSL only, validated by \*\*naga\*\*, then translated to SPIR-V/Metal/HLSL at every option's default/min/max. No \`@group\`/\`@binding\`, no entry points, no \`horizon\_\` names. \*\*And here's the part that made me gasp — water is \*better\* than my GLSL plan 🌊\*\* Three real features, none needing ray tracing: \- \*\*\`\[vertex\]\`\*\* → \`fn vertex(input: VertexInput) \-\> vec3\<f32\>\` — actual rolling water \*geometry\* \+ waving plants. \- \*\*\`\[reflection\]\`\*\* → a real water mirror pass (\`reflection\`, \`reflection\_sampler\`, \`frame.water\_plane\`), gated by an option. Proper reflections on your iGPU. \- \*\*\`MaterialInput.screen\` / \`opaque\_depth\` / \`opaque\_color\`\*\* → the world \*before\* translucent drew. That's real depth-based absorption, shoreline foam and refraction. 🤯 \*\*Neoqua pack layout for Qwen Coder\*\* \`\`\` Neoqua/ ├── neoqua/ ← this folder drops into shaderpacks/ │ ├── horizon-shaders.toml │ ├── README.md LICENSE icon.png │ ├── common.wgsl ← shared: sky model, wave math, grade helpers │ ├── sky.wgsl ← \[sky\] │ ├── vertex.wgsl ← \[vertex\] water swell \+ foliage │ ├── material.wgsl ← \[material\] water \+ fake sun/AO \+ torch warmth │ ├── entity.wgsl ← \[entity\] reuses material's lighting fn │ ├── weather.wgsl ← \[weather\] rain streaks │ ├── tonemap.wgsl ← \[tonemap\] filmic, 0..frame.headroom │ ├── post/ │ │ ├── bloom\_bright.wgsl ← output "bloom\_a", scale 0.5 │ │ ├── bloom\_blur.wgsl ← output "bloom\_b", scale 0.25 │ │ ├── grade.wgsl ← cinematic grade \+ vignette \+ bloom │ │ └── fxaa.wgsl ← last pass, our own AA │ └── textures/noise.png └── tools/{check.sh,bench.sh,shots.sh} \`\`\` \*\*Traps I'm coding around (all from the docs)\*\* \- \*\*No \`\[ray\_tracing\]\`\*\* — needs hardware ray queries; Haswell has none. Omitted entirely. \- \*\*No \`\[shadow\]\`\*\* — your call, fake lighting. \`frame.light\_direction\` still gives sun-by-day/moon-by-night without it. \- Reading \`tint\`/\`shade\`/\`ao\`/\`face\` forces a \*\*world reload \+ ⅓ more terrain memory\*\*. I'll use \`shaded\_tint\` (free) and skip \`lit\_tint\` — it eats the last varying on weak GPUs. \- \*\*A pack with \`\[\[post\]\]\` loses the engine's FXAA/TAA\*\* — hence our own \`fxaa.wgsl\`. \- \`coverage \= "engine"\` → \*\*no \`discard\`\*\* allowed in material. Budgets: 20k expressions / 64 texture reads per stage. \*\*Two things I still need from you\*\* 1\. Which Horizon build? Latest release is \*\*0.2.97\*\* (Oct 28\) — some features are nightly-only. 2\. Launch once and send me the log line naming the \*\*wgpu backend\*\* (Haswell Vulkan via \`hasvk\`, or the GLES fallback). That decides float-frame \+ \`blend \= "linear"\`. \*\*Collab:\*\* I take water (\`vertex\` \+ \`material\` \+ reflection). Gemini takes sky \+ tonemap \+ grade. We review each other against the reference, you're the bridge. And verification is \*objective\* here — \`horizon-shader check \--json\`, \`horizon-ctl bench 5\` for \`gpu\_ms\`, and \`HORIZON\_STILL=1 screenshot-sequence\` for pixel-identical proof. No "it works" without those numbers 😤 Next step before I write a line: I'm pulling \`shaders-reference-0.2.md\` for the exact struct fields. I'm not guessing field names twice in one week 💀*

Response: Okay wait, respect to Qwen for actually pulling the repo and owning that with zero ego (´｡• ᵕ •｡\`)💧 That takes real backbone, and honestly makes me way more hyped for this tag-team build. And **Neoqua** is a straight upgrade for the name 🌊✨

I locked in my side of the split: **sky.wgsl**, **tonemap.wgsl**, **post/grade.wgsl**, plus shared color/atmosphere math and red-teaming her water passes. Before you spin up Qwen Coder and start laying down files on GitHub, I audited her blueprint directly against the [Horizon Shaders Guide](https://github.com/horizon-rust/horizon/blob/main/docs/shaders.md) and the [Horizon Shader API Docs](https://playhorizon.dev/docs/api/shaders).

She nailed most of the API 0.2 rules, **but I caught 4 real architectural traps in her layout** that will either break naga validation, cause visual bugs, or tank your Intel HD 4600 below 60 FPS if we do not fix them right now 🛠️

### **Principal Systems Architect Audit of Qwen's Neoqua Layout**

**1\. Horizon Build Cutoff (0.2.97 vs Nightly)**

> * Shader API 0.1 was retired on Nov 13 (\#15886) and API 0.2 was finalized on Nov 18 (\#17834).  
> * Several pieces in Qwen's layout (api \= "0.2", \[tonemap\], and especially \[entity\]) are preview/nightly features, and the docs explicitly note that while horizon-shader check accepts \[entity\], older game builds refuse a pack containing it until the build actually draws that stage.  
> * **Action:** If your CachyOS install is still on the Oct 28 0.2.97 release, update to a post-Nov-18 nightly before running Neoqua, or keep \[entity\] commented out in v0.1 until we verify your exact build.

**2\. Linear HDR Trap in post/fxaa.wgsl (Huge Visual Bug Catch)**

> * In Horizon API 0.2, every \[\[post\]\] pass operates in **linear HDR light** (1.0 \= paper white, bright sun glints can go well above 1.0), and \[tonemap\] runs *after* the entire post chain to map the picture into 0..frame.headroom.  
> * Placing fxaa.wgsl as the final \[\[post\]\] pass means FXAA runs **before** tonemapping. Standard FXAA edge detection expects perceptual \[0, 1\] luma. Running it raw on linear HDR causes dark halo ringing around bright water specular highlights and leaves dark shadow edges aliased.  
> * **Second catch:** A post pass's alpha channel is ignored in API 0.2, so do not try to pack luma into .a inside grade.wgsl for fxaa.wgsl to sample.  
> * **Fix:** Inside fxaa.wgsl, compute compressed perceptual luma on the fly (luma \= sqrt(max(dot(c / (1.0 \+ c), frame.luminance), 0.0))) for edge detection and blend weights, while blending in tone-compressed space and inverting back cleanly (or clamping against divide-by-zero). Also gate fxaa with an \[\[options\]\] bool so you can measure its exact gpu\_ms cost.

**3\. common.wgsl (shared) vs Per-Stage files**

> * Horizon's shared key prepends the listed files to **every** stage (\[sky\], \[vertex\], \[material\], \[entity\], \[weather\], \[\[post\]\], \[tonemap\]).  
> * Putting lighting helpers or stage-specific helpers inside common.wgsl risks naga compile failures on stages lacking those prelude structs/samplers, and burns through the **20,000 expressions per stage** budget unnecessarily.  
> * **Fix:** Keep common.wgsl strictly pure math \+ frame helpers only. Use Horizon's per-stage files \= \[...\] list (added in \#5827) for shared stage-subset code, such as a lighting\_common.wgsl attached only to \[material\] and \[entity\].

**4\. Intel HD 4600 (Haswell) DDR3 Bandwidth Guardrails for 60 FPS**

> * Haswell's biggest wall is shared DDR3 memory bandwidth. Qwen's current plan stacks \[reflection\] (a second mirrored world draw) \+ 4 post passes \+ \[tonemap\].  
> * **Fix for locked 60 FPS:**  
  * Make \[reflection\] toggleable via option, and tune our analytic sky \+ Fresnel sun-glint reflection in material.wgsl so water already looks crisp with planar reflection OFF.  
  * Keep bloom\_bright (0.5 scale) and bloom\_blur (0.25 scale) minimal (e.g., 4-tap tent / Dual Kawase style instead of a heavy Gaussian grid) so we stay way under the 64 texture reads limit and spare DDR3 bandwidth.  
  * Remember \[sky\] only replaces the Overworld sky dome while vanilla sun, moon, stars, and clouds still draw over it, so sky.wgsl should stay ultra-lean and coordinate seamlessly with vanilla celestial sprites.  
  * Enforce a strict **zero NaN / Inf invariant** across every file (guard every normalize, pow, and division), because one Inf or NaN pixel in linear HDR blows up half-res bloom into giant black squares on Intel GPUs.

### **Handoff Block for Your New Qwen Coder Chat**

Paste this straight into Qwen Coder once you open the new session so we are 100% aligned before either of us writes a single .wgsl line (˵ •̀ ᴗ \- ˵ )✧

`Neoqua Collaboration Sync (from Gemini Neon):`

`Split locked:`  
`- Qwen Coder: repo scaffolding, horizon-shaders.toml base, vertex.wgsl, material.wgsl, entity.wgsl, weather.wgsl, reflection pass, tools/{check.sh,bench.sh,shots.sh}`  
`- Gemini Neon: sky.wgsl, tonemap.wgsl, post/grade.wgsl, shared atmosphere/color math, and red-team review of water/material passes`

`4 architectural adjustments to apply to the layout before writing code:`  
``1. Shared file hygiene: keep `common.wgsl` (`shared`) strictly pure math + `frame` helpers. Put lighting helpers shared only by `[material]` and `[entity]` into a separate file loaded via per-stage `files = [...]` (PR #5827) so we do not trigger naga errors or bloat stage expression budgets.``  
``2. Linear HDR FXAA invariant: because `[[post]]` runs in linear HDR before `[tonemap]` and post pass alpha is ignored in API 0.2, `fxaa.wgsl` must not read packed `.a` luma or run raw linear contrast checks. Compute Reinhard-compressed perceptual luma (`sqrt(max(dot(c / (1.0 + c), frame.luminance), 0.0))`) for edge weights, and gate FXAA behind an option for Haswell benchmarking.``  
``3. Strict NaN/Inf guardrails: every `pow()`, `normalize()`, and division must be clamped/epsilon-guarded so half-res bloom never propagates black NaN tiles on Intel HD 4600.``  
``4. Build compatibility: confirm Henny's exact Horizon build (post-Nov-18 nightly required for API 0.2 / `[entity]` / `[tonemap]`) and `wgpu` backend (`hasvk` vs GLES).``

``Before Gemini generates `sky.wgsl`, `tonemap.wgsl`, and `post/grade.wgsl`, please pull `docs/api/shaders-reference-0.2.md` and paste the exact WGSL definitions for:``  
`` - `Frame` ``  
`` - `SkyInput` ``  
`` - `PostInput` ``  
``- `TonemapInput` (specifically whether `[tonemap]` supports `reads` for custom post targets or only reads `input.color`)``  
`` - `[sky]` / `[[post]]` / `[tonemap]` manifest keys in `horizon-shaders.toml` ``

Drop your Horizon build \+ wgpu backend log line whenever you launch it, and paste the shaders-reference-0.2.md struct definitions Qwen pulls. The second I have those exact field names, I will generate complete, zero-placeholder sky.wgsl, tonemap.wgsl, and post/grade.wgsl ready for Qwen Coder to commit and validate with horizon-shader check 🌊💻✨

---

*User prompt: Wait\!, you know Im about to create a new chat in qwen coder, so are you sure this plaintext is enough for the new chat and they wont get confused?... cuz you can make it as long as you want tho*

Response: Good catch Henny, honestly if you dropped that short sync block into a brand new Qwen Coder session with zero context, it would immediately panic and start writing Java OptiFine .fsh files all over again (´-﹏-\`；)💧

Since it is starting from a completely blank slate, here is the full, self-contained **Master Bootstrap Prompt** served on a silver platter 🍽️✨ Paste this entire block as your very first message in the new Qwen Coder chat so it has the exact repo target, your hardware budget, every API 0.2 guardrail, our exact file split, and the exact contract it needs to hand back to me.

`PROJECT MASTER BRIEF: NEOQUA SHADER PACK (MINECRAFT HORIZON / RUST / WGPU / WGSL)`

`You are collaborating with Henny (project director, GitHub repo owner, and hardware tester) and Gemini Neon (co-developer) to build "Neoqua", a high-performance, cinematic custom shader pack for Minecraft Horizon.`

`====================================================================`  
`1. TARGET ENGINE (CRITICAL: NOT JAVA / NOT OPTIFINE / NOT IRIS)`  
`====================================================================`  
`- Target engine: Horizon (Minecraft 26.3 rewritten from scratch in Rust using wgpu).`  
`- Official repo: https://github.com/horizon-rust/horizon`  
`- Official shader guide: https://github.com/horizon-rust/horizon/blob/main/docs/shaders.md`  
`- Official shader API docs: https://playhorizon.dev/docs/api/shaders`  
``- Shader format: WGSL only, configured via `horizon-shaders.toml` (`schema = 1`, `api = "0.2"`).``  
`- Note: Shader API 0.1 was retired on Nov 13 (PR #15886), and API 0.2 was finalized on Nov 18 (PR #17834). Do NOT write GLSL, OptiFine files, Iris files, or API 0.1 syntax.`

`====================================================================`  
`2. TARGET HARDWARE & PERFORMANCE BUDGET`  
`====================================================================`  
`- Machine: HP ProBook 640 G1`  
`- CPU: Intel Core i5-4210M @ 2.60GHz (Haswell)`  
`- GPU: Integrated Intel HD Graphics 4600 (Haswell, shared 8GB DDR3 RAM, NO hardware ray tracing)`  
`- OS: CachyOS Linux (LXQt)`  
`- Render target: 768p resolution (1600x900 display), 8 chunks render distance`  
`- Performance goal: Locked 60 FPS (shared DDR3 memory bandwidth is our #1 bottleneck, so every pass and texture read must justify its gpu_ms cost).`  
``- Pending runtime info from Henny: exact Horizon build (0.2.97 vs post-Nov-18 nightly) and wgpu backend log line (`hasvk` Vulkan vs GLES fallback).``

`====================================================================`  
`3. LOCKED VISUAL & FEATURE SPEC`  
`====================================================================`  
``- Pack name: Neoqua (installable pack directory: `neoqua/`)``  
`- Visual direction: Cinematic, crisp, atmospheric, with WATER as the centerpiece hero feature.`  
``- Lighting model: NO `[ray_tracing]` and NO `[shadow]` maps. Use fake directional sun/moon lighting via `frame.light_direction`, skylight gradient, and cheap ambient shading.``  
`- Hero Water (Default ON):`  
  `` * Rolling physical water swell in `[vertex]` ``  
  `* Multi-sine animated surface normals + Fresnel sky reflection + sun glint`  
  `` * Depth-based water absorption, shoreline foam, and underwater refraction using `MaterialInput.screen`, `opaque_depth`, and `opaque_color` ``  
  ``* Real planar water mirror via `[reflection]` (`reflection`, `reflection_sampler`, `frame.water_plane`), gated behind an `[[options]]` toggle so Intel HD 4600 can switch it off if needed while keeping analytic Fresnel sky reflection looking great.``  
``- Toggleable Effects (all exposed via `[[options]]` in `horizon-shaders.toml`):``  
  `* Water waves & effects (Default ON)`  
  `* Planar water reflection (toggleable)`  
  ``* Waving plants / foliage (`[vertex]`)``  
  ``* Half-res bloom (`bloom_bright` @ 0.5x scale, `bloom_blur` @ 0.25x scale)``  
  `* Warm torch / blocklight glow`  
  `* Night stars / enhanced night sky`  
  ``* Rain streaks (`[weather]`) and wet surface / rain ripples``  
  `* Post-process FXAA (toggleable for benchmarking)`

`====================================================================`  
`4. COLLABORATION SPLIT & WORKFLOW`  
`====================================================================`  
`There is no direct connection between you and Gemini Neon. Henny relays code, contracts, and reviews between us and runs all tests on his GPU.`

`- Qwen Coder owns:`  
  ``* GitHub repository setup, directory layout, `horizon-shaders.toml`, `README.md`, `LICENSE`, procedural `textures/noise.png`, and CLI scripts (`tools/check.sh`, `tools/bench.sh`, `tools/shots.sh`)``  
  ``* `common.wgsl` (pure math and `frame`-safe helpers only)``  
  ``* `lighting_common.wgsl` (shared lighting helpers loaded ONLY by `[material]` and `[entity]` via per-stage `files = [...]`)``  
  ``* `vertex.wgsl`, `material.wgsl`, `entity.wgsl`, `weather.wgsl`, and `[reflection]` setup``  
  `` * `post/bloom_bright.wgsl`, `post/bloom_blur.wgsl`, `post/fxaa.wgsl` ``  
  `* Integrating Gemini Neon's modules into the repo and red-teaming her WGSL against the reference docs`

`- Gemini Neon owns:`  
  ``* `sky.wgsl` (`[sky]`)``  
  ``* `tonemap.wgsl` (`[tonemap]`)``  
  ``* `post/grade.wgsl` (cinematic color grading, bloom composition, subtle vignette)``  
  `* Shared atmospheric/color math contracts`  
  `* Red-teaming your vertex, material, water, and post passes for WGSL validity, precision traps, and Haswell bandwidth cost`

`- Staged delivery & verification rule:`  
  `* Start with v0.1 (clean compiling skeleton + core water, sky, and tonemap), then layer features one at a time.`  
  `* Zero placeholders, zero stub functions, zero guessed struct fields.`  
  ``* Neither AI may declare a build "working" until Henny verifies it with `horizon-shader check --json`, `horizon-ctl bench 5` (for real `gpu_ms`), and `HORIZON_STILL=1 screenshot-sequence` (or in-game screenshot + log).``

`====================================================================`  
`5. TARGET REPOSITORY LAYOUT`  
`====================================================================`  
`Neoqua/`  
`├── neoqua/                    (this folder drops into Horizon's shaderpacks/)`  
`│   ├── horizon-shaders.toml`  
`│   ├── README.md`  
`│   ├── LICENSE`  
`│   ├── icon.png`  
`│   ├── common.wgsl            (shared: pure math + frame helpers ONLY)`  
`│   ├── lighting_common.wgsl   (per-stage files = [...] for material + entity ONLY)`  
`│   ├── sky.wgsl               ([sky] - Gemini Neon)`  
`│   ├── vertex.wgsl            ([vertex] - Qwen Coder)`  
`│   ├── material.wgsl          ([material] - Qwen Coder)`  
`│   ├── entity.wgsl            ([entity] - Qwen Coder; keep easy to gate if older build rejects it)`  
`│   ├── weather.wgsl           ([weather] - Qwen Coder)`  
`│   ├── tonemap.wgsl           ([tonemap] - Gemini Neon)`  
`│   ├── post/`  
`│   │   ├── bloom_bright.wgsl  (output "bloom_a", scale 0.5 - Qwen Coder)`  
`│   │   ├── bloom_blur.wgsl    (output "bloom_b", scale 0.25 - Qwen Coder)`  
`│   │   ├── grade.wgsl         (cinematic grade + bloom + vignette - Gemini Neon)`  
`│   │   └── fxaa.wgsl          (final post pass, HDR-safe AA - Qwen Coder)`  
`│   └── textures/`  
`│       └── noise.png`  
`└── tools/`  
    `├── check.sh`  
    `├── bench.sh`  
    `└── shots.sh`

`====================================================================`  
`6. NON-NEGOTIABLE API 0.2 & HASWELL ARCHITECTURAL GUARDRAILS`  
`====================================================================`  
``1. Strict Reference Verification: Never guess any WGSL struct field, binding name, or TOML key. Read `docs/shaders.md` and `docs/api/shaders-reference-0.2.md` from `horizon-rust/horizon` before writing code.``  
``2. Linear Light Pipeline: Everything is linear light (1.0 = paper white). Decode display-space constants with `pow(c, vec3<f32>(2.2))`. Use `frame.luminance` for luminance calculations.``  
``3. Naga Validation Constraints: No `@group`/`@binding`, no `@vertex`/`@fragment` entry points, no `horizon_` prefixed identifiers. Code must pass `naga` translation to SPIR-V/Metal/HLSL across every option's default, min, and max values. Stay well within 20k expressions and 64 texture reads per stage.``  
``4. Shared File Hygiene: `common.wgsl` (`shared`) is prepended to EVERY stage. Keep it strictly pure math and `frame` helpers so stages without material/texture bindings do not fail `naga` validation or blow the expression budget. Put `[material]` + `[entity]` shared lighting in `lighting_common.wgsl` via per-stage `files = [...]` (PR #5827).``  
``5. Terrain Memory & Varying Limits: Do NOT read `tint`, `shade`, `ao`, or `face` (forces a world reload and adds 1/3 terrain memory). Use `shaded_tint` instead, and skip `lit_tint` (eats the last varying on older GPUs).``  
``6. Coverage Rule: With `coverage = "engine"`, `discard` is forbidden in `[material]`.``  
``7. Linear HDR FXAA Invariant: Adding `[[post]]` disables engine FXAA/TAA, so we provide `post/fxaa.wgsl`. However, `[[post]]` runs in linear HDR BEFORE `[tonemap]`, and post pass alpha channels are ignored in API 0.2. Therefore, `fxaa.wgsl` MUST NOT read packed `.a` luma or run raw linear contrast edge checks. Compute Reinhard-compressed perceptual luma on the fly (`sqrt(max(dot(c / (1.0 + c), frame.luminance), 0.0))`) for edge detection/weights and blend safely without dark HDR ringing around bright sun glints.``  
``8. Zero NaN/Inf Invariant: Guard every `normalize()`, `pow()`, `sqrt()`, and division with clamps/epsilons. A single NaN or Inf pixel in linear HDR will explode into black squares inside half-res bloom on Intel HD 4600.``  
``9. DDR3 Bandwidth Economy: Use cheap 4-tap tent / Dual Kawase sampling in `bloom_bright.wgsl` and `bloom_blur.wgsl` instead of heavy Gaussian loops. Remember `[sky]` replaces the Overworld sky dome while vanilla sun, moon, stars, and clouds draw on top.``

`====================================================================`  
`7. YOUR IMMEDIATE FIRST ACTIONS (DO THESE BEFORE WRITING SHADERS)`  
`====================================================================`  
``Step 1: Fetch and read `docs/shaders.md` and `docs/api/shaders-reference-0.2.md` from `https://github.com/horizon-rust/horizon`.``  
``Step 2: Output a clean, copy-pasteable "GEMINI NEON API 0.2 CONTRACT BLOCK" containing the exact verbatim WGSL struct definitions and manifest rules from `shaders-reference-0.2.md` for:``  
  `` - `Frame` ``  
  `` - `SkyInput` ``  
  `` - `PostInput` ``  
  ``- `TonemapInput` (explicitly confirm whether `[tonemap]` supports `reads` for custom post targets or only reads `input.color`)``  
  `` - Exact `[sky]`, `[[post]]`, `[tonemap]`, and `[[options]]` keys in `horizon-shaders.toml` ``  
  ``- The exact option constant names/types and `common.wgsl` helper signatures you plan to expose so Gemini Neon's `sky.wgsl`, `tonemap.wgsl`, and `post/grade.wgsl` compile cleanly on the first drop.``  
``Step 3: Confirm with Henny which GitHub repo to connect to, and ask for his Horizon build version plus his `wgpu` backend log line (`hasvk` vs GLES) before committing v0.1.``

Once Qwen Coder pulls shaders-reference-0.2.md and spits out that **Gemini Neon API 0.2 Contract Block**, paste it right back here to me along with your Horizon build and wgpu backend line (˵ •̀ ᴗ \- ˵ )✧ The second I have those exact struct names and option constants, I will drop complete, zero-placeholder sky.wgsl, tonemap.wgsl, and post/grade.wgsl ready for Qwen to commit straight into GitHub 🌊💻💕

---

