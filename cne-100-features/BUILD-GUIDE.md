# Building Codename Engine with 100 Features — Windows Guide

## Prerequisites
- **Windows 10/11** (64-bit)
- **Haxe 4.3.7** — [Download here](https://haxe.org/download/version/4.3.7/)
- **Git** — [Download here](https://git-scm.com/download/win)

## Step 1: Clone the branch
```bat
git clone https://github.com/kfirimcchaki/codename-f.git
cd codename-f
git checkout arena/019f45e2-codename-f
```

## Step 2: Install dependencies
```bat
setup-windows.bat
```
This runs the custom installer that fetches:
- openfl (CodenameCrew fork)
- lime 8.1.2
- flixel (CodenameCrew fork)
- flixel-addons (CodenameCrew fork)
- hscript-improved (codename-dev branch)
- funkin-modchart
- hxvlc 1.9.3
- hxcpp (CodenameCrew fork)
- flixel-animate
- markdown, format, hxp, nape-haxe4

## Step 3: Compile for Windows
```bat
haxelib run lime test windows
```
Or use the helper script:
```bat
building\cne-windows.bat test
```

## Step 4: Extract the feature assets
After compilation, extract `cne-100-features.zip` into the engine root:
```bat
powershell Expand-Archive cne-100-features.zip -DestinationPath . -Force
```

Or manually copy the `assets/` and `mods/` folders from `cne-100-features/` into the engine root.

## What compiles vs what's runtime

| Component | How it works | Needs recompile? |
|-----------|-------------|-----------------|
| `EventsData.hx` (22 new events) | Compiled into engine binary | ✅ Yes |
| Event JSONs in `assets/data/events/` | Loaded at runtime by `reloadEvents()` | ❌ No |
| HScript handlers in `assets/data/scripts/` | Interpreted at runtime | ❌ No |
| GLSL shaders in `assets/shaders/engine/` | Compiled by GPU at runtime | ❌ No |
| Stage XMLs in `assets/data/stages/` | Parsed at runtime | ❌ No |
| Achievement JSONs | Loaded at runtime | ❌ No |
| Preset JSONs | Loaded at runtime | ❌ No |

## Troubleshooting

### "lime not found"
```bat
haxelib run lime setup
```

### "hxcpp build failed"
Make sure Visual Studio 2019/2022 Build Tools are installed with C++ workload.

### "openfl version mismatch"
The setup script installs custom forks. Don't manually install openfl/flixel from haxelib.

### Events not showing in Charter
Make sure `cne-100-features/assets/data/events/*.json` files are in `assets/data/events/`. The events are registered both in compiled code (EventsData.hx) and via JSON files for redundancy.

### Shaders not working
Make sure `cne-100-features/assets/shaders/engine/*.frag` files are in `assets/shaders/engine/`.

## Release build (optimized, no debug)
```bat
haxelib run lime build windows
```
Output: `export/release/windows/bin/`

## Debug build (with console)
```bat
haxelib run lime test windows -debug
```
