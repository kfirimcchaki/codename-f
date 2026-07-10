// HX File Browser - Codename Engine
// Place in: mods/hx-tools/data/states/HXBrowser.hx
// Navigate: FlxG.switchState(new ModState("HXBrowser"))

var files:Array<Dynamic> = [];
var cats:Map<String, Array<Dynamic>> = [];
var catNames:Array<String> = [];
var curCat:Int = 0;
var curFile:Int = 0;
var catExpanded:Map<String, Bool> = [];
var searchQuery:String = "";
var searching:Bool = false;
var sortMode:Int = 0;
var scrollOffset:Int = 0;
var previewScroll:Int = 0;

// UI refs
var bg:FlxSprite;
var catText:FlxText;
var listText:FlxText;
var previewText:FlxText;
var previewLineNums:FlxText;
var infoText:FlxText;
var searchText:FlxText;
var statusText:FlxText;
var headerText:FlxText;
var cursorSpr:FlxSprite;
var catCursorSpr:FlxSprite;

// Layout
var CAT_X = 10;
var CAT_W = 280;
var LIST_X = 300;
var LIST_W = 370;
var PREV_X = 680;
var TOP_Y = 44;
var LINE_H = 18;
var MAX_LIST = 32;
var MAX_CAT = 28;

function create() {
	FlxG.mouse.visible = true;

	// Dark background
	bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(18, 18, 26));
	add(bg);

	// Header bar
	var headerBar = new FlxSprite(0, 0).makeGraphic(FlxG.width, 38, FlxColor.fromRGB(12, 12, 18));
	add(headerBar);
	var headerLine = new FlxSprite(0, 37).makeGraphic(FlxG.width, 1, FlxColor.fromRGB(60, 120, 220));
	headerLine.alpha = 0.5;
	add(headerLine);

	headerText = new FlxText(12, 10, 400, "HX File Browser", 16);
	headerText.color = FlxColor.fromRGB(80, 150, 255);
	add(headerText);

	var hintText = new FlxText(FlxG.width - 520, 12, 510, "UP/DOWN:Navigate  TAB:Switch Cat  ENTER:Open  S:Search  F2:Sort  ESC:Exit", 10);
	hintText.color = FlxColor.fromRGB(80, 80, 110);
	hintText.alignment = "right";
	add(hintText);

	// Panel backgrounds
	var catBg = new FlxSprite(5, TOP_Y).makeGraphic(CAT_W, FlxG.height - TOP_Y - 30, FlxColor.fromRGB(24, 24, 36));
	catBg.alpha = 0.8;
	add(catBg);

	var listBg = new FlxSprite(LIST_X - 5, TOP_Y).makeGraphic(LIST_W, FlxG.height - TOP_Y - 30 - 170, FlxColor.fromRGB(24, 24, 36));
	listBg.alpha = 0.8;
	add(listBg);

	var prevBg = new FlxSprite(PREV_X - 5, TOP_Y).makeGraphic(FlxG.width - PREV_X + 5, FlxG.height - TOP_Y - 30, FlxColor.fromRGB(22, 22, 32));
	prevBg.alpha = 0.8;
	add(prevBg);

	var infoBg = new FlxSprite(LIST_X - 5, FlxG.height - 30 - 170).makeGraphic(LIST_W, 170, FlxColor.fromRGB(24, 24, 36));
	infoBg.alpha = 0.8;
	add(infoBg);

	// Status bar
	var statusBg = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, FlxColor.fromRGB(12, 12, 18));
	add(statusBg);

	// Cursor highlights
	catCursorSpr = new FlxSprite(8, TOP_Y + 20).makeGraphic(CAT_W - 6, LINE_H, FlxColor.fromRGB(50, 70, 120));
	catCursorSpr.alpha = 0.7;
	add(catCursorSpr);

	cursorSpr = new FlxSprite(LIST_X, TOP_Y + 20).makeGraphic(LIST_W - 10, LINE_H, FlxColor.fromRGB(50, 70, 120));
	cursorSpr.alpha = 0.7;
	add(cursorSpr);

	// Text elements
	catText = new FlxText(10, TOP_Y + 4, CAT_W - 10, "", 11);
	catText.color = FlxColor.fromRGB(200, 200, 220);
	add(catText);

	listText = new FlxText(LIST_X, TOP_Y + 4, LIST_W - 10, "", 11);
	listText.color = FlxColor.fromRGB(200, 200, 220);
	add(listText);

	previewLineNums = new FlxText(PREV_X, TOP_Y + 24, 40, "", 10);
	previewLineNums.color = FlxColor.fromRGB(70, 70, 100);
	previewLineNums.alignment = "right";
	add(previewLineNums);

	previewText = new FlxText(PREV_X + 46, TOP_Y + 24, FlxG.width - PREV_X - 56, "", 10);
	previewText.color = FlxColor.fromRGB(190, 190, 210);
	add(previewText);

	var prevTitle = new FlxText(PREV_X, TOP_Y + 4, FlxG.width - PREV_X - 10, "Preview", 12);
	prevTitle.color = FlxColor.fromRGB(80, 150, 255);
	add(prevTitle);

	infoText = new FlxText(LIST_X, FlxG.height - 30 - 166, LIST_W - 10, "", 10);
	infoText.color = FlxColor.fromRGB(160, 160, 185);
	add(infoText);

	searchText = new FlxText(LIST_X, TOP_Y + 4, LIST_W - 10, "", 11);
	searchText.color = FlxColor.fromRGB(80, 150, 255);
	searchText.visible = false;
	add(searchText);

	statusText = new FlxText(10, FlxG.height - 22, FlxG.width - 20, "", 10);
	statusText.color = FlxColor.fromRGB(90, 90, 120);
	add(statusText);

	// Scan files
	scanFiles();
	refresh();
}

