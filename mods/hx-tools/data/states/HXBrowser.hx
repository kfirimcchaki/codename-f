// =============================================================================
//  HX BROWSER - Custom State for Codename Engine
//  Place in: mods/hx-tools/data/states/HXBrowser.hx
//  Redirect: [StateRedirects] StoryMenuState="HXBrowser"
// =============================================================================

// ============ DATA ============
var allFiles:Array<Dynamic> = [];
var filteredFiles:Array<Dynamic> = [];
var categories:Map<String, Dynamic> = [];
var rootCats:Array<Dynamic> = [];
var selectedFile:Dynamic = null;
var selectedCat:Dynamic = null;
var searchQuery:String = "";
var sortMode:Int = 0;
var fileIndex:Int = -1;
var catIndex:Int = 0;
var listScrollY:Float = 0;

// ============ UI ============
var bg:FlxSprite;
var headerBg:FlxSprite;
var catBg:FlxSprite;
var listBg:FlxSprite;
var previewBg:FlxSprite;
var infoBg:FlxSprite;
var statusBg:FlxSprite;
var titleText:FlxText;
var hintText:FlxText;
var catTitleText:FlxText;
var listTitleText:FlxText;
var previewTitleText:FlxText;
var previewCodeText:FlxText;
var infoLabelText:FlxText;
var statusLabelText:FlxText;
var searchLabelText:FlxText;
var catItemsGroup:FlxTypedGroup<FlxSprite>;
var listItemsGroup:FlxTypedGroup<FlxSprite>;

// Colors
var COL_BG = FlxColor.fromRGB(22, 22, 30);
var COL_PANEL = FlxColor.fromRGB(28, 28, 40);
var COL_PANEL2 = FlxColor.fromRGB(34, 34, 48);
var COL_TEXT = FlxColor.fromRGB(220, 220, 235);
var COL_DIM = FlxColor.fromRGB(110, 110, 135);
var COL_ACCENT = FlxColor.fromRGB(80, 150, 255);
var COL_SELECT = FlxColor.fromRGB(55, 70, 110);

var CAT_COLORS:Map<String, Int> = [
	"States" => 0xFF4488FF, "Substates" => 0xFF44AAFF, "Editors" => 0xFF44FF88,
	"Editor UI" => 0xFF88FF44, "Scripts" => 0xFFFFAA44, "Game" => 0xFFFF4466,
	"Backend" => 0xFF9944FF, "Menus" => 0xFF44FFDD, "Options" => 0xFFDDDD44,
	"Libraries" => 0xFF666666, "Other" => 0xFF888888
];

var CAT_W = 300;
var LIST_W = 380;
var TOP_H = 34;
var STATUS_H = 26;

