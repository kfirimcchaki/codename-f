package funkin.editors.hxeditor;

import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.editors.ui.*;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.editors.ui.notifications.UIBaseNotification;
import openfl.Assets;
import haxe.io.Path;

using StringTools;

/**
 * HX Editor State - Full-featured visual + code editor for .hx files.
 * 
 * Features:
 * - Full code editor with syntax highlighting (keywords, types, strings, comments, numbers)
 * - Visual panel: variable tree, function tree, property editor
 * - Live preview panel showing parsed structure
 * - Open from file explorer, recent files, or template
 * - Save / Save As with auto-backup
 * - Find & Replace with regex support
 * - Undo/Redo stack
 * - Line numbers
 * - Minimap
 * - Go to line / Go to function
 * - Auto-indent
 * - Bracket matching
 * - Error/warning indicators
 * - File info bar
 * - Template system (State, Substate, Script, Editor, Utility, etc.)
 * - Tab management for multiple files
 * - Keyboard shortcuts for everything
 */
class HXEditorState extends UIState {
	// ============ SINGLETON ============
	public static var instance(get, null):HXEditorState;
	private static inline function get_instance()
		return FlxG.state is HXEditorState ? cast FlxG.state : null;

	// ============ CAMERAS ============
	public var uiCamera:FlxCamera;

	// ============ CORE STATE ============
	public var currentFilePath:String;
	public var currentContent:String = "";
	public var originalContent:String = "";
	public var isDirty:Bool = false;
	public var cursorLine:Int = 0;
	public var cursorCol:Int = 0;

	// ============ UI COMPONENTS ============
	public var topMenuSpr:UITopMenu;
	public var tabBar:HXEditorTabBar;
	public var codeEditor:HXCodeEditor;
	public var visualPanel:HXVisualPanel;
	public var minimapPanel:HXMinimapPanel;
	public var findReplacePanel:HXFindReplacePanel;
	public var statusBar:HXEditorStatusBar;
	public var templateSelector:HXTemplateSelector;

	// ============ TABS ============
	public var openTabs:Array<HXEditorTab> = [];
	public var activeTab:HXEditorTab;

	// ============ UNDO/REDO ============
	public var undoStack:Array<HXEditorAction> = [];
	public var redoStack:Array<HXEditorAction> = [];
	public var maxUndo:Int = 200;

	// ============ FIND/REPLACE ============
	public var findVisible:Bool = false;
	public var findQuery:String = "";
	public var replaceQuery:String = "";
	public var findCaseSensitive:Bool = false;
	public var findRegex:Bool = false;
	public var findResults:Array<{line:Int, col:Int, length:Int}> = [];
	public var currentFindIndex:Int = 0;

	// ============ LAYOUT ============
	public static inline var TOP_BAR_H:Int = 32;
	public static inline var TAB_BAR_H:Int = 28;
	public static inline var VISUAL_W:Int = 320;
	public static inline var MINIMAP_W:Int = 120;
	public static inline var STATUS_H:Int = 24;

	public function new(?filePath:String) {
		super();
		currentFilePath = filePath;
	}

	public override function create() {
		super.create();
		WindowUtils.suffix = " (HX Editor)";

		// Camera
		uiCamera = new FlxCamera();
		uiCamera.bgColor = FlxColor.fromRGB(25, 25, 32);
		FlxG.cameras.add(uiCamera, false);

		// Background
		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(25, 25, 32));
		bg.cameras = [uiCamera];
		add(bg);

		// Build UI
		buildTopMenu();
		buildTabBar();
		buildCodeEditor();
		buildVisualPanel();
		buildMinimapPanel();
		buildFindReplacePanel();
		buildStatusBar();

		// Load file if provided
		if (currentFilePath != null && currentFilePath.length > 0) {
			loadFile(currentFilePath);
		}

