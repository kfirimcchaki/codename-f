// =============================================================================
//  HX BROWSER - Full HScript State (works via ModState / StateRedirects)
//  Place in: mods/hx-tools/data/states/HXBrowser.hx
//  Redirect: [StateRedirects] StoryMenuState="HXBrowser"
//  Or open:  FlxG.switchState(new ModState("HXBrowser"))
// =============================================================================

using StringTools;

// ============ LAYOUT ============
var CAT_W = 300;
var LIST_W = 380;
var TOP_H = 34;
var STATUS_H = 26;
var INFO_H = 160;

// ============ DATA ============
var allFiles:Array<Dynamic> = [];
var filteredFiles:Array<Dynamic> = [];
var categories:Map<String, Dynamic> = [];
var rootCats:Array<Dynamic> = [];
var selectedFile:Dynamic = null;
var selectedCat:Dynamic = null;
var searchQuery:String = "";
var sortMode:Int = 0;

// ============ UI ============
var uiCam:FlxCamera;
var catGroup:FlxTypedGroup<FlxSprite>;
var listGroup:FlxTypedGroup<FlxSprite>;
var previewText:FlxText;
var previewTitle:FlxText;
var infoText:FlxText;
var statusText:FlxText;
var searchInput:FlxText;
var searchBg:FlxSprite;
var listScrollY:Float = 0;
var fileIndex:Int = -1;

// Colors
var COL_BG = FlxColor.fromRGB(22, 22, 30);
var COL_PANEL = FlxColor.fromRGB(28, 28, 40);
var COL_PANEL2 = FlxColor.fromRGB(34, 34, 48);
var COL_TEXT = FlxColor.fromRGB(220, 220, 235);
var COL_DIM = FlxColor.fromRGB(110, 110, 135);
var COL_ACCENT = FlxColor.fromRGB(80, 150, 255);
var COL_SELECT = FlxColor.fromRGB(55, 70, 110);
var COL_HOVER = FlxColor.fromRGB(42, 42, 60);

var CAT_COLORS:Map<String, Int> = [
	"States" => 0xFF4488FF, "Substates" => 0xFF44AAFF, "Editors" => 0xFF44FF88,
	"Editor UI" => 0xFF88FF44, "Scripts" => 0xFFFFAA44, "Game" => 0xFFFF4466,
	"Backend" => 0xFF9944FF, "Menus" => 0xFF44FFDD, "Options" => 0xFFDDDD44,
	"Libraries" => 0xFF666666, "Other" => 0xFF888888
];

