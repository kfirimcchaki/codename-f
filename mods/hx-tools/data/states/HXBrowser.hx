// =============================================================================
//  HX BROWSER - Full HScript State
//  Place in: assets/data/states/HXBrowser.hx
//  Navigate: FlxG.switchState(new ModState("HXBrowser"))
//  Or redirect in mod config: "states.HXBrowser" -> "HXBrowser"
// =============================================================================
//  A powerful file browser that categorizes all .hx files in the engine
//  by type, lets you preview them, search them, and open them in the
//  HX Editor. Press Ctrl+E or double-click to open in editor.
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
import haxe.io.Path;

using StringTools;

// ============ LAYOUT CONSTANTS ============
var CAT_W = 300;
var LIST_W = 380;
var TOP_H = 34;
var STATUS_H = 26;
var SEARCH_H = 34;
var INFO_H = 170;

// ============ DATA STRUCTURES ============
var allFiles:Array<Dynamic> = [];
var filteredFiles:Array<Dynamic> = [];
var categories:Map<String, Dynamic> = [];
var rootCats:Array<Dynamic> = [];
var selectedFile:Dynamic = null;
var selectedCat:Dynamic = null;
var searchQuery:String = "";
var sortMode:Int = 0; // 0=name, 1=size desc, 2=lines desc
var recentFiles:Array<String> = [];

// ============ UI REFS ============
var uiCam:FlxCamera;
var bgSpr:FlxSprite;
var catGroup:FlxSpriteGroup;
var listGroup:FlxSpriteGroup;
var previewText:FlxText;
var previewTitle:FlxText;
var infoText:FlxText;
var statusText:FlxText;
var searchBox:UITextBox;
var searchLabel:FlxText;
var catScrollY:Float = 0;
var listScrollY:Float = 0;

// ============ COLORS ============
var COL_BG = FlxColor.fromRGB(22, 22, 30);
var COL_PANEL = FlxColor.fromRGB(28, 28, 38);
var COL_PANEL2 = FlxColor.fromRGB(32, 32, 44);
var COL_TEXT = FlxColor.fromRGB(220, 220, 230);
var COL_DIM = FlxColor.fromRGB(120, 120, 140);
var COL_ACCENT = FlxColor.fromRGB(80, 140, 255);
var COL_HOVER = FlxColor.fromRGB(45, 45, 65);
var COL_SELECT = FlxColor.fromRGB(55, 65, 100);

var CAT_COLORS:Map<String, Int> = [
	"States" => 0xFF4488FF, "Substates" => 0xFF44AAFF, "Editors" => 0xFF44FF88,
	"Editor UI" => 0xFF88FF44, "Scripts" => 0xFFFFAA44, "State Scripts" => 0xFFFF8844,
	"Game" => 0xFFFF4466, "Scoring" => 0xFFFF4488, "Cutscenes" => 0xFFFF44AA,
	"Backend" => 0xFF9944FF, "Scripting" => 0xFFAA44FF, "System" => 0xFF8844FF,
	"Chart" => 0xFF6644FF, "Assets" => 0xFFAA66FF, "Shaders" => 0xFFCC44FF,
	"Utilities" => 0xFFBB44FF, "Weeks" => 0xFFDD44FF, "Menus" => 0xFF44FFDD,
	"Menu UI" => 0xFF44FFCC, "Credits" => 0xFF44DDFF, "Options" => 0xFFDDDD44,
	"Save Data" => 0xFFAAAA44, "Libraries" => 0xFF666666, "Other" => 0xFF888888
];

