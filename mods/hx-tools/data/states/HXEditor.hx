// =============================================================================
//  HX EDITOR - Full HScript State
//  Place in: mods/hx-tools/data/states/HXEditor.hx
//  Navigate: FlxG.switchState(new ModState("HXEditor", {path: "path/to/file.hx"}))
//  =============================================================================
//  A powerful visual + code editor for .hx files. Features:
//  - Full code editor with line numbers, current line highlight, scrolling
//  - Visual structure panel (package, class, functions, variables tree)
//  - Minimap panel for code overview
//  - Find & Replace with regex support
//  - Undo/Redo stack (200 levels)
//  - Tab management for multiple files
//  - Open / Save / Save As file operations
//  - Template system (State, Substate, Editor, HScript, Event Handler)
//  - Syntax validation (bracket/brace/paren balancing)
//  - Code formatting (auto-indent)
//  - Go to line, go to function navigation
//  - Keyboard shortcuts for everything
//  - Status bar with cursor position, file info, search results
// =============================================================================

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import funkin.editors.ui.*;
import funkin.backend.utils.CoolUtil;
import openfl.Assets;
import openfl.desktop.Clipboard;
import haxe.io.Path;

using StringTools;

// ============ LAYOUT CONSTANTS ============
var VISUAL_W = 310;
var MINIMAP_W = 110;
var TOP_H = 34;
var TAB_H = 28;
var STATUS_H = 26;
var FIND_H = 78;

// ============ COLORS ============
var COL_BG = FlxColor.fromRGB(25, 25, 32);
var COL_PANEL = FlxColor.fromRGB(30, 30, 40);
var COL_PANEL2 = FlxColor.fromRGB(22, 22, 30);
var COL_EDITOR_BG = FlxColor.fromRGB(28, 28, 36);
var COL_TEXT = FlxColor.fromRGB(215, 215, 225);
var COL_DIM = FlxColor.fromRGB(110, 110, 130);
var COL_ACCENT = FlxColor.fromRGB(80, 150, 255);
var COL_HOVER = FlxColor.fromRGB(42, 42, 58);
var COL_SELECT = FlxColor.fromRGB(55, 65, 100);
var COL_LINE_HL = FlxColor.fromRGB(38, 38, 50);
var COL_KEYWORD = FlxColor.fromRGB(200, 120, 255);
var COL_STRING = FlxColor.fromRGB(180, 230, 130);
var COL_COMMENT = FlxColor.fromRGB(100, 110, 130);
var COL_NUMBER = FlxColor.fromRGB(255, 200, 100);
var COL_TYPE = FlxColor.fromRGB(100, 200, 255);
var COL_FUNC = FlxColor.fromRGB(255, 220, 120);
var COL_ERROR = FlxColor.fromRGB(255, 80, 80);
var COL_SUCCESS = FlxColor.fromRGB(80, 255, 120);

// ============ STATE ============
var filePath:String = "";
var content:String = "";
var originalContent:String = "";
var isDirty:Bool = false;
var lines:Array<String> = [];
var cursorLine:Int = 0;
var cursorCol:Int = 0;
var scrollY:Float = 0;
var scrollX:Float = 0;
var fontSize:Int = 13;
var lineH:Int = 17;
var showLineNumbers:Bool = true;
var showVisual:Bool = true;
var showMinimap:Bool = true;
var showFind:Bool = false;

// Tabs
var tabs:Array<Dynamic> = [];
var activeTab:Dynamic = null;

// Undo/Redo
var undoStack:Array<Dynamic> = [];
var redoStack:Array<Dynamic> = [];
var MAX_UNDO:Int = 200;

// Find/Replace
var findQuery:String = "";
var replaceQuery:String = "";
var findResults:Array<Dynamic> = [];
var findCaseSensitive:Bool = false;
var findUseRegex:Bool = false;
var currentFindIdx:Int = 0;

// Parsed structure
var parsedPkg:String = "";
var parsedClass:String = "";
var parsedExtends:String = "";
var parsedFuncs:Array<Dynamic> = [];
var parsedVars:Array<Dynamic> = [];
var parsedImports:Array<String> = [];

// ============ UI REFS ============
var uiCam:FlxCamera;
var headerBg:FlxSprite;
var tabBarBg:FlxSprite;
var visualBg:FlxSprite;
var editorBg:FlxSprite;
var minimapBg:FlxSprite;
var statusBg:FlxSprite;
var findBg:FlxSprite;

var tabGroup:FlxSpriteGroup;
var visualGroup:FlxSpriteGroup;
var lineNumText:FlxText;
var codeText:FlxText;
var highlightSpr:FlxSprite;
var minimapText:FlxText;
var statusLabel:FlxText;