// =============================================================================
//  CREATE - called by MusicBeatState after its own create()
// =============================================================================
function create() {
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

	var title = new FlxText(12, 8, 300, "HX File Browser", 16);
	title.color = COL_ACCENT;
	title.scrollFactor.set();
	add(title);

	var hint = new FlxText(FlxG.width - 350, 9, 340, "Ctrl+E: Open in Editor  |  F2: Sort  |  ESC: Exit", 11);
	hint.color = COL_DIM;
	hint.scrollFactor.set();
	add(hint);

	// Search bar
	searchBg = new FlxSprite(CAT_W, TOP_H).makeGraphic(LIST_W, 30, FlxColor.fromRGB(24, 24, 34));
	searchBg.scrollFactor.set();
	add(searchBg);

	var searchLbl = new FlxText(CAT_W + 8, TOP_H + 7, 55, "Search:", 12);
	searchLbl.color = COL_DIM;
	searchLbl.scrollFactor.set();
	add(searchLbl);

	searchInput = new FlxText(CAT_W + 65, TOP_H + 7, LIST_W - 75, "", 12);
	searchInput.color = COL_TEXT;
	searchInput.scrollFactor.set();
	add(searchInput);

	// Category panel background
	var catBg = new FlxSprite(0, TOP_H).makeGraphic(CAT_W, FlxG.height - TOP_H - STATUS_H, COL_PANEL);
	catBg.scrollFactor.set();
	add(catBg);

	var catTitle = new FlxText(10, TOP_H + 6, CAT_W - 20, "Categories", 13);
	catTitle.color = COL_DIM;
	catTitle.scrollFactor.set();
	add(catTitle);

	catGroup = new FlxTypedGroup<FlxSprite>();
	add(catGroup);

	// File list panel background
	var listBg = new FlxSprite(CAT_W, TOP_H + 30).makeGraphic(LIST_W, FlxG.height - TOP_H - 30 - STATUS_H - INFO_H, COL_PANEL);
	listBg.scrollFactor.set();
	add(listBg);

	var listTitle = new FlxText(CAT_W + 10, TOP_H + 36, LIST_W - 20, "Files", 13);
	listTitle.color = COL_DIM;
	listTitle.scrollFactor.set();
	add(listTitle);

	listGroup = new FlxTypedGroup<FlxSprite>();
	add(listGroup);

	// Preview panel
	var px = CAT_W + LIST_W;
	var pw = FlxG.width - px;
	var previewBg = new FlxSprite(px, TOP_H).makeGraphic(pw, FlxG.height - TOP_H - STATUS_H, COL_PANEL2);
	previewBg.scrollFactor.set();
	add(previewBg);

	previewTitle = new FlxText(px + 10, TOP_H + 8, pw - 20, "Preview — select a file", 14);
	previewTitle.color = COL_ACCENT;
	previewTitle.scrollFactor.set();
	add(previewTitle);

	previewText = new FlxText(px + 10, TOP_H + 34, pw - 20, "", 11);
	previewText.color = FlxColor.fromRGB(190, 190, 205);
	previewText.scrollFactor.set();
	add(previewText);

	// Info panel
	var iy = FlxG.height - STATUS_H - INFO_H;
	var infoBgSpr = new FlxSprite(CAT_W, iy).makeGraphic(LIST_W, INFO_H, FlxColor.fromRGB(24, 24, 34));
	infoBgSpr.scrollFactor.set();
	add(infoBgSpr);

	var infoTitle = new FlxText(CAT_W + 10, iy + 4, LIST_W - 20, "File Info", 12);
	infoTitle.color = COL_DIM;
	infoTitle.scrollFactor.set();
	add(infoTitle);

	infoText = new FlxText(CAT_W + 10, iy + 22, LIST_W - 20, "", 11);
	infoText.color = FlxColor.fromRGB(160, 160, 180);
	infoText.scrollFactor.set();
	add(infoText);

	// Status bar
	var statusBg = new FlxSprite(0, FlxG.height - STATUS_H).makeGraphic(FlxG.width, STATUS_H, FlxColor.fromRGB(16, 16, 24));
	statusBg.scrollFactor.set();
	add(statusBg);

	statusText = new FlxText(10, FlxG.height - STATUS_H + 5, FlxG.width - 20, "", 11);
	statusText.color = COL_DIM;
	statusText.scrollFactor.set();
	add(statusText);

	// Scan files
	scanAllFiles();

	// Select first category
	if (rootCats.length > 0) selectCategory(rootCats[0]);

	refreshStatus();
}