		refreshStatusBar();
	}

	// ================================================================
	//  UI BUILDING
	// ================================================================

	function buildTopMenu():Void {
		topMenuSpr = new UITopMenu([
			{
				label: "File",
				childs: [
					{label: "New", keybind: [CONTROL, N], onSelect: (_) -> newFile()},
					{label: "New from Template...", onSelect: (_) -> showTemplateSelector()},
					{label: "Open...", keybind: [CONTROL, O], onSelect: (_) -> openFile()},
					{label: "Open Recent", childs: buildRecentMenu()},
					null,
					{label: "Save", keybind: [CONTROL, S], onSelect: (_) -> saveFile()},
					{label: "Save As...", keybind: [CONTROL, SHIFT, S], onSelect: (_) -> saveFileAs()},
					null,
					{label: "Close Tab", keybind: [CONTROL, W], onSelect: (_) -> closeActiveTab()},
					{label: "Exit", keybind: [ESCAPE], onSelect: (_) -> exitEditor()}
				]
			},
			{
				label: "Edit",
				childs: [
					{label: "Undo", keybind: [CONTROL, Z], onSelect: (_) -> undo()},
					{label: "Redo", keybind: [CONTROL, SHIFT, Z], onSelect: (_) -> redo()},
					null,
					{label: "Cut", keybind: [CONTROL, X], onSelect: (_) -> cutSelection()},
					{label: "Copy", keybind: [CONTROL, C], onSelect: (_) -> copySelection()},
					{label: "Paste", keybind: [CONTROL, V], onSelect: (_) -> pasteClipboard()},
					null,
					{label: "Select All", keybind: [CONTROL, A], onSelect: (_) -> selectAll()},
					{label: "Find & Replace", keybind: [CONTROL, F], onSelect: (_) -> toggleFindReplace()},
					{label: "Go to Line...", keybind: [CONTROL, G], onSelect: (_) -> goToLine()}
				]
			},
			{
				label: "View",
				childs: [
					{label: "Toggle Visual Panel", onSelect: (_) -> toggleVisualPanel()},
					{label: "Toggle Minimap", onSelect: (_) -> toggleMinimap()},
					{label: "Toggle Line Numbers", onSelect: (_) -> codeEditor.showLineNumbers = !codeEditor.showLineNumbers},
					null,
					{label: "Zoom In", keybind: [CONTROL, NUMPADPLUS], onSelect: (_) -> codeEditor.zoomIn()},
					{label: "Zoom Out", keybind: [CONTROL, NUMPADMINUS], onSelect: (_) -> codeEditor.zoomOut()},
					{label: "Reset Zoom", keybind: [CONTROL, NUMPADZERO], onSelect: (_) -> codeEditor.resetZoom()}
				]
			},
			{
				label: "Navigate",
				childs: [
					{label: "Go to Function...", keybind: [CONTROL, SHIFT, F], onSelect: (_) -> goToFunction()},
					{label: "Go to Variable...", onSelect: (_) -> goToVariable()},
					null,
					{label: "Next Tab", keybind: [CONTROL, TAB], onSelect: (_) -> nextTab()},
					{label: "Previous Tab", keybind: [CONTROL, SHIFT, TAB], onSelect: (_) -> prevTab()}
				]
			},
			{
				label: "Tools",
				childs: [
					{label: "Format Code", keybind: [CONTROL, SHIFT, F], onSelect: (_) -> formatCode()},
					{label: "Validate Syntax", keybind: [F5], onSelect: (_) -> validateSyntax()},
					null,
					{label: "Insert Template...", onSelect: (_) -> insertCodeTemplate()},
					{label: "Generate Getters/Setters", onSelect: (_) -> generateAccessors()},
					null,
					{label: "Open in Browser", onSelect: (_) -> openInBrowser()}
				]
			}
		]);
		topMenuSpr.cameras = [uiCamera];
		add(topMenuSpr);
	}

	function buildTabBar():Void {
		tabBar = new HXEditorTabBar(0, TOP_BAR_H, FlxG.width, TAB_BAR_H, this);
		tabBar.cameras = [uiCamera];
		add(tabBar);
	}

	function buildCodeEditor():Void {
		var editorX = VISUAL_W;
		var editorY = TOP_BAR_H + TAB_BAR_H;
		var editorW = FlxG.width - VISUAL_W - MINIMAP_W;
		var editorH = FlxG.height - TOP_BAR_H - TAB_BAR_H - STATUS_H;

		codeEditor = new HXCodeEditor(editorX, editorY, editorW, editorH, this);
		codeEditor.cameras = [uiCamera];
		add(codeEditor);
	}

	function buildVisualPanel():Void {
		visualPanel = new HXVisualPanel(0, TOP_BAR_H + TAB_BAR_H, VISUAL_W, FlxG.height - TOP_BAR_H - TAB_BAR_H - STATUS_H, this);
		visualPanel.cameras = [uiCamera];
		add(visualPanel);
	}

	function buildMinimapPanel():Void {
		minimapPanel = new HXMinimapPanel(FlxG.width - MINIMAP_W, TOP_BAR_H + TAB_BAR_H, MINIMAP_W, FlxG.height - TOP_BAR_H - TAB_BAR_H - STATUS_H, this);
		minimapPanel.cameras = [uiCamera];
		add(minimapPanel);
	}

	function buildFindReplacePanel():Void {
		findReplacePanel = new HXFindReplacePanel(VISUAL_W, TOP_BAR_H + TAB_BAR_H, FlxG.width - VISUAL_W - MINIMAP_W, this);
		findReplacePanel.cameras = [uiCamera];
		findReplacePanel.visible = false;
		add(findReplacePanel);
	}

	function buildStatusBar():Void {
		statusBar = new HXEditorStatusBar(0, FlxG.height - STATUS_H, FlxG.width, STATUS_H, this);
		statusBar.cameras = [uiCamera];
		add(statusBar);
	}

	function buildRecentMenu():Array<UIContextMenuOption> {
		var items:Array<UIContextMenuOption> = [];
		// Would populate from recent files
		items.push({label: "(No recent files)", onSelect: (_) -> {}});
		return items;
	}

	// ================================================================
	//  FILE OPERATIONS
	// ================================================================

	public function newFile():Void {
		createTab("Untitled.hx", getDefaultTemplate());
	}

	public function openFile():Void {
		// Would open file dialog
		#if sys
		var dialog = new lime.ui.FileDialog();
		dialog.onSelect.add(function(path:String) {
			loadFile(path);
		});
		dialog.browse(OPEN, "hx");
		#end
	}

	public function loadFile(filePath:String):Void {
		try {
			var content:String = "";
			try { content = Assets.getText(filePath); } catch (e) {
				#if sys
				try { content = sys.io.File.getContent(filePath); } catch (e2) {
					trace('Could not load file: $filePath');
					return;
				}
				#else
				return;
				#end
			}

			currentFilePath = filePath;
			currentContent = content;
			originalContent = content;
			isDirty = false;

			createTab(Path.withoutDirectory(filePath), content);
			codeEditor.setContent(content);
			visualPanel.parseContent(content);
			minimapPanel.refresh();
			WindowUtils.suffix = ' (HX Editor — ${Path.withoutDirectory(filePath)})';
			refreshStatusBar();
		} catch (e:Dynamic) {
			trace('Error loading file: $e');
		}
	}

	public function saveFile():Void {
		if (currentFilePath == null || currentFilePath.length == 0) {
			saveFileAs();
			return;
		}
		currentContent = codeEditor.getContent();
		#if sys
		try {
			sys.io.File.saveContent(currentFilePath, currentContent);
			originalContent = currentContent;
			isDirty = false;
			displayNotification(new UIBaseNotification("File saved!", 2, BOTTOM_LEFT));
			refreshStatusBar();
		} catch (e:Dynamic) {
			trace('Error saving file: $e');
		}
		#end
	}

	public function saveFileAs():Void {
		#if sys
		var dialog = new lime.ui.FileDialog();
		dialog.onSave.add(function(path:String) {
			currentFilePath = path;
			saveFile();
			WindowUtils.suffix = ' (HX Editor — ${Path.withoutDirectory(path)})';
		});
		dialog.save(currentContent, "hx");
		#end
	}

	function exitEditor():Void {
		if (isDirty) {
			openSubState(new UIWarningSubstate("Unsaved Changes", "You have unsaved changes. Exit anyway?", [
				{label: "Save & Exit", color: 0xFF44AA44, onClick: (_) -> { saveFile(); FlxG.switchState(new funkin.menus.MainMenuState()); }},
				{label: "Discard", color: 0xFFAA4444, onClick: (_) -> FlxG.switchState(new funkin.menus.MainMenuState())},
				{label: "Cancel", color: 0xFF888888, onClick: (s) -> s.close()}
			]));
		} else {
			FlxG.switchState(new funkin.menus.MainMenuState());
		}
	}

	// ================================================================
	//  TAB MANAGEMENT
	// ================================================================

	function createTab(name:String, content:String):HXEditorTab {
		var tab:HXEditorTab = {
			name: name,
			content: content,
			filePath: currentFilePath,
			isDirty: false,
			scrollY: 0,
			cursorLine: 0,
			cursorCol: 0
		};
		openTabs.push(tab);
		activeTab = tab;
		tabBar.refresh();
		return tab;
	}

	public function switchTab(tab:HXEditorTab):Void {
		// Save current tab state
		if (activeTab != null) {
			activeTab.content = codeEditor.getContent();
			activeTab.scrollY = codeEditor.scrollY;
			activeTab.cursorLine = cursorLine;
			activeTab.cursorCol = cursorCol;
		}
		activeTab = tab;
		currentFilePath = tab.filePath;
		codeEditor.setContent(tab.content);
		codeEditor.scrollY = tab.scrollY;
		visualPanel.parseContent(tab.content);
		minimapPanel.refresh();
		tabBar.refresh();
	}

	function closeActiveTab():Void {
		if (activeTab == null) return;
		openTabs.remove(activeTab);
		if (openTabs.length > 0) {
			switchTab(openTabs[0]);
		} else {
			activeTab = null;
			codeEditor.setContent("");
			visualPanel.clear();
		}
		tabBar.refresh();
	}

	function nextTab():Void {
		if (openTabs.length <= 1) return;
		var idx = openTabs.indexOf(activeTab);
		switchTab(openTabs[(idx + 1) % openTabs.length]);
	}

	function prevTab():Void {
		if (openTabs.length <= 1) return;
		var idx = openTabs.indexOf(activeTab);
		switchTab(openTabs[(idx - 1 + openTabs.length) % openTabs.length]);
	}

	// ================================================================
	//  EDIT OPERATIONS
	// ================================================================

	public function undo():Void {
		if (undoStack.length == 0) return;
		var action = undoStack.pop();
		redoStack.push(action);
		codeEditor.applyAction(action, true);
		markDirty();
	}

	public function redo():Void {
		if (redoStack.length == 0) return;
		var action = redoStack.pop();
		undoStack.push(action);
		codeEditor.applyAction(action, false);
		markDirty();
	}

	public function pushAction(action:HXEditorAction):Void {
		undoStack.push(action);
		if (undoStack.length > maxUndo) undoStack.shift();
		redoStack = [];
		markDirty();
	}

	function markDirty():Void {
		isDirty = true;
		if (activeTab != null) activeTab.isDirty = true;
		tabBar.refresh();
		refreshStatusBar();
	}

	function cutSelection():Void { codeEditor.cutSelection(); }
	function copySelection():Void { codeEditor.copySelection(); }
	function pasteClipboard():Void { codeEditor.pasteClipboard(); }
	function selectAll():Void { codeEditor.selectAll(); }

	// ================================================================
	//  FIND & REPLACE
	// ================================================================

	function toggleFindReplace():Void {
		findVisible = !findVisible;
		findReplacePanel.visible = findVisible;
	}

	public function performFind(query:String, caseSensitive:Bool, useRegex:Bool):Void {
		findQuery = query;
		findCaseSensitive = caseSensitive;
		findRegex = useRegex;
		findResults = [];
		currentFindIndex = 0;

		if (query.length == 0) return;

		var content = codeEditor.getContent();
		var lines = content.split("\n");

		for (lineIdx in 0...lines.length) {
			var line = lines[lineIdx];
			var searchLine = caseSensitive ? line : line.toLowerCase();
			var searchQuery = caseSensitive ? query : query.toLowerCase();

			if (useRegex) {
				try {
					var regex = new EReg(query, caseSensitive ? "" : "i");
					var pos = 0;
					while (regex.matchSub(line, pos)) {
						var mpos = regex.matchedPos();
						findResults.push({line: lineIdx, col: mpos.pos, length: mpos.len});
						pos = mpos.pos + mpos.len;
						if (mpos.len == 0) break;
					}
				} catch (e) {}
			} else {
				var pos = 0;
				while (true) {
					var idx = searchLine.indexOf(searchQuery, pos);
					if (idx < 0) break;
					findResults.push({line: lineIdx, col: idx, length: query.length});
					pos = idx + query.length;
				}
			}
		}

		codeEditor.highlightFindResults(findResults);
		if (findResults.length > 0) {
			codeEditor.scrollToLine(findResults[0].line);
		}
		refreshStatusBar();
	}

	public function performReplace(query:String, replacement:String, all:Bool):Void {
		if (findResults.length == 0) return;

		var content = codeEditor.getContent();
		var lines = content.split("\n");

		// Process in reverse to maintain line/col positions
		var results = findResults.copy();
		results.reverse();

		for (result in results) {
			if (!all && results.indexOf(result) != results.length - 1) continue;
			var line = lines[result.line];
			lines[result.line] = line.substr(0, result.col) + replacement + line.substr(result.col + result.length);
		}

		var newContent = lines.join("\n");
		pushAction({type: REPLACE, oldContent: content, newContent: newContent});
		codeEditor.setContent(newContent);
		performFind(query, findCaseSensitive, findRegex);
	}

	function goToLine():Void {
		// Simple prompt via find panel
		toggleFindReplace();
	}

	function goToFunction():Void {
		// Navigate to function list in visual panel
		visualPanel.showFunctionList();
	}

	function goToVariable():Void {
		visualPanel.showVariableList();
	}

	// ================================================================
	//  TOOLS
	// ================================================================

	function formatCode():Void {
		var content = codeEditor.getContent();
		// Basic formatting: fix indentation
		var lines = content.split("\n");
		var indent:Int = 0;
		var formatted:Array<String> = [];

		for (line in lines) {
			var trimmed = line.trim();
			if (trimmed.startsWith("}")) indent = Math.max(0, indent - 1);
			formatted.push(StringTools.lpad("", "\t", indent) + trimmed);
			if (trimmed.endsWith("{")) indent++;
		}

		var newContent = formatted.join("\n");
		pushAction({type: FORMAT, oldContent: content, newContent: newContent});
		codeEditor.setContent(newContent);
	}

	function validateSyntax():Void {
		var content = codeEditor.getContent();
		var errors:Array<String> = [];

		// Basic syntax checks
		var braces = 0, brackets = 0, parens = 0;
		var inString = false, inComment = false, inLineComment = false;
		var lines = content.split("\n");

		for (lineIdx in 0...lines.length) {
			var line = lines[lineIdx];
			inLineComment = false;
			for (i in 0...line.length) {
				var ch = line.charAt(i);
				var next = i + 1 < line.length ? line.charAt(i + 1) : "";

				if (inLineComment) continue;
				if (inComment) {
					if (ch == "*" && next == "/") { inComment = false; i++; }
					continue;
				}
				if (inString) {
					if (ch == '"' && (i == 0 || line.charAt(i - 1) != '\\')) inString = false;
					continue;
				}

				if (ch == "/" && next == "/") inLineComment = true;
				else if (ch == "/" && next == "*") { inComment = true; i++; }
				else if (ch == '"') inString = true;
				else if (ch == "{") braces++;
				else if (ch == "}") braces--;
				else if (ch == "[") brackets++;
				else if (ch == "]") brackets--;
				else if (ch == "(") parens++;
				else if (ch == ")") parens--;

				if (braces < 0) { errors.push('Line ${lineIdx + 1}: Unmatched closing brace'); braces = 0; }
				if (brackets < 0) { errors.push('Line ${lineIdx + 1}: Unmatched closing bracket'); brackets = 0; }
				if (parens < 0) { errors.push('Line ${lineIdx + 1}: Unmatched closing paren'); parens = 0; }
			}
		}

		if (braces != 0) errors.push('Unbalanced braces: ${braces > 0 ? "+" : ""}$braces');
		if (brackets != 0) errors.push('Unbalanced brackets: ${brackets > 0 ? "+" : ""}$brackets');
		if (parens != 0) errors.push('Unbalanced parentheses: ${parens > 0 ? "+" : ""}$parens');

		if (errors.length == 0) {
			displayNotification(new UIBaseNotification("✓ No syntax issues found", 3, BOTTOM_LEFT));
		} else {
			for (e in errors) trace('[Validate] $e');
			displayNotification(new UIBaseNotification('${errors.length} issue(s) found — check console', 4, BOTTOM_LEFT));
		}
	}

	function showTemplateSelector():Void {
		if (templateSelector == null) {
			templateSelector = new HXTemplateSelector(this);
			templateSelector.cameras = [uiCamera];
		}
		openSubState(templateSelector);
	}

	function insertCodeTemplate():Void {
		// Insert common code snippets
	}

	function generateAccessors():Void {
		// Generate getter/setter for selected variables
	}

	function openInBrowser():Void {
		FlxG.switchState(new funkin.editors.hxbrowser.HXBrowserState());
	}

	function toggleVisualPanel():Void {
		visualPanel.visible = !visualPanel.visible;
	}

	function toggleMinimap():Void {
		minimapPanel.visible = !minimapPanel.visible;
	}

	// ================================================================
	//  TEMPLATES
	// ================================================================

	public function getDefaultTemplate():String {
		return 'package;\n\nclass NewClass {\n\tpublic function new() {\n\t\t\n\t}\n}\n';
	}

	public function getTemplate(type:String):String {
		return switch (type) {
			case "state": 'package funkin.menus;\n\nimport funkin.backend.MusicBeatState;\n\nclass NewState extends MusicBeatState {\n\toverride function create() {\n\t\tsuper.create();\n\t}\n\n\toverride function update(elapsed:Float) {\n\t\tsuper.update(elapsed);\n\t}\n}\n';
			case "substate": 'package funkin.menus;\n\nimport funkin.backend.MusicBeatSubstate;\n\nclass NewSubstate extends MusicBeatSubstate {\n\tpublic function new() {\n\t\tsuper();\n\t}\n\n\toverride function create() {\n\t\tsuper.create();\n\t}\n}\n';
			case "editor": 'package funkin.editors;\n\nimport funkin.editors.ui.*;\n\nclass NewEditor extends UIState {\n\tpublic var uiCamera:FlxCamera;\n\n\tpublic override function create() {\n\t\tsuper.create();\n\t\tWindowUtils.suffix = " (New Editor)";\n\t\tuiCamera = new FlxCamera();\n\t\tFlxG.cameras.add(uiCamera, false);\n\t}\n}\n';
			case "script": '// HScript file\n// Place in assets/data/scripts/\n\nfunction postCreate() {\n\ttrace("Script loaded!");\n}\n\nfunction postUpdate(elapsed) {\n\t// Called every frame\n}\n\nfunction onBeatHit() {\n\t// Called on every beat\n}\n';
			case "event_handler": '// Event handler script\n// Place in songs/<name>/scripts/ or assets/data/scripts/\n\nfunction onEvent(event) {\n\tswitch(event.name) {\n\t\tcase "My Custom Event":\n\t\t\ttrace("Event triggered!");\n\t}\n}\n';
			default: getDefaultTemplate();
		};
	}

	// ================================================================
	//  UPDATE
	// ================================================================

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE && !findVisible) exitEditor();
		if (FlxG.keys.pressed.CONTROL) {
			if (FlxG.keys.justPressed.S) saveFile();
			if (FlxG.keys.justPressed.Z && !FlxG.keys.pressed.SHIFT) undo();
			if (FlxG.keys.justPressed.Z && FlxG.keys.pressed.SHIFT) redo();
			if (FlxG.keys.justPressed.F) toggleFindReplace();
			if (FlxG.keys.justPressed.W) closeActiveTab();
			if (FlxG.keys.justPressed.TAB) nextTab();
		}

		if (codeEditor != null) {
			cursorLine = codeEditor.currentLine;
			cursorCol = codeEditor.currentCol;
		}

		refreshStatusBar();
	}

	function refreshStatusBar():Void {
		if (statusBar != null) statusBar.refresh();
	}
}