function scanFiles() {
	files = [];
	cats = [];
	catNames = [];

	scanDir("source/");
	scanDir("mods/");

	for (f in files) {
		var cat = f.cat;
		if (!cats.exists(cat)) {
			cats.set(cat, []);
			catNames.push(cat);
			catExpanded.set(cat, true);
		}
		cats.get(cat).push(f);
	}

	// Sort category names
	catNames.sort(Reflect.compare);
}

function scanDir(dir:String) {
	try {
		if (!sys.FileSystem.exists(dir)) return;
		var entries = sys.FileSystem.readDirectory(dir);
		for (entry in entries) {
			var full = dir + entry;
			try {
				if (sys.FileSystem.isDirectory(full)) {
					scanDir(full + "/");
				} else if (entry.endsWith(".hx")) {
					var info = parseFile(full);
					if (info != null) files.push(info);
				}
			} catch(e2:Dynamic) {}
		}
	} catch(e:Dynamic) {}
}

function parseFile(path:String):Dynamic {
	try {
		var c = sys.io.File.getContent(path);
		if (c == null || c.length == 0) return null;

		var lns = c.split("\n");
		var pkg = "";
		var cls = "";
		var ext = "";

		// Package
		var pi = c.indexOf("package ");
		if (pi >= 0) {
			var pe = c.indexOf(";", pi);
			if (pe >= 0) pkg = StringTools.trim(c.substr(pi + 8, pe - pi - 8));
		}

		// Class
		var ci = c.indexOf("class ");
		if (ci >= 0) {
			var after = c.substr(ci + 6);
			var si = after.indexOf(" ");
			var bi = after.indexOf("{");
			var ni = after.indexOf("\n");
			var ei = si >= 0 ? si : (bi >= 0 ? bi : ni);
			if (ei > 0) cls = StringTools.trim(after.substr(0, ei));
		} else {
			cls = haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(path));
		}

		// Extends
		var ei = c.indexOf("extends ");
		if (ei >= 0) {
			var after = c.substr(ei + 8);
			var si = after.indexOf(" ");
			var ni = after.indexOf("\n");
			var endI = si >= 0 ? si : ni;
			if (endI < 0) endI = after.length;
			if (endI > 0) ext = StringTools.trim(after.substr(0, endI));
		}

		// Functions
		var funcs:Array<Dynamic> = [];
		var fp = 0;
		while (true) {
			var fi = c.indexOf("function ", fp);
			if (fi < 0) break;
			var lineNum = c.substr(0, fi).split("\n").length;
			var after = c.substr(fi + 9);
			var pi2 = after.indexOf("(");
			if (pi2 < 0 || pi2 > 40) { fp = fi + 9; continue; }
			var name = StringTools.trim(after.substr(0, pi2));
			if (name.length == 0 || name.indexOf(" ") >= 0 || name.indexOf("\n") >= 0) { fp = fi + 9; continue; }
			var ls = c.lastIndexOf("\n", fi) + 1;
			var before = c.substr(ls, fi - ls);
			funcs.push({
				name: name,
				pub: before.indexOf("public") >= 0,
				stat: before.indexOf("static") >= 0,
				line: lineNum
			});
			fp = fi + 9;
		}

		// Variables
		var varCount = 0;
		var vp = 0;
		while (true) {
			var vi = c.indexOf("var ", vp);
			if (vi < 0) break;
			varCount++;
			vp = vi + 4;
		}

		// Imports
		var impCount = 0;
		var ip = 0;
		while (true) {
			var ii = c.indexOf("import ", ip);
			if (ii < 0) break;
			impCount++;
			ip = ii + 7;
		}

		// Category
		var cat = detectCat(path, c);

		return {
			path: path,
			name: haxe.io.Path.withoutDirectory(path),
			base: haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(path)),
			pkg: pkg,
			cls: cls,
			ext: ext,
			funcs: funcs,
			funcCount: funcs.length,
			varCount: varCount,
			impCount: impCount,
			cat: cat,
			lines: lns,
			lineCount: lns.length,
			size: c.length,
			content: c
		};
	} catch(e:Dynamic) { return null; }
}