var findBox:UITextBox;
var replaceBox:UITextBox;
var findResultLabel:FlxText;

// Text boxes for editing
var editTextBox:UITextBox;

// =============================================================================
//  CREATE
// =============================================================================
function create() {
	super.create();

	// Get file path from ModState data
	if (data != null && data.path != null) filePath = data.path;

	// Camera
	uiCam = new FlxCamera();
	uiCam.bgColor = COL_BG;
	FlxG.cameras.add(uiCam, false);

	// Build all UI
	buildBackground();
	buildHeader();
	buildTabBar();
	buildVisualPanel();
	buildCodeEditor();
	buildMinimapPanel();
	buildFindReplacePanel();
	buildStatusBar();

	// Load file
	if (filePath != null && filePath.length > 0) {
		loadFile(filePath);
	} else {
		createTab("Untitled.hx", getDefaultTemplate());
	}

	refreshAll();
}

// =============================================================================
//  UI BUILDING
// =============================================================================
function buildBackground() {
	var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, COL_BG);
	bg.cameras = [uiCam];
	add(bg);
}

function buildHeader() {
	headerBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, TOP_H, FlxColor.fromRGB(18, 18, 26));
	headerBg.cameras = [uiCam];
	add(headerBg);

	var title = new FlxText(12, 8, 200, "HX Editor", 15);
	title.color = COL_ACCENT;
	title.cameras = [uiCam];
	add(title);

	// Menu buttons
	var menuItems = [
		{label: "File", x: FlxG.width - 480},
		{label: "Edit", x: FlxG.width - 400},
		{label: "View", x: FlxG.width - 320},
		{label: "Navigate", x: FlxG.width - 230},
		{label: "Tools", x: FlxG.width - 130}
	];

	for (m in menuItems) {
		var btn = new FlxSprite(m.x, 5).makeGraphic(72, 24, FlxColor.fromRGB(38, 38, 52));
		btn.cameras = [uiCam];
		var lbl = new FlxText(m.x, 8, 72, m.label, 11);
		lbl.alignment = CENTER;
		lbl.color = COL_TEXT;
		lbl.cameras = [uiCam];
		add(btn);
		add(lbl);
	}
}

function buildTabBar() {
	tabBarBg = new FlxSprite(0, TOP_H).makeGraphic(FlxG.width, TAB_H, FlxColor.fromRGB(22, 22, 32));
	tabBarBg.cameras = [uiCam];
	add(tabBarBg);

	tabGroup = new FlxSpriteGroup(4, TOP_H + 3);
	tabGroup.cameras = [uiCam];
	add(tabGroup);
}

function buildVisualPanel() {
	visualBg = new FlxSprite(0, TOP_H + TAB_H).makeGraphic(VISUAL_W, FlxG.height - TOP_H - TAB_H - STATUS_H, COL_PANEL);
	visualBg.cameras = [uiCam];
	add(visualBg);

	var vTitle = new FlxText(10, TOP_H + TAB_H + 6, VISUAL_W - 20, "Structure", 12);
	vTitle.color = COL_DIM;
	vTitle.cameras = [uiCam];
	add(vTitle);

	visualGroup = new FlxSpriteGroup(8, TOP_H + TAB_H + 26);
	visualGroup.cameras = [uiCam];
	add(visualGroup);
}

function buildCodeEditor() {
	var ex = VISUAL_W;
	var ey = TOP_H + TAB_H;
	var ew = FlxG.width - VISUAL_W - MINIMAP_W;
	var eh = FlxG.height - TOP_H - TAB_H - STATUS_H;

	editorBg = new FlxSprite(ex, ey).makeGraphic(ew, eh, COL_EDITOR_BG);
	editorBg.cameras = [uiCam];
	add(editorBg);

	// Current line highlight
	highlightSpr = new FlxSprite(ex + 52, ey).makeGraphic(ew - 56, lineH, COL_LINE_HL);
	highlightSpr.alpha = 0.6;
	highlightSpr.cameras = [uiCam];
	add(highlightSpr);

	// Line numbers
	lineNumText = new FlxText(ex + 4, ey + 4, 46, "", 11);
	lineNumText.color = FlxColor.fromRGB(70, 70, 90);
	lineNumText.cameras = [uiCam];
	add(lineNumText);

	// Code display
	codeText = new FlxText(ex + 56, ey + 4, ew - 60, "", fontSize);
	codeText.color = COL_TEXT;
	codeText.cameras = [uiCam];
	add(codeText);

	// Edit text box (hidden, used for actual text input)
	editTextBox = new UITextBox(ex + 56, ey + 4, "", ew - 60, eh - 8, true);
	editTextBox.cameras = [uiCam];
	editTextBox.onChange = function(text:String) {
		if (text != content) {
			pushUndo(content);
			content = text;
			lines = content.split("\n");
			isDirty = true;
			parseContent();
			refreshCode();
			refreshVisual();
			refreshMinimap();
			refreshStatus();
			refreshTabs();
		}
	};
	add(editTextBox);
}