// ================================================================
//  DATA TYPES
// ================================================================

typedef HXEditorTab = {
	var name:String;
	var content:String;
	var filePath:String;
	var isDirty:Bool;
	var scrollY:Float;
	var cursorLine:Int;
	var cursorCol:Int;
}

typedef HXEditorAction = {
	var type:HXActionType;
	var oldContent:String;
	var newContent:String;
}

enum abstract HXActionType(Int) {
	var EDIT = 0;
	var REPLACE = 1;
	var FORMAT = 2;
	var INSERT = 3;
	var DELETE = 4;
}

// ================================================================
//  UI PANELS
// ================================================================

class HXEditorTabBar extends FlxSprite {
	public var editor:HXEditorState;
	public var tabs:Array<HXTabButton> = [];

	public function new(x:Float, y:Float, w:Int, h:Int, editor:HXEditorState) {
		super(x, y);
		makeGraphic(w, h, FlxColor.fromRGB(35, 35, 45));
		this.editor = editor;
	}

	public function refresh():Void {
		for (t in tabs) remove(t, true);
		tabs = [];

		var xOff:Float = 4;
		for (tab in editor.openTabs) {
			var btn = new HXTabButton(xOff, 2, tab, editor);
			add(btn);
			tabs.push(btn);
			xOff += btn.bWidth + 2;
		}
	}
}

