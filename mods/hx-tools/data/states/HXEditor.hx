// =============================================================================
//  HX EDITOR - Custom State for Codename Engine
//  Place in: mods/hx-tools/data/states/HXEditor.hx
//  Redirect: [StateRedirects] FreeplayState="HXEditor"
//  Or open:  FlxG.switchState(new ModState("HXEditor", {path: "file.hx"}))
// =============================================================================

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
var editing:Bool = false;

// Tabs
var tabs:Array<Dynamic> = [];
var activeTab:Dynamic = null;

// Undo/Redo
var undoStack:Array<Dynamic> = [];
var redoStack:Array<Dynamic> = [];

// Find
var findQuery:String = "";
var findResults:Array<Dynamic> = [];
var findMode:Bool = false;

// Parsed
var parsedPkg:String = "";
var parsedClass:String = "";
var parsedExtends:String = "";
var parsedFuncs:Array<Dynamic> = [];
var parsedVars:Array<Dynamic> = [];
var parsedImports:Int = 0;

// ============ UI ============
var bg:FlxSprite;
var headerBg:FlxSprite;
var tabBarBg:FlxSprite;
var visualBg:FlxSprite;
var editorBg:FlxSprite;
var minimapBg:FlxSprite;
var statusBg:FlxSprite;
var findBg:FlxSprite;

var titleText:FlxText;
var hintText:FlxText;
var lineNumText:FlxText;
var codeText:FlxText;
var highlightSpr:FlxSprite;
var visualTitleText:FlxText;
var minimapTitleText:FlxText;
var minimapCodeText:FlxText;
var statusLabelText:FlxText;
var findLabelText:FlxText;
var findResultText:FlxText;

var visualItemsGroup:FlxTypedGroup<FlxSprite>;
var tabItemsGroup:FlxTypedGroup<FlxSprite>;

// Colors
var COL_BG = FlxColor.fromRGB(24, 24, 32);
var COL_PANEL = FlxColor.fromRGB(30, 30, 42);
var COL_PANEL2 = FlxColor.fromRGB(22, 22, 30);
var COL_EDITOR = FlxColor.fromRGB(26, 26, 36);
var COL_TEXT = FlxColor.fromRGB(215, 215, 230);
var COL_DIM = FlxColor.fromRGB(100, 100, 125);
var COL_ACCENT = FlxColor.fromRGB(80, 150, 255);
var COL_LINE_HL = FlxColor.fromRGB(36, 36, 50);
var COL_SELECT = FlxColor.fromRGB(50, 60, 95);
var COL_ERROR = FlxColor.fromRGB(255, 80, 80);
var COL_SUCCESS = FlxColor.fromRGB(80, 255, 120);

var VISUAL_W = 290;
var MINIMAP_W = 100;
var TOP_H = 34;
var TAB_H = 26;
var STATUS_H = 26;

