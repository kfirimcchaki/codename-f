# PROMPT: Create Two Codename Engine HScript States (HXBrowser + HXEditor)

You are creating two HScript state files for **Codename Engine** (a Friday Night Funkin' engine built with HaxeFlixel). These are NOT compiled Haxe — they are **HScript** files that run at runtime via the engine's scripting system. This distinction is CRITICAL because HScript has severe limitations compared to Haxe.

---

## 🚨 CRITICAL HSCRIPT CONSTRAINTS (VIOLATING ANY OF THESE = BLACK SCREEN / CRASH)

### ABSOLUTELY FORBIDDEN — These will cause parse errors or black screens:
1. **NO `#if` / `#else` / `#end`** — HScript has NO conditional compilation
2. **NO `~/pattern/flags` regex literals** — HScript parser CANNOT parse these. Use `new EReg("pattern", "flags")` instead
3. **NO `import` statements** — Types like `FlxSprite`, `FlxText`, `FlxG`, `FlxTween`, `FlxEase`, `FlxColor`, `FlxMath`, `StringTools` are ALREADY available in the script context
4. **NO `super.create()` / `super.update()` / `super.destroy()`** — Scripts are HOOKS, not class overrides. The engine calls your `create()` AFTER its own setup
5. **NO custom `FlxCamera` creation** — Use the state's default camera. Never do `new FlxCamera()` or `camera = something`
6. **NO `scrollFactor.set()` on UI elements** — Not needed when using the default camera
7. **NO `cast` expressions** — Use `Std.int()`, `Std.parseFloat()` etc. instead
8. **NO complex generic types** — Use `Array<Dynamic>` not `Array<SomeSpecificType>`
9. **NO `typedef`** — Define types inline or use Dynamic
10. **NO `enum` or `enum abstract`** — Use constants instead
11. **NO `using` statements** — e.g. `using StringTools;` won't work. Call `StringTools.trim(str)` directly instead of `str.trim()`
12. **NO null-coalescing `??`** — Use ternary or if/else
13. **NO safe navigation `?.`** — Use explicit null checks
14. **NO arrow functions `() ->`** — Use `function()` instead. EXCEPTION: simple callbacks in FlxTween like `{ease: FlxEase.quadOut}` are fine
15. **NO class definitions** — The script IS the state. Define `function create()` and `function update(elapsed:Float)` at top level

### What IS available in HScript context (pre-injected by the engine):
- `FlxG` — game globals (FlxG.width, FlxG.height, FlxG.keys, FlxG.mouse, FlxG.sound, FlxG.switchState, FlxG.cameras)
- `FlxSprite` — sprites (new FlxSprite(x, y).makeGraphic(w, h, color), .loadGraphic(), .scale, .alpha, .color, .angle, .x, .y, .visible)
- `FlxText` — text (new FlxText(x, y, fieldWidth, text, size), .color, .alignment, .font, .bold)
- `FlxObject` — invisible hitbox objects
- `FlxTypedGroup<T>` — groups (new FlxTypedGroup<FlxSprite>(), .add(), .clear(), .remove())
- `FlxSpriteGroup` — sprite groups
- `FlxTween` — tweens (FlxTween.tween(target, {props}, duration, {ease: FlxEase.quadOut, onComplete: function(t) {}}))
- `FlxEase` — easing functions (FlxEase.quadIn, quadOut, quadInOut, cubeIn, cubeOut, backOut, bounceOut, elasticOut, sineIn, sineOut, expoOut, linear, etc.)
- `FlxColor` — colors (FlxColor.fromRGB(r,g,b), FlxColor.WHITE, FlxColor.BLACK, FlxColor.RED, etc.)
- `FlxMath` — math utils (FlxMath.lerp(a, b, ratio), FlxMath.wrap(val, min, max), FlxMath.roundDecimal(val, precision))
- `FlxPoint` — points (FlxPoint.get(x, y))
- `FlxTimer` — timers (new FlxTimer().start(seconds, function(t) {}))
- `add(sprite)` — adds to the state (this is how you put things on screen)
- `remove(sprite)` — removes from state
- `openSubState(substate)` — opens a substate
- `camera` — the state's default camera (DO NOT reassign this)
- `EReg` — regex (new EReg("pattern", "flags"), .match(str), .matchSub(str, pos), .matched(n), .matchedPos())
- `StringTools` — string utils (StringTools.trim(str), StringTools.lpad(str, chars, len), StringTools.replace(str, find, rep), StringTools.startsWith(str, prefix))
- `haxe.io.Path` — path utils (haxe.io.Path.withoutDirectory(path), haxe.io.Path.withoutExtension(path))
- `sys.io.File` — file I/O (sys.io.File.getContent(path), sys.io.File.saveContent(path, content))
- `sys.FileSystem` — filesystem (sys.FileSystem.exists(path), sys.FileSystem.isDirectory(path), sys.FileSystem.readDirectory(path))
- `Reflect` — reflection (Reflect.hasField(obj, name), Reflect.field(obj, name), Reflect.compare(a, b))
- `Std` — standard (Std.int(float), Std.parseFloat(str), Std.string(val), Std.isOfType(val, Type))
- `Math` — math (Math.max, Math.min, Math.round, Math.floor, Math.ceil, Math.abs, Math.random, Math.sqrt, Math.pow, Math.sin, Math.cos)
- `Type` — type info (Type.getClassName(Type.getClass(obj)))
- `Date` — dates (Date.now())
- `Json` — JSON (haxe.Json.parse(str), haxe.Json.stringify(obj))
- `Assets` — openfl assets (Assets.getText(path), Assets.exists(path))

### State navigation:
```haxe
// Switch to a built-in state:
FlxG.switchState(new funkin.menus.MainMenuState());
FlxG.switchState(new funkin.menus.FreeplayState());

// Switch to another HScript state via ModState:
FlxG.switchState(new funkin.backend.scripting.ModState("HXBrowser"));
FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: "source/funkin/game/PlayState.hx"}));

// Access data passed from ModState:
if (data != null && Reflect.hasField(data, "path")) {
    var filePath = Reflect.field(data, "path");
}
```

### Input handling pattern:
```haxe
function update(elapsed:Float) {
    if (FlxG.keys.justPressed.ESCAPE) { /* exit */ }
    if (FlxG.keys.justPressed.ENTER) { /* confirm */ }
    if (FlxG.keys.justPressed.UP) { /* navigate up */ }
    if (FlxG.keys.justPressed.DOWN) { /* navigate down */ }
    if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S) { /* save */ }
    if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.Z) { /* undo */ }
    if (FlxG.keys.justPressed.TAB) { /* cycle */ }
    if (FlxG.keys.justPressed.F1) { /* help */ }
    if (FlxG.keys.justPressed.F5) { /* validate */ }
    if (FlxG.mouse.wheel != 0) { /* scroll */ }
    if (FlxG.mouse.justReleased) { /* click */ }
    if (FlxG.keys.justPressed.BACKSPACE) { /* delete */ }
    // For text input, iterate char codes:
    for (code in 32...127) {
        if (FlxG.keys.justPressed(cast code)) {
            myString += String.fromCharCode(code);
            break;
        }
    }
}
```

### UI creation pattern (the ONLY correct way):
```haxe
function create() {
    FlxG.mouse.visible = true;
    
    // Background
    var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(22, 22, 30));
    add(bg);
    
    // Header
    var header = new FlxSprite(0, 0).makeGraphic(FlxG.width, 32, FlxColor.fromRGB(16, 16, 24));
    add(header);
    
    // Text
    var title = new FlxText(12, 8, 300, "My Title", 16);
    title.color = FlxColor.fromRGB(80, 150, 255);
    add(title);
    
    // Group for dynamic content
    var itemsGroup = new FlxTypedGroup<FlxSprite>();
    add(itemsGroup);
    
    // Add items to group
    var item = new FlxSprite(10, 50).makeGraphic(200, 24, FlxColor.fromRGB(40, 40, 60));
    itemsGroup.add(item);
    var label = new FlxText(16, 52, 190, "Item name", 12);
    label.color = FlxColor.WHITE;
    itemsGroup.add(label);
}
```

---

## 📁 FILE STRUCTURE

Create exactly these two files:

### File 1: `HXBrowser.hx`
- Location: `mods/hx-tools/data/states/HXBrowser.hx`
- Purpose: File browser that scans and categorizes all .hx files in the engine
- Opened via: `FlxG.switchState(new ModState("HXBrowser"))` or state redirect

### File 2: `HXEditor.hx`  
- Location: `mods/hx-tools/data/states/HXEditor.hx`
- Purpose: Full code editor for .hx files with visual structure panel
- Opened via: `FlxG.switchState(new ModState("HXEditor", {path: "path/to/file.hx"}))` or state redirect

---

## 🎨 VISUAL DESIGN REQUIREMENTS

Both states should use a **dark IDE-like theme** with these colors:
- Background: RGB(22, 22, 30)
- Panel: RGB(28, 28, 42)
- Panel Alt: RGB(34, 34, 48)
- Editor BG: RGB(26, 26, 36)
- Text: RGB(215, 215, 230)
- Dim Text: RGB(110, 110, 135)
- Accent: RGB(80, 150, 255)
- Selection: RGB(55, 70, 110)
- Line Highlight: RGB(36, 36, 50)

**Category colors:**
- States: #4488FF, Substates: #44AAFF, Editors: #44FF88
- Editor UI: #88FF44, Scripts: #FFAA44, Game: #FF4466
- Backend: #9944FF, Menus: #44FFDD, Options: #DDDD44
- Libraries: #666666, Other: #888888

**Visual elements to include:**
- Rounded-feel panels using semi-transparent overlays
- Clear visual hierarchy with headers, separators
- Hover states (lighter background when mouse is over items)
- Selected states (accent-colored background)
- Smooth transitions using FlxTween where appropriate
- Visual indicators for dirty/modified files
- Line numbers in the editor (dimmed, right-aligned)
- Current line highlighting in the editor
- A minimap panel (tiny text rendering of the whole file)
- Tab bar for multiple open files
- Status bar at the bottom with cursor position, file info, hints

---

## 🔍 HXBrowser.hx — FULL FEATURE SPECIFICATION

### Layout (1280x720):
```
┌──────────────────────────────────────────────────────────┐
│ HEADER: "HX File Browser" + keyboard shortcut hints      │ 34px
├─────────┬──────────┬─────────────────────────────────────┤
│CATEGORY │ SEARCH   │                                     │
│ PANEL   │ BAR      │         PREVIEW PANEL               │
│ 290px   │──────────│         (code preview of             │
│         │ FILE     │          selected file,              │
│ [▼]States│ LIST     │          first 80 lines)            │
│   (24)  │ 380px    │                                     │
│ [▼]Edit.│          │                                     │
│   (18)  │ file1.hx │                                     │
│ [▶]Game │ file2.hx │                                     │
│   (12)  │ file3.hx │                                     │
│ [▼]Back.│ ...      │                                     │
│   (45)  │          │                                     │
│         │──────────│                                     │
│         │ INFO     │                                     │
│         │ PANEL    │                                     │
│         │ 155px    │                                     │
├─────────┴──────────┴─────────────────────────────────────┤
│ STATUS: Files: 200/500 | Cat: States | Selected: x.hx   │ 26px
└──────────────────────────────────────────────────────────┘
```

### Features:
1. **File scanning**: Recursively scan `source/` and `mods/` directories for all `.hx` files using `sys.FileSystem`
2. **Auto-categorization**: Detect file type by content analysis:
   - Contains `extends MusicBeatState` or `extends UIState` → States
   - Contains `extends MusicBeatSubstate` or `extends FlxSubState` → Substates
   - Path contains `editors/ui/` → Editor UI
   - Path contains `editors/` → Editors
   - Path contains `scripts` → Scripts
   - Path contains `game/` → Game
   - Path contains `backend/` → Backend
   - Path contains `menus/` → Menus
   - Path contains `options/` → Options
   - Path contains `flixel/` or `haxe/` or `lime/` or `openfl/` → Libraries
3. **File info extraction** (using `new EReg()` for regex):
   - Package name: `new EReg("^package\\s+([\\w.]+)\\s*;", "m")`
   - Class name: `new EReg("class\\s+(\\w+)", "")`
   - Extends: `new EReg("class\\s+\\w+\\s+extends\\s+([\\w.]+)", "")`
   - Functions: `new EReg("((?:public|private|static|override)\\s+)*function\\s+(\\w+)", "g")` with `matchSub` loop
   - Variables: `new EReg("var\\s+(\\w+)\\s*(?::\\s*(\\w+))?", "g")` with `matchSub` loop
4. **Tree view**: Expandable categories with subcategories, file counts, color-coded
5. **File list**: Scrollable list with file name (colored by category), line count, file size
6. **Search**: Press S to activate, type to filter across filename/classname/package, ENTER to confirm, ESC to cancel
7. **Preview panel**: Shows first 80 lines of selected file's content
8. **Info panel**: Shows package, class, extends, category, line count, size, function list, variable count
9. **Navigation**: UP/DOWN arrows for files, TAB to switch categories, LEFT to expand/collapse, mouse wheel to scroll
10. **Open in editor**: Ctrl+E or ENTER opens the file in HXEditor via `FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: selectedFile.path}))`
11. **Sort**: F2 cycles between name/size/lines sort
12. **Exit**: ESC returns to MainMenuState
13. **Status bar**: Shows file count, current category, selected file, keyboard hints

### Keyboard shortcuts:
- UP/DOWN: Navigate file list
- TAB: Switch between categories
- LEFT: Expand/collapse category
- ENTER or Ctrl+E: Open selected file in HXEditor
- S: Activate search mode
- F2: Cycle sort mode
- Mouse wheel: Scroll file list
- ESC: Exit to main menu

---

## ✏️ HXEditor.hx — FULL FEATURE SPECIFICATION

### Layout (1280x720):
```
┌──────────────────────────────────────────────────────────┐
│ HEADER: "HX Editor" + filename + keyboard shortcut hints │ 34px
├──────────────────────────────────────────────────────────┤
│ [tab1.hx] [tab2.hx *] [tab3.hx]                         │ 26px tab bar
├────────┬─────────────────────────────────────┬───────────┤
│STRUCT. │ LINE │                              │  MINIMAP  │
│ PANEL  │ NUMS │      CODE EDITOR AREA        │   PANEL   │
│ 280px  │ 44px │      (monospace text)        │   100px   │
│        │      │                              │           │
│📦 pkg  │  1  │ package funkin.game;         │ (tiny     │
│📥 imp.5│  2  │                              │  text of  │
│🏗️ Class│  3  │ class PlayState extends      │  entire   │
│  ext.  │  4  │     MusicBeatState            │  file)    │
│        │  5  │ {                            │           │
│VARS(12)│  6  │     public var health:Float; │           │
│ [+] x  │  7  │     public var score:Int;    │           │
│ [-] y  │  8  │                              │           │
│ [S] z  │  9  │     override function        │           │
│        │ 10  │         create() {           │           │
│FUNCS(8)│ 11  │         super.create();      │           │
│ [+] cr │     │     }                        │           │
│ [+] up │     │ }                            │           │
│ [-] he │     │                              │           │
│        │     │                              │           │
├────────┴──────┴──────────────────────────────┴───────────┤
│ STATUS: file.hx | * Modified | Ln 42, Col 8 | 500 lines │ 26px
└──────────────────────────────────────────────────────────┘
```

### Features:
1. **File loading**: Load file from `data.path` (passed via ModState), or create new untitled file
2. **File saving**: Ctrl+S saves to current path using `sys.io.File.saveContent()`, marks as clean
3. **Tab management**: Multiple files open simultaneously, click to switch, dirty indicator (*), Ctrl+W to close, Ctrl+TAB to cycle
4. **Code display**: Monospace font, line numbers (dimmed right-aligned), current line highlighted with subtle background
5. **Visual structure panel** (left side):
   - Package name with icon
   - Import count
   - Class name with extends info
   - Variables list with visibility indicators: `[+]` public, `[-]` private, `[S]` static
   - Functions list with indicators: `[+]` public, `[-]` private, `[S]` static, `[O]` override
   - Line numbers for functions
   - Summary counts at bottom
6. **Minimap** (right side): Tiny (size 3 font) rendering of entire file content
7. **Find & Replace** (Ctrl+F):
   - Toggle find bar at top of editor area
   - Type to search, results highlighted
   - Show match count
   - Navigate between matches with ENTER
   - Replace input + Replace/Replace All buttons
   - ESC to close find bar
8. **Undo/Redo**: Ctrl+Z undo, Ctrl+Shift+Z or Ctrl+Y redo, 200-level stack, stores full content snapshots
9. **Syntax validation** (F5): Check bracket/brace/paren balance, respecting strings and comments, show results in find bar area
10. **Code formatting** (F6): Auto-indent based on brace depth
11. **Templates**: Ctrl+N creates new file from template (basic class structure)
12. **Navigation**: UP/DOWN to move cursor line, LEFT/RIGHT for column, PAGEUP/PAGEDOWN for page scroll, mouse wheel to scroll
13. **Text editing**: Actually allow typing into the code! When user types characters, insert them at cursor position. BACKSPACE to delete. This makes it a real editor.
14. **Status bar**: File path, modified indicator, cursor line/column, line count, find results, undo count, keyboard hints
15. **Exit**: ESC saves if dirty and returns to MainMenuState

### Keyboard shortcuts:
- UP/DOWN: Move cursor line
- LEFT/RIGHT: Move cursor column
- PAGEUP/PAGEDOWN: Page scroll
- ENTER: New line at cursor (for actual editing)
- BACKSPACE: Delete character before cursor
- Typing any character: Insert at cursor position
- Ctrl+S: Save file
- Ctrl+Z: Undo
- Ctrl+Shift+Z / Ctrl+Y: Redo
- Ctrl+F: Toggle find & replace
- Ctrl+N: New file from template
- Ctrl+W: Close current tab
- Ctrl+TAB: Next tab
- F5: Validate syntax
- F6: Format code (auto-indent)
- Mouse wheel: Scroll code
- ESC: Save & exit

---

## 📝 IMPORTANT IMPLEMENTATION NOTES

1. **Both files should be 500-800 lines each** — comprehensive but not bloated
2. **Use `FlxTypedGroup<FlxSprite>` for dynamic lists** — clear and rebuild on refresh
3. **All text should use FlxText** with explicit x, y, width, text, size parameters
4. **All sprites should use `.makeGraphic(w, h, color)`** for solid rectangles
5. **Refresh pattern**: When data changes, call `refreshXxx()` functions that clear groups and rebuild
6. **Use `StringTools.lpad("", "\t", indent)` for indentation** in formatting
7. **File I/O uses `sys.io.File.getContent()` and `sys.io.File.saveContent()`** — no `#if sys` guards needed
8. **Regex uses `new EReg("pattern", "flags")`** — NEVER `~/pattern/`
9. **The `data` variable** is available in HXEditor when opened via `ModState("HXEditor", {path: "..."})` — access with `Reflect.hasField(data, "path")` and `Reflect.field(data, "path")`
10. **Mark dirty on any content change**, clear dirty on save
11. **For text editing in the editor**: Track cursor position as line+column indices into the `lines` array. When user types, modify `lines[cursorLine]` by inserting character at `cursorCol`. When BACKSPACE, remove character before cursor or merge with previous line. When ENTER, split current line at cursor.

---

## 📦 OUTPUT FORMAT

Output exactly two files:

### `HXBrowser.hx`
```
// Comment header with usage instructions
// Variable declarations
// function create() { ... }
// function scanAllFiles() { ... }
// function scanDir(dir) { ... }
// function makeFileInfo(path) { ... }  -- uses new EReg()
// function detectCat(path, content) { ... }
// function categorize(info) { ... }
// function selectCategory(cat) { ... }
// function selectFile(file) { ... }
// function refreshCats() { ... }
// function refreshList() { ... }
// function refreshPreview() { ... }
// function refreshInfo() { ... }
// function refreshStatus() { ... }
// function update(elapsed) { ... }
// function doSearch() { ... }
```

### `HXEditor.hx`
```
// Comment header with usage instructions
// Variable declarations
// function create() { ... }
// function loadFile(path) { ... }
// function saveFile() { ... }
// function createTab(name, content) { ... }
// function refreshTabs() { ... }
// function parseContent() { ... }  -- uses new EReg()
// function refreshCode() { ... }
// function refreshVisual() { ... }
// function refreshMinimap() { ... }
// function refreshStatus() { ... }
// function performFind() { ... }
// function pushUndo() { ... }
// function undo() { ... }
// function redo() { ... }
// function validateSyntax() { ... }
// function formatCode() { ... }
// function update(elapsed) { ... }
```

---

Now generate both complete files. Make them polished, robust, and visually impressive. Every sprite needs proper x/y positioning. Every group needs clear/rebuild refresh functions. Every feature needs proper keyboard handling. This should feel like a real IDE, not a prototype.