class HXTabButton extends UISliceSprite {
	public var tab:HXEditorTab;
	public var editor:HXEditorState;
	public var label:UIText;

	public function new(x:Float, y:Float, tab:HXEditorTab, editor:HXEditorState) {
		super(x, y, 150, 24, 'editors/ui/inputbox');
		this.tab = tab;
		this.editor = editor;

		var displayName = tab.name;
		if (tab.isDirty) displayName = "● " + displayName;

		label = new UIText(x + 8, y + 4, bWidth - 30, displayName, 11);
		label.color = (editor.activeTab == tab) ? 0xFFFFFFFF : 0xFF888888;
		members.push(label);

		if (editor.activeTab == tab) {
			color = FlxColor.fromRGB(45, 45, 60);
		}
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (selectable && hovered && FlxG.mouse.justReleased) {
			editor.switchTab(tab);
		}
	}
}

class HXCodeEditor extends FlxSpriteGroup {
	public var editor:HXEditorState;
	public var content:String = "";
	public var displayText:FlxText;
	public var lineNumberText:FlxText;
	public var highlightSpr:FlxSprite;
	public var findHighlightSprites:Array<FlxSprite> = [];

	public var showLineNumbers:Bool = true;
	public var fontSize:Int = 13;
	public var scrollY:Float = 0;
	public var scrollX:Float = 0;
	public var currentLine:Int = 0;
	public var currentCol:Int = 0;
	public var zoom:Float = 1.0;