// =============================================================================
//  CREATE
// =============================================================================
function create() {
	super.create();

	// Camera
	uiCam = new FlxCamera();
	uiCam.bgColor = COL_BG;
	FlxG.cameras.add(uiCam, false);

	// Background
	bgSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, COL_BG);
	bgSpr.cameras = [uiCam];
	add(bgSpr);

	// Scan files
	scanAllFiles();

	// Build UI
	buildHeader();
	buildSearchBar();
	buildCategoryPanel();
	buildFileListPanel();
	buildPreviewPanel();
	buildInfoPanel();
	buildStatusBar();

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
	scanDir("assets/data/states/");
	scanDir("assets/data/scripts/");
	#end

	// Also scan from Assets
	try {
		var list = Assets.list();
		for (p in list) {
			if (p.endsWith(".hx") && !fileExists(p)) {
				var info = makeFileInfo(p);
				if (info != null) allFiles.push(info);
			}
		}
	} catch(e:Dynamic) {}

	// Categorize all files
	for (f in allFiles) categorize(f);

	// Sort categories
	rootCats.sort(function(a, b) return Reflect.compare(a.order, b.order));
	for (c in rootCats) c.subs.sort(function(a, b) return Reflect.compare(a.name, b.name));

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
		var pkg = extractPkg(content);
		var cls = extractClass(content);
		var funcs = extractFuncs(content);
		var vars = extractVars(content);
		var cat = detectCat(path, content);

		return {
			path: path,
			fileName: Path.withoutDirectory(path),
			baseName: Path.withoutExtension(Path.withoutDirectory(path)),
			package: pkg,
			className: cls,
			fullClass: pkg.length > 0 ? pkg + "." + cls : cls,
			funcs: funcs,
			vars: vars,
			category: cat.main,
			subCategory: cat.sub,
			color: cat.color,
			content: content,
			lines: lines,
			lineCount: lines.length,
			size: content.length,
			isClass: content.indexOf("class ") >= 0,
			isInterface: content.indexOf("interface ") >= 0,
			isAbstract: content.indexOf("abstract ") >= 0,
			isEnum: content.indexOf("enum ") >= 0 && content.indexOf("enum abstract") < 0,
			isTypedef: content.indexOf("typedef ") >= 0,
			extendsCls: extractExtends(content),
			favorite: false
		};
	} catch(e:Dynamic) { return null; }
}

function extractPkg(c:String):String {
	var m = ~/^package\s+([\w.]+)\s*;/m;
	return m.match(c) ? m.matched(1) : "";
}

function extractClass(c:String):String {
	var m = ~/(?:class|interface|abstract|enum)\s+(\w+)/;
	return m.match(c) ? m.matched(1) : Path.withoutExtension("unknown");
}

function extractExtends(c:String):String {
	var m = ~/class\s+\w+\s+extends\s+([\w.]+)/;
	return m.match(c) ? m.matched(1) : "";
}