// =============================================================================
//  CREATE
// =============================================================================
function create() {
	FlxG.mouse.visible = true;

	// Background
	bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, COL_BG);
	add(bg);

	// Header bar
	headerBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, TOP_H, FlxColor.fromRGB(16, 16, 24));
	add(headerBg);

	titleText = new FlxText(12, 8, 300, "HX File Browser", 16);
	titleText.color = COL_ACCENT;
	add(titleText);

	hintText = new FlxText(FlxG.width - 400, 9, 390, "Ctrl+E: Open in Editor  |  F2: Sort  |  ESC: Exit  |  F3: Back", 11);
	hintText.color = COL_DIM;
	add(hintText);

	// Category panel
	catBg = new FlxSprite(0, TOP_H).makeGraphic(CAT_W, FlxG.height - TOP_H - STATUS_H, COL_PANEL);
	add(catBg);

	catTitleText = new FlxText(10, TOP_H + 6, CAT_W - 20, "Categories", 13);
	catTitleText.color = COL_DIM;
	add(catTitleText);

	catItemsGroup = new FlxTypedGroup<FlxSprite>();
	add(catItemsGroup);

	// Search bar area
	var searchBg = new FlxSprite(CAT_W, TOP_H).makeGraphic(LIST_W, 28, FlxColor.fromRGB(24, 24, 34));
	add(searchBg);

	searchLabelText = new FlxText(CAT_W + 8, TOP_H + 6, LIST_W - 16, "Search: (press S to start typing)", 11);
	searchLabelText.color = COL_DIM;
	add(searchLabelText);

	// File list panel
	listBg = new FlxSprite(CAT_W, TOP_H + 28).makeGraphic(LIST_W, FlxG.height - TOP_H - 28 - STATUS_H - 155, COL_PANEL);
	add(listBg);

	listTitleText = new FlxText(CAT_W + 10, TOP_H + 34, LIST_W - 20, "Files", 12);
	listTitleText.color = COL_DIM;
	add(listTitleText);

	listItemsGroup = new FlxTypedGroup<FlxSprite>();
	add(listItemsGroup);

	// Preview panel
	var px = CAT_W + LIST_W;
	var pw = FlxG.width - px;
	previewBg = new FlxSprite(px, TOP_H).makeGraphic(pw, FlxG.height - TOP_H - STATUS_H, COL_PANEL2);
	add(previewBg);

	previewTitleText = new FlxText(px + 10, TOP_H + 8, pw - 20, "Preview -- select a file", 14);
	previewTitleText.color = COL_ACCENT;
	add(previewTitleText);

	previewCodeText = new FlxText(px + 10, TOP_H + 32, pw - 20, "", 10);
	previewCodeText.color = FlxColor.fromRGB(185, 185, 200);
	add(previewCodeText);

	// Info panel
	var iy = FlxG.height - STATUS_H - 155;
	infoBg = new FlxSprite(CAT_W, iy).makeGraphic(LIST_W, 155, FlxColor.fromRGB(24, 24, 34));
	add(infoBg);

	var infoTitle = new FlxText(CAT_W + 10, iy + 4, LIST_W - 20, "File Info", 11);
	infoTitle.color = COL_DIM;
	add(infoTitle);

	infoLabelText = new FlxText(CAT_W + 10, iy + 20, LIST_W - 20, "", 10);
	infoLabelText.color = FlxColor.fromRGB(155, 155, 175);
	add(infoLabelText);

	// Status bar
	statusBg = new FlxSprite(0, FlxG.height - STATUS_H).makeGraphic(FlxG.width, STATUS_H, FlxColor.fromRGB(16, 16, 24));
	add(statusBg);

	statusLabelText = new FlxText(10, FlxG.height - STATUS_H + 5, FlxG.width - 20, "", 11);
	statusLabelText.color = COL_DIM;
	add(statusLabelText);

	// Scan files
	scanAllFiles();

	if (rootCats.length > 0) {
		selectCategory(rootCats[0]);
	}

	refreshStatus();
}

// =============================================================================
//  SCANNING
// =============================================================================
function scanAllFiles() {
	allFiles = [];
	categories = [];
	rootCats = [];

	#if sys
	scanDir("source/");
	scanDir("mods/");
	#end

	for (f in allFiles) categorize(f);
	rootCats.sort(function(a, b) return Reflect.compare(a.order, b.order));
	for (c in rootCats) if (c.subs != null) c.subs.sort(function(a, b) return Reflect.compare(a.name, b.name));
	filteredFiles = allFiles.copy();
}

#if sys
function scanDir(dir:String) {
	try {
		if (!sys.FileSystem.exists(dir)) return;
		for (entry in sys.FileSystem.readDirectory(dir)) {
			var full = dir + entry;
			if (sys.FileSystem.isDirectory(full)) scanDir(full + "/");
			else if (entry.endsWith(".hx") && !fileExists(full)) {
				var info = makeFileInfo(full);
				if (info != null) allFiles.push(info);
			}
		}
	} catch(e:Dynamic) {}
}
#end

function fileExists(path:String):Bool {
	for (f in allFiles) if (f.path == path) return true;
	return false;
}