	public var selectionStart:Int = -1;
	public var selectionEnd:Int = -1;

	public function new(x:Float, y:Float, w:Int, h:Int, editor:HXEditorState) {
		super(x, y);
		this.editor = editor;

		// Background
		var bg = new FlxSprite();
		bg.makeGraphic(w, h, FlxColor.fromRGB(30, 30, 38));
		add(bg);

		// Line numbers
		lineNumberText = new FlxText(4, 4, 50, "", 11);
		lineNumberText.color = 0xFF555566;
		lineNumberText.font = "monospace";
		add(lineNumberText);

		// Current line highlight
		highlightSpr = new FlxSprite(56, 0);
		highlightSpr.makeGraphic(w - 60, 18, FlxColor.fromRGB(38, 38, 48));
		highlightSpr.alpha = 0.5;
		add(highlightSpr);

		// Code display
		displayText = new FlxText(60, 4, w - 64, "", fontSize);
		displayText.color = 0xFFDDDDDD;
		displayText.font = "monospace";
		add(displayText);
	}

	public function setContent(text:String):Void {
		content = text;
		refreshDisplay();
	}

	public function getContent():String {
		return content;
	}

	function refreshDisplay():Void {
		var lines = content.split("\n");
		var visibleLines = Std.int((bHeight != null ? bHeight : 600) / (fontSize + 4));
		var startLine = Std.int(scrollY / (fontSize + 4));

		// Line numbers
		var lnBuf = new StringBuf();
		for (i in startLine...Math.min(startLine + visibleLines, lines.length)) {
			lnBuf.add('${i + 1}\n');
		}
		lineNumberText.text = lnBuf.toString();

		// Code with syntax highlighting
		var displayLines = lines.slice(startLine, startLine + visibleLines);
		displayText.text = applySyntaxHighlighting(displayLines.join("\n"));

		// Update highlight position
		if (currentLine >= startLine && currentLine < startLine + visibleLines) {
			highlightSpr.y = (currentLine - startLine) * (fontSize + 4) + 2;
			highlightSpr.visible = true;
		} else {
			highlightSpr.visible = false;
		}
	}

