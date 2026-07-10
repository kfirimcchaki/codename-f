// HX Code Editor - Codename Engine
// Place in: mods/hx-tools/data/states/HXEditor.hx
// Navigate: FlxG.switchState(new ModState("HXEditor", {path: "file.hx"}))

var filePath:String = "";
var fileName:String = "Untitled.hx";
var content:String = "";
var originalContent:String = "";
var dirty:Bool = false;
var lines:Array<String> = [];
var curLine:Int = 0;
var curCol:Int = 0;
var scrollY:Int = 0;
var scrollX:Int = 0;

// Selection
var selStartLine:Int = -1;
var selStartCol:Int = -1;
var selEndLine:Int = -1;
var selEndCol:Int = -1;
var hasSel:Bool = false;

// Undo
var undoStack:Array<Dynamic> = [];
var redoStack:Array<Dynamic> = [];

// Find
var findMode:Bool = false;
var findQuery:String = "";
var findResults:Array<Dynamic> = [];
var findIdx:Int = -1;

// Parsed info
var parsedPkg:String = "";
var parsedClass:String = "";
var parsedExtends:String = "";
var parsedFuncs:Array<Dynamic> = [];
var parsedVars:Array<Dynamic> = [];

// UI
var bg:FlxSprite;
var headerText:FlxText;
var lineNumText:FlxText;
var codeText:FlxText;
var cursorSpr:FlxSprite;
var highlightSpr:FlxSprite;
var selSpr:FlxSprite;
var visualText:FlxText;
var statusText:FlxText;
var findText:FlxText;
var findBg:FlxSprite;
var notifText:FlxText;
var notifTimer:Float = 0;
var blinkTimer:Float = 0;

// Layout
var VIS_W = 280;
var LINE_NUM_W = 44;
var LINE_H = 16;
var FONT_SIZE = 12;
var HEADER_H = 38;
var STATUS_H = 26;
var VIS_LINES = 40;