// =============================================================================
//  FILE SCANNING
// =============================================================================
function scanAllFiles() {
	allFiles = [];
	categories = [];
	rootCats = [];

	#if sys
	scanDir("source/");
	scanDir("mods/");
	#end

	// Also try assets
	try {
		var list = Assets.list();
		for (p in list) {
			if (p.endsWith(".hx") && !fileExists(p)) {
				var info = makeFileInfo(p);
				if (info != null) allFiles.push(info);
			}
		}
	} catch(e:Dynamic) {}

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
			if (sys.FileSystem.isDirectory(full)) {
				scanDir(full + "/");
			} else if (entry.endsWith(".hx")) {
				if (!fileExists(full)) {
					var info = makeFileInfo(full);
					if (info != null) allFiles.push(info);
				}
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
		var content:String = "";
		#if sys
		try { content = sys.io.File.getContent(path); } catch(e) { return null; }
		#else
		try { content = Assets.getText(path); } catch(e) { return null; }
		#end
		if (content == null || content.length == 0) return null;

		var lines = content.split("\n");
		var pkg = ""; var cls = ""; var ext = "";
		var pkgM = ~/^package\s+([\w.]+)\s*;/m;
		if (pkgM.match(content)) pkg = pkgM.matched(1);
		var clsM = ~/(?:class|interface|abstract|enum)\s+(\w+)/;
		if (clsM.match(content)) cls = clsM.matched(1);
		var extM = ~/class\s+\w+\s+extends\s+([\w.]+)/;
		if (extM.match(content)) ext = extM.matched(1);

		var funcs:Array<Dynamic> = [];
		var funcM = ~/((?:public|private|static|inline|override)\s+)*function\s+(\w+)\s*\(/g;
		var pos = 0;
		while (funcM.matchSub(content, pos)) {
			var mods = funcM.matched(1) != null ? funcM.matched(1) : "";
			funcs.push({
				name: funcM.matched(2),
				isPublic: mods.indexOf("public") >= 0,
				isStatic: mods.indexOf("static") >= 0,
				isOverride: mods.indexOf("override") >= 0,
				line: content.substr(0, funcM.matchedPos().pos).split("\n").length
			});
			pos = funcM.matchedPos().pos + funcM.matchedPos().len;
		}

		var vars:Array<Dynamic> = [];
		var varM = ~/((?:public|private|static)\s+)*var\s+(\w+)\s*(?::\s*(\w+))?/g;
		pos = 0;
		while (varM.matchSub(content, pos)) {
			var mods = varM.matched(1) != null ? varM.matched(1) : "";
			vars.push({
				name: varM.matched(2),
				type: varM.matched(3),
				isPublic: mods.indexOf("public") >= 0,
				isStatic: mods.indexOf("static") >= 0
			});
			pos = varM.matchedPos().pos + varM.matchedPos().len;
		}

		var cat = detectCat(path, content);

		return {
			path: path,
			fileName: haxe.io.Path.withoutDirectory(path),
			package: pkg, className: cls, extendsCls: ext,
			funcs: funcs, vars: vars,
			category: cat.main, subCategory: cat.sub, color: cat.color,
			content: content, lines: lines, lineCount: lines.length,
			size: content.length
		};
	} catch(e:Dynamic) { return null; }
}

function detectCat(path:String, content:String):Dynamic {
	var main = "Other"; var sub = ""; var col = 0xFF888888;
	if (content.indexOf("extends UIState") >= 0 && path.indexOf("editors/") >= 0) { main = "Editors"; sub = "Editor States"; col = CAT_COLORS["Editors"]; }
	else if (content.indexOf("extends MusicBeatState") >= 0 || content.indexOf("extends UIState") >= 0) { main = "States"; sub = "Game States"; col = CAT_COLORS["States"]; }
	else if (content.indexOf("extends MusicBeatSubstate") >= 0 || content.indexOf("extends FlxSubState") >= 0) { main = "States"; sub = "Substates"; col = CAT_COLORS["Substates"]; }
	else if (path.indexOf("editors/ui/") >= 0) { main = "Editors"; sub = "Editor UI"; col = CAT_COLORS["Editor UI"]; }
	else if (path.indexOf("editors/") >= 0) { main = "Editors"; sub = "Editor Support"; col = CAT_COLORS["Editors"]; }
	else if (path.indexOf("scripts") >= 0) { main = "Scripts"; sub = "HScript"; col = CAT_COLORS["Scripts"]; }
	else if (path.indexOf("game/") >= 0) { main = "Game"; sub = "Gameplay"; col = CAT_COLORS["Game"]; }
	else if (path.indexOf("backend/") >= 0) { main = "Backend"; sub = "Core"; col = CAT_COLORS["Backend"]; }
	else if (path.indexOf("menus/") >= 0) { main = "Menus"; sub = "Menu States"; col = CAT_COLORS["Menus"]; }
	else if (path.indexOf("options/") >= 0) { main = "Options"; sub = "Settings"; col = CAT_COLORS["Options"]; }
	else if (path.indexOf("flixel/") >= 0 || path.indexOf("haxe/") >= 0 || path.indexOf("lime/") >= 0 || path.indexOf("openfl/") >= 0 || path.indexOf("hscript/") >= 0) { main = "Libraries"; sub = "Extensions"; col = CAT_COLORS["Libraries"]; }
	return { main: main, sub: sub, color: col };
}

function categorize(info:Dynamic) {
	var catName = info.category;
	if (!categories.exists(catName)) {
		var cat = { name: catName, subs: [], files: [], color: info.color, expanded: true, order: getCatOrder(catName), total: 0 };
		categories.set(catName, cat);
		rootCats.push(cat);
	}
	var cat = categories.get(catName);
	cat.files.push(info);
	cat.total++;
	if (info.subCategory != null && info.subCategory.length > 0) {
		var found = false;
		for (s in cat.subs) { if (s.name == info.subCategory) { s.files.push(info); s.total++; found = true; break; } }
		if (!found) cat.subs.push({ name: info.subCategory, files: [info], total: 1, expanded: false });
	}
}

function getCatOrder(name:String):Int {
	return switch(name) { case "States": 0; case "Editors": 1; case "Game": 2; case "Backend": 3; case "Menus": 4; case "Options": 5; case "Scripts": 6; case "Libraries": 10; default: 8; };
}

// =============================================================================
//  SELECTION & REFRESH
// =============================================================================
function selectCategory(cat:Dynamic) {
	selectedCat = cat;
	filteredFiles = cat.files.copy();
	if (searchQuery.length > 0) applyFilter();
	else sortFiles();
	fileIndex = filteredFiles.length > 0 ? 0 : -1;
	if (fileIndex >= 0) selectFile(filteredFiles[0]);
	refreshCategories();
	refreshFileList();
	refreshStatus();
}

function selectFile(file:Dynamic) {
	selectedFile = file;
	refreshFileList();
	refreshPreview();
	refreshInfo();
	refreshStatus();
}

function applyFilter() {
	if (searchQuery.length == 0) {
		filteredFiles = selectedCat != null ? selectedCat.files.copy() : allFiles.copy();
	} else {
		var q = searchQuery.toLowerCase();
		filteredFiles = allFiles.filter(function(f) return f.fileName.toLowerCase().indexOf(q) >= 0 || f.className.toLowerCase().indexOf(q) >= 0 || f.package.toLowerCase().indexOf(q) >= 0);
	}
	sortFiles();
	fileIndex = filteredFiles.length > 0 ? 0 : -1;
}

function sortFiles() {
	switch(sortMode) {
		case 0: filteredFiles.sort(function(a, b) return Reflect.compare(a.fileName.toLowerCase(), b.fileName.toLowerCase()));
		case 1: filteredFiles.sort(function(a, b) return b.size - a.size);
		case 2: filteredFiles.sort(function(a, b) return b.lineCount - a.lineCount);
	}
}

function refreshCategories() {
	catGroup.clear();
	var y:Float = TOP_H + 26;
	for (cat in rootCats) {
		var arrow = cat.expanded ? "▼" : "▶";
		var bg = new FlxSprite(4, y).makeGraphic(CAT_W - 8, 26, cat == selectedCat ? COL_SELECT : FlxColor.fromRGB(34, 34, 48));
		bg.alpha = cat == selectedCat ? 0.8 : 0.4;
		bg.scrollFactor.set();
		catGroup.add(bg);
		var lbl = new FlxText(12, y + 5, CAT_W - 24, arrow + " " + cat.name + "  (" + cat.total + ")", 12);
		lbl.color = cat.color;
		lbl.scrollFactor.set();
		catGroup.add(lbl);
		y += 28;

		if (cat.expanded) {
			for (sub in cat.subs) {
				var subBg = new FlxSprite(16, y).makeGraphic(CAT_W - 20, 22, FlxColor.fromRGB(30, 30, 44));
				subBg.alpha = 0.3;
				subBg.scrollFactor.set();
				catGroup.add(subBg);
				var subLbl = new FlxText(24, y + 3, CAT_W - 36, "└ " + sub.name + " (" + sub.total + ")", 11);
				subLbl.color = cat.color;
				subLbl.alpha = 0.7;
				subLbl.scrollFactor.set();
				catGroup.add(subLbl);
				y += 24;
			}
		}
	}
	// Summary
	var summ = new FlxText(10, y + 8, CAT_W - 20, allFiles.length + " files in " + rootCats.length + " categories", 10);
	summ.color = FlxColor.fromRGB(80, 80, 100);
	summ.scrollFactor.set();
	catGroup.add(summ);
}

function refreshFileList() {
	listGroup.clear();
	var y:Float = TOP_H + 56;
	var maxShow = Std.int((FlxG.height - TOP_H - 30 - STATUS_H - INFO_H - 30) / 24);
	var startIdx = Std.int(listScrollY / 24);

	for (i in 0...Math.min(filteredFiles.length - startIdx, maxShow)) {
		var idx = i + startIdx;
		if (idx < 0 || idx >= filteredFiles.length) continue;
		var f = filteredFiles[idx];
		var isSelected = f == selectedFile;
		var bg = new FlxSprite(CAT_W + 4, y).makeGraphic(LIST_W - 8, 22, isSelected ? COL_SELECT : FlxColor.fromRGB(30, 30, 44));
		bg.alpha = isSelected ? 0.8 : 0.3;
		bg.scrollFactor.set();
		listGroup.add(bg);

		var nameL = new FlxText(CAT_W + 12, y + 3, LIST_W - 120, f.fileName, 11);
		nameL.color = f.color;
		nameL.scrollFactor.set();
		listGroup.add(nameL);

		var sizeL = new FlxText(CAT_W + LIST_W - 100, y + 4, 90, f.lineCount + " ln | " + formatSize(f.size), 9);
		sizeL.color = COL_DIM;
		sizeL.alignment = RIGHT;
		sizeL.scrollFactor.set();
		listGroup.add(sizeL);

		y += 24;
	}
}

function refreshPreview() {
	if (selectedFile == null) { previewTitle.text = "Preview — select a file"; previewText.text = ""; return; }
	previewTitle.text = selectedFile.fileName + " — " + (selectedFile.package.length > 0 ? selectedFile.package + "." : "") + selectedFile.className;
	previewTitle.color = selectedFile.color;
	var display = selectedFile.lines.slice(0, 80).join("\n");
	if (selectedFile.lineCount > 80) display += "\n\n... (" + (selectedFile.lineCount - 80) + " more lines)";
	previewText.text = display;
}

function refreshInfo() {
	if (selectedFile == null) { infoText.text = ""; return; }
	var f = selectedFile;
	var info = "Package: " + f.package + "\nClass: " + f.className;
	if (f.extendsCls != null && f.extendsCls.length > 0) info += " extends " + f.extendsCls;
	info += "\nCategory: " + f.category + (f.subCategory != null && f.subCategory.length > 0 ? " / " + f.subCategory : "");
	info += "\nLines: " + f.lineCount + " | Size: " + formatSize(f.size);
	info += "\nFunctions: " + f.funcs.length + " | Variables: " + f.vars.length;
	if (f.funcs.length > 0) {
		info += "\n\nFunctions:";
		var show = Math.min(f.funcs.length, 10);
		for (i in 0...show) {
			var fn = f.funcs[i];
			var pfx = fn.isPublic ? "+" : "-";
			if (fn.isStatic) pfx += "S";
			if (fn.isOverride) pfx += "O";
			info += "\n  " + pfx + " " + fn.name + "()";
		}
		if (f.funcs.length > show) info += "\n  ... +" + (f.funcs.length - show) + " more";
	}
	infoText.text = info;
}

function refreshStatus() {
	var parts = ["Files: " + filteredFiles.length + "/" + allFiles.length];
	if (selectedCat != null) parts.push("Category: " + selectedCat.name);
	if (selectedFile != null) parts.push("Selected: " + selectedFile.fileName);
	if (searchQuery.length > 0) parts.push('Search: "' + searchQuery + '"');
	parts.push("Ctrl+E: Editor | ESC: Exit");
	statusText.text = parts.join("  |  ");
}

function formatSize(bytes:Int):String {
	if (bytes < 1024) return bytes + " B";
	if (bytes < 1048576) return Math.round(bytes / 1024) + " KB";
	return (Math.round(bytes / 1048576 * 100) / 100) + " MB";
}

// =============================================================================
//  UPDATE
// =============================================================================
var searchActive:Bool = false;

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

	// Sort cycle
	if (FlxG.keys.justPressed.F2) {
		sortMode = (sortMode + 1) % 3;
		sortFiles();
		refreshFileList();
		return;
	}

	// Search input (type to search)
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F) {
		searchActive = !searchActive;
		if (searchActive) { searchQuery = ""; searchInput.text = "|"; }
		return;
	}

	if (searchActive) {
		if (FlxG.keys.justPressed.BACKSPACE) {
			searchQuery = searchQuery.substr(0, Math.max(0, searchQuery.length - 1));
			searchInput.text = searchQuery + "|";
			applyFilter();
			refreshFileList();
			refreshStatus();
		} else if (FlxG.keys.justPressed.ENTER) {
			searchActive = false;
			searchInput.text = searchQuery;
		} else {
			// Capture typed characters
			for (code in 32...127) {
				if (FlxG.keys.justPressed(cast code)) {
					searchQuery += String.fromCharCode(code);
					searchInput.text = searchQuery + "|";
					applyFilter();
					refreshFileList();
					refreshStatus();
					break;
				}
			}
		}
		return;
	}

	// Navigate file list
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

	// Scroll with mouse wheel
	if (FlxG.mouse.wheel != 0) {
		listScrollY -= FlxG.mouse.wheel * 48;
		if (listScrollY < 0) listScrollY = 0;
		var maxScroll = (filteredFiles.length * 24) - (FlxG.height - TOP_H - 30 - STATUS_H - INFO_H - 30);
		if (maxScroll < 0) maxScroll = 0;
		if (listScrollY > maxScroll) listScrollY = maxScroll;
		refreshFileList();
	}

	// Enter = open in editor
	if (FlxG.keys.justPressed.ENTER && selectedFile != null) {
		FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: selectedFile.path}));
	}
}

function destroy() {
	if (uiCam != null && FlxG.cameras.list.contains(uiCam)) {
		FlxG.cameras.remove(uiCam);
	}
}
