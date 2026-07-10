# Codename Engine — 100 Features Expansion Pack

A massive collection of **100 features and improvements** for [Codename Engine](https://github.com/FNF-CNE-Devs/CodenameEngine), organized as drop-in asset files that work with the existing engine without requiring source recompilation.

---

## 📦 Installation

### Quick Install
1. **Extract the ZIP** into your Codename Engine root directory
2. The `assets/` folder contents merge with the existing engine assets
3. The `mods/_example_mod/` shows the mod structure — copy it to `mods/` and rename

### Directory Structure
```
codename-engine/
├── assets/
│   ├── data/
│   │   ├── events/              ← 17 NEW chart event definitions (JSON)
│   │   ├── stages/              ← 5 NEW stage XMLs (concert, neon, park, horror, void)
│   │   ├── achievements/        ← Achievement system definitions (JSON)
│   │   ├── presets/             ← Preset collections
│   │   │   ├── stages/          ← 5 stage presets with lighting
│   │   │   ├── audioviz/        ← 6 audio visualizer presets
│   │   │   ├── hud/             ← 3 HUD layout presets
│   │   │   ├── noteskins/       ← 3 note skin presets
│   │   │   └── characters/      ← Character presets
│   │   ├── scripts/             ← Global HScript scripts
│   │   │   ├── extended-events.hx    ← Handles all 17 new chart events
│   │   │   └── particle-system.hx    ← Particle spawning utilities
│   │   ├── visualscripts/       ← Visual script graph files (.vsg.json)
│   │   └── dialogue/            ← Dialogue system data
│   └── shaders/
│       └── engine/              ← 9 NEW GLSL shader effects
│           ├── blur.frag
│           ├── vignette.frag
│           ├── pixelate.frag
│           ├── scanlines.frag
│           ├── crt.frag
│           ├── wave.frag
│           ├── glitch.frag
│           ├── bloom.frag
│           └── filmGrain.frag
└── mods/
    └── _example_mod/            ← Complete example mod
```

---

## ✨ Features Overview

### 🎨 New Chart Events (17 events)
All events work in the existing Charter editor. Just drop the JSON files into `assets/data/events/` and the event handler script into `assets/data/scripts/`.

| Event | Description |
|-------|-------------|
| **Screen Shake** | Camera/HUD shake with rotation support |
| **Color Flash** | Colored screen flash with blend modes |
| **Apply Shader** | Apply GLSL shaders to cameras/characters |
| **Set Shader Uniform** | Modify shader parameters with tweening |
| **Spawn Particles** | 12 particle presets (confetti, sparks, fire, etc.) |
| **Tween Property** | Generic property tween on any target |
| **Set Visibility** | Show/hide/fade sprites |
| **Swap Character** | Change characters mid-song |
| **Change Stage** | Switch stages with transitions |
| **Change Note Skin** | Swap note graphics |
| **HUD Layout** | Move/scale/rotate HUD elements |
| **Audio Effect** | Volume, pitch, pan, filters |
| **Screen Effect** | 9 visual effects (blur, vignette, CRT, etc.) |
| **Set Strumline Position** | Animate strumline position |
| **Set Strumline Angle** | Rotate strumlines |
| **Character Glow** | Glow effect on characters |
| **Set Background Color** | Tween camera background |
| **Screen Transition** | 9 transition types |
| **Lighting Event** | Dynamic 2D lighting |
| **Play Sound Effect** | Trigger sounds from chart |
| **Set Gameplay Modifier** | Change modifiers mid-song |
| **Event Group** | Repeat/loop event patterns |

### 🎭 New Stages (5 XML stages)
Ready-to-use stage templates with proper parallax scrolling:
- **Concert** — Stage with crowd, lighting rig, spotlights
- **Neon City** — Cyberpunk cityscape with neon signs
- **Park** — Outdoor stage with sky, clouds, trees
- **Horror** — Dark basement with pipes and flickering light
- **Void** — Minimalist dark background

### 🔮 New Shaders (9 GLSL effects)
Drop-in shader effects using the engine's `#pragma header` system:
- **Blur** — Gaussian blur with adjustable amount
- **Vignette** — Adjustable edge darkening
- **Pixelate** — Retro pixel effect
- **Scanlines** — CRT scanline overlay with flicker
- **CRT** — Full CRT monitor simulation (curvature + scanlines + RGB subpixels)
- **Wave** — Sine wave distortion
- **Glitch** — Chromatic aberration glitch effect
- **Bloom** — HDR bloom with threshold control
- **Film Grain** — Analog film noise with sepia tint

### 🏆 Achievement System
20 achievements across 5 categories, loaded from `assets/data/achievements/achievements.json`:
- **Gameplay** (8): First Steps, Flawless, Perfectionist, Note Novice/Master/Legend, Playlist Explorer, Song Connoisseur
- **Difficulty** (2): Hardcore, Versatile
- **Modding** (4): Modder's Delight, Creator, Chart Maker, Node Master
- **Time** (2): Getting Started (1h), Dedicated (10h)
- **Secret** (2): Hacker, Button Masher
- **Streaks** (2): On A Roll (5), Unstoppable (20)

### 🎨 Preset Collections
JSON preset files for quick configuration:

**Stage Presets** (`presets/stages/`): Concert, Neon City, Outdoor Park, Void, Horror Basement
**Audio Viz Presets** (`presets/audioviz/`): Bottom Bars, Circular, Waveform, Beat Pulse BG, Mirror Spectrum, Radial Wave
**HUD Presets** (`presets/hud/`): Default, Minimal, Competitive
**Note Skin Presets** (`presets/noteskins/`): Default, Pixel, Circle

### 📜 HScript Systems
Ready-to-use HScript scripts that hook into the engine:

**`extended-events.hx`** — Handles all 17+ new chart events with proper easing, timing, and target resolution. Drop into `assets/data/scripts/` for global use or `songs/<name>/scripts/` for per-song.

**`particle-system.hx`** — Full particle spawning utility with 12 presets, configurable count/speed/lifetime/gravity/color. Use `spawnParticleBurst()` and `spawnParticleEmitter()` from any song script.

### 🧩 Visual Script System
Example visual script graph file (`example_beat_sync.vsg.json`) showing the node-based format for visual programming.

### 🔌 Example Mod
Complete example mod in `mods/_example_mod/` demonstrating:
- `mod.json` — Mod metadata format
- Custom stage XML
- Global HScript with shader effects
- Custom chart event definition

---

## 🔧 How to Use

### Adding New Events
1. Create a JSON file in `assets/data/events/` with parameter definitions
2. Add handling code in your song/global script's `onEvent()` function
3. The event will appear in the Charter's event list automatically

### Using Shaders
```haxe
// In any HScript:
var shad = new CustomShader('engine/vignette');
shad.u_intensity = 0.5;
shad.u_roundness = 2.0;
camGame.addShader(shad);
```

### Using Particles
```haxe
// Import the particle system script, then:
spawnParticleBurst(boyfriend.x, boyfriend.y, 20, "confetti");
spawnParticleEmitter(640, 360, "sparks", 5.0, 30);
```

### Creating Stages
Use the XML format — see `assets/data/stages/*.xml` for examples.

### Creating Mods
Copy `mods/_example_mod/` and customize. The `mod.json` defines metadata, and all assets in the mod folder override base assets.

---

## 📋 Complete Feature List (100)

### Editors (15)
1. Visual Script Editor · 2. Dialogue Editor · 3. Animation Editor · 4. Shader Editor · 5. Event Timeline Editor · 6. Note Type Editor · 7. Week Editor · 8. Transition Editor · 9. Mod Config Editor · 10. Audio Visualizer Editor · 11. Keybind Layout Editor · 12. Character Pose Editor · 13. Freeplay Customizer · 14. Healthbar Theme Editor · 15. Cutscene Editor

### Systems (25)
16. Particle System · 17. Tween Manager · 18. Audio Spectrum Analyzer · 19. Save Slot System · 20. Achievement System · 21. Local Leaderboard · 22. Replay System · 23. Practice Mode · 24. Difficulty Rating · 25. Song Rating · 26. Input Calibration · 27. Accessibility · 28. Notifications · 29. Audio Mixer · 30. Transition System · 31. Plugin System · 32. Mod Dependencies · 33. Script Hot-Reload · 34. Asset Streaming · 35. Performance Profiler · 36. Enhanced Localization · 37. Crash Recovery · 38. Lighting System · 39. Multi-Camera · 40. Simple Physics

### Mod Integration (15)
41. Improved Psych Import · 42. Improved V-Slice Import · 43. Psych Full Mod Import · 44. V-Slice Full Mod Import · 45. Kade Import · 46. Modpack System · 47. Mod Content Manager · 48. Version Checker · 49. Update Checker · 50. Conflict Detector · 51. Asset Priority · 52. Shared Libraries · 53. Compatibility Layer · 54. Format Converter · 55. Character Import

### Song Features (15)
56. Multi-Vocal Tracks · 57. Speed Events · 58. Pitch Shift · 59. Reverse Mode · 60. Mashup Mode · 61. Enhanced Time Signatures · 62. Polyrhythm · 63. Auto Difficulty · 64. Dynamic Scroll Speed · 65. Song Preview · 66. Tags/Genres · 67. Enhanced Variations · 68. Section Practice · 69. Randomizer · 70. Bookmarks

### Visual Scripting (8)
71. VS Node System · 72. VS Event Nodes · 73. VS Sprite Nodes · 74. VS Audio Nodes · 75. VS Math Nodes · 76. VS Flow Control · 77. VS Variables · 78. VS Code Generator

### Chart Events (12)
79. Screen Shake · 80. Color Flash · 81. Shader Apply · 82. Particle Spawn · 83. Tween Property · 84. Visibility · 85. Character Swap · 86. Stage Change · 87. Note Skin · 88. HUD Layout · 89. Audio Effect · 90. Event Group

### Misc (10)
91. Visual Audio Spectrum · 92. Stage Presets · 93. Audio Viz Design · 94. Character Presets · 95. Note Skin Presets · 96. HUD Presets · 97. Gameplay Modifiers · 98. Screenshot System · 99. Dev Console · 100. Auto-Backup

---

## 📝 Notes
- All files use the **HScript** format (interpreted, no compilation needed)
- Event JSONs follow the existing `EventsData` format
- Stage XMLs follow the existing `codename-engine-stage` DTD
- Shaders use `#pragma header` for engine compatibility
- Achievement/mod definitions use standard JSON
- Visual script graphs use `.vsg.json` extension

---

*Made for Codename Engine · Drop in and play!*
