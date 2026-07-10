// =============================================================================
//  HX EDITOR - Full HScript State (works via ModState / StateRedirects)
//  Place in: mods/hx-tools/data/states/HXEditor.hx
//  Redirect: [StateRedirects] FreeplayState="HXEditor"
//  Or open:  FlxG.switchState(new ModState("HXEditor", {path: "file.hx"}))
// =============================================================================

using StringTools;

// ============ LAYOUT ============
var VISUAL_W = 300;
var MINIMAP_W = 100;
var TOP_H = 34;
var TAB_H = 26;
var STATUS_H = 26;

// ============ COLORS ============
var COL_BG = FlxColor.fromRGB(24, 24, 32);
var COL_PANEL = FlxColor.fromRGB(30, 30, 42);
var COL_PANEL2 = FlxColor.fromRGB(22, 22, 30);
var COL_EDITOR = FlxColor.fromRGB(26, 26, 36);
var COL_TEXT = FlxColor.fromRGB(215, 215, 230);
var COL_DIM = FlxColor.fromRGB(100, 100, 125);
var COL_ACCENT = FlxColor.fromRGB(80, 150, 255);
var COL_LINE_HL = FlxColor.fromRGB(36, 36, 50);
var COL_SELECT = FlxColor.fromRGB(50, 60, 95);
var COL_KEYWORD = FlxColor.fromRGB(200, 120, 255);
var COL_STRING = FlxColor.fromRGB(180, 230, 130);
var COL_COMMENT = FlxColor.fromRGB(95, 105, 125);
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
var lineH:Int = 16;
var fontSize:Int = 12;
var editing:Bool = false; // whether we're typing in the editor

// Tabs
var tabs:Array<Dynamic> = [];
var activeTab:Dynamic = null;

// Undo/Redo
var undoStack:Array<Dynamic> = [];
var redoStack:Array<Dynamic> = [];

// Find
var findQuery:String = "";
var findResults:Array<Dynamic> = [];
var findVisible:Bool = false;

// Parsed structure
var parsedPkg:String = "";
var parsedClass:String = "";
var parsedExtends:String = "";
var parsedFuncs:Array<Dynamic> = [];
var parsedVars:Array<Dynamic> = [];
var parsedImports:Int = 0;

// ============ UI ============
var uiCam:FlxCamera;
var lineNumText:FlxText;
var codeText:FlxText;
var highlightSpr:FlxSprite;
var visualGroup:FlxTypedGroup<FlxSprite>;
var minimapText:FlxText;
var statusLabel:FlxText;
var tabGroup:FlxTypedGroup<FlxSprite>;
var findGroup:FlxTypedGroup<FlxSprite>;
var editInput:FlxText; // invisible input capture
var findInputText:FlxText;
var findResultText:FlxText;