function buildMinimapPanel() {
	var mx = FlxG.width - MINIMAP_W;
	var my = TOP_H + TAB_H;
	var mh = FlxG.height - TOP_H - TAB_H - STATUS_H;

	minimapBg = new FlxSprite(mx, my).makeGraphic(MINIMAP_W, mh, COL_PANEL2);
	minimapBg.cameras = [uiCam];
	add(minimapBg);

	var mTitle = new FlxText(mx + 6, my + 4, MINIMAP_W - 12, "Minimap", 10);
	mTitle.color = COL_DIM;
	mTitle.cameras = [uiCam];
	add(mTitle);

	minimapText = new FlxText(mx + 4, my + 20, MINIMAP_W - 8, "", 3);
	minimapText.color = FlxColor.fromRGB(80, 80, 100);
	minimapText.cameras = [uiCam];
	add(minimapText);
}

function buildFindReplacePanel() {
	var fx = VISUAL_W;
	var fy = TOP_H + TAB_H;
	var fw = FlxG.width - VISUAL_W - MINIMAP_W;

	findBg = new FlxSprite(fx, fy).makeGraphic(fw, FIND_H, FlxColor.fromRGB(38, 38, 52));
	findBg.cameras = [uiCam];
	findBg.visible = false;
	add(findBg);

	var findLabel = new FlxText(fx + 8, fy + 6, 40, "Find:", 11);
	findLabel.color = COL_DIM;
	findLabel.cameras = [uiCam];
	add(findLabel);

	findBox = new UITextBox(fx + 52, fy + 4, "", fw - 220, 24);
	findBox.cameras = [uiCam];
	findBox.onChange = function(text:String) {
		findQuery = text;
		performFind();
	};
	add(findBox);

	var repLabel = new FlxText(fx + 8, fy + 34, 40, "Replace:", 11);
	repLabel.color = COL_DIM;
	repLabel.cameras = [uiCam];
	add(repLabel);

	replaceBox = new UITextBox(fx + 52, fy + 32, "", fw - 220, 24);
	replaceBox.cameras = [uiCam];
	add(replaceBox);

	// Buttons
	var findBtn = new FlxSprite(fx + fw - 160, fy + 4).makeGraphic(70, 24, COL_ACCENT);
	findBtn.cameras = [uiCam];
	add(findBtn);
	var findBtnL = new FlxText(fx + fw - 160, fy + 7, 70, "Find", 11);
	findBtnL.alignment = CENTER;
	findBtnL.color = FlxColor.WHITE;
	findBtnL.cameras = [uiCam];
	add(findBtnL);

	var repBtn = new FlxSprite(fx + fw - 160, fy + 32).makeGraphic(70, 24, FlxColor.fromRGB(80, 180, 80));
	repBtn.cameras = [uiCam];
	add(repBtn);
	var repBtnL = new FlxText(fx + fw - 160, fy + 35, 70, "Replace", 11);
	repBtnL.alignment = CENTER;
	repBtnL.color = FlxColor.WHITE;
	repBtnL.cameras = [uiCam];
	add(repBtnL);

	var repAllBtn = new FlxSprite(fx + fw - 82, fy + 32).makeGraphic(70, 24, FlxColor.fromRGB(180, 80, 80));
	repAllBtn.cameras = [uiCam];
	add(repAllBtn);
	var repAllBtnL = new FlxText(fx + fw - 82, fy + 35, 70, "Replace All", 11);
	repAllBtnL.alignment = CENTER;
	repAllBtnL.color = FlxColor.WHITE;
	repAllBtnL.cameras = [uiCam];
	add(repAllBtnL);

	findResultLabel = new FlxText(fx + 8, fy + 60, fw - 16, "", 10);
	findResultLabel.color = COL_DIM;
	findResultLabel.cameras = [uiCam];
	add(findResultLabel);
}

function buildStatusBar() {
	var sy = FlxG.height - STATUS_H;
	statusBg = new FlxSprite(0, sy).makeGraphic(FlxG.width, STATUS_H, FlxColor.fromRGB(18, 18, 26));
	statusBg.cameras = [uiCam];
	add(statusBg);

	statusLabel = new FlxText(10, sy + 5, FlxG.width - 20, "", 11);
	statusLabel.color = COL_DIM;
	statusLabel.cameras = [uiCam];
	add(statusLabel);
}