function makeFileInfo(path:String):Dynamic {
	try {
		var c:String = "";
		#if sys
		try { c = sys.io.File.getContent(path); } catch(e) { return null; }
		#else
		try { c = Assets.getText(path); } catch(e) { return null; }
		#end
		if (c == null || c.length == 0) return null;

		var lns = c.split("\n");
		var pkg = ""; var cls = ""; var ext = "";
		var m1 = ~/^package\s+([\w.]+)\s*;/m;
		if (m1.match(c)) pkg = m1.matched(1);
		var m2 = ~/(?:class|interface|abstract|enum)\s+(\w+)/;
		if (m2.match(c)) cls = m2.matched(1);
		var m3 = ~/class\s+\w+\s+extends\s+([\w.]+)/;
		if (m3.match(c)) ext = m3.matched(1);

		var funcs:Array<Dynamic> = [];
		var fm = ~/((?:public|private|static|inline|override)\s+)*function\s+(\w+)/g;
		var pos = 0;
		while (fm.matchSub(c, pos)) {
			var mods = fm.matched(1) != null ? fm.matched(1) : "";
			funcs.push({ name: fm.matched(2), pub: mods.indexOf("public") >= 0, stat: mods.indexOf("static") >= 0, over: mods.indexOf("override") >= 0 });
			pos = fm.matchedPos().pos + fm.matchedPos().len;
		}

		var vars:Array<Dynamic> = [];
		var vm = ~/((?:public|private|static)\s+)*var\s+(\w+)\s*(?::\s*(\w+))?/g;
		pos = 0;
		while (vm.matchSub(c, pos)) {
			var mods = vm.matched(1) != null ? vm.matched(1) : "";
			vars.push({ name: vm.matched(2), type: vm.matched(3), pub: mods.indexOf("public") >= 0 });
			pos = vm.matchedPos().pos + vm.matchedPos().len;
		}

		var cat = detectCat(path, c);
		return { path: path, fileName: haxe.io.Path.withoutDirectory(path), package: pkg, className: cls, extendsCls: ext, funcs: funcs, vars: vars, category: cat.main, subCategory: cat.sub, color: cat.color, content: c, lines: lns, lineCount: lns.length, size: c.length };
	} catch(e:Dynamic) { return null; }
}

function detectCat(path:String, c:String):Dynamic {
	var main = "Other"; var sub = ""; var col = 0xFF888888;
	if (c.indexOf("extends UIState") >= 0 && path.indexOf("editors/") >= 0) { main = "Editors"; sub = "Editor States"; col = CAT_COLORS["Editors"]; }
	else if (c.indexOf("extends MusicBeatState") >= 0 || c.indexOf("extends UIState") >= 0) { main = "States"; sub = "Game States"; col = CAT_COLORS["States"]; }
	else if (c.indexOf("extends MusicBeatSubstate") >= 0 || c.indexOf("extends FlxSubState") >= 0) { main = "States"; sub = "Substates"; col = CAT_COLORS["Substates"]; }
	else if (path.indexOf("editors/ui/") >= 0) { main = "Editors"; sub = "Editor UI"; col = CAT_COLORS["Editor UI"]; }
	else if (path.indexOf("editors/") >= 0) { main = "Editors"; sub = "Editor Support"; col = CAT_COLORS["Editors"]; }
	else if (path.indexOf("scripts") >= 0) { main = "Scripts"; sub = "HScript"; col = CAT_COLORS["Scripts"]; }
	else if (path.indexOf("game/") >= 0) { main = "Game"; sub = "Gameplay"; col = CAT_COLORS["Game"]; }
	else if (path.indexOf("backend/") >= 0) { main = "Backend"; sub = "Core"; col = CAT_COLORS["Backend"]; }
	else if (path.indexOf("menus/") >= 0) { main = "Menus"; sub = "Menu States"; col = CAT_COLORS["Menus"]; }
	else if (path.indexOf("options/") >= 0) { main = "Options"; sub = "Settings"; col = CAT_COLORS["Options"]; }
	else if (path.indexOf("flixel/") >= 0 || path.indexOf("haxe/") >= 0 || path.indexOf("lime/") >= 0 || path.indexOf("openfl/") >= 0) { main = "Libraries"; sub = "Extensions"; col = CAT_COLORS["Libraries"]; }
	return { main: main, sub: sub, color: col };
}