function create() {
	FlxG.mouse.visible = true;
	VIS_LINES = Math.floor((FlxG.height - HEADER_H - STATUS_H) / LINE_H);

	// Get file path
	if (data != null && Reflect.hasField(data, "path")) {
		filePath = Reflect.field(data, "path");
		loadFile(filePath);
	} else {
		content = "package;\n\nclass NewClass {\n\n\tpublic function new() {\n\t\t\n\t}\n}\n";
		originalContent = content;
		lines = content.split("\n");
		fileName = "Untitled.hx";
	}

	// Background
	bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(18, 18, 26));
	add(bg);

	// Header
	var headerBar = new FlxSprite(0, 0).makeGraphic(FlxG.width, HEADER_H, FlxColor.fromRGB(12, 12, 18));
	add(headerBar);
	var headerLine = new FlxSprite(0, HEADER_H - 1).makeGraphic(FlxG.width, 1, FlxColor.fromRGB(60, 120, 220));
	headerLine.alpha = 0.5;
	add(headerLine);

	headerText = new FlxText(12, 10, 600, "HX Editor", 16);
	headerText.color = FlxColor.fromRGB(80, 150, 255);
	add(headerText);

	var hints = new FlxText(FlxG.width - 500, 12, 490, "Ctrl+S:Save  Ctrl+Z:Undo  Ctrl+F:Find  F5:Validate  F6:Format  ESC:Exit", 10);
	hints.color = FlxColor.fromRGB(80, 80, 110);
	hints.alignment = "right";
	add(hints);

	// Visual panel background
	var visBg = new FlxSprite(0, HEADER_H).makeGraphic(VIS_W, FlxG.height - HEADER_H - STATUS_H, FlxColor.fromRGB(24, 24, 36));
	visBg.alpha = 0.8;
	add(visBg);

	var visTitle = new FlxText(8, HEADER_H + 6, VIS_W - 16, "Structure", 11);
	visTitle.color = FlxColor.fromRGB(80, 150, 255);
	add(visTitle);

	visualText = new FlxText(8, HEADER_H + 24, VIS_W - 16, "", 10);
	visualText.color = FlxColor.fromRGB(160, 160, 185);
	add(visualText);

	// Editor background
	var edBg = new FlxSprite(VIS_W, HEADER_H).makeGraphic(FlxG.width - VIS_W, FlxG.height - HEADER_H - STATUS_H, FlxColor.fromRGB(22, 22, 32));
	add(edBg);

	// Line number background
	var lnBg = new FlxSprite(VIS_W, HEADER_H).makeGraphic(LINE_NUM_W, FlxG.height - HEADER_H - STATUS_H, FlxColor.fromRGB(20, 20, 28));
	add(lnBg);

	// Current line highlight
	highlightSpr = new FlxSprite(VIS_W + LINE_NUM_W, HEADER_H).makeGraphic(FlxG.width - VIS_W - LINE_NUM_W, LINE_H, FlxColor.fromRGB(30, 30, 45));
	highlightSpr.alpha = 0.6;
	add(highlightSpr);

	// Selection highlight
	selSpr = new FlxSprite(VIS_W + LINE_NUM_W, HEADER_H).makeGraphic(100, LINE_H, FlxColor.fromRGB(50, 70, 120));
	selSpr.alpha = 0.5;
	selSpr.visible = false;
	add(selSpr);

	// Line numbers
	lineNumText = new FlxText(VIS_W + 4, HEADER_H + 4, LINE_NUM_W - 8, "", FONT_SIZE - 2);
	lineNumText.color = FlxColor.fromRGB(60, 60, 85);
	lineNumText.alignment = "right";
	add(lineNumText);

	// Code
	codeText = new FlxText(VIS_W + LINE_NUM_W + 4, HEADER_H + 4, FlxG.width - VIS_W - LINE_NUM_W - 8, "", FONT_SIZE);
	codeText.color = FlxColor.fromRGB(210, 210, 225);
	add(codeText);

	// Cursor
	cursorSpr = new FlxSprite(0, 0).makeGraphic(2, LINE_H, FlxColor.fromRGB(80, 150, 255));
	add(cursorSpr);

	// Status bar
	var statusBg = new FlxSprite(0, FlxG.height - STATUS_H).makeGraphic(FlxG.width, STATUS_H, FlxColor.fromRGB(12, 12, 18));
	add(statusBg);

	statusText = new FlxText(10, FlxG.height - STATUS_H + 5, FlxG.width - 20, "", 10);
	statusText.color = FlxColor.fromRGB(90, 90, 120);
	add(statusText);

	// Find bar (hidden)
	findBg = new FlxSprite(VIS_W, HEADER_H).makeGraphic(FlxG.width - VIS_W, 30, FlxColor.fromRGB(35, 35, 50));
	findBg.visible = false;
	add(findBg);

	findText = new FlxText(VIS_W + 10, HEADER_H + 7, FlxG.width - VIS_W - 20, "", 12);
	findText.color = FlxColor.fromRGB(200, 200, 220);
	findText.visible = false;
	add(findText);

	// Notification
	notifText = new FlxText(FlxG.width / 2 - 150, HEADER_H + 10, 300, "", 12);
	notifText.color = FlxColor.fromRGB(80, 220, 120);
	notifText.alignment = "center";
	notifText.visible = false;
	add(notifText);

	parseContent();
	refreshAll();
	notify("Editor ready", 2);
}

function loadFile(path:String) {
	try {
		var c = sys.io.File.getContent(path);
		if (c == null) c = "";
		filePath = path;
		fileName = haxe.io.Path.withoutDirectory(path);
		content = c;
		originalContent = c;
		lines = content.split("\n");
		dirty = false;
		curLine = 0;
		curCol = 0;
		scrollY = 0;
	} catch(e:Dynamic) {
		content = "// Error loading: " + path;
		lines = content.split("\n");
	}
}

function saveFile() {
	if (filePath.length == 0) { notify("No file path", 3); return; }
	try {
		sys.io.File.saveContent(filePath, content);
		originalContent = content;
		dirty = false;
		notify("Saved: " + fileName, 2);
		refreshHeader();
	} catch(e:Dynamic) {
		notify("Save error: " + Std.string(e), 4);
	}
}

// Text editing
function insertChar(ch:String) {
	pushUndo();
	if (hasSel) deleteSelection();
	var before = lines[curLine].substr(0, curCol);
	var after = lines[curLine].substr(curCol);
	lines[curLine] = before + ch + after;
	curCol += ch.length;
	updateContent();
}