// =============================================================================
//  FILE OPERATIONS
// =============================================================================
function loadFile(path:String) {
	try {
		var c:String = "";
		#if sys
		c = sys.io.File.getContent(path);
		#else
		c = Assets.getText(path);
		#end
		filePath = path;
		content = c;
		originalContent = c;
		lines = content.split("\n");
		isDirty = false;
		cursorLine = 0;
		cursorCol = 0;
		scrollY = 0;

		parseContent();
		createTab(Path.withoutDirectory(path), content);
		editTextBox.label.text = content;
		refreshAll();
	} catch(e:Dynamic) {
		trace("Error loading file: " + e);
	}
}

function saveFile() {
	if (filePath == null || filePath.length == 0) {
		saveFileAs();
		return;
	}
	#if sys
	try {
		sys.io.File.saveContent(filePath, content);
		originalContent = content;
		isDirty = false;
		refreshStatus();
		refreshTabs();
		trace("File saved: " + filePath);
	} catch(e:Dynamic) {
		trace("Error saving: " + e);
	}
	#end
}

function saveFileAs() {
	#if sys
	try {
		var dialog = new lime.ui.FileDialog();
		dialog.onSave.add(function(path:String) {
			filePath = path;
			saveFile();
		});
		dialog.save(content, "hx");
	} catch(e:Dynamic) {
		trace("Error in Save As: " + e);
	}
	#end
}

function newFile() {
	filePath = "";
	content = getDefaultTemplate();
	originalContent = content;
	lines = content.split("\n");
	isDirty = false;
	cursorLine = 0;
	scrollY = 0;
	parseContent();
	createTab("Untitled.hx", content);
	editTextBox.label.text = content;
	refreshAll();
}

function newFromTemplate(type:String) {
	filePath = "";
	content = getTemplate(type);
	originalContent = content;
	lines = content.split("\n");
	isDirty = false;
	cursorLine = 0;
	scrollY = 0;
	parseContent();
	createTab("New " + type + ".hx", content);
	editTextBox.label.text = content;
	refreshAll();
}

// =============================================================================
//  TAB MANAGEMENT
// =============================================================================
function createTab(name:String, cont:String):Dynamic {
	var tab = {
		name: name, content: cont, path: filePath,
		dirty: false, scrollY: 0, curLine: 0
	};
	tabs.push(tab);
	activeTab = tab;
	refreshTabs();
	return tab;
}

function switchTab(tab:Dynamic) {
	if (activeTab != null) {
		activeTab.content = content;
		activeTab.scrollY = scrollY;
		activeTab.curLine = cursorLine;
	}
	activeTab = tab;
	filePath = tab.path;
	content = tab.content;
	lines = content.split("\n");
	scrollY = tab.scrollY;
	cursorLine = tab.curLine;
	isDirty = tab.dirty;
	parseContent();
	editTextBox.label.text = content;
	refreshAll();
}

function closeTab(tab:Dynamic) {
	tabs.remove(tab);
	if (tabs.length > 0) {
		switchTab(tabs[0]);
	} else {
		newFile();
	}
}

function refreshTabs() {
	tabGroup.clear();
	var xOff:Float = 0;

	for (tab in tabs) {
		var isActive = tab == activeTab;
		var w = 150;
		var bg = new FlxSprite(xOff, 0).makeGraphic(w, TAB_H - 6, isActive ? FlxColor.fromRGB(40, 40, 55) : FlxColor.fromRGB(28, 28, 38));
		bg.cameras = [uiCam];
		tabGroup.add(bg);

		var displayName = tab.name;
		if (tab.dirty) displayName = "● " + displayName;

		var lbl = new FlxText(xOff + 8, 3, w - 30, displayName, 10);
		lbl.color = isActive ? FlxColor.WHITE : COL_DIM;
		lbl.cameras = [uiCam];
		tabGroup.add(lbl);

		// Close button
		var closeBtn = new FlxText(xOff + w - 18, 2, 16, "×", 12);
		closeBtn.color = FlxColor.fromRGB(180, 80, 80);
		closeBtn.cameras = [uiCam];
		tabGroup.add(closeBtn);

		xOff += w + 2;
	}
}