function categorize(info:Dynamic) {
	var cn = info.category;
	if (!categories.exists(cn)) {
		var cat = { name: cn, subs: [], files: [], color: info.color, expanded: true, order: getCatOrder(cn), total: 0 };
		categories.set(cn, cat);
		rootCats.push(cat);
	}
	var cat = categories.get(cn);
	cat.files.push(info);
	cat.total++;
	if (info.subCategory != null && info.subCategory.length > 0) {
		var found = false;
		for (s in cat.subs) { if (s.name == info.subCategory) { s.files.push(info); s.total++; found = true; break; } }
		if (!found) cat.subs.push({ name: info.subCategory, files: [info], total: 1, expanded: false });
	}
}

function getCatOrder(n:String):Int {
	return switch(n) { case "States": 0; case "Editors": 1; case "Game": 2; case "Backend": 3; case "Menus": 4; case "Options": 5; case "Scripts": 6; case "Libraries": 10; default: 8; };
}

// =============================================================================
//  SELECTION & REFRESH
// =============================================================================
function selectCategory(cat:Dynamic) {
	selectedCat = cat;
	filteredFiles = cat.files.copy();
	sortFiles();
	fileIndex = filteredFiles.length > 0 ? 0 : -1;
	if (fileIndex >= 0) selectFile(filteredFiles[0]);
	refreshCats();
	refreshList();
	refreshStatus();
}

function selectFile(file:Dynamic) {
	selectedFile = file;
	refreshList();
	refreshPreview();
	refreshInfo();
	refreshStatus();
}

function sortFiles() {
	switch(sortMode) {
		case 0: filteredFiles.sort(function(a, b) return Reflect.compare(a.fileName.toLowerCase(), b.fileName.toLowerCase()));
		case 1: filteredFiles.sort(function(a, b) return b.size - a.size);
		case 2: filteredFiles.sort(function(a, b) return b.lineCount - a.lineCount);
	}
}

function refreshCats() {
	catItemsGroup.clear();
	var y:Float = TOP_H + 26;
	for (cat in rootCats) {
		var arrow = cat.expanded ? "v" : ">";
		var isSel = cat == selectedCat;
		var spr = new FlxSprite(4, y).makeGraphic(CAT_W - 8, 24, isSel ? COL_SELECT : FlxColor.fromRGB(34, 34, 48));
		spr.alpha = isSel ? 0.8 : 0.4;
		catItemsGroup.add(spr);
		var lbl = new FlxText(12, y + 4, CAT_W - 24, arrow + " " + cat.name + "  (" + cat.total + ")", 12);
		lbl.color = cat.color;
		catItemsGroup.add(lbl);
		y += 26;
		if (cat.expanded) {
			for (sub in cat.subs) {
				var subLbl = new FlxText(24, y + 2, CAT_W - 36, "  - " + sub.name + " (" + sub.total + ")", 10);
				subLbl.color = cat.color;
				subLbl.alpha = 0.7;
				catItemsGroup.add(subLbl);
				y += 20;
			}
		}
	}
	var summ = new FlxText(10, y + 8, CAT_W - 20, allFiles.length + " files in " + rootCats.length + " categories", 10);
	summ.color = FlxColor.fromRGB(80, 80, 100);
	catItemsGroup.add(summ);
}