function extractFuncs(c:String):Array<Dynamic> {
	var result:Array<Dynamic> = [];
	var m = ~/((?:public|private|static|inline|override)\s+)*function\s+(\w+)\s*\(/g;
	var pos = 0;
	while (m.matchSub(c, pos)) {
		var mods = m.matched(1) != null ? m.matched(1) : "";
		result.push({
			name: m.matched(2),
			isPublic: mods.indexOf("public") >= 0,
			isStatic: mods.indexOf("static") >= 0,
			isOverride: mods.indexOf("override") >= 0,
			line: c.substr(0, m.matchedPos().pos).split("\n").length
		});
		pos = m.matchedPos().pos + m.matchedPos().len;
	}
	return result;
}

function extractVars(c:String):Array<Dynamic> {
	var result:Array<Dynamic> = [];
	var m = ~/((?:public|private|static)\s+)*var\s+(\w+)\s*(?::\s*(\w+))?/g;
	var pos = 0;
	while (m.matchSub(c, pos)) {
		var mods = m.matched(1) != null ? m.matched(1) : "";
		result.push({
			name: m.matched(2),
			type: m.matched(3),
			isPublic: mods.indexOf("public") >= 0,
			isStatic: mods.indexOf("static") >= 0,
			line: c.substr(0, m.matchedPos().pos).split("\n").length
		});
		pos = m.matchedPos().pos + m.matchedPos().len;
	}
	return result;
}

function detectCat(path:String, content:String):Dynamic {
	var main = "Other"; var sub = ""; var col = 0xFF888888;

	if (content.indexOf("extends UIState") >= 0 && path.indexOf("editors/") >= 0)
		{ main = "Editors"; sub = "Editor States"; col = CAT_COLORS["Editors"]; }
	else if (content.indexOf("extends MusicBeatState") >= 0 || content.indexOf("extends UIState") >= 0)
		{ main = "States"; sub = "Game States"; col = CAT_COLORS["States"]; }
	else if (content.indexOf("extends MusicBeatSubstate") >= 0 || content.indexOf("extends FlxSubState") >= 0)
		{ main = "States"; sub = "Substates"; col = CAT_COLORS["Substates"]; }
	else if (path.indexOf("editors/ui/") >= 0)
		{ main = "Editors"; sub = "Editor UI"; col = CAT_COLORS["Editor UI"]; }
	else if (path.indexOf("editors/") >= 0)
		{ main = "Editors"; sub = "Editor Support"; col = CAT_COLORS["Editors"]; }
	else if (path.indexOf("data/scripts") >= 0 || path.indexOf("scripts/") >= 0)
		{ main = "Scripts"; sub = "HScript"; col = CAT_COLORS["Scripts"]; }
	else if (path.indexOf("data/states") >= 0)
		{ main = "Scripts"; sub = "State Scripts"; col = CAT_COLORS["State Scripts"]; }
	else if (path.indexOf("game/scoring") >= 0)
		{ main = "Game"; sub = "Scoring"; col = CAT_COLORS["Scoring"]; }
	else if (path.indexOf("game/cutscenes") >= 0)
		{ main = "Game"; sub = "Cutscenes"; col = CAT_COLORS["Cutscenes"]; }
	else if (path.indexOf("game/") >= 0)
		{ main = "Game"; sub = "Gameplay"; col = CAT_COLORS["Game"]; }
	else if (path.indexOf("backend/scripting") >= 0)
		{ main = "Backend"; sub = "Scripting"; col = CAT_COLORS["Scripting"]; }
	else if (path.indexOf("backend/system") >= 0)
		{ main = "Backend"; sub = "System"; col = CAT_COLORS["System"]; }
	else if (path.indexOf("backend/chart") >= 0)
		{ main = "Backend"; sub = "Chart"; col = CAT_COLORS["Chart"]; }
	else if (path.indexOf("backend/assets") >= 0)
		{ main = "Backend"; sub = "Assets"; col = CAT_COLORS["Assets"]; }
	else if (path.indexOf("backend/shaders") >= 0)
		{ main = "Backend"; sub = "Shaders"; col = CAT_COLORS["Shaders"]; }
	else if (path.indexOf("backend/utils") >= 0)
		{ main = "Backend"; sub = "Utilities"; col = CAT_COLORS["Utilities"]; }
	else if (path.indexOf("backend/week") >= 0)
		{ main = "Backend"; sub = "Weeks"; col = CAT_COLORS["Weeks"]; }
	else if (path.indexOf("backend/") >= 0)
		{ main = "Backend"; sub = "Other"; col = CAT_COLORS["Backend"]; }
	else if (path.indexOf("menus/ui") >= 0)
		{ main = "Menus"; sub = "Menu UI"; col = CAT_COLORS["Menu UI"]; }
	else if (path.indexOf("menus/credits") >= 0)
		{ main = "Menus"; sub = "Credits"; col = CAT_COLORS["Credits"]; }
	else if (path.indexOf("menus/") >= 0)
		{ main = "Menus"; sub = "Menu States"; col = CAT_COLORS["Menus"]; }
	else if (path.indexOf("options/") >= 0)
		{ main = "Options"; sub = "Settings"; col = CAT_COLORS["Options"]; }
	else if (path.indexOf("savedata") >= 0)
		{ main = "Backend"; sub = "Save Data"; col = CAT_COLORS["Save Data"]; }
	else if (path.indexOf("flixel/") >= 0 || path.indexOf("haxe/") >= 0 || path.indexOf("lime/") >= 0 || path.indexOf("openfl/") >= 0 || path.indexOf("hscript/") >= 0)
		{ main = "Libraries"; sub = "Extensions"; col = CAT_COLORS["Libraries"]; }

	return { main: main, sub: sub, color: col };
}

function categorize(info:Dynamic) {
	var catName = info.category;
	if (!categories.exists(catName)) {
		var cat = {
			name: catName, subs: [], files: [], color: info.color,
			expanded: true, order: getCatOrder(catName), total: 0
		};
		categories.set(catName, cat);
		rootCats.push(cat);
	}
	var cat = categories.get(catName);
	cat.files.push(info);
	cat.total++;

	if (info.subCategory != null && info.subCategory.length > 0) {
		var found = false;
		for (s in cat.subs) {
			if (s.name == info.subCategory) { s.files.push(info); s.total++; found = true; break; }
		}
		if (!found) {
			cat.subs.push({ name: info.subCategory, files: [info], total: 1, expanded: false });
		}
	}
}

function getCatOrder(name:String):Int {
	return switch(name) {
		case "States": 0; case "Editors": 1; case "Game": 2; case "Backend": 3;
		case "Menus": 4; case "Options": 5; case "Scripts": 6; case "Libraries": 10;
		default: 8;
	};
}

// =============================================================================
//  UI BUILDING
// =============================================================================
function buildHeader() {
	var header = new FlxSprite(0, 0).makeGraphic(FlxG.width, TOP_H, FlxColor.fromRGB(18, 18, 26));
	header.cameras = [uiCam];
	add(header);

	var title = new FlxText(12, 7, 300, "HX File Browser", 16);
	title.color = COL_ACCENT;
	title.cameras = [uiCam];
	add(title);

	// Quick nav buttons
	var navItems = ["States", "Editors", "Game", "Backend", "Scripts"];
	var nx = FlxG.width - 500;
	for (n in navItems) {
		var btn = makeNavBtn(nx, 5, n);
		add(btn);
		nx += 95;
	}
}

function makeNavBtn(x:Float, y:Float, catName:String):FlxSprite {
	var spr = new FlxSprite(x, y).makeGraphic(88, 24, FlxColor.fromRGB(40, 40, 55));
	spr.cameras = [uiCam];
	var col = CAT_COLORS.exists(catName) ? CAT_COLORS[catName] : 0xFF888888;
	var lbl = new FlxText(x, y + 4, 88, catName, 11);
	lbl.alignment = CENTER;
	lbl.color = col;
	lbl.cameras = [uiCam];
	spr.add(lbl);
	return spr;
}

function buildSearchBar() {
	var searchBg = new FlxSprite(CAT_W, TOP_H).makeGraphic(LIST_W, SEARCH_H, FlxColor.fromRGB(25, 25, 35));
	searchBg.cameras = [uiCam];
	add(searchBg);

	searchLabel = new FlxText(CAT_W + 8, TOP_H + 9, 60, "Search:", 12);
	searchLabel.color = COL_DIM;
	searchLabel.cameras = [uiCam];
	add(searchLabel);

	searchBox = new UITextBox(CAT_W + 60, TOP_H + 4, "", LIST_W - 70, SEARCH_H - 8);
	searchBox.cameras = [uiCam];
	searchBox.onChange = function(text:String) {
		searchQuery = text;
		applyFilter();
	};
	add(searchBox);
}

function buildCategoryPanel() {
	var panelBg = new FlxSprite(0, TOP_H).makeGraphic(CAT_W, FlxG.height - TOP_H - STATUS_H, COL_PANEL);
	panelBg.cameras = [uiCam];
	add(panelBg);

	var panelTitle = new FlxText(10, TOP_H + 6, CAT_W - 20, "Categories", 13);
	panelTitle.color = COL_DIM;
	panelTitle.cameras = [uiCam];
	add(panelTitle);

	catGroup = new FlxSpriteGroup(0, TOP_H + 26);
	catGroup.cameras = [uiCam];
	add(catGroup);
}

function buildFileListPanel() {
	var listBg = new FlxSprite(CAT_W, TOP_H + SEARCH_H).makeGraphic(LIST_W, FlxG.height - TOP_H - SEARCH_H - STATUS_H - INFO_H, COL_PANEL);
	listBg.cameras = [uiCam];
	add(listBg);

	var listTitle = new FlxText(CAT_W + 10, TOP_H + SEARCH_H + 6, LIST_W - 20, "Files", 13);
	listTitle.color = COL_DIM;
	listTitle.cameras = [uiCam];
	add(listTitle);

	listGroup = new FlxSpriteGroup(CAT_W, TOP_H + SEARCH_H + 26);
	listGroup.cameras = [uiCam];
	add(listGroup);
}

function buildPreviewPanel() {
	var px = CAT_W + LIST_W;
	var pw = FlxG.width - px;
	var previewBg = new FlxSprite(px, TOP_H).makeGraphic(pw, FlxG.height - TOP_H - STATUS_H, COL_PANEL2);
	previewBg.cameras = [uiCam];
	add(previewBg);

	previewTitle = new FlxText(px + 10, TOP_H + 8, pw - 20, "Preview — Select a file", 14);
	previewTitle.color = COL_ACCENT;
	previewTitle.cameras = [uiCam];
	add(previewTitle);

	previewText = new FlxText(px + 10, TOP_H + 36, pw - 20, "", 11);
	previewText.color = FlxColor.fromRGB(190, 190, 200);
	previewText.cameras = [uiCam];
	add(previewText);
}

function buildInfoPanel() {
	var ix = CAT_W;
	var iy = FlxG.height - STATUS_H - INFO_H;
	var infoBg = new FlxSprite(ix, iy).makeGraphic(LIST_W, INFO_H, FlxColor.fromRGB(24, 24, 34));
	infoBg.cameras = [uiCam];
	add(infoBg);

	var infoTitle = new FlxText(ix + 10, iy + 4, LIST_W - 20, "File Info", 12);
	infoTitle.color = COL_DIM;
	infoTitle.cameras = [uiCam];
	add(infoTitle);

	infoText = new FlxText(ix + 10, iy + 22, LIST_W - 20, "", 11);
	infoText.color = FlxColor.fromRGB(160, 160, 180);
	infoText.cameras = [uiCam];
	add(infoText);
}

function buildStatusBar() {
	var sy = FlxG.height - STATUS_H;
	var statusBg = new FlxSprite(0, sy).makeGraphic(FlxG.width, STATUS_H, FlxColor.fromRGB(18, 18, 26));
	statusBg.cameras = [uiCam];
	add(statusBg);

	statusText = new FlxText(10, sy + 5, FlxG.width - 20, "", 11);
	statusText.color = COL_DIM;
	statusText.cameras = [uiCam];
	add(statusText);
}

// =============================================================================
//  REFRESH FUNCTIONS
// =============================================================================
function refreshCategories() {
	catGroup.clear();
	var y:Float = 0;

	for (cat in rootCats) {
		// Main category button
		var arrow = cat.expanded ? "▼" : "▶";
		var catSpr = makeCatButton(4, y, CAT_W - 8, arrow + " " + cat.name + "  (" + cat.total + ")", cat.color, false, cat);
		catGroup.add(catSpr);
		y += 28;

		if (cat.expanded) {
			for (sub in cat.subs) {
				var subArrow = sub.expanded ? "  └ ▼" : "  └ ▶";
				var subSpr = makeCatButton(12, y, CAT_W - 16, subArrow + " " + sub.name + "  (" + sub.total + ")", cat.color, true, sub);
				catGroup.add(subSpr);
				y += 24;
			}
		}
	}

	// Summary
	var summarySpr = new FlxText(10, y + 10, CAT_W - 20, allFiles.length + " files total", 10);
	summarySpr.color = FlxColor.fromRGB(80, 80, 100);
	summarySpr.cameras = [uiCam];
	catGroup.add(summarySpr);
}

function makeCatButton(x:Float, y:Float, w:Int, text:String, color:Int, isSub:Bool, catData:Dynamic):FlxSprite {
	var bg = new FlxSprite(x, y).makeGraphic(w, isSub ? 22 : 26, FlxColor.fromRGB(35, 35, 48));
	bg.alpha = 0.5;
	bg.cameras = [uiCam];
	var lbl = new FlxText(x + 6, y + (isSub ? 3 : 5), w - 12, text, isSub ? 11 : 12);
	lbl.color = color;
	lbl.cameras = [uiCam];
	bg.add(lbl);

	// Click handling via update check
	bg.ID = isSub ? 2 : 1; // marker

	return bg;
}

function refreshFileList() {
	listGroup.clear();
	var y:Float = 0;
	var maxShow = Std.int((FlxG.height - TOP_H - SEARCH_H - STATUS_H - INFO_H - 50) / 26);

	for (i in 0...Math.min(filteredFiles.length, maxShow)) {
		var f = filteredFiles[i + Std.int(listScrollY / 26)];
		if (f == null) continue;

		var bg = new FlxSprite(4, y).makeGraphic(LIST_W - 8, 24, f == selectedFile ? COL_SELECT : FlxColor.fromRGB(32, 32, 44));
		bg.alpha = f == selectedFile ? 0.8 : 0.3;
		bg.cameras = [uiCam];

		var nameL = new FlxText(10, y + 4, LIST_W - 110, f.fileName, 11);
		nameL.color = f.color;
		nameL.cameras = [uiCam];
		bg.add(nameL);

		var infoL = new FlxText(LIST_W - 95, y + 5, 85, f.lineCount + " ln | " + formatSize(f.size), 9);
		infoL.color = COL_DIM;
		infoL.alignment = RIGHT;
		infoL.cameras = [uiCam];
		bg.add(infoL);

		listGroup.add(bg);
		y += 26;
	}

	// Scrollbar indicator
	if (filteredFiles.length > maxShow) {
		var scrollPct = listScrollY / ((filteredFiles.length - maxShow) * 26);
		var scrollBar = new FlxSprite(LIST_W - 6, 0).makeGraphic(4, Std.int(maxShow * 26 * (maxShow / filteredFiles.length)), COL_ACCENT);
		scrollBar.alpha = 0.3;
		scrollBar.y = scrollPct * (maxShow * 26 - scrollBar.height);
		scrollBar.cameras = [uiCam];
		listGroup.add(scrollBar);
	}
}

function refreshPreview() {
	if (selectedFile == null) {
		previewTitle.text = "Preview — Select a file";
		previewTitle.color = COL_DIM;
		previewText.text = "";
		return;
	}

	previewTitle.text = selectedFile.fileName + "  —  " + selectedFile.fullClass;
	previewTitle.color = selectedFile.color;

	var display = selectedFile.lines.slice(0, 80).join("\n");
	if (selectedFile.lineCount > 80) display += "\n\n... (" + (selectedFile.lineCount - 80) + " more lines, Ctrl+E to open in editor)";
	previewText.text = display;
}

function refreshInfo() {
	if (selectedFile == null) {
		infoText.text = "";
		return;
	}

	var f = selectedFile;
	var type = f.isInterface ? "interface" : f.isAbstract ? "abstract" : f.isEnum ? "enum" : f.isTypedef ? "typedef" : "class";
	var info = "Package: " + f.package + "\n";
	info += "Type: " + type + " " + f.className;
	if (f.extendsCls != null && f.extendsCls.length > 0) info += " extends " + f.extendsCls;
	info += "\nCategory: " + f.category + (f.subCategory != null && f.subCategory.length > 0 ? " / " + f.subCategory : "");
	info += "\nLines: " + f.lineCount + " | Size: " + formatSize(f.size);
	info += "\nFunctions: " + f.funcs.length + " | Variables: " + f.vars.length;
	info += "\n\nFunctions:";
	var showCount = Math.min(f.funcs.length, 12);
	for (i in 0...showCount) {
		var fn = f.funcs[i];
		var prefix = fn.isPublic ? "+" : "-";
		if (fn.isStatic) prefix += "S";
		if (fn.isOverride) prefix += "O";
		info += "\n  " + prefix + " " + fn.name + "() [L" + fn.line + "]";
	}
	if (f.funcs.length > showCount) info += "\n  ... +" + (f.funcs.length - showCount) + " more";
	infoText.text = info;
}

function refreshStatus() {
	var parts = [];
	parts.push("Files: " + filteredFiles.length + "/" + allFiles.length);
	if (selectedCat != null) parts.push("Category: " + selectedCat.name);
	if (selectedFile != null) parts.push("Selected: " + selectedFile.fileName);
	if (searchQuery.length > 0) parts.push('Search: "' + searchQuery + '"');
	parts.push("Ctrl+E: Open in Editor | ESC: Exit");
	statusText.text = parts.join("  |  ");
}

// =============================================================================
//  INTERACTION
// =============================================================================
function selectCategory(cat:Dynamic) {
	selectedCat = cat;
	filteredFiles = cat.files.copy();
	if (searchQuery.length > 0) applyFilter();
	else sortFiles();
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

	// Track recent
	if (recentFiles.indexOf(file.path) < 0) {
		recentFiles.unshift(file.path);
		while (recentFiles.length > 20) recentFiles.pop();
	}
}

function applyFilter() {
	if (searchQuery.length == 0) {
		if (selectedCat != null) filteredFiles = selectedCat.files.copy();
		else filteredFiles = allFiles.copy();
	} else {
		var q = searchQuery.toLowerCase();
		filteredFiles = [];
		for (f in allFiles) {
			if (f.fileName.toLowerCase().indexOf(q) >= 0 ||
				f.className.toLowerCase().indexOf(q) >= 0 ||
				f.package.toLowerCase().indexOf(q) >= 0 ||
				f.content.toLowerCase().indexOf(q) >= 0) {
				filteredFiles.push(f);
			}
		}
	}
	sortFiles();
	listScrollY = 0;
	refreshFileList();
	refreshStatus();
}

function sortFiles() {
	switch(sortMode) {
		case 0: filteredFiles.sort(function(a, b) return Reflect.compare(a.fileName.toLowerCase(), b.fileName.toLowerCase()));
		case 1: filteredFiles.sort(function(a, b) return b.size - a.size);
		case 2: filteredFiles.sort(function(a, b) return b.lineCount - a.lineCount);
	}
}

function openInEditor(file:Dynamic) {
	FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: file.path}));
}