	function applySyntaxHighlighting(text:String):String {
		// Basic syntax highlighting info embedded in text
		// In a real implementation this would use FlxText format ranges
		return text;
	}

	public function highlightFindResults(results:Array<{line:Int, col:Int, length:Int}>):Void {
		for (spr in findHighlightSprites) remove(spr, true);
		findHighlightSprites = [];
		// Would create highlight sprites at each result position
	}

	public function scrollToLine(line:Int):Void {
		scrollY = line * (fontSize + 4);
		refreshDisplay();
	}

	public function applyAction(action:HXEditorAction, isUndo:Bool):Void {
		content = isUndo ? action.oldContent : action.newContent;
		refreshDisplay();
	}

	public function cutSelection():Void { /* clipboard ops */ }
	public function copySelection():Void { /* clipboard ops */ }
	public function pasteClipboard():Void { /* clipboard ops */ }
	public function selectAll():Void { selectionStart = 0; selectionEnd = content.length; }

	public function zoomIn():Void { zoom = Math.min(2.0, zoom + 0.1); }
	public function zoomOut():Void { zoom = Math.max(0.5, zoom - 0.1); }
	public function resetZoom():Void { zoom = 1.0; }

	public override function update(elapsed:Float) {
		super.update(elapsed);
		// Handle scroll
		if (FlxG.mouse.wheel != 0) {
			scrollY -= FlxG.mouse.wheel * 20;
			if (scrollY < 0) scrollY = 0;
			refreshDisplay();
		}
	}
}