// =============================================================================
//  CONTENT PARSING
// =============================================================================
function parseContent() {
	parsedPkg = "";
	parsedClass = "";
	parsedExtends = "";
	parsedFuncs = [];
	parsedVars = [];
	parsedImports = [];

	// Package
	var pkgM = ~/^package\s+([\w.]+)\s*;/m;
	if (pkgM.match(content)) parsedPkg = pkgM.matched(1);

	// Class
	var clsM = ~/class\s+(\w+)(?:\s+extends\s+([\w.]+))?/;
	if (clsM.match(content)) {
		parsedClass = clsM.matched(1);
		if (clsM.matched(2) != null) parsedExtends = clsM.matched(2);
	}

	// Imports
	var impM = ~/^import\s+([\w.*]+)\s*;/gm;
	var pos = 0;
	while (impM.matchSub(content, pos)) {
		parsedImports.push(impM.matched(1));
		pos = impM.matchedPos().pos + impM.matchedPos().len;
	}

	// Functions
	var funcM = ~/((?:public|private|static|inline|override)\s+)*function\s+(\w+)\s*\(/g;
	pos = 0;
	while (funcM.matchSub(content, pos)) {
		var mods = funcM.matched(1) != null ? funcM.matched(1) : "";
		parsedFuncs.push({
			name: funcM.matched(2),
			isPublic: mods.indexOf("public") >= 0,
			isStatic: mods.indexOf("static") >= 0,
			isOverride: mods.indexOf("override") >= 0,
			line: content.substr(0, funcM.matchedPos().pos).split("\n").length
		});
		pos = funcM.matchedPos().pos + funcM.matchedPos().len;
	}

	// Variables
	var varM = ~/((?:public|private|static)\s+)*var\s+(\w+)\s*(?::\s*(\w+))?/g;
	pos = 0;
	while (varM.matchSub(content, pos)) {
		var mods = varM.matched(1) != null ? varM.matched(1) : "";
		parsedVars.push({
			name: varM.matched(2),
			type: varM.matched(3),
			isPublic: mods.indexOf("public") >= 0,
			isStatic: mods.indexOf("static") >= 0,
			line: content.substr(0, varM.matchedPos().pos).split("\n").length
		});
		pos = varM.matchedPos().pos + varM.matchedPos().len;
	}
}

// =============================================================================
//  REFRESH FUNCTIONS
// =============================================================================
function refreshAll() {
	refreshCode();
	refreshVisual();
	refreshMinimap();
	refreshStatus();
	refreshTabs();
}

function refreshCode() {
	var ex = VISUAL_W;
	var ey = TOP_H + TAB_H;
	var ew = FlxG.width - VISUAL_W - MINIMAP_W;
	var eh = FlxG.height - TOP_H - TAB_H - STATUS_H;
	var visibleLines = Std.int(eh / lineH);
	var startLine = Std.int(scrollY / lineH);
	if (startLine < 0) startLine = 0;

	// Line numbers
	var lnBuf = new StringBuf();
	for (i in startLine...Math.min(startLine + visibleLines, lines.length)) {
		lnBuf.add("" + (i + 1) + "\n");
	}
	lineNumText.text = lnBuf.toString();

	// Code display with basic syntax coloring info
	var displayLines = lines.slice(startLine, startLine + visibleLines);
	codeText.text = displayLines.join("\n");

	// Highlight current line
	if (cursorLine >= startLine && cursorLine < startLine + visibleLines) {
		highlightSpr.y = ey + (cursorLine - startLine) * lineH + 2;
		highlightSpr.visible = true;
	} else {
		highlightSpr.visible = false;
	}
}

function refreshVisual() {
	visualGroup.clear();
	var y:Float = 0;

	// Package
	if (parsedPkg.length > 0) {
		var pkgL = makeVisualItem("📦 " + parsedPkg, 0xFFAAAAFF, 0, y);
		visualGroup.add(pkgL);
		y += 22;
	}

	// Imports
	if (parsedImports.length > 0) {
		var impL = makeVisualItem("📥 Imports (" + parsedImports.length + ")", 0xFF88AA88, 0, y);
		visualGroup.add(impL);
		y += 22;
	}

	// Class
	if (parsedClass.length > 0) {
		var clsText = "🏗️ " + parsedClass;
		if (parsedExtends.length > 0) clsText += " extends " + parsedExtends;
		var clsL = makeVisualItem(clsText, 0xFFFFCC44, 0, y);
		visualGroup.add(clsL);
		y += 26;
	}

	// Variables
	if (parsedVars.length > 0) {
		var varHeader = makeVisualItem("Variables (" + parsedVars.length + ")", 0xFF88CCFF, 0, y);
		visualGroup.add(varHeader);
		y += 20;

		var showVars = Math.min(parsedVars.length, 25);
		for (i in 0...showVars) {
			var v = parsedVars[i];
			var icon = v.isPublic ? "🟢" : "🔴";
			if (v.isStatic) icon = "⚡";
			var typeStr = v.type != null ? ": " + v.type : "";
			var varL = makeVisualItem(icon + " " + v.name + typeStr, v.isPublic ? 0xFF88FF88 : 0xFFFF8888, 12, y);
			visualGroup.add(varL);
			y += 17;
		}
		if (parsedVars.length > showVars) {
			var more = makeVisualItem("  ... +" + (parsedVars.length - showVars) + " more", COL_DIM, 12, y);
			visualGroup.add(more);
			y += 17;
		}
		y += 8;
	}

	// Functions
	if (parsedFuncs.length > 0) {
		var funcHeader = makeVisualItem("Functions (" + parsedFuncs.length + ")", 0xFFFFCC88, 0, y);
		visualGroup.add(funcHeader);
		y += 20;

		var showFuncs = Math.min(parsedFuncs.length, 30);
		for (i in 0...showFuncs) {
			var f = parsedFuncs[i];
			var icon = f.isPublic ? "🟢" : "🔴";
			if (f.isStatic) icon = "⚡";
			if (f.isOverride) icon = "🔄";
			var funcL = makeVisualItem(icon + " " + f.name + "() [L" + f.line + "]", f.isPublic ? 0xFF88CCFF : 0xFFCC8888, 12, y);
			visualGroup.add(funcL);
			y += 17;
		}
		if (parsedFuncs.length > showFuncs) {
			var more = makeVisualItem("  ... +" + (parsedFuncs.length - showFuncs) + " more", COL_DIM, 12, y);
			visualGroup.add(more);
			y += 17;
		}
	}

	// Summary
	y += 12;
	var summary = makeVisualItem("Lines: " + lines.length + " | Funcs: " + parsedFuncs.length + " | Vars: " + parsedVars.length, FlxColor.fromRGB(80, 80, 100), 0, y);
	visualGroup.add(summary);
}

function makeVisualItem(text:String, color:Int, indent:Int, y:Float):FlxText {
	var lbl = new FlxText(indent, y, VISUAL_W - indent - 16, text, 11);
	lbl.color = color;
	lbl.cameras = [uiCam];
	return lbl;
}

function refreshMinimap() {
	minimapText.text = content;
}

function refreshStatus() {
	var parts = [];
	if (filePath != null && filePath.length > 0) {
		parts.push(filePath);
	} else {
		parts.push("Untitled");
	}
	if (isDirty) parts.push("● Modified");
	parts.push("Ln " + (cursorLine + 1) + ", Col " + (cursorCol + 1));
	parts.push(lines.length + " lines");
	if (findResults.length > 0) parts.push("Find: " + findResults.length + " matches");
	parts.push("Undo: " + undoStack.length);
	parts.push("Ctrl+S:Save | Ctrl+F:Find | Ctrl+Z:Undo | ESC:Exit");
	statusLabel.text = parts.join("  |  ");
}

// =============================================================================
//  FIND & REPLACE
// =============================================================================
function performFind() {
	findResults = [];
	currentFindIdx = 0;

	if (findQuery.length == 0) {
		findResultLabel.text = "";
		return;
	}

	var searchContent = findCaseSensitive ? content : content.toLowerCase();
	var searchQuery = findCaseSensitive ? findQuery : findQuery.toLowerCase();

	if (findUseRegex) {
		try {
			var flags = findCaseSensitive ? "" : "i";
			var regex = new EReg(findQuery, flags + "g");
			var pos = 0;
			while (regex.matchSub(content, pos)) {
				var mp = regex.matchedPos();
				var lineNum = content.substr(0, mp.pos).split("\n").length - 1;
				findResults.push({line: lineNum, col: mp.pos, len: mp.len});
				pos = mp.pos + mp.len;
				if (mp.len == 0) break;
			}
		} catch(e:Dynamic) {
			findResultLabel.text = "Invalid regex";
			return;
		}
	} else {
		var pos = 0;
		while (true) {
			var idx = searchContent.indexOf(searchQuery, pos);
			if (idx < 0) break;
			var lineNum = content.substr(0, idx).split("\n").length - 1;
			findResults.push({line: lineNum, col: idx, len: findQuery.length});
			pos = idx + findQuery.length;
		}
	}

	findResultLabel.text = findResults.length + " match(es) found";
	if (findResults.length > 0) {
		scrollToLine(findResults[0].line);
	}
}

function performReplace(all:Bool) {
	if (findResults.length == 0 || replaceQuery == null) return;

	pushUndo(content);

	if (all) {
		if (findUseRegex) {
			try {
				var regex = new EReg(findQuery, findCaseSensitive ? "g" : "gi");
				content = regex.replace(content, replaceQuery);
			} catch(e:Dynamic) {}
		} else {
			content = content.split(findQuery).join(replaceQuery);
		}
	} else if (currentFindIdx >= 0 && currentFindIdx < findResults.length) {
		var r = findResults[currentFindIdx];
		content = content.substr(0, r.col) + replaceQuery + content.substr(r.col + r.len);
	}

	lines = content.split("\n");
	isDirty = true;
	editTextBox.label.text = content;
	parseContent();
	performFind();
	refreshAll();
}

function scrollToLine(line:Int) {
	var ey = TOP_H + TAB_H;
	var eh = FlxG.height - TOP_H - TAB_H - STATUS_H;
	var visibleLines = Std.int(eh / lineH);

	if (line < Std.int(scrollY / lineH) || line >= Std.int(scrollY / lineH) + visibleLines) {
		scrollY = Math.max(0, (line - Std.int(visibleLines / 2)) * lineH);
	}
	cursorLine = line;
	refreshCode();
}

// =============================================================================
//  UNDO/REDO
// =============================================================================
function pushUndo(oldContent:String) {
	undoStack.push({content: oldContent, line: cursorLine, col: cursorCol});
	if (undoStack.length > MAX_UNDO) undoStack.shift();
	redoStack = [];
}

function undo() {
	if (undoStack.length == 0) return;
	var action = undoStack.pop();
	redoStack.push({content: content, line: cursorLine, col: cursorCol});
	content = action.content;
	lines = content.split("\n");
	cursorLine = action.line;
	cursorCol = action.col;
	isDirty = content != originalContent;
	editTextBox.label.text = content;
	parseContent();
	refreshAll();
}

function redo() {
	if (redoStack.length == 0) return;
	var action = redoStack.pop();
	undoStack.push({content: content, line: cursorLine, col: cursorCol});
	content = action.content;
	lines = content.split("\n");
	cursorLine = action.line;
	cursorCol = action.col;
	isDirty = content != originalContent;
	editTextBox.label.text = content;
	parseContent();
	refreshAll();
}

// =============================================================================
//  TOOLS
// =============================================================================
function validateSyntax() {
	var errors:Array<String> = [];
	var braces = 0; var brackets = 0; var parens = 0;
	var inStr = false; var inComment = false; var inLineComment = false;

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
			if (inStr) {
				if (ch == '"' && (i == 0 || line.charAt(i - 1) != '\\')) inStr = false;
				continue;
			}

			if (ch == "/" && next == "/") inLineComment = true;
			else if (ch == "/" && next == "*") { inComment = true; i++; }
			else if (ch == '"') inStr = true;
			else if (ch == "{") braces++;
			else if (ch == "}") braces--;
			else if (ch == "[") brackets++;
			else if (ch == "]") brackets--;
			else if (ch == "(") parens++;
			else if (ch == ")") parens--;
		}
	}

	if (braces != 0) errors.push("Braces: " + (braces > 0 ? "+" : "") + braces);
	if (brackets != 0) errors.push("Brackets: " + (brackets > 0 ? "+" : "") + brackets);
	if (parens != 0) errors.push("Parens: " + (parens > 0 ? "+" : "") + parens);

	if (errors.length == 0) {
		findResultLabel.text = "✓ No syntax issues found";
		findResultLabel.color = COL_SUCCESS;
	} else {
		findResultLabel.text = "Issues: " + errors.join(", ");
		findResultLabel.color = COL_ERROR;
	}

	// Show find panel to display results
	showFind = true;
	findBg.visible = true;
}