function deleteBack() {
	if (hasSel) { deleteSelection(); return; }
	if (curCol > 0) {
		pushUndo();
		var before = lines[curLine].substr(0, curCol - 1);
		var after = lines[curLine].substr(curCol);
		lines[curLine] = before + after;
		curCol--;
	} else if (curLine > 0) {
		pushUndo();
		var prevLen = lines[curLine - 1].length;
		lines[curLine - 1] = lines[curLine - 1] + lines[curLine];
		lines.splice(curLine, 1);
		curLine--;
		curCol = prevLen;
	}
	updateContent();
}

function deleteForward() {
	if (hasSel) { deleteSelection(); return; }
	if (curCol < lines[curLine].length) {
		pushUndo();
		lines[curLine] = lines[curLine].substr(0, curCol) + lines[curLine].substr(curCol + 1);
	} else if (curLine < lines.length - 1) {
		pushUndo();
		lines[curLine] = lines[curLine] + lines[curLine + 1];
		lines.splice(curLine + 1, 1);
	}
	updateContent();
}

function insertNewline() {
	pushUndo();
	if (hasSel) deleteSelection();
	var before = lines[curLine].substr(0, curCol);
	var after = lines[curLine].substr(curCol);
	var indent = getIndent(curLine);
	if (StringTools.trim(before).endsWith("{") || StringTools.trim(before).endsWith(":")) indent += "\t";
	lines[curLine] = before;
	lines.insert(curLine + 1, indent + after);
	curLine++;
	curCol = indent.length;
	updateContent();
}

function getIndent(lineIdx:Int):String {
	if (lineIdx < 0 || lineIdx >= lines.length) return "";
	var line = lines[lineIdx];
	var indent = "";
	for (i in 0...line.length) {
		var ch = line.charAt(i);
		if (ch == "\t" || ch == " ") indent += ch;
		else break;
	}
	return indent;
}

function deleteSelection() {
	if (!hasSel) return;
	pushUndo();
	var sL = selStartLine; var sC = selStartCol;
	var eL = selEndLine; var eC = selEndCol;
	if (sL > eL || (sL == eL && sC > eC)) { var t = sL; sL = eL; eL = t; t = sC; sC = eC; eC = t; }
	if (sL == eL) {
		lines[sL] = lines[sL].substr(0, sC) + lines[sL].substr(eC);
	} else {
		lines[sL] = lines[sL].substr(0, sC) + lines[eL].substr(eC);
		for (i in 0...(eL - sL)) lines.splice(sL + 1, 1);
	}
	curLine = sL; curCol = sC;
	hasSel = false;
	updateContent();
}

function getSelectedText():String {
	if (!hasSel) return "";
	var sL = selStartLine; var sC = selStartCol;
	var eL = selEndLine; var eC = selEndCol;
	if (sL > eL || (sL == eL && sC > eC)) { var t = sL; sL = eL; eL = t; t = sC; sC = eC; eC = t; }
	if (sL == eL) return lines[sL].substr(sC, eC - sC);
	var result = lines[sL].substr(sC) + "\n";
	for (i in sL + 1...eL) result += lines[i] + "\n";
	result += lines[eL].substr(0, eC);
	return result;
}

function updateContent() {
	content = lines.join("\n");
	dirty = content != originalContent;
	parseContent();
	refreshAll();
}

// Undo/Redo
function pushUndo() {
	undoStack.push({ content: content, line: curLine, col: curCol });
	if (undoStack.length > 200) undoStack.shift();
	redoStack = [];
}

function undo() {
	if (undoStack.length == 0) { notify("Nothing to undo", 1); return; }
	var a = undoStack.pop();
	redoStack.push({ content: content, line: curLine, col: curCol });
	content = a.content;
	lines = content.split("\n");
	curLine = a.line;
	curCol = a.col;
	dirty = content != originalContent;
	refreshAll();
	notify("Undo (" + undoStack.length + " left)", 1);
}

function redo() {
	if (redoStack.length == 0) { notify("Nothing to redo", 1); return; }
	var a = redoStack.pop();
	undoStack.push({ content: content, line: curLine, col: curCol });
	content = a.content;
	lines = content.split("\n");
	curLine = a.line;
	curCol = a.col;
	dirty = content != originalContent;
	refreshAll();
	notify("Redo", 1);
}