function detectCat(path:String, c:String):String {
	if (c.indexOf("extends UIState") >= 0 && path.indexOf("editors/") >= 0) return "Editors";
	if (c.indexOf("extends MusicBeatState") >= 0) return "States";
	if (c.indexOf("extends MusicBeatSubstate") >= 0 || c.indexOf("extends FlxSubState") >= 0) return "Substates";
	if (path.indexOf("editors/ui/") >= 0) return "Editor UI";
	if (path.indexOf("editors/") >= 0) return "Editors";
	if (path.indexOf("data/scripts") >= 0 || path.indexOf("data/states") >= 0) return "Scripts";
	if (path.indexOf("game/") >= 0) return "Game";
	if (path.indexOf("backend/") >= 0) return "Backend";
	if (path.indexOf("menus/") >= 0) return "Menus";
	if (path.indexOf("options/") >= 0) return "Options";
	if (path.indexOf("flixel/") >= 0 || path.indexOf("haxe/") >= 0 || path.indexOf("lime/") >= 0 || path.indexOf("openfl/") >= 0 || path.indexOf("hscript/") >= 0) return "Libraries";
	return "Other";
}

function getCurFiles():Array<Dynamic> {
	if (searching && searchQuery.length > 0) {
		var q = searchQuery.toLowerCase();
		var result:Array<Dynamic> = [];
		for (f in files) {
			if (f.name.toLowerCase().indexOf(q) >= 0 || f.cls.toLowerCase().indexOf(q) >= 0 || f.pkg.toLowerCase().indexOf(q) >= 0) {
				result.push(f);
			}
		}
		return result;
	}
	if (curCat >= 0 && curCat < catNames.length) {
		return cats.get(catNames[curCat]);
	}
	return [];
}

function getSortedFiles(fls:Array<Dynamic>):Array<Dynamic> {
	var sorted = fls.copy();
	switch(sortMode) {
		case 0: sorted.sort(function(a, b) return Reflect.compare(a.name.toLowerCase(), b.name.toLowerCase()));
		case 1: sorted.sort(function(a, b) return b.lineCount - a.lineCount);
		case 2: sorted.sort(function(a, b) return b.funcCount - a.funcCount);
		case 3: sorted.sort(function(a, b) return b.size - a.size);
	}
	return sorted;
}

function refresh() {
	refreshCats();
	refreshList();
	refreshPreview();
	refreshInfo();
	refreshStatus();
}

function refreshCats() {
	var buf = "";
	for (i in 0...catNames.length) {
		var name = catNames[i];
		var count = cats.get(name).length;
		var arrow = catExpanded.exists(name) && catExpanded.get(name) ? "v" : ">";
		var marker = i == curCat ? " > " : "   ";
		buf += marker + arrow + " " + name + " (" + count + ")\n";
	}
	catText.text = buf;

	// Position cursor
	var visIdx = curCat - scrollOffset;
	if (visIdx >= 0 && visIdx < MAX_CAT) {
		catCursorSpr.y = TOP_Y + 20 + (visIdx * LINE_H);
		catCursorSpr.visible = true;
	} else {
		catCursorSpr.visible = false;
	}
}