// =============================================================================
//  CREATE
// =============================================================================
function create() {
	// Get file path from ModState data
	if (data != null && Reflect.hasField(data, "path")) filePath = data.path;

	// Camera
	uiCam = new FlxCamera();
	uiCam.bgColor = COL_BG;
	FlxG.cameras.add(uiCam, false);
	camera = uiCam;

	// Background
	var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, COL_BG);
	bg.scrollFactor.set();
	add(bg);

	// Header
	var header = new FlxSprite(0, 0).makeGraphic(FlxG.width, TOP_H, FlxColor.fromRGB(16, 16, 24));
	header.scrollFactor.set();
	add(header);

	var title = new FlxText(12, 8, 200, "HX Editor", 15);
	title.color = COL_ACCENT;
	title.scrollFactor.set();
	add(title);

	var hint = new FlxText(FlxG.width - 520, 9, 510, "Ctrl+S:Save  Ctrl+Z:Undo  Ctrl+F:Find  F5:Validate  F6:Format  ESC:Exit", 10);
	hint.color = COL_DIM;
	hint.scrollFactor.set();
	add(hint);

	// Tab bar
	var tabBarBg = new FlxSprite(0, TOP_H).makeGraphic(FlxG.width, TAB_H, FlxColor.fromRGB(20, 20, 30));
	tabBarBg.scrollFactor.set();
	add(tabBarBg);

	tabGroup = new FlxTypedGroup<FlxSprite>();
	add(tabGroup);

	// Visual panel
	var visBg = new FlxSprite(0, TOP_H + TAB_H).makeGraphic(VISUAL_W, FlxG.height - TOP_H - TAB_H - STATUS_H, COL_PANEL);
	visBg.scrollFactor.set();
	add(visBg);

	var visTitle = new FlxText(10, TOP_H + TAB_H + 6, VISUAL_W - 20, "Structure", 12);
	visTitle.color = COL_DIM;
	visTitle.scrollFactor.set();
	add(visTitle);

	visualGroup = new FlxTypedGroup<FlxSprite>();
	add(visualGroup);

	// Code editor area
	var ex = VISUAL_W;
	var ey = TOP_H + TAB_H;
	var ew = FlxG.width - VISUAL_W - MINIMAP_W;
	var eh = FlxG.height - TOP_H - TAB_H - STATUS_H;

	var edBg = new FlxSprite(ex, ey).makeGraphic(ew, eh, COL_EDITOR);
	edBg.scrollFactor.set();
	add(edBg);

	highlightSpr = new FlxSprite(ex + 50, ey).makeGraphic(ew - 54, lineH, COL_LINE_HL);
	highlightSpr.alpha = 0.6;
	highlightSpr.scrollFactor.set();
	add(highlightSpr);

	lineNumText = new FlxText(ex + 4, ey + 4, 44, "", 10);
	lineNumText.color = FlxColor.fromRGB(65, 65, 85);
	lineNumText.scrollFactor.set();
	add(lineNumText);

	codeText = new FlxText(ex + 54, ey + 4, ew - 58, "", fontSize);
	codeText.color = COL_TEXT;
	codeText.scrollFactor.set();
	add(codeText);

	// Minimap
	var mx = FlxG.width - MINIMAP_W;
	var miniBg = new FlxSprite(mx, ey).makeGraphic(MINIMAP_W, eh, COL_PANEL2);
	miniBg.scrollFactor.set();
	add(miniBg);

	var miniTitle = new FlxText(mx + 6, ey + 4, MINIMAP_W - 12, "Minimap", 9);
	miniTitle.color = COL_DIM;
	miniTitle.scrollFactor.set();
	add(miniTitle);

	minimapText = new FlxText(mx + 4, ey + 18, MINIMAP_W - 8, "", 3);
	minimapText.color = FlxColor.fromRGB(75, 75, 95);
	minimapText.scrollFactor.set();
	add(minimapText);

	// Status bar
	var statusBg = new FlxSprite(0, FlxG.height - STATUS_H).makeGraphic(FlxG.width, STATUS_H, FlxColor.fromRGB(16, 16, 24));
	statusBg.scrollFactor.set();
	add(statusBg);

	statusLabel = new FlxText(10, FlxG.height - STATUS_H + 5, FlxG.width - 20, "", 11);
	statusLabel.color = COL_DIM;
	statusLabel.scrollFactor.set();
	add(statusLabel);

	// Find panel (hidden by default)
	findGroup = new FlxTypedGroup<FlxSprite>();
	findGroup.visible = false;
	add(findGroup);

	var findBg = new FlxSprite(ex, ey).makeGraphic(ew, 70, FlxColor.fromRGB(38, 38, 54));
	findBg.scrollFactor.set();
	findGroup.add(findBg);

	var findLbl = new FlxText(ex + 8, ey + 6, 40, "Find:", 11);
	findLbl.color = COL_DIM;
	findLbl.scrollFactor.set();
	findGroup.add(findLbl);

	findInputText = new FlxText(ex + 52, ey + 6, ew - 200, "", 12);
	findInputText.color = COL_TEXT;
	findInputText.scrollFactor.set();
	findGroup.add(findInputText);

	var findBorder = new FlxSprite(ex + 50, ey + 4).makeGraphic(ew - 196, 20, FlxColor.fromRGB(50, 50, 70));
	findBorder.alpha = 0.3;
	findBorder.scrollFactor.set();
	findGroup.add(findBorder);

	findResultText = new FlxText(ex + 8, ey + 50, ew - 16, "", 10);
	findResultText.color = COL_DIM;
	findResultText.scrollFactor.set();
	findGroup.add(findResultText);

	// Load file or create new
	if (filePath != null && filePath.length > 0) {
		loadFile(filePath);
	} else {
		content = getDefaultTemplate();
		originalContent = content;
		lines = content.split("\n");
		createTab("Untitled.hx", content);
	}

	parseContent();
	refreshAll();
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
		if (c == null) c = "";
		filePath = path;
		content = c;
		originalContent = c;
		lines = content.split("\n");
		isDirty = false;
		cursorLine = 0;
		scrollY = 0;
		createTab(haxe.io.Path.withoutDirectory(path), content);
	} catch(e:Dynamic) {
		trace("HXEditor: Error loading " + path + ": " + e);
		content = "// Error loading file: " + path;
		lines = content.split("\n");
	}
}