// Parsing
function parseContent() {
	parsedPkg = ""; parsedClass = ""; parsedExtends = "";
	parsedFuncs = []; parsedVars = [];

	var pi = content.indexOf("package ");
	if (pi >= 0) {
		var pe = content.indexOf(";", pi);
		if (pe >= 0) parsedPkg = StringTools.trim(content.substr(pi + 8, pe - pi - 8));
	}

	var ci = content.indexOf("class ");
	if (ci >= 0) {
		var after = content.substr(ci + 6);
		var si = after.indexOf(" ");
		var bi = after.indexOf("{");
		var ni = after.indexOf("\n");
		var ei = si >= 0 ? si : (bi >= 0 ? bi : ni);
		if (ei > 0) parsedClass = StringTools.trim(after.substr(0, ei));
		var exti = content.indexOf("extends ");
		if (exti >= 0) {
			var afterExt = content.substr(exti + 8);
			var si2 = afterExt.indexOf(" ");
			var ni2 = afterExt.indexOf("\n");
			var ei2 = si2 >= 0 ? si2 : ni2;
			if (ei2 < 0) ei2 = afterExt.length;
			if (ei2 > 0) parsedExtends = StringTools.trim(afterExt.substr(0, ei2));
		}
	}

	// Functions
	var fp = 0;
	while (true) {
		var fi = content.indexOf("function ", fp);
		if (fi < 0) break;
		var lineNum = content.substr(0, fi).split("\n").length;
		var after = content.substr(fi + 9);
		var pi2 = after.indexOf("(");
		if (pi2 < 0 || pi2 > 40) { fp = fi + 9; continue; }
		var name = StringTools.trim(after.substr(0, pi2));
		if (name.length == 0 || name.indexOf(" ") >= 0 || name.indexOf("\n") >= 0) { fp = fi + 9; continue; }
		var ls = content.lastIndexOf("\n", fi) + 1;
		var before = content.substr(ls, fi - ls);
		parsedFuncs.push({ name: name, pub: before.indexOf("public") >= 0, stat: before.indexOf("static") >= 0, over: before.indexOf("override") >= 0, line: lineNum });
		fp = fi + 9;
	}

	// Variables
	var vp = 0;
	while (true) {
		var vi = content.indexOf("var ", vp);
		if (vi < 0) break;
		var lineNum = content.substr(0, vi).split("\n").length;
		var after = content.substr(vi + 4);
		var endIdx = after.length;
		for (ch in [" ", ":", ";", "="]) {
			var ci2 = after.indexOf(ch);
			if (ci2 >= 0 && ci2 < endIdx) endIdx = ci2;
		}
		var name = StringTools.trim(after.substr(0, endIdx));
		if (name.length > 0 && name.indexOf("\n") < 0) {
			var ls = content.lastIndexOf("\n", vi) + 1;
			var before = content.substr(ls, vi - ls);
			parsedVars.push({ name: name, pub: before.indexOf("public") >= 0, stat: before.indexOf("static") >= 0, line: lineNum });
		}
		vp = vi + 4;
	}
}

// Refresh
function refreshAll() {
	refreshHeader();
	refreshCode();
	refreshVisual();
	refreshStatus();
}

function refreshHeader() {
	var title = "HX Editor";
	if (filePath.length > 0) title += " - " + filePath;
	if (dirty) title += " *";
	headerText.text = title;
}

function refreshCode() {
	if (scrollY < 0) scrollY = 0;
	if (scrollY > Math.max(0, lines.length - VIS_LINES)) scrollY = Math.max(0, lines.length - VIS_LINES);

	var endLine = Math.min(scrollY + VIS_LINES, lines.length);

	// Line numbers
	var lnBuf = "";
	for (i in scrollY...endLine) lnBuf += "" + (i + 1) + "\n";
	lineNumText.text = lnBuf;

	// Code
	var codeBuf = "";
	for (i in scrollY...endLine) codeBuf += lines[i] + "\n";
	codeText.text = codeBuf;

	// Highlight current line
	if (curLine >= scrollY && curLine < endLine) {
		highlightSpr.y = HEADER_H + (curLine - scrollY) * LINE_H + 4;
		highlightSpr.visible = true;
	} else {
		highlightSpr.visible = false;
	}

	// Cursor position
	if (curLine >= scrollY && curLine < endLine) {
		cursorSpr.x = VIS_W + LINE_NUM_W + 4 + (curCol * (FONT_SIZE * 0.6));
		cursorSpr.y = HEADER_H + (curLine - scrollY) * LINE_H + 4;
		cursorSpr.visible = true;
	} else {
		cursorSpr.visible = false;
	}
}