// =============================================================================
//  CREATE
// =============================================================================
function create() {
	FlxG.mouse.visible = true;

	// Get file path from ModState data
	if (data != null && Reflect.hasField(data, "path")) filePath = data.path;

	// Background
	bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, COL_BG);
	add(bg);

	// Header
	headerBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, TOP_H, FlxColor.fromRGB(16, 16, 24));
	add(headerBg);

	titleText = new FlxText(12, 8, 200, "HX Editor", 15);
	titleText.color = COL_ACCENT;
	add(titleText);

	hintText = new FlxText(FlxG.width - 540, 9, 530, "Ctrl+S:Save  Ctrl+Z:Undo  Ctrl+F:Find  F5:Validate  F6:Format  ESC:Exit", 10);
	hintText.color = COL_DIM;
	add(hintText);

	// Tab bar
	tabBarBg = new FlxSprite(0, TOP_H).makeGraphic(FlxG.width, TAB_H, FlxColor.fromRGB(20, 20, 30));
	add(tabBarBg);

	tabItemsGroup = new FlxTypedGroup<FlxSprite>();
	add(tabItemsGroup);

	// Visual panel
	visualBg = new FlxSprite(0, TOP_H + TAB_H).makeGraphic(VISUAL_W, FlxG.height - TOP_H - TAB_H - STATUS_H, COL_PANEL);
	add(visualBg);

	visualTitleText = new FlxText(10, TOP_H + TAB_H + 6, VISUAL_W - 20, "Structure", 12);
	visualTitleText.color = COL_DIM;
	add(visualTitleText);

	visualItemsGroup = new FlxTypedGroup<FlxSprite>();
	add(visualItemsGroup);

	// Code editor area
	var ex = VISUAL_W;
	var ey = TOP_H + TAB_H;
	var ew = FlxG.width - VISUAL_W - MINIMAP_W;
	var eh = FlxG.height - TOP_H - TAB_H - STATUS_H;

	editorBg = new FlxSprite(ex, ey).makeGraphic(ew, eh, COL_EDITOR);
	add(editorBg);

	highlightSpr = new FlxSprite(ex + 48, ey).makeGraphic(ew - 52, lineH, COL_LINE_HL);
	highlightSpr.alpha = 0.6;
	add(highlightSpr);

	lineNumText = new FlxText(ex + 4, ey + 4, 42, "", 10);
	lineNumText.color = FlxColor.fromRGB(65, 65, 85);
	add(lineNumText);

	codeText = new FlxText(ex + 52, ey + 4, ew - 56, "", 12);
	codeText.color = COL_TEXT;
	add(codeText);

	// Minimap
	var mx = FlxG.width - MINIMAP_W;
	minimapBg = new FlxSprite(mx, ey).makeGraphic(MINIMAP_W, eh, COL_PANEL2);
	add(minimapBg);

	minimapTitleText = new FlxText(mx + 6, ey + 4, MINIMAP_W - 12, "Minimap", 9);
	minimapTitleText.color = COL_DIM;
	add(minimapTitleText);

	minimapCodeText = new FlxText(mx + 4, ey + 18, MINIMAP_W - 8, "", 3);
	minimapCodeText.color = FlxColor.fromRGB(75, 75, 95);
	add(minimapCodeText);

	// Status bar
	statusBg = new FlxSprite(0, FlxG.height - STATUS_H).makeGraphic(FlxG.width, STATUS_H, FlxColor.fromRGB(16, 16, 24));
	add(statusBg);

	statusLabelText = new FlxText(10, FlxG.height - STATUS_H + 5, FlxG.width - 20, "", 11);
	statusLabelText.color = COL_DIM;
	add(statusLabelText);

	// Find panel (hidden)
	findBg = new FlxSprite(ex, ey).makeGraphic(ew, 50, FlxColor.fromRGB(38, 38, 54));
	findBg.visible = false;
	add(findBg);

	findLabelText = new FlxText(ex + 8, ey + 6, ew - 16, "Find: (type to search, ENTER to confirm, ESC to close)", 11);
	findLabelText.color = COL_DIM;
	findLabelText.visible = false;
	add(findLabelText);

	findResultText = new FlxText(ex + 8, ey + 30, ew - 16, "", 10);
	findResultText.color = COL_DIM;
	findResultText.visible = false;
	add(findResultText);

	// Load file or create new
	if (filePath != null && filePath.length > 0) {
		loadFile(filePath);
	} else {
		content = "package;\n\nclass NewClass {\n\tpublic function new() {\n\t\t\n\t}\n}\n";
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
	tabItemsGroup.clear();
	var xOff:Float = 4;
	for (tab in tabs) {
		var isActive = tab == activeTab;
		var w = 130;
		var spr = new FlxSprite(xOff, TOP_H + 2).makeGraphic(w, TAB_H - 4, isActive ? FlxColor.fromRGB(40, 40, 58) : FlxColor.fromRGB(26, 26, 38));
		tabItemsGroup.add(spr);
		var displayName = tab.name;
		if (tab.dirty) displayName = "* " + displayName;
		var lbl = new FlxText(xOff + 6, TOP_H + 6, w - 12, displayName, 10);
		lbl.color = isActive ? FlxColor.WHITE : COL_DIM;
		tabItemsGroup.add(lbl);
		xOff += w + 2;
	}
}