function refreshList() {
	listItemsGroup.clear();
	var y:Float = TOP_H + 54;
	var maxShow = Std.int((FlxG.height - TOP_H - 28 - STATUS_H - 155 - 30) / 22);
	var startIdx = Std.int(listScrollY / 22);
	for (i in 0...Math.min(filteredFiles.length - startIdx, maxShow)) {
		var idx = i + startIdx;
		if (idx < 0 || idx >= filteredFiles.length) continue;
		var f = filteredFiles[idx];
		var isSel = f == selectedFile;
		var spr = new FlxSprite(CAT_W + 4, y).makeGraphic(LIST_W - 8, 20, isSel ? COL_SELECT : FlxColor.fromRGB(30, 30, 44));
		spr.alpha = isSel ? 0.8 : 0.3;
		listItemsGroup.add(spr);
		var nameL = new FlxText(CAT_W + 10, y + 2, LIST_W - 120, f.fileName, 10);
		nameL.color = f.color;
		listItemsGroup.add(nameL);
		var sizeL = new FlxText(CAT_W + LIST_W - 100, y + 3, 90, f.lineCount + " ln", 9);
		sizeL.color = COL_DIM;
		sizeL.alignment = RIGHT;
		listItemsGroup.add(sizeL);
		y += 22;
	}
}

function refreshPreview() {
	if (selectedFile == null) { previewTitleText.text = "Preview -- select a file"; previewCodeText.text = ""; return; }
	previewTitleText.text = selectedFile.fileName + " -- " + (selectedFile.package.length > 0 ? selectedFile.package + "." : "") + selectedFile.className;
	previewTitleText.color = selectedFile.color;
	var display = selectedFile.lines.slice(0, 70).join("\n");
	if (selectedFile.lineCount > 70) display += "\n\n... (" + (selectedFile.lineCount - 70) + " more lines)";
	previewCodeText.text = display;
}

function refreshInfo() {
	if (selectedFile == null) { infoLabelText.text = ""; return; }
	var f = selectedFile;
	var info = "Package: " + f.package + "\nClass: " + f.className;
	if (f.extendsCls != null && f.extendsCls.length > 0) info += " extends " + f.extendsCls;
	info += "\nCategory: " + f.category + (f.subCategory != null && f.subCategory.length > 0 ? " / " + f.subCategory : "");
	info += "\nLines: " + f.lineCount + " | Size: " + formatSize(f.size);
	info += "\nFunctions: " + f.funcs.length + " | Variables: " + f.vars.length;
	if (f.funcs.length > 0) {
		info += "\n\nFunctions:";
		var show = Math.min(f.funcs.length, 8);
		for (i in 0...show) {
			var fn = f.funcs[i];
			var pfx = fn.pub ? "+" : "-";
			if (fn.stat) pfx += "S";
			if (fn.over) pfx += "O";
			info += "\n  " + pfx + " " + fn.name + "()";
		}
		if (f.funcs.length > show) info += "\n  ... +" + (f.funcs.length - show) + " more";
	}
	infoLabelText.text = info;
}

function refreshStatus() {
	var parts = ["Files: " + filteredFiles.length + "/" + allFiles.length];
	if (selectedCat != null) parts.push("Cat: " + selectedCat.name);
	if (selectedFile != null) parts.push("File: " + selectedFile.fileName);
	parts.push("Ctrl+E: Editor | ESC: Exit");
	statusLabelText.text = parts.join("  |  ");
}

function formatSize(bytes:Int):String {
	if (bytes < 1024) return bytes + " B";
	if (bytes < 1048576) return Math.round(bytes / 1024) + " KB";
	return (Math.round(bytes / 1048576 * 100) / 100) + " MB";
}

// =============================================================================
//  UPDATE
// =============================================================================
var searchMode:Bool = false;