function refreshVisual() {
	var buf = "";
	if (parsedPkg.length > 0) buf += "Package: " + parsedPkg + "\n";
	if (parsedClass.length > 0) {
		buf += "Class: " + parsedClass;
		if (parsedExtends.length > 0) buf += " extends " + parsedExtends;
		buf += "\n";
	}
	buf += "Lines: " + lines.length + "\n\n";

	if (parsedFuncs.length > 0) {
		buf += "Functions (" + parsedFuncs.length + "):\n";
		var show = Math.min(parsedFuncs.length, 20);
		for (i in 0...show) {
			var f = parsedFuncs[i];
			var icon = f.pub ? "+" : "-";
			if (f.stat) icon += "S";
			if (f.over) icon += "O";
			buf += " " + icon + " " + f.name + "() L" + f.line + "\n";
		}
		if (parsedFuncs.length > show) buf += " ...+" + (parsedFuncs.length - show) + "\n";
		buf += "\n";
	}

	if (parsedVars.length > 0) {
		buf += "Variables (" + parsedVars.length + "):\n";
		var show = Math.min(parsedVars.length, 15);
		for (i in 0...show) {
			var v = parsedVars[i];
			var icon = v.pub ? "+" : "-";
			if (v.stat) icon += "S";
			buf += " " + icon + " " + v.name + "\n";
		}
		if (parsedVars.length > show) buf += " ...+" + (parsedVars.length - show) + "\n";
	}

	visualText.text = buf;
}

function refreshStatus() {
	var left = "Ln " + (curLine + 1) + ", Col " + (curCol + 1);
	if (hasSel) left += "  |  Sel: " + getSelectedText().length + " chars";
	left += "  |  " + lines.length + " lines";
	if (dirty) left += "  |  * Modified";
	if (findResults.length > 0) left += "  |  Find: " + findResults.length;
	left += "  |  Undo: " + undoStack.length;
	statusText.text = left;
}

function ensureVisible() {
	if (curLine < scrollY) scrollY = curLine;
	if (curLine >= scrollY + VIS_LINES - 1) scrollY = curLine - VIS_LINES + 2;
	if (scrollY < 0) scrollY = 0;
}

function notify(msg:String, dur:Float) {
	notifText.text = msg;
	notifText.visible = true;
	notifTimer = dur;
}

// Find
function toggleFind() {
	findMode = !findMode;
	findBg.visible = findMode;
	findText.visible = findMode;
	if (findMode) {
		findQuery = "";
		findText.text = "Find: |";
		findResults = [];
		findIdx = -1;
	}
	refreshStatus();
}

function doFind() {
	findResults = [];
	findIdx = -1;
	if (findQuery.length == 0) return;
	var q = findQuery.toLowerCase();
	for (i in 0...lines.length) {
		var line = lines[i].toLowerCase();
		var pos = 0;
		while (true) {
			var idx = line.indexOf(q, pos);
			if (idx < 0) break;
			findResults.push({ line: i, col: idx });
			pos = idx + findQuery.length;
		}
	}
	findText.text = "Find: " + findQuery + "  (" + findResults.length + " matches)  ENTER:Next  ESC:Close";
	if (findResults.length > 0) {
		findIdx = 0;
		curLine = findResults[0].line;
		curCol = findResults[0].col;
		ensureVisible();
		refreshCode();
	}
}

function findNext() {
	if (findResults.length == 0) return;
	findIdx = (findIdx + 1) % findResults.length;
	curLine = findResults[findIdx].line;
	curCol = findResults[findIdx].col;
	ensureVisible();
	refreshCode();
	findText.text = "Find: " + findQuery + "  (" + (findIdx + 1) + "/" + findResults.length + ")  ENTER:Next  ESC:Close";
}

// Format
function formatCode() {
	pushUndo();
	var formatted:Array<String> = [];
	var indent = 0;
	for (line in lines) {
		var trimmed = StringTools.trim(line);
		if (trimmed.startsWith("}")) indent = Math.max(0, indent - 1);
		formatted.push(StringTools.lpad("", "\t", indent) + trimmed);
		if (trimmed.endsWith("{")) indent++;
	}
	content = formatted.join("\n");
	lines = content.split("\n");
	dirty = true;
	refreshAll();
	notify("Code formatted", 2);
}

// Validate
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
	if (braces != 0) errors.push("Braces:" + braces);
	if (brackets != 0) errors.push("Brackets:" + brackets);
	if (parens != 0) errors.push("Parens:" + parens);
	if (errors.length == 0) notify("No syntax issues", 3);
	else notify("Issues: " + errors.join(", "), 5);
}

