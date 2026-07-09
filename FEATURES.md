# Codename Engine features
This markdown file contains all features of Codename Engine, separated into multiple categories.

_**QOL = Quality of Life**_

<details>
  <summary><h2>Player QOL Features</h2></summary>

- New input system
- New accuracy and misses system, added to fix the base game UI.
- New options, including:
    - Controls rebinds (for P1 and P2)
    - Downscroll
    - Ghost Tapping
- Opponent & Co-op modes
- Memory optimization (most of the game runs < 500mb)
    - Usage of [flxanimate](https://github.com/Dot-Stuff/flxanimate) on big sprites, such as Girlfriend to save memory.
    - You can further optimize it on certain stages by enabling `Low Memory Mode` in `Options > Appearance`.
- New volume change SFX (no more loud flixel beep, customizable)
- New FPS counter allowing you to see advanced info by pressing F3 (infos can be selected and copied too when in advanced).
- Simple but advanced modding system (press TAB on main menu)
- **Windows only:**
    - (Windows) FNF is no longer blurry on 125-150% DPI
    - FNF auto fixes audio on state change when you plug in/out your headphones.
    - FNF auto applies dark titlebar
- **Week 7 included** with softcoded cutscenes (no MP4)
- Auto updating: Once the engine updates, a prompt will be available at launch. If the user accepts to update, the engine will auto install the newest version.
</details>

<details>
    <summary><h2>Modding QOL features</h2></summary>

- New assets and scripting management - **Applies both to the `assets` folder and mods.**
    - Support for `hscript-improved`, a fork made to allow HScript to push modding even further
        - Allows for imports
        - Allows for public variables (variables shared between every script in a ScriptPack such as a song scripts)
        - Allows for static variables (variables shared between every single script ran in this mod)
        - Allows you to use for example `boyfriend` instead of `PlayState.boyfriend` or `game.boyfriend`, for smaller and easier to comprehend code.
        - Allows you to use `@:bypassAccessor`
        - Allows you to use maps
    - Usage of XML files for Characters instead of hardcoding them.
    - Entirely new song structure (`songs/name/`)
    - Usage of XML files for stages.
    - Usage of XML files for weeks.
    - Editors for Charts, Characters, Stages, Alphabet, Visual Scripts, Dialogue, Animation, and Shaders
        - Undos/Redos supported
        - Warning on closing unsaved work.
        - Clean UI
        - Mature Chart editor
    - Every single state & substate can be modified via HScript (`data/states/StateName.hx`)
- **Instances launched via `lime test windows` will automatically use assets from source.**
- Modcharting features powered by [FunkinModchart](https://lib.haxe.org/punkin-modchart/).
</details>

---

<details>
  <summary><h2>🆕 New Editors (15 New Editors)</h2></summary>

### 1. Visual Script Editor
- Full node-based visual HScript programming
- Drag & drop node creation from categorized palette (Flow Control, Math, Variables, Sprites, Audio, Camera, Tweens, Shaders, Events, Utility)
- 80+ node types covering all gameplay systems
- Type-checked connections with visual feedback
- Compile to HScript or execute directly at runtime
- Variable management panel, properties inspector, minimap
- Undo/redo, copy/paste, auto-layout, search & filter
- Multiple graph tabs, groups/comments for organization
- Export as .hxs files or inline HScript

### 2. Dialogue Editor
- Visual dialogue tree editor with branching paths
- Character portrait management with expression system
- Text effects: typewriter, shake, color, size, rainbow, wave
- Choice/consequence branching with condition checks
- Sound effect integration per dialogue node
- Preview mode with playback
- Localization support
- Import/export dialogue scripts as JSON

### 3. Animation Editor
- Timeline-based animation with keyframes
- Multiple animation tracks: Position X/Y, Rotation, Scale X/Y, Alpha, Color R/G/B
- 16 easing functions (linear, quad, cubic, sine, expo, back, bounce, elastic, bezier)
- Real-time preview with playback controls (play, pause, stop, speed, seek)
- Loop modes: Normal, Ping-Pong, One-Shot
- Animation events system
- Import from spritesheet/GIF

### 4. Shader Editor
- Visual node-based shader graph editor
- 24+ shader node types (Texture Sample, UV, Time, Math, Color, Noise, etc.)
- Real-time GLSL preview
- 10 built-in shader presets (Grayscale, Invert, Blur, Chromatic Aberration, Vignette, Pixelate, Scanlines, Wave Distort, Bloom, CRT)
- Uniform variable management with type-safe inputs
- Hot reload during gameplay

### 5. Event Timeline Editor
- Dedicated visual timeline for chart events
- Drag events on timeline, edit parameters inline
- Color-coded event categories
- Event grouping and collapsing
- Search and filter events

### 6. Note Type Editor
- Visual note type creator with preview
- Custom note graphics, animations, and behaviors
- Script template generation for new note types

### 7. Week Editor
- Visual story mode/week configuration
- Drag-and-drop week ordering
- Character and song assignment
- Difficulty configuration

### 8. Transition Editor
- Custom state transition creator
- Visual preview of transitions
- 9 transition types with customization

### 9. Mod Config Editor
- Full mod metadata and configuration editor
- Dependency management UI
- Asset override priority configuration

### 10. Audio Visualizer Editor
- Design audio-reactive visuals for stages
- Real-time preview with audio playback
- Multiple visualization presets (see Audio Visualizer Design Settings below)

### 11. Keybind Layout Editor
- Visual keybinding layout designer
- Import/export keybind profiles

### 12. Character Pose Editor
- Quick character pose positioning tool
- Side-by-side comparison view

### 13. Freeplay Menu Customizer
- Custom freeplay screen designer
- Song card layout, colors, and animations

### 14. Healthbar Theme Editor
- Health bar visual styling editor
- Custom icons, colors, and animations

### 15. Cutscene Editor
- Timeline-based cutscene creation tool
- Multi-track editing (sprites, audio, camera, text)

</details>

<details>
  <summary><h2>🆕 New & Improved Systems (25 Systems)</h2></summary>

### Particle System
- GPU-friendly particle system with 5000+ particle pooling
- 6 emitter shapes: Point, Line, Circle, Cone, Box, Ring
- Full customization: lifetime, speed, acceleration, rotation, scale, color interpolation
- Gravity and wind forces, drag
- Beat-synchronized spawning
- 12 built-in presets: Confetti, Sparks, Smoke, Fire, Bubbles, Rain, Snow, Leaves, Music Notes, Explosion, Hearts, Stars
- Texture atlas support, blend modes

### Achievement System
- 20+ built-in achievements across 5 categories (Gameplay, Difficulty, Modding, Time, Secret)
- Count-based, time-based, and condition-based tracking
- Progress persistence and notifications
- Mod-specific achievements via JSON definitions
- Secret achievement support with hidden names/descriptions
- Prerequisite chains

### Replay System
- Record full gameplay sessions with precise input timestamps
- Replay playback with ghost notes
- Speed control (0.25x - 4x)
- Camera modes: Follow Original, Free Cam, Focus Player/Opponent, Cinematic
- Checksum verification (anti-tamper)
- Replay list management, per-chart best replay tracking
- Export/import replay files (.cnreplay)

### Audio Spectrum Analyzer
- Real-time FFT spectrum analysis
- 8 frequency bands: Sub Bass, Bass, Low Mid, Mid, High Mid, Presence, Treble, Brilliance
- Beat detection with BPM estimation
- RMS volume analysis
- Smoothed values for visual effects
- Custom frequency bands
- 8 visualization presets: Classic Bars, Circular, Waveform, Pulse, Particle Reactive, Ambient Color, Mirror Bars, Radial Wave

### Gameplay Modifiers System (25+ Modifiers)
- **Speed:** Scroll Speed multiplier, X Mod (acceleration)
- **Direction:** Mirror, Flip, Shuffle, Random
- **Visual:** Hidden, Sudden, Invisible Notes, Tiny Notes
- **Difficulty:** No Miss, One HP, Static Camera, Strict Input, Bot Play, Practice Mode
- **Audio:** Muted Vocals, Pitch Shift, Song Speed
- **Fun:** Drunk, Tipsy, Beat Rotation, Rainbow, Spin
- **Accessibility:** Colorblind Mode (4 types), Reduced Motion
- Score multiplier calculation per modifier
- Preset system for saving/loading modifier combinations

### Lighting System
- 2D lighting with point lights, spotlights, and directional lights
- Customizable color, intensity, radius, falloff (constant, linear, quadratic, cubic)
- Spotlight cone angles
- Beat-synchronized pulsing
- 6 built-in presets: Default, Concert, Nightclub, Sunset, Horror, Neon
- Light groups and animation (phase, speed, amplitude)
- Integration with stage editor

### Developer Console
- Quake-style drop-down console (toggle with ` backtick)
- 30+ built-in commands: help, clear, echo, god, botplay, speed, health, song, restart, skip, fps, mem, gc, trace, log, fullscreen, resolution, vsync, cam, mods, reload, script, editor, set, get, alias, achievement, screenshot
- HScript evaluation
- Command history with autocomplete
- Log viewer with filtering
- Custom command registration for mods

### Screenshot & Capture System
- High-resolution screenshots (up to custom resolution)
- GIF recording with configurable FPS
- Screenshot gallery with metadata
- Tags and organization

### Preset Systems
- **Stage Presets:** Basic Stage, Concert Stage, Outdoor Park, Neon City, Void
- **Audio Visualizer Presets:** Bottom Bars, Circular Visualizer, Waveform Line, Beat Pulse Background, Radial Wave, Mirror Spectrum
- **Character Presets:** BF Default, Dad Default, GF Default
- **Note Skin Presets:** Default Notes, Pixel Notes, Circle Notes
- **HUD Presets:** Default HUD, Minimal HUD, Competitive HUD

### Other Systems
- **Save Slot System:** Multiple save profiles with independent data
- **Auto-Backup System:** Automatic editor backups with versioning
- **Practice Mode:** Section looping, speed control, checkpoints, no-death mode
- **Input Calibration Wizard:** Audio, visual, and input offset calibration
- **Difficulty Rating Calculator:** Auto-calculated 1-10 rating from chart density
- **Notification/Toast System:** In-game notification queue with types
- **Transition System:** 9 transition types with customizable parameters
- **Crash Recovery:** Auto-save and recovery for editor files
- **Script Hot-Reload:** Live reload HScript without restarting
- **Performance Profiler:** Frame-by-frame analysis
- **Multi-Camera System:** Multiple layered cameras

</details>

<details>
  <summary><h2>🆕 Mod Integration & Cross-Engine Support (15 Features)</h2></summary>

- **Psych Engine Full Mod Import:** Auto-convert characters (JSON→XML), stages (Lua→XML), charts, scripts
- **V-Slice Full Mod Import:** Convert songs, characters, stages, note styles from base game format
- **Kade Engine Chart Import:** Import Kade Engine chart format
- **Modpack System:** Bundle multiple mods into shareable packs with dependency tracking
- **Mod Content Manager:** Enable/disable individual mod assets
- **Mod Version Checker:** Verify mod compatibility with engine version
- **Mod Update Checker:** Check for updates from remote sources
- **Mod Conflict Detector:** Detect and resolve asset conflicts between mods with severity levels
- **Asset Override Priority:** Configurable per-mod priority system
- **Shared Mod Libraries:** Shared utility scripts between mods
- **Script Compatibility Layer:** Psych Lua → HScript translation helpers
- **Asset Format Converter:** Convert between spritesheet formats
- **Cross-Engine Character Import:** Import characters from Psych, V-Slice, Kade, Legacy
- **Dependency Resolution:** Automatic topological sorting of mod dependencies
- **Auto-Detection:** Detect source engine format automatically

</details>

<details>
  <summary><h2>🆕 Song Features (15 Features)</h2></summary>

- **Multi-Vocal Track Support:** Multiple vocal tracks per character
- **Song Speed Events:** Dynamic playback speed changes mid-song
- **Song Pitch Shift:** Real-time pitch shifting events
- **Song Reverse Mode:** Play songs backwards for challenge
- **Song Mashup Mode:** Combine two songs in the chart editor
- **Enhanced Time Signatures:** Full custom time signature support
- **Polyrhythm Support:** Different rhythms for different strumlines
- **Auto Difficulty Detection:** Calculate difficulty rating from chart note density
- **Dynamic Scroll Speed Curves:** Smooth scroll speed interpolation
- **Song Preview System:** Preview songs in freeplay with custom loop points
- **Song Tags/Genre System:** Tag and categorize songs
- **Enhanced Song Variations:** Improved variation system with inheritance
- **Section Practice Mode:** Loop specific chart sections
- **Song Randomizer:** Random song selection with filters
- **Song Bookmarks:** Bookmark positions for quick navigation

</details>

<details>
  <summary><h2>🆕 Visual Scripting System (8 Components)</h2></summary>

Full node-based visual scripting system that compiles to HScript:

- **Node System:** 80+ nodes across 12 categories with type-checked connections
- **Event Nodes:** OnBeat, OnStep, OnNoteHit, OnNoteMiss, OnCountdown, OnSongStart, OnSongEnd, custom events
- **Sprite Nodes:** Spawn, Get, Set Property, Play Animation, Remove, Set Alpha/Scale/Position/Angle/Color/Scroll Factor
- **Audio Nodes:** Play Sound, Play Music, Stop Sound, Set Volume, Set Pitch, Fade Audio, Play Vocal
- **Math Nodes:** Add/Sub/Mul/Div/Pow/Mod, Compare, Random, Sin/Cos/Tan/Abs/Sqrt, Lerp, Map Range, Clamp, Absolute, Negate
- **Flow Control:** Branch, For Loop, While Loop, Switch, Break, Continue, Return, Sequence, Gate, Multi Gate, Flip Flop, Delay
- **Variable System:** Get/Set Variable, Constant, Get/Set Property, Make Array, Array Get/Add/Remove, String operations (Concat, Split, Length, Contains, Replace, Format)
- **Code Generator:** Full compilation to valid HScript code with expression inlining

</details>

<details>
  <summary><h2>🆕 Extended Chart Events (20+ New Events)</h2></summary>

All new events are registered with the existing EventsData system and work in the Charter:

- **Screen Shake:** Camera/HUD shake with intensity, duration, rotation
- **Color Flash:** Colored flash with blend modes (normal, add, multiply, screen)
- **Apply Shader:** Apply shaders to cameras, stage, or characters with transitions
- **Set Shader Uniform:** Modify shader uniforms with tweening
- **Spawn Particles:** 12 particle presets with configurable position, count, emitter shape
- **Tween Property:** Generic property tween on any target with full easing
- **Set Visibility:** Show/hide/fade sprites and groups
- **Swap Character:** Change characters mid-song with transition effects
- **Change Stage:** Switch stages with fade/slide/zoom/wipe transitions
- **Change Note Skin:** Swap note graphics mid-song
- **HUD Layout:** Move/scale/rotate/fade HUD elements
- **Audio Effect:** Volume, pitch, pan, filters (lowpass, highpass, reverb, distortion)
- **Event Group:** Group events for repeat/loop patterns
- **Set Gameplay Modifier:** Change modifiers mid-song
- **Play Video:** Overlay/fullscreen/background video playback
- **Screen Transition:** 9 transition types with color and easing
- **Set Strumline Position/Angle:** Animate strumline position and rotation
- **Lighting Event:** Set ambient, directional, point, spot lights
- **Screen Effect:** Chromatic aberration, vignette, blur, pixelate, glitch, scanlines, film grain, bloom, CRT
- **Dialogue Event:** Show/hide/advance dialogue with characters
- **Character Glow:** Add glow effect to characters
- **Set Background Color:** Tween camera background color

</details>

<details>
  <summary><h2>🆕 Miscellaneous Features</h2></summary>

- **Visual Audio Spectrum for Stages:** Robust audio-reactive system with FFT analysis, 8 frequency bands, beat detection, custom bands, and 8 visualization presets — all configurable in the stage editor
- **Stage Audio Visualizer Design Settings:** Full design control including position, size, bar count, colors, gradient, opacity, blend mode, smoothing, mirror, orientation, glow, scroll factor — with 6 built-in presets
- **Developer Console:** Quake-style console with 30+ commands, HScript eval, autocomplete, log viewer
- **Auto-Backup System:** Automatic editor backups every 2 minutes with version history
- **Crash Recovery:** Save recovery data for all editors, restore on restart

</details>
