# HX Tools — Codename Engine Mod

A powerful mod that adds an **HX File Browser** and **HX Code Editor** to Codename Engine, plus 22 new chart events, 5 stage presets, 9 shader effects, and more.

## Installation

1. Copy the `hx-tools` folder into your `mods/` directory
2. Enable it in the mod switcher (TAB on main menu)
3. Done! Press **F3** from anywhere to open the HX Browser

## Features

### 🔍 HX File Browser (`HXBrowser`)
- **Auto-categorizes** all `.hx` files: States, Substates, Editors, Scripts, Game, Backend, Menus, Options, Libraries
- **Tree view** with expandable categories and color-coded subcategories
- **Full-text search** across file names, class names, packages, and content
- **Preview panel** showing first 80 lines of any file
- **Info panel** with package, class, extends, functions, variables, line count
- **Sort** by name, size, or line count (F2 to cycle)
- **Keyboard navigation** — arrows, Enter, Escape
- Open files in the HX Editor with **Ctrl+E** or double-click

### ✏️ HX Code Editor (`HXEditor`)
- **Full code editor** with line numbers, current line highlight, scrolling
- **Visual structure panel** — parsed tree showing package, imports, class, functions (with modifiers), variables (public/private/static)
- **Minimap** — tiny overview of entire file
- **Find & Replace** with regex support, case sensitivity toggle
- **Undo/Redo** — 200-level stack (Ctrl+Z / Ctrl+Shift+Z)
- **Tab management** — multiple files open simultaneously
- **Open / Save / Save As** — full file I/O with system dialogs
- **Templates** — State, Substate, Editor, HScript, Event Handler
- **Syntax validation** — bracket/brace/paren balancing (F5)
- **Code formatting** — auto-indent fixer (F6)
- **Status bar** with cursor position, file info, search results

### 📊 22 New Chart Events
All appear in the Charter editor automatically:
Screen Shake, Color Flash, Apply Shader, Set Shader Uniform, Spawn Particles, Tween Property, Set Visibility, Swap Character, Change Stage, Change Note Skin, HUD Layout, Audio Effect, Event Group, Screen Effect, Set Strumline Position/Angle, Lighting Event, Play Sound Effect, Screen Transition, Character Glow, Set Background Color, Set Gameplay Modifier

### 🎭 5 Stage Presets
concert, neon-city, park, horror, void — all with proper parallax scrolling

### 🔮 9 GLSL Shader Effects
blur, vignette, pixelate, scanlines, CRT, wave distortion, glitch/chromatic aberration, bloom, film grain

### 🎮 Integration
- **F3** opens HX Browser from anywhere
- **Ctrl+E** opens selected file in HX Editor from Browser
- Open from scripts: `FlxG.switchState(new ModState("HXBrowser"))` or `FlxG.switchState(new ModState("HXEditor", {path: "source/funkin/game/PlayState.hx"}))`

## Keyboard Shortcuts

### HX Browser
| Key | Action |
|-----|--------|
| F3 | Open Browser (from anywhere) |
| Ctrl+E | Open selected file in Editor |
| Ctrl+F | Focus search |
| F2 | Cycle sort mode |
| ↑/↓ | Navigate file list |
| Escape | Exit to main menu |

### HX Editor
| Key | Action |
|-----|--------|
| Ctrl+S | Save |
| Ctrl+Z | Undo |
| Ctrl+Shift+Z / Ctrl+Y | Redo |
| Ctrl+F | Toggle Find & Replace |
| Ctrl+N | New file |
| Ctrl+W | Close tab |
| Ctrl+G | Go to line |
| Ctrl+Tab | Next tab |
| F5 | Validate syntax |
| F6 | Format code |
| ↑/↓ | Navigate lines |
| Mouse wheel | Scroll |
| Escape | Exit (auto-saves) |

## File Structure
```
mods/hx-tools/
├── data/
│   ├── config/
│   │   ├── mod.json          ← Mod metadata
│   │   └── menuItems.txt     ← Menu integration
│   ├── events/               ← 22 event JSON definitions
│   ├── stages/               ← 5 stage XML presets
│   ├── scripts/
│   │   └── hx-tools-integration.hx  ← Global integration (F3 shortcut)
│   └── states/
│       ├── HXBrowser.hx      ← File browser state (HScript)
│       └── HXEditor.hx       ← Code editor state (HScript)
└── shaders/
    └── engine/               ← 9 GLSL shader effects
```