// =============================================================================
//  PARSING
// =============================================================================
function parseContent() {
	parsedPkg = ""; parsedClass = ""; parsedExtends = ""; parsedFuncs = []; parsedVars = []; parsedImports = 0;

	var m1 = ~/^package\s+([\w.]+)\s*;/m;
	if (m1.match(content)) parsedPkg = m1.matched(1);

	var m2 = ~/class\s+(\w+)(?:\s+extends\s+([\w.]+))?/;
	if (m2.match(content)) { parsedClass = m2.matched(1); if (m2.matched(2) != null) parsedExtends = m2.matched(2); }

	var impM = ~/^import\s+/gm;
	var pos = 0;
	while (impM.matchSub(content, pos)) { parsedImports++; pos = impM.matchedPos().pos + impM.matchedPos().len; }

	var funcM = ~/((?:public|private|static|inline|override)\s+)*function\s+(\w+)/g;
	pos = 0;
	while (funcM.matchSub(content, pos)) {
		var mods = funcM.matched(1) != null ? funcM.matched(1) : "";
		parsedFuncs.push({ name: funcM.matched(2), pub: mods.indexOf("public") >= 0, stat: mods.indexOf("static") >= 0, over: mods.indexOf("override") >= 0, line: content.substr(0, funcM.matchedPos().pos).split("\n").length });
		pos = funcM.matchedPos().pos + funcM.matchedPos().len;
	}

	var varM = ~/((?:public|private|static)\s+)*var\s+(\w+)\s*(?::\s*(\w+))?/g;
	pos = 0;
	while (varM.matchSub(content, pos)) {
		var mods = varM.matched(1) != null ? varM.matched(1) : "";
		parsedVars.push({ name: varM.matched(2), type: varM.matched(3), pub: mods.indexOf("public") >= 0, stat: mods.indexOf("static") >= 0 });
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

	var lnBuf = new StringBuf();
	for (i in startLine...Math.min(startLine + visLines, lines.length)) { lnBuf.add("" + (i + 1) + "\n"); }
	lineNumText.text = lnBuf.toString();

	var displayLines = lines.slice(startLine, startLine + visLines);
	codeText.text = displayLines.join("\n");

	if (cursorLine >= startLine && cursorLine < startLine + visLines) {
		highlightSpr.y = ey + (cursorLine - startLine) * lineH + 2;
		highlightSpr.visible = true;
	} else {
		highlightSpr.visible = false;
	}
}

function refreshVisual() {
	visualItemsGroup.clear();
	var y:Float = TOP_H + TAB_H + 24;

	if (parsedPkg.length > 0) y = addVisItem("Package: " + parsedPkg, 0xFFAAAAFF, 8, y, 18);
	if (parsedImports > 0) y = addVisItem("Imports (" + parsedImports + ")", 0xFF88AA88, 8, y, 18);
	if (parsedClass.length > 0) {
		var clsText = "Class: " + parsedClass;
		if (parsedExtends.length > 0) clsText += " extends " + parsedExtends;
		y = addVisItem(clsText, 0xFFFFCC44, 8, y, 22);
	}

	if (parsedVars.length > 0) {
		y = addVisItem("Variables (" + parsedVars.length + ")", 0xFF88CCFF, 8, y + 4, 18);
		var showV = Math.min(parsedVars.length, 18);
		for (i in 0...showV) {
			var v = parsedVars[i];
			var icon = v.pub ? "[+]" : "[-]";
			if (v.stat) icon = "[S]";
			var typeStr = v.type != null ? ": " + v.type : "";
			y = addVisItem(" " + icon + " " + v.name + typeStr, v.pub ? 0xFF88FF88 : 0xFFFF8888, 16, y, 15);
		}
		if (parsedVars.length > showV) y = addVisItem("  ... +" + (parsedVars.length - showV), COL_DIM, 16, y, 15);
	}

	if (parsedFuncs.length > 0) {
		y = addVisItem("Functions (" + parsedFuncs.length + ")", 0xFFFFCC88, 8, y + 6, 18);
		var showF = Math.min(parsedFuncs.length, 22);
		for (i in 0...showF) {
			var f = parsedFuncs[i];
			var icon = f.pub ? "[+]" : "[-]";
			if (f.stat) icon = "[S]";
			if (f.over) icon = "[O]";
			y = addVisItem(" " + icon + " " + f.name + "()  L" + f.line, f.pub ? 0xFF88CCFF : 0xFFCC8888, 16, y, 15);
		}
		if (parsedFuncs.length > showF) y = addVisItem("  ... +" + (parsedFuncs.length - showF), COL_DIM, 16, y, 15);
	}

	y = addVisItem("---", COL_DIM, 8, y + 8, 12);
	y = addVisItem("Lines: " + lines.length + "  Funcs: " + parsedFuncs.length + "  Vars: " + parsedVars.length, FlxColor.fromRGB(75, 75, 95), 8, y, 14);
}

function addVisItem(text:String, color:Int, x:Float, y:Float, h:Float):Float {
	var lbl = new FlxText(x, y, VISUAL_W - x - 8, text, 10);
	lbl.color = color;
	visualItemsGroup.add(lbl);
	return y + h;
}

function refreshMinimap() { minimapCodeText.text = content; }

function refreshStatus() {
	var parts = [];
	parts.push(filePath.length > 0 ? filePath : "Untitled");
	if (isDirty) parts.push("* Modified");
	parts.push("Ln " + (cursorLine + 1) + ", Col " + (cursorCol + 1));
	parts.push(lines.length + " lines");
	if (findResults.length > 0) parts.push("Find: " + findResults.length);
	parts.push("Undo: " + undoStack.length);
	statusLabelText.text = parts.join("  |  ");
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

	findBg.visible = true;
	findLabelText.visible = true;
	findResultText.visible = true;
	findResultText.color = errors.length == 0 ? COL_SUCCESS : COL_ERROR;
	findResultText.text = errors.length == 0 ? "No syntax issues found" : "Issues: " + errors.join(", ");
	findLabelText.text = "Validation (press ESC to close)";
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
//  UPDATE
// =============================================================================
function update(elapsed:Float) {
	// Exit
	if (FlxG.keys.justPressed.ESCAPE) {
		if (findBg.visible) { findBg.visible = false; findLabelText.visible = false; findResultText.visible = false; findMode = false; return; }
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
			findMode = !findMode;
			findBg.visible = findMode;
			findLabelText.visible = findMode;
			findResultText.visible = findMode;
			if (findMode) { findQuery = ""; findLabelText.text = "Find: |  (type to search, ENTER to confirm)"; findResultText.text = ""; }
			return;
		}
	}

	// F5 = validate, F6 = format
	if (FlxG.keys.justPressed.F5) { validateSyntax(); return; }
	if (FlxG.keys.justPressed.F6) { formatCode(); return; }

	// Find input
	if (findMode) {
		if (FlxG.keys.justPressed.BACKSPACE) {
			findQuery = findQuery.substr(0, Math.max(0, findQuery.length - 1));
			findLabelText.text = "Find: " + findQuery + "|";
			performFind();
		} else if (FlxG.keys.justPressed.ENTER) {
			findLabelText.text = 'Find: "$findQuery"  (' + findResults.length + ' matches)';
		} else {
			for (code in 32...127) {
				if (FlxG.keys.justPressed(cast code)) {
					findQuery += String.fromCharCode(code);
					findLabelText.text = "Find: " + findQuery + "|";
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
	if (FlxG.keys.justPressed.RIGHT) {
		if (cursorLine < lines.length) cursorCol = Math.min(lines[cursorLine].length, cursorCol + 1);
		refreshStatus();
	}
	if (FlxG.keys.justPressed.LEFT) {
		cursorCol = Math.max(0, cursorCol - 1);
		refreshStatus();
	}

	// Page up/down
	if (FlxG.keys.justPressed.PAGEDOWN) {
		var visLines = Std.int((FlxG.height - TOP_H - TAB_H - STATUS_H) / lineH);
		cursorLine = Math.min(lines.length - 1, cursorLine + visLines);
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.PAGEUP) {
		var visLines = Std.int((FlxG.height - TOP_H - TAB_H - STATUS_H) / lineH);
		cursorLine = Math.max(0, cursorLine - visLines);
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