function update(elapsed:Float) {
	// Exit
	if (FlxG.keys.justPressed.ESCAPE) {
		FlxG.switchState(new funkin.menus.MainMenuState());
		return;
	}

	// Open in editor
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.E && selectedFile != null) {
		FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: selectedFile.path}));
		return;
	}

	// Enter also opens editor
	if (FlxG.keys.justPressed.ENTER && selectedFile != null) {
		FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: selectedFile.path}));
		return;
	}

	// Sort cycle
	if (FlxG.keys.justPressed.F2) {
		sortMode = (sortMode + 1) % 3;
		sortFiles();
		refreshList();
		return;
	}

	// Search mode toggle
	if (FlxG.keys.justPressed.S && !searchMode) {
		searchMode = true;
		searchQuery = "";
		searchLabelText.text = "Search: |  (type to search, ENTER to confirm, ESC to cancel)";
		searchLabelText.color = COL_ACCENT;
		return;
	}

	if (searchMode) {
		if (FlxG.keys.justPressed.ESCAPE) {
			searchMode = false;
			searchQuery = "";
			searchLabelText.text = "Search: (press S to start typing)";
			searchLabelText.color = COL_DIM;
			if (selectedCat != null) { filteredFiles = selectedCat.files.copy(); sortFiles(); fileIndex = filteredFiles.length > 0 ? 0 : -1; if (fileIndex >= 0) selectFile(filteredFiles[0]); refreshList(); refreshStatus(); }
			return;
		}
		if (FlxG.keys.justPressed.ENTER) {
			searchMode = false;
			searchLabelText.text = 'Search: "$searchQuery"  (press S to search again)';
			searchLabelText.color = COL_DIM;
			return;
		}
		if (FlxG.keys.justPressed.BACKSPACE) {
			searchQuery = searchQuery.substr(0, Math.max(0, searchQuery.length - 1));
			searchLabelText.text = "Search: " + searchQuery + "|";
			doSearch();
			return;
		}
		// Type characters
		for (code in 32...127) {
			if (FlxG.keys.justPressed(cast code)) {
				searchQuery += String.fromCharCode(code);
				searchLabelText.text = "Search: " + searchQuery + "|";
				doSearch();
				break;
			}
		}
		return;
	}

	// Navigate categories with LEFT/RIGHT
	if (FlxG.keys.justPressed.LEFT) {
		if (selectedCat != null) selectedCat.expanded = !selectedCat.expanded;
		refreshCats();
	}

	// Navigate file list with UP/DOWN
	if (FlxG.keys.justPressed.DOWN) {
		if (filteredFiles.length > 0) {
			fileIndex = Math.min(filteredFiles.length - 1, fileIndex + 1);
			selectFile(filteredFiles[fileIndex]);
		}
	}
	if (FlxG.keys.justPressed.UP) {
		if (filteredFiles.length > 0) {
			fileIndex = Math.max(0, fileIndex - 1);
			selectFile(filteredFiles[fileIndex]);
		}
	}

	// Switch categories with TAB
	if (FlxG.keys.justPressed.TAB) {
		catIndex = (catIndex + 1) % rootCats.length;
		selectCategory(rootCats[catIndex]);
	}

	// Scroll with mouse wheel
	if (FlxG.mouse.wheel != 0) {
		listScrollY -= FlxG.mouse.wheel * 44;
		if (listScrollY < 0) listScrollY = 0;
		var maxScroll = (filteredFiles.length * 22) - (FlxG.height - TOP_H - 28 - STATUS_H - 155 - 30);
		if (maxScroll < 0) maxScroll = 0;
		if (listScrollY > maxScroll) listScrollY = maxScroll;
		refreshList();
	}
}

function doSearch() {
	if (searchQuery.length == 0) {
		if (selectedCat != null) filteredFiles = selectedCat.files.copy();
		else filteredFiles = allFiles.copy();
	} else {
		var q = searchQuery.toLowerCase();
		filteredFiles = [];
		for (f in allFiles) {
			if (f.fileName.toLowerCase().indexOf(q) >= 0 || f.className.toLowerCase().indexOf(q) >= 0 || f.package.toLowerCase().indexOf(q) >= 0) {
				filteredFiles.push(f);
			}
		}
	}
	sortFiles();
	fileIndex = filteredFiles.length > 0 ? 0 : -1;
	if (fileIndex >= 0) selectFile(filteredFiles[0]);
	refreshList();
	refreshStatus();
}