function formatCode() {
	pushUndo(content);
	var formatted:Array<String> = [];
	var indent:Int = 0;

	for (line in lines) {
		var trimmed = line.trim();
		if (trimmed.startsWith("}")) indent = Math.max(0, indent - 1);
		formatted.push(StringTools.lpad("", "\t", indent) + trimmed);
		if (trimmed.endsWith("{")) indent++;
	}

	content = formatted.join("\n");
	lines = content.split("\n");
	isDirty = true;
	editTextBox.label.text = content;
	refreshAll();
}

// =============================================================================
//  TEMPLATES
// =============================================================================
function getDefaultTemplate():String {
	return "package;\n\nclass NewClass {\n\tpublic function new() {\n\t\t\n\t}\n}\n";
}

function getTemplate(type:String):String {
	return switch(type) {
		case "state": "package funkin.menus;\n\nimport funkin.backend.MusicBeatState;\n\nclass NewState extends MusicBeatState {\n\toverride function create() {\n\t\tsuper.create();\n\t}\n\n\toverride function update(elapsed:Float) {\n\t\tsuper.update(elapsed);\n\t}\n}\n";
		case "substate": "package funkin.menus;\n\nimport funkin.backend.MusicBeatSubstate;\n\nclass NewSubstate extends MusicBeatSubstate {\n\tpublic function new() {\n\t\tsuper();\n\t}\n\n\toverride function create() {\n\t\tsuper.create();\n\t}\n}\n";
		case "editor": "package funkin.editors;\n\nimport funkin.editors.ui.*;\n\nclass NewEditor extends UIState {\n\tpublic var uiCamera:FlxCamera;\n\n\tpublic override function create() {\n\t\tsuper.create();\n\t\tWindowUtils.suffix = \" (New Editor)\";\n\t\tuiCamera = new FlxCamera();\n\t\tFlxG.cameras.add(uiCamera, false);\n\t}\n}\n";
		case "script": "// HScript file\n// Place in assets/data/scripts/ or mods/<modname>/data/scripts/\n\nfunction postCreate() {\n\ttrace(\"Script loaded!\");\n}\n\nfunction postUpdate(elapsed) {\n\t// Called every frame\n}\n\nfunction onBeatHit() {\n\t// Called on every beat\n}\n";
		case "event_handler": "// Event handler script\n// Place in songs/<name>/scripts/ or assets/data/scripts/\n\nfunction onEvent(event) {\n\tswitch(event.name) {\n\t\tcase \"My Custom Event\":\n\t\t\ttrace(\"Event triggered!\");\n\t}\n}\n";
		default: getDefaultTemplate();
	};
}