function refreshList() {
	var fls = getSortedFiles(getCurFiles());
	if (curFile < 0) curFile = 0;
	if (curFile >= fls.length) curFile = fls.length - 1;

	var buf = "";
	var start = scrollOffset;
	var end = Math.min(start + MAX_LIST, fls.length);

	for (i in start...end) {
		var f = fls[i];
		var marker = i == curFile ? " > " : "   ";
		var info = f.lineCount + "ln";
		if (f.funcCount > 0) info += " " + f.funcCount + "fn";
		buf += marker + f.name + "  " + info + "\n";
	}

	if (searching) {
		listText.text = "Search: \"" + searchQuery + "\" (" + fls.length + " results)\n" + buf;
		searchText.visible = false;
	} else {
		listText.text = buf;
	}

	// Position cursor
	var visIdx = curFile - scrollOffset;
	if (visIdx >= 0 && visIdx < MAX_LIST && fls.length > 0) {
		var yOffset = searching ? LINE_H : 0;
		cursorSpr.y = TOP_Y + 20 + yOffset + (visIdx * LINE_H);
		cursorSpr.visible = true;
	} else {
		cursorSpr.visible = false;
	}
}

function refreshPreview() {
	var fls = getSortedFiles(getCurFiles());
	if (curFile < 0 || curFile >= fls.length) {
		previewText.text = "";
		previewLineNums.text = "";
		return;
	}

	var f = fls[curFile];
	var maxLines = 50;
	var start = previewScroll;
	var end = Math.min(start + maxLines, f.lines.length);

	var lnBuf = "";
	var codeBuf = "";
	for (i in start...end) {
		lnBuf += "" + (i + 1) + "\n";
		codeBuf += f.lines[i] + "\n";
	}
	previewLineNums.text = lnBuf;
	previewText.text = codeBuf;
}

function refreshInfo() {
	var fls = getSortedFiles(getCurFiles());
	if (curFile < 0 || curFile >= fls.length) {
		infoText.text = "";
		return;
	}

	var f = fls[curFile];
	var info = "File Info\n";
	info += "---\n";
	info += "Package: " + (f.pkg.length > 0 ? f.pkg : "(none)") + "\n";
	info += "Class: " + f.cls;
	if (f.ext.length > 0) info += " extends " + f.ext;
	info += "\n";
	info += "Lines: " + f.lineCount + "  |  Size: " + formatSize(f.size) + "\n";
	info += "Functions: " + f.funcCount + "  |  Variables: " + f.varCount + "  |  Imports: " + f.impCount + "\n";
	info += "Path: " + f.path + "\n";

	if (f.funcs.length > 0) {
		info += "\nFunctions:\n";
		var show = Math.min(f.funcs.length, 8);
		for (i in 0...show) {
			var fn = f.funcs[i];
			var pfx = fn.pub ? "+" : "-";
			if (fn.stat) pfx += "S";
			info += "  " + pfx + " " + fn.name + "()  [L" + fn.line + "]\n";
		}
		if (f.funcs.length > show) info += "  ... +" + (f.funcs.length - show) + " more\n";
	}

	infoText.text = info;
}

function refreshStatus() {
	var fls = getSortedFiles(getCurFiles());
	var sortNames = ["A-Z", "Lines", "Functions", "Size"];
	var left = files.length + " files  |  " + catNames.length + " categories";
	if (searching) left += "  |  Searching: \"" + searchQuery + "\"";
	var right = "Sort: " + sortNames[sortMode] + "  |  F1:Help  F2:Sort  S:Search  ESC:Exit";
	statusText.text = left + "     " + right;
}

function formatSize(bytes:Int):String {
	if (bytes < 1024) return bytes + "B";
	if (bytes < 1048576) return Math.round(bytes / 1024) + "KB";
	return (Math.round(bytes / 1048576 * 10) / 10) + "MB";
}

function openFile(f:Dynamic) {
	FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: f.path}));
}