function saveFile() {
	if (filePath == null || filePath.length == 0) return;
	#if sys
	try {
		sys.io.File.saveContent(filePath, content);
		originalContent = content;
		isDirty = false;
		refreshStatus();
		refreshTabs();
		trace("HXEditor: Saved " + filePath);
	} catch(e:Dynamic) {
		trace("HXEditor: Save error: " + e);
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
	refreshAll();
}

// =============================================================================
//  TABS
// =============================================================================
function createTab(name:String, cont:String):Dynamic {
	var tab = { name: name, content: cont, path: filePath, dirty: false, scrollY: 0, curLine: 0 };
	tabs.push(tab);
	activeTab = tab;
	refreshTabs();
	return tab;
}

function refreshTabs() {
	tabGroup.clear();
	var xOff:Float = 4;
	for (tab in tabs) {
		var isActive = tab == activeTab;
		var w = 140;
		var bg = new FlxSprite(xOff, TOP_H + 2).makeGraphic(w, TAB_H - 4, isActive ? FlxColor.fromRGB(40, 40, 58) : FlxColor.fromRGB(26, 26, 38));
		bg.scrollFactor.set();
		tabGroup.add(bg);

		var displayName = tab.name;
		if (tab.dirty) displayName = "● " + displayName;
		var lbl = new FlxText(xOff + 6, TOP_H + 6, w - 20, displayName, 10);
		lbl.color = isActive ? FlxColor.WHITE : COL_DIM;
		lbl.scrollFactor.set();
		tabGroup.add(lbl);
		xOff += w + 2;
	}
}

// =============================================================================
//  PARSING
// =============================================================================
function parseContent() {
	parsedPkg = ""; parsedClass = ""; parsedExtends = ""; parsedFuncs = []; parsedVars = []; parsedImports = 0;

	var pkgM = ~/^package\s+([\w.]+)\s*;/m;
	if (pkgM.match(content)) parsedPkg = pkgM.matched(1);

	var clsM = ~/class\s+(\w+)(?:\s+extends\s+([\w.]+))?/;
	if (clsM.match(content)) { parsedClass = clsM.matched(1); if (clsM.matched(2) != null) parsedExtends = clsM.matched(2); }

	var impM = ~/^import\s+/gm;
	var pos = 0;
	while (impM.matchSub(content, pos)) { parsedImports++; pos = impM.matchedPos().pos + impM.matchedPos().len; }

	var funcM = ~/((?:public|private|static|inline|override)\s+)*function\s+(\w+)\s*\(/g;
	pos = 0;
	while (funcM.matchSub(content, pos)) {
		var mods = funcM.matched(1) != null ? funcM.matched(1) : "";
		parsedFuncs.push({ name: funcM.matched(2), isPublic: mods.indexOf("public") >= 0, isStatic: mods.indexOf("static") >= 0, isOverride: mods.indexOf("override") >= 0, line: content.substr(0, funcM.matchedPos().pos).split("\n").length });
		pos = funcM.matchedPos().pos + funcM.matchedPos().len;
	}

	var varM = ~/((?:public|private|static)\s+)*var\s+(\w+)\s*(?::\s*(\w+))?/g;
	pos = 0;
	while (varM.matchSub(content, pos)) {
		var mods = varM.matched(1) != null ? varM.matched(1) : "";
		parsedVars.push({ name: varM.matched(2), type: varM.matched(3), isPublic: mods.indexOf("public") >= 0, isStatic: mods.indexOf("static") >= 0 });
		pos = varM.matchedPos().pos + varM.matchedPos().len;
	}
}

// =============================================================================
//  REFRESH
// =============================================================================
function refreshAll() { refreshCode(); refreshVisual(); refreshMinimap(); refreshStatus(); refreshTabs(); }

function refreshCode() {
	var ey = TOP_H + TAB_H;
	var ew = FlxG.width - VISUAL_W - MINIMAP_W;
	var eh = FlxG.height - TOP_H - TAB_H - STATUS_H;
	var visLines = Std.int(eh / lineH);
	var startLine = Std.int(scrollY / lineH);
	if (startLine < 0) startLine = 0;

	// Line numbers
	var lnBuf = new StringBuf();
	for (i in startLine...Math.min(startLine + visLines, lines.length)) { lnBuf.add("" + (i + 1) + "\n"); }
	lineNumText.text = lnBuf.toString();

	// Code
	var displayLines = lines.slice(startLine, startLine + visLines);
	codeText.text = displayLines.join("\n");

	// Highlight
	if (cursorLine >= startLine && cursorLine < startLine + visLines) {
		highlightSpr.y = ey + (cursorLine - startLine) * lineH + 2;
		highlightSpr.visible = true;
	} else {
		highlightSpr.visible = false;
	}
}

function refreshVisual() {
	visualGroup.clear();
	var y:Float = TOP_H + TAB_H + 24;

	if (parsedPkg.length > 0) { y = addVisItem("📦 " + parsedPkg, 0xFFAAAAFF, 8, y, 20); }
	if (parsedImports > 0) { y = addVisItem("📥 Imports (" + parsedImports + ")", 0xFF88AA88, 8, y, 20); }
	if (parsedClass.length > 0) {
		var clsText = "🏗️ " + parsedClass;
		if (parsedExtends.length > 0) clsText += " extends " + parsedExtends;
		y = addVisItem(clsText, 0xFFFFCC44, 8, y, 24);
	}

	if (parsedVars.length > 0) {
		y = addVisItem("Variables (" + parsedVars.length + ")", 0xFF88CCFF, 8, y + 4, 18);
		var showV = Math.min(parsedVars.length, 20);
		for (i in 0...showV) {
			var v = parsedVars[i];
			var icon = v.isPublic ? "🟢" : "🔴";
			if (v.isStatic) icon = "⚡";
			var typeStr = v.type != null ? ": " + v.type : "";
			y = addVisItem(icon + " " + v.name + typeStr, v.isPublic ? 0xFF88FF88 : 0xFFFF8888, 18, y, 16);
		}
		if (parsedVars.length > showV) y = addVisItem("  ... +" + (parsedVars.length - showV), COL_DIM, 18, y, 16);
	}

	if (parsedFuncs.length > 0) {
		y = addVisItem("Functions (" + parsedFuncs.length + ")", 0xFFFFCC88, 8, y + 6, 18);
		var showF = Math.min(parsedFuncs.length, 25);
		for (i in 0...showF) {
			var f = parsedFuncs[i];
			var icon = f.isPublic ? "🟢" : "🔴";
			if (f.isStatic) icon = "⚡";
			if (f.isOverride) icon = "🔄";
			y = addVisItem(icon + " " + f.name + "() [L" + f.line + "]", f.isPublic ? 0xFF88CCFF : 0xFFCC8888, 18, y, 16);
		}
		if (parsedFuncs.length > showF) y = addVisItem("  ... +" + (parsedFuncs.length - showF), COL_DIM, 18, y, 16);
	}

	y = addVisItem("Lines: " + lines.length + " | Funcs: " + parsedFuncs.length + " | Vars: " + parsedVars.length, FlxColor.fromRGB(75, 75, 95), 8, y + 10, 16);
}

function addVisItem(text:String, color:Int, x:Float, y:Float, h:Float):Float {
	var lbl = new FlxText(x, y, VISUAL_W - x - 8, text, 11);
	lbl.color = color;
	lbl.scrollFactor.set();
	visualGroup.add(lbl);
	return y + h;
}

function refreshMinimap() { minimapText.text = content; }

function refreshStatus() {
	var parts = [];
	parts.push(filePath.length > 0 ? filePath : "Untitled");
	if (isDirty) parts.push("● Modified");
	parts.push("Ln " + (cursorLine + 1) + ", Col " + (cursorCol + 1));
	parts.push(lines.length + " lines");
	if (findResults.length > 0) parts.push("Find: " + findResults.length);
	parts.push("Undo: " + undoStack.length);
	statusLabel.text = parts.join("  |  ");
}

// =============================================================================
//  FIND
// =============================================================================
function performFind() {
	findResults = [];
	if (findQuery.length == 0) { findResultText.text = ""; return; }
	var q = findQuery.toLowerCase();
	for (i in 0...lines.length) {
		var line = lines[i].toLowerCase();
		var pos = 0;
		while (true) {
			var idx = line.indexOf(q, pos);
			if (idx < 0) break;
			findResults.push({line: i, col: idx});
			pos = idx + q.length;
		}
	}
	findResultText.text = findResults.length + " match(es) found";
	if (findResults.length > 0) {
		cursorLine = findResults[0].line;
		scrollY = Math.max(0, (cursorLine - 5) * lineH);
		refreshCode();
	}
}

function performReplaceAll(replacement:String) {
	if (findQuery.length == 0) return;
	pushUndo();
	content = content.split(findQuery).join(replacement);
	lines = content.split("\n");
	isDirty = true;
	parseContent();
	performFind();
	refreshAll();
}

// =============================================================================
//  UNDO/REDO
// =============================================================================
function pushUndo() {
	undoStack.push({content: content, line: cursorLine});
	if (undoStack.length > 200) undoStack.shift();
	redoStack = [];
}

function undo() {
	if (undoStack.length == 0) return;
	var action = undoStack.pop();
	redoStack.push({content: content, line: cursorLine});
	content = action.content;
	lines = content.split("\n");
	cursorLine = action.line;
	isDirty = content != originalContent;
	parseContent();
	refreshAll();
}

function redo() {
	if (redoStack.length == 0) return;
	var action = redoStack.pop();
	undoStack.push({content: content, line: cursorLine});
	content = action.content;
	lines = content.split("\n");
	cursorLine = action.line;
	isDirty = content != originalContent;
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
			if (inComment) { if (ch == "*" && next == "/") { inComment = false; i++; } continue; }
			if (inStr) { if (ch == '"' && (i == 0 || line.charAt(i - 1) != '\\')) inStr = false; continue; }
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

	findResultText.color = errors.length == 0 ? COL_SUCCESS : COL_ERROR;
	findResultText.text = errors.length == 0 ? "✓ No syntax issues found" : "Issues: " + errors.join(", ");
	findVisible = true;
	findGroup.visible = true;
}

function formatCode() {
	pushUndo();
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
	parseContent();
	refreshAll();
}

// =============================================================================
//  TEMPLATES
// =============================================================================
function getDefaultTemplate():String {
	return "package;\n\nclass NewClass {\n\tpublic function new() {\n\t\t\n\t}\n}\n";
}

// =============================================================================
//  UPDATE
// =============================================================================
var findActive:Bool = false;

function update(elapsed:Float) {
	// Exit
	if (FlxG.keys.justPressed.ESCAPE) {
		if (findVisible) { findVisible = false; findGroup.visible = false; return; }
		if (isDirty) saveFile();
		FlxG.switchState(new funkin.menus.MainMenuState());
		return;
	}

	// Ctrl shortcuts
	if (FlxG.keys.pressed.CONTROL) {
		if (FlxG.keys.justPressed.S) { saveFile(); return; }
		if (FlxG.keys.justPressed.Z && !FlxG.keys.pressed.SHIFT) { undo(); return; }
		if (FlxG.keys.justPressed.Z && FlxG.keys.pressed.SHIFT) { redo(); return; }
		if (FlxG.keys.justPressed.Y) { redo(); return; }
		if (FlxG.keys.justPressed.F) {
			findVisible = !findVisible;
			findGroup.visible = findVisible;
			if (findVisible) { findActive = true; findQuery = ""; findInputText.text = "|"; }
			else findActive = false;
			return;
		}
		if (FlxG.keys.justPressed.N) { newFile(); return; }
		if (FlxG.keys.justPressed.A) { /* select all - no-op for now */ return; }
	}

	// F5 = validate, F6 = format
	if (FlxG.keys.justPressed.F5) { validateSyntax(); return; }
	if (FlxG.keys.justPressed.F6) { formatCode(); return; }

	// Find input
	if (findActive) {
		if (FlxG.keys.justPressed.BACKSPACE) {
			findQuery = findQuery.substr(0, Math.max(0, findQuery.length - 1));
			findInputText.text = findQuery + "|";
			performFind();
		} else if (FlxG.keys.justPressed.ENTER) {
			findActive = false;
			findInputText.text = findQuery;
		} else {
			for (code in 32...127) {
				if (FlxG.keys.justPressed(cast code)) {
					findQuery += String.fromCharCode(code);
					findInputText.text = findQuery + "|";
					performFind();
					break;
				}
			}
		}
		return;
	}

	// Arrow navigation
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

	// Scroll with mouse wheel
	if (FlxG.mouse.wheel != 0) {
		scrollY -= FlxG.mouse.wheel * lineH * 3;
		if (scrollY < 0) scrollY = 0;
		var maxScroll = (lines.length * lineH) - (FlxG.height - TOP_H - TAB_H - STATUS_H);
		if (maxScroll < 0) maxScroll = 0;
		if (scrollY > maxScroll) scrollY = maxScroll;
		refreshCode();
	}
}

function destroy() {
	if (uiCam != null && FlxG.cameras.list.contains(uiCam)) {
		FlxG.cameras.remove(uiCam);
	}
}