// Go to function
function goToFunction() {
	if (parsedFuncs.length == 0) { notify("No functions", 2); return; }
	var next = null;
	for (f in parsedFuncs) {
		if (f.line > curLine + 1) { next = f; break; }
	}
	if (next == null) next = parsedFuncs[0];
	curLine = next.line - 1;
	curCol = 0;
	ensureVisible();
	refreshCode();
	notify("Jumped to: " + next.name + "()", 2);
}

function update(elapsed:Float) {
	// Notification fade
	if (notifTimer > 0) {
		notifTimer -= elapsed;
		if (notifTimer <= 0) notifText.visible = false;
		else if (notifTimer < 0.5) notifText.alpha = notifTimer * 2;
		else notifText.alpha = 1;
	}

	// Cursor blink
	blinkTimer += elapsed;
	if (blinkTimer > 0.5) blinkTimer = 0;
	cursorSpr.alpha = blinkTimer < 0.25 ? 0.9 : 0.2;

	// ESC
	if (FlxG.keys.justPressed.ESCAPE) {
		if (findMode) { toggleFind(); return; }
		if (dirty) saveFile();
		FlxG.switchState(new funkin.menus.MainMenuState());
		return;
	}

	// Find mode
	if (findMode) {
		if (FlxG.keys.justPressed.ENTER) { findNext(); return; }
		if (FlxG.keys.justPressed.BACKSPACE) {
			findQuery = findQuery.substr(0, Math.max(0, findQuery.length - 1));
			findText.text = "Find: " + findQuery + "|";
			doFind();
			return;
		}
		for (code in 32...127) {
			if (FlxG.keys.justPressed(cast code)) {
				findQuery += String.fromCharCode(code);
				findText.text = "Find: " + findQuery + "|";
				doFind();
				break;
			}
		}
		return;
	}

	// Ctrl shortcuts
	if (FlxG.keys.pressed.CONTROL) {
		if (FlxG.keys.justPressed.S) { saveFile(); return; }
		if (FlxG.keys.justPressed.Z && !FlxG.keys.pressed.SHIFT) { undo(); return; }
		if (FlxG.keys.justPressed.Z && FlxG.keys.pressed.SHIFT) { redo(); return; }
		if (FlxG.keys.justPressed.Y) { redo(); return; }
		if (FlxG.keys.justPressed.F) { toggleFind(); return; }
		if (FlxG.keys.justPressed.A) {
			selStartLine = 0; selStartCol = 0;
			selEndLine = lines.length - 1; selEndCol = lines[lines.length - 1].length;
			hasSel = true;
			refreshCode();
			return;
		}
		if (FlxG.keys.justPressed.C) {
			if (hasSel) { notify("Copied " + getSelectedText().length + " chars", 1.5); }
			return;
		}
		if (FlxG.keys.justPressed.X) {
			if (hasSel) { deleteSelection(); notify("Cut", 1.5); }
			return;
		}
		if (FlxG.keys.justPressed.V) { notify("Paste not available in HScript", 2); return; }
		if (FlxG.keys.justPressed.D) {
			// Duplicate line
			pushUndo();
			lines.insert(curLine + 1, lines[curLine]);
			curLine++;
			updateContent();
			notify("Line duplicated", 1);
			return;
		}
		if (FlxG.keys.justPressed.P) { goToFunction(); return; }
		if (FlxG.keys.justPressed.SLASH) {
			// Toggle comment
			pushUndo();
			var line = lines[curLine];
			var trimmed = StringTools.trim(line);
			if (trimmed.startsWith("//")) {
				var idx = line.indexOf("//");
				if (idx + 2 < line.length && line.charAt(idx + 2) == " ") {
					lines[curLine] = line.substr(0, idx) + line.substr(idx + 3);
				} else {
					lines[curLine] = line.substr(0, idx) + line.substr(idx + 2);
				}
			} else {
				var indent = getIndent(curLine);
				lines[curLine] = indent + "// " + trimmed;
			}
			updateContent();
			return;
		}
	}

	// F keys
	if (FlxG.keys.justPressed.F5) { validateSyntax(); return; }
	if (FlxG.keys.justPressed.F6) { formatCode(); return; }

	// Alt+UP/DOWN move line
	if (FlxG.keys.pressed.ALT) {
		if (FlxG.keys.justPressed.UP && curLine > 0) {
			pushUndo();
			var tmp = lines[curLine];
			lines[curLine] = lines[curLine - 1];
			lines[curLine - 1] = tmp;
			curLine--;
			updateContent();
			return;
		}
		if (FlxG.keys.justPressed.DOWN && curLine < lines.length - 1) {
			pushUndo();
			var tmp = lines[curLine];
			lines[curLine] = lines[curLine + 1];
			lines[curLine + 1] = tmp;
			curLine++;
			updateContent();
			return;
		}
	}

	// Tab indent
	if (FlxG.keys.justPressed.TAB && !FlxG.keys.pressed.CONTROL) {
		if (FlxG.keys.pressed.SHIFT) {
			// Unindent
			pushUndo();
			if (StringTools.startsWith(lines[curLine], "\t")) {
				lines[curLine] = lines[curLine].substr(1);
				curCol = Math.max(0, curCol - 1);
			}
			updateContent();
		} else {
			insertChar("\t");
		}
		return;
	}

	// Cursor movement
	if (FlxG.keys.justPressed.DOWN) {
		if (FlxG.keys.pressed.SHIFT) {
			if (!hasSel) { selStartLine = curLine; selStartCol = curCol; hasSel = true; }
		} else { hasSel = false; }
		curLine = Math.min(lines.length - 1, curLine + 1);
		curCol = Math.min(curCol, lines[curLine].length);
		if (FlxG.keys.pressed.SHIFT) { selEndLine = curLine; selEndCol = curCol; }
		ensureVisible();
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.UP) {
		if (FlxG.keys.pressed.SHIFT) {
			if (!hasSel) { selStartLine = curLine; selStartCol = curCol; hasSel = true; }
		} else { hasSel = false; }
		curLine = Math.max(0, curLine - 1);
		curCol = Math.min(curCol, lines[curLine].length);
		if (FlxG.keys.pressed.SHIFT) { selEndLine = curLine; selEndCol = curCol; }
		ensureVisible();
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.RIGHT) {
		if (FlxG.keys.pressed.SHIFT) {
			if (!hasSel) { selStartLine = curLine; selStartCol = curCol; hasSel = true; }
		} else { hasSel = false; }
		if (curCol < lines[curLine].length) curCol++;
		else if (curLine < lines.length - 1) { curLine++; curCol = 0; }
		if (FlxG.keys.pressed.SHIFT) { selEndLine = curLine; selEndCol = curCol; }
		ensureVisible();
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.LEFT) {
		if (FlxG.keys.pressed.SHIFT) {
			if (!hasSel) { selStartLine = curLine; selStartCol = curCol; hasSel = true; }
		} else { hasSel = false; }
		if (curCol > 0) curCol--;
		else if (curLine > 0) { curLine--; curCol = lines[curLine].length; }
		if (FlxG.keys.pressed.SHIFT) { selEndLine = curLine; selEndCol = curCol; }
		ensureVisible();
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.HOME) {
		var indent = getIndent(curLine);
		curCol = curCol == indent.length ? 0 : indent.length;
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.END) {
		curCol = lines[curLine].length;
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.PAGEDOWN) {
		curLine = Math.min(lines.length - 1, curLine + VIS_LINES);
		curCol = Math.min(curCol, lines[curLine].length);
		ensureVisible();
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.PAGEUP) {
		curLine = Math.max(0, curLine - VIS_LINES);
		curCol = Math.min(curCol, lines[curLine].length);
		ensureVisible();
		refreshCode();
		refreshStatus();
	}

	// Text input
	if (FlxG.keys.justPressed.ENTER) { insertNewline(); return; }
	if (FlxG.keys.justPressed.BACKSPACE) { deleteBack(); return; }
	if (FlxG.keys.justPressed.DELETE) { deleteForward(); return; }

	for (code in 32...127) {
		if (FlxG.keys.justPressed(cast code)) {
			insertChar(String.fromCharCode(code));
			break;
		}
	}

	// Mouse wheel scroll
	if (FlxG.mouse.wheel != 0) {
		scrollY -= FlxG.mouse.wheel * 3;
		if (scrollY < 0) scrollY = 0;
		if (scrollY > Math.max(0, lines.length - VIS_LINES)) scrollY = Math.max(0, lines.length - VIS_LINES);
		refreshCode();
	}
}