function update(elapsed:Float) {
	// Search mode
	if (searching) {
		if (FlxG.keys.justPressed.ESCAPE) {
			searching = false;
			searchQuery = "";
			curFile = 0;
			scrollOffset = 0;
			refresh();
			return;
		}
		if (FlxG.keys.justPressed.ENTER) {
			searching = false;
			refresh();
			return;
		}
		if (FlxG.keys.justPressed.BACKSPACE) {
			searchQuery = searchQuery.substr(0, Math.max(0, searchQuery.length - 1));
			curFile = 0;
			scrollOffset = 0;
			refresh();
			return;
		}
		for (code in 32...127) {
			if (FlxG.keys.justPressed(cast code)) {
				searchQuery += String.fromCharCode(code);
				curFile = 0;
				scrollOffset = 0;
				refresh();
				break;
			}
		}
		return;
	}

	// Exit
	if (FlxG.keys.justPressed.ESCAPE) {
		FlxG.switchState(new funkin.menus.MainMenuState());
		return;
	}

	// Search
	if (FlxG.keys.justPressed.S || (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F)) {
		searching = true;
		searchQuery = "";
		curFile = 0;
		scrollOffset = 0;
		refresh();
		return;
	}

	// Sort
	if (FlxG.keys.justPressed.F2) {
		sortMode = (sortMode + 1) % 4;
		refresh();
		return;
	}

	// Tab: switch category
	if (FlxG.keys.justPressed.TAB) {
		if (catNames.length > 0) {
			curCat = (curCat + 1) % catNames.length;
			curFile = 0;
			scrollOffset = 0;
			previewScroll = 0;
			refresh();
		}
		return;
	}

	// Open file
	if (FlxG.keys.justPressed.ENTER || (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.E)) {
		var fls = getSortedFiles(getCurFiles());
		if (curFile >= 0 && curFile < fls.length) {
			openFile(fls[curFile]);
		}
		return;
	}

	// Navigate file list
	var fls = getSortedFiles(getCurFiles());
	if (FlxG.keys.justPressed.DOWN) {
		if (fls.length > 0) {
			curFile = Math.min(fls.length - 1, curFile + 1);
			if (curFile >= scrollOffset + MAX_LIST) scrollOffset = curFile - MAX_LIST + 1;
			previewScroll = 0;
			refreshList();
			refreshPreview();
			refreshInfo();
		}
	}
	if (FlxG.keys.justPressed.UP) {
		if (fls.length > 0) {
			curFile = Math.max(0, curFile - 1);
			if (curFile < scrollOffset) scrollOffset = curFile;
			previewScroll = 0;
			refreshList();
			refreshPreview();
			refreshInfo();
		}
	}

	// Navigate categories with LEFT/RIGHT when not in file list
	if (FlxG.keys.justPressed.LEFT) {
		if (catNames.length > 0) {
			var name = catNames[curCat];
			if (catExpanded.exists(name)) catExpanded.set(name, !catExpanded.get(name));
			refreshCats();
		}
	}

	// Preview scroll with SHIFT+wheel or SHIFT+UP/DOWN
	if (FlxG.keys.pressed.SHIFT) {
		if (FlxG.keys.justPressed.DOWN) {
			previewScroll += 5;
			refreshPreview();
		}
		if (FlxG.keys.justPressed.UP) {
			previewScroll = Math.max(0, previewScroll - 5);
			refreshPreview();
		}
	}

	// Mouse wheel scroll
	if (FlxG.mouse.wheel != 0) {
		if (FlxG.keys.pressed.SHIFT) {
			previewScroll -= FlxG.mouse.wheel * 5;
			if (previewScroll < 0) previewScroll = 0;
			refreshPreview();
		} else {
			var oldFile = curFile;
			curFile -= FlxG.mouse.wheel * 3;
			if (curFile < 0) curFile = 0;
			if (curFile >= fls.length) curFile = fls.length - 1;
			if (curFile >= scrollOffset + MAX_LIST) scrollOffset = curFile - MAX_LIST + 1;
			if (curFile < scrollOffset) scrollOffset = curFile;
			if (curFile != oldFile) {
				previewScroll = 0;
				refreshList();
				refreshPreview();
				refreshInfo();
			}
		}
	}

	// Page up/down
	if (FlxG.keys.justPressed.PAGEDOWN) {
		curFile = Math.min(fls.length - 1, curFile + MAX_LIST);
		if (curFile >= scrollOffset + MAX_LIST) scrollOffset = curFile - MAX_LIST + 1;
		previewScroll = 0;
		refreshList();
		refreshPreview();
		refreshInfo();
	}
	if (FlxG.keys.justPressed.PAGEUP) {
		curFile = Math.max(0, curFile - MAX_LIST);
		if (curFile < scrollOffset) scrollOffset = curFile;
		previewScroll = 0;
		refreshList();
		refreshPreview();
		refreshInfo();
	}
}