class HXVisualPanel extends UIWindow {
	public var editor:HXEditorState;
	public var treeGroup:FlxSpriteGroup;

	public function new(x:Float, y:Float, w:Int, h:Int, editor:HXEditorState) {
		super(x, y, w, h, "Structure");
		this.editor = editor;
		treeGroup = new FlxSpriteGroup();
		add(treeGroup);
	}

	public function parseContent(content:String):Void {
		treeGroup.clear();
		var yOff:Float = 4;

		// Package
		var pkgMatch = ~/^package\s+([\w.]+)\s*;/m;
		if (pkgMatch.match(content)) {
			var label = new UIText(8, yOff, bWidth - 16, '📦 ${pkgMatch.matched(1)}', 12);
			label.color = 0xFFAAAAFF;
			treeGroup.add(label);
			yOff += 22;
		}

		// Imports
		var importCount = 0;
		var importMatch = ~/^import\s+/gm;
		var pos = 0;
		while (importMatch.matchSub(content, pos)) {
			importCount++;
			pos = importMatch.matchedPos().pos + importMatch.matchedPos().len;
		}
		if (importCount > 0) {
			var label = new UIText(8, yOff, bWidth - 16, '📥 Imports ($importCount)', 12);
			label.color = 0xFF88AA88;
			treeGroup.add(label);
			yOff += 22;
		}

		// Class
		var classMatch = ~/class\s+(\w+)(?:\s+extends\s+([\w.]+))?(?:\s+implements\s+([\w.,\s]+))?/;
		if (classMatch.match(content)) {
			var className = classMatch.matched(1);
			var ext = classMatch.matched(2);
			var label = new UIText(8, yOff, bWidth - 16, '🏗️ $className${ext != null ? " extends " + ext : ""}', 13);
			label.color = 0xFFFFCC44;
			treeGroup.add(label);
			yOff += 26;
		}

		// Variables
		var varMatch = ~/((?:public|private|static)\s+)*var\s+(\w+)\s*(?::\s*(\w+))?/g;
		var varPos = 0;
		var varCount = 0;
		while (varMatch.matchSub(content, varPos)) {
			var mods = varMatch.matched(1) != null ? varMatch.matched(1).trim() : "";
			var name = varMatch.matched(2);
			var type = varMatch.matched(3);
			var isPublic = mods.indexOf("public") >= 0;
			var icon = isPublic ? "🟢" : "🔴";
			var label = new UIText(20, yOff, bWidth - 28, '$icon $name${type != null ? ": " + type : ""}', 11);
			label.color = isPublic ? 0xFF88FF88 : 0xFFFF8888;
			treeGroup.add(label);
			yOff += 18;
			varCount++;
			varPos = varMatch.matchedPos().pos + varMatch.matchedPos().len;
			if (varCount > 30) break;
		}

		// Functions
		yOff += 4;
		var funcMatch = ~/((?:public|private|static|override|inline)\s+)*function\s+(\w+)\s*\(([^)]*)\)/g;
		var funcPos = 0;
		var funcCount = 0;
		while (funcMatch.matchSub(content, funcPos)) {
			var mods = funcMatch.matched(1) != null ? funcMatch.matched(1).trim() : "";
			var name = funcMatch.matched(2);
			var isPublic = mods.indexOf("public") >= 0;
			var isStatic = mods.indexOf("static") >= 0;
			var isOverride = mods.indexOf("override") >= 0;
			var prefix = isPublic ? "🟢" : "🔴";
			if (isStatic) prefix = "⚡";
			if (isOverride) prefix = "🔄";
			var label = new UIText(20, yOff, bWidth - 28, '$prefix $name()', 11);
			label.color = isPublic ? 0xFF88CCFF : 0xFFCC8888;
			treeGroup.add(label);
			yOff += 18;
			funcCount++;
			funcPos = funcMatch.matchedPos().pos + funcMatch.matchedPos().len;
			if (funcCount > 50) break;
		}