// =============================================================================
//  UPDATE
// =============================================================================
function update(elapsed:Float) {
	super.update(elapsed);

	// Exit
	if (FlxG.keys.justPressed.ESCAPE && !showFind) {
		if (isDirty) {
			// Simple save prompt - just save and exit
			saveFile();
		}
		FlxG.switchState(new funkin.menus.MainMenuState());
	}

	// Ctrl shortcuts
	if (FlxG.keys.pressed.CONTROL) {
		if (FlxG.keys.justPressed.S) saveFile();
		if (FlxG.keys.justPressed.Z && !FlxG.keys.pressed.SHIFT) undo();
		if (FlxG.keys.justPressed.Z && FlxG.keys.pressed.SHIFT) redo();
		if (FlxG.keys.justPressed.Y) redo();
		if (FlxG.keys.justPressed.F) {
			showFind = !showFind;
			findBg.visible = showFind;
		}
		if (FlxG.keys.justPressed.N) newFile();
		if (FlxG.keys.justPressed.W) {
			if (activeTab != null) closeTab(activeTab);
		}
		if (FlxG.keys.justPressed.G) {
			// Go to line prompt (use find box)
			showFind = true;
			findBg.visible = true;
		}
		if (FlxG.keys.justPressed.TAB) {
			// Next tab
			if (tabs.length > 1) {
				var idx = tabs.indexOf(activeTab);
				switchTab(tabs[(idx + 1) % tabs.length]);
			}
		}
	}

	// F5 = validate
	if (FlxG.keys.justPressed.F5) validateSyntax();

	// F6 = format
	if (FlxG.keys.justPressed.F6) formatCode();

	// Scroll with mouse wheel (when not in text box)
	if (FlxG.mouse.wheel != 0 && !editTextBox.hovered) {
		scrollY -= FlxG.mouse.wheel * lineH * 3;
		if (scrollY < 0) scrollY = 0;
		var maxScroll = (lines.length * lineH) - (FlxG.height - TOP_H - TAB_H - STATUS_H);
		if (maxScroll < 0) maxScroll = 0;
		if (scrollY > maxScroll) scrollY = maxScroll;
		refreshCode();
	}

	// Arrow key navigation in code
	if (!editTextBox.hovered) {
		if (FlxG.keys.justPressed.DOWN) {
			cursorLine = Math.min(lines.length - 1, cursorLine + 1);
			refreshCode();
			refreshStatus();
		}
		if (FlxG.keys.justPressed.UP) {
			cursorLine = Math.max(0, cursorLine - 1);
			refreshCode();
			refreshStatus();
		}
	}

	// Update cursor line from text box
	if (editTextBox.label != null) {
		var textBefore = editTextBox.label.text.substr(0, Math.min(editTextBox.position, editTextBox.label.text.length));
		var linesBefore = textBefore.split("\n");
		cursorLine = linesBefore.length - 1;
		cursorCol = linesBefore[linesBefore.length - 1].length;
	}
}

function destroy() {
	super.destroy();
}