function formatSize(bytes:Int):String {
	if (bytes < 1024) return bytes + " B";
	if (bytes < 1024 * 1024) return Math.round(bytes / 1024) + " KB";
	return (Math.round(bytes / 1024 / 1024 * 100) / 100) + " MB";
}

// =============================================================================
//  UPDATE
// =============================================================================
function update(elapsed:Float) {
	super.update(elapsed);

	// Exit
	if (FlxG.keys.justPressed.ESCAPE) {
		FlxG.switchState(new funkin.menus.MainMenuState());
	}

	// Open in editor
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.E && selectedFile != null) {
		openInEditor(selectedFile);
	}

	// Focus search
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F) {
		// Would focus searchBox
	}

	// Sort cycling with F2
	if (FlxG.keys.justPressed.F2) {
		sortMode = (sortMode + 1) % 3;
		sortFiles();
		refreshFileList();
	}

	// Scroll file list with mouse wheel
	if (FlxG.mouse.wheel != 0) {
		listScrollY -= FlxG.mouse.wheel * 26;
		if (listScrollY < 0) listScrollY = 0;
		var maxScroll = (filteredFiles.length * 26) - (FlxG.height - TOP_H - SEARCH_H - STATUS_H - INFO_H - 50);
		if (maxScroll < 0) maxScroll = 0;
		if (listScrollY > maxScroll) listScrollY = maxScroll;
		refreshFileList();
	}

	// Keyboard navigation in file list
	if (FlxG.keys.justPressed.DOWN && filteredFiles.length > 0) {
		var idx = selectedFile != null ? filteredFiles.indexOf(selectedFile) : -1;
		if (idx < filteredFiles.length - 1) selectFile(filteredFiles[idx + 1]);
	}
	if (FlxG.keys.justPressed.UP && filteredFiles.length > 0) {
		var idx = selectedFile != null ? filteredFiles.indexOf(selectedFile) : 1;
		if (idx > 0) selectFile(filteredFiles[idx - 1]);
	}
	if (FlxG.keys.justPressed.ENTER && selectedFile != null) {
		if (FlxG.keys.pressed.CONTROL) openInEditor(selectedFile);
	}

	// Refresh on search change (handled by onChange callback)
}

function destroy() {
	super.destroy();
}