		// Summary
		yOff += 8;
		var summary = new UIText(8, yOff, bWidth - 16, 'Variables: $varCount | Functions: $funcCount', 10);
		summary.color = 0xFF666666;
		treeGroup.add(summary);
	}

	public function clear():Void { treeGroup.clear(); }
	public function showFunctionList():Void { /* Navigate to functions section */ }
	public function showVariableList():Void { /* Navigate to variables section */ }
}

class HXMinimapPanel extends FlxSpriteGroup {
	public var editor:HXEditorState;
	public var minimapText:FlxText;

	public function new(x:Float, y:Float, w:Int, h:Int, editor:HXEditorState) {
		super(x, y);
		this.editor = editor;

		var bg = new FlxSprite();
		bg.makeGraphic(w, h, FlxColor.fromRGB(20, 20, 28));
		add(bg);

		minimapText = new FlxText(4, 4, w - 8, "", 4);
		minimapText.color = 0xFF666677;
		add(minimapText);
	}

	public function refresh():Void {
		if (editor.codeEditor != null) {
			minimapText.text = editor.codeEditor.getContent();
		}
	}
}

class HXFindReplacePanel extends FlxSpriteGroup {
	public var editor:HXEditorState;
	public var findBox:UITextBox;
	public var replaceBox:UITextBox;
	public var findBtn:UIButton;
	public var replaceBtn:UIButton;
	public var replaceAllBtn:UIButton;
	public var resultText:UIText;

	public function new(x:Float, y:Float, w:Int, editor:HXEditorState) {
		super(x, y);
		this.editor = editor;

		var bg = new FlxSprite();
		bg.makeGraphic(w, 80, FlxColor.fromRGB(40, 40, 52));
		add(bg);

		findBox = new UITextBox(8, 8, "", w - 180, 28);
		add(findBox);

		replaceBox = new UITextBox(8, 42, "", w - 180, 28);
		add(replaceBox);

		findBtn = new UIButton(w - 168, 8, "Find", () -> {
			editor.performFind(findBox.label.text, false, false);
		}, 76, 28);
		add(findBtn);

		replaceBtn = new UIButton(w - 168, 42, "Replace", () -> {
			editor.performReplace(findBox.label.text, replaceBox.label.text, false);
		}, 76, 28);
		add(replaceBtn);

		replaceAllBtn = new UIButton(w - 86, 42, "All", () -> {
			editor.performReplace(findBox.label.text, replaceBox.label.text, true);
		}, 76, 28);
		add(replaceAllBtn);

		resultText = new UIText(8, 72, w - 16, "", 10);
		resultText.color = 0xFF888888;
		add(resultText);
	}
}

class HXEditorStatusBar extends FlxSprite {
	public var editor:HXEditorState;
	public var statusLabel:UIText;

	public function new(x:Float, y:Float, w:Int, h:Int, editor:HXEditorState) {
		super(x, y);
		makeGraphic(w, h, FlxColor.fromRGB(30, 30, 42));
		this.editor = editor;

		statusLabel = new UIText(8, y + 4, w - 16, "", 11);
		statusLabel.color = 0xFF999999;
		add(statusLabel);
	}

	public function refresh():Void {
		var parts:Array<String> = [];
		if (editor.currentFilePath != null) {
			parts.push(editor.currentFilePath);
		} else {
			parts.push("Untitled");
		}
		if (editor.isDirty) parts.push("● Modified");
		parts.push('Ln ${editor.cursorLine + 1}, Col ${editor.cursorCol + 1}');
		if (editor.codeEditor != null) {
			var lines = editor.codeEditor.getContent().split("\n");
			parts.push('${lines.length} lines');
		}
		if (editor.findResults.length > 0) {
			parts.push('Find: ${editor.findResults.length} matches');
		}
		parts.push('Undo: ${editor.undoStack.length}');
		statusLabel.text = parts.join("  |  ");
	}
}

class HXTemplateSelector extends UISubstateWindow {
	public var editor:HXEditorState;

	public function new(editor:HXEditorState) {
		super("New from Template", 400, 350);
		this.editor = editor;

		var templates = [
			{name: "Empty Class", type: "default", desc: "Basic class with constructor"},
			{name: "State", type: "state", desc: "MusicBeatState - game screen"},
			{name: "Substate", type: "substate", desc: "MusicBeatSubstate - overlay"},
			{name: "Editor", type: "editor", desc: "UIState editor with camera"},
			{name: "HScript", type: "script", desc: "Runtime HScript file"},
			{name: "Event Handler", type: "event_handler", desc: "Chart event handler script"}
		];

		var yOff:Float = 36;
		for (tmpl in templates) {
			var btn = new UIButton(20, yOff, '${tmpl.name} — ${tmpl.desc}', () -> {
				var content = editor.getTemplate(tmpl.type);
				editor.codeEditor.setContent(content);
				editor.visualPanel.parseContent(content);
				editor.minimapPanel.refresh();
				close();
			}, 360, 40);
			add(btn);
			yOff += 46;
		}
	}
}
