package funkin.editors.hxbrowser;

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
 * HX Browser State - Categorizes and browses all .hx files in the engine.
 * 
 * Features:
 * - Auto-categorizes files by type (States, Substates, Editors, Scripts, UI, Game, Backend, etc.)
 * - Tree view with expandable categories and subcategories
 * - Click to preview file content, Ctrl+Click to open in HX Editor
 * - Full-text search with instant filtering
 * - File info panel (size, line count, category, package, imports)
 * - Sort by name, size, date, category
 * - Recent files tracking
 * - Keyboard navigation (arrows, enter, escape)
 * - Color-coded categories with icons
 */
class HXBrowserState extends UIState {
	// ============ SINGLETON ============
	public static var instance(get, null):HXBrowserState;
	private static inline function get_instance()
		return FlxG.state is HXBrowserState ? cast FlxG.state : null;

	// ============ CAMERAS ============
	public var uiCamera:FlxCamera;
	public var previewCamera:FlxCamera;

	// ============ UI COMPONENTS ============
	public var topMenuSpr:UITopMenu;
	public var categoryPanel:HXCategoryPanel;
	public var fileListPanel:HXFileListPanel;
	public var previewPanel:HXPreviewPanel;
	public var infoPanel:HXInfoPanel;
	public var searchBox:UITextBox;
	public var statusBar:HXStatusBar;

	// ============ DATA ============
	public var allFiles:Array<HXFileInfo> = [];
	public var filteredFiles:Array<HXFileInfo> = [];
	public var categories:Map<String, HXCategory> = [];
	public var rootCategories:Array<HXCategory> = [];
	public var recentFiles:Array<String> = [];
	public var maxRecent:Int = 20;

	// ============ STATE ============
	public var selectedFile:HXFileInfo;
	public var selectedCategory:HXCategory;
	public var currentSort:HXSortMode = NAME_ASC;
	public var searchQuery:String = "";
	public var showHidden:Bool = false;

	// ============ LAYOUT CONSTANTS ============
	public static inline var CAT_PANEL_WIDTH:Int = 300;
	public static inline var FILE_LIST_WIDTH:Int = 400;
	public static inline var PREVIEW_WIDTH:Int = 580;
	public static inline var INFO_HEIGHT:Int = 180;
	public static inline var TOP_BAR_HEIGHT:Int = 32;
	public static inline var STATUS_HEIGHT:Int = 24;
	public static inline var SEARCH_HEIGHT:Int = 36;

	public override function create() {
		super.create();

		WindowUtils.suffix = " (HX File Browser)";

		// Setup cameras
		uiCamera = new FlxCamera();
		uiCamera.bgColor = FlxColor.fromRGB(22, 22, 30);
		FlxG.cameras.add(uiCamera, false);

		previewCamera = new FlxCamera();
		previewCamera.bgColor = FlxColor.fromRGB(18, 18, 24);
		FlxG.cameras.add(previewCamera, false);

		// Build background
		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(22, 22, 30));
		bg.cameras = [uiCamera];
		add(bg);

		// Scan all .hx files
		scanAllFiles();

		// Build UI
		buildTopMenu();
		buildSearchBar();
		buildCategoryPanel();
		buildFileListPanel();
		buildPreviewPanel();
		buildInfoPanel();
		buildStatusBar();

		// Select first category
		if (rootCategories.length > 0) {
			selectCategory(rootCategories[0]);
		}

		refreshStatusBar();
	}

	// ================================================================
	//  FILE SCANNING & CATEGORIZATION
	// ================================================================

	public function scanAllFiles():Void {
		allFiles = [];
		categories = [];
		rootCategories = [];

		var fileList = Assets.list();
		for (filePath in fileList) {
			if (!filePath.endsWith(".hx")) continue;
			if (!showHidden && filePath.indexOf("/.") >= 0) continue;

			var info = createFileInfo(filePath);
			if (info != null) {
				allFiles.push(info);
				addToCategory(info);
			}
		}

		// Also scan from sys filesystem if available
		#if sys
		scanDirectory("source/", "source");
		scanDirectory("mods/", "mods");
		#end

		// Sort categories
		rootCategories.sort((a, b) -> Reflect.compare(a.sortOrder, b.sortOrder));

		filteredFiles = allFiles.copy();
	}

	#if sys
	function scanDirectory(dir:String, prefix:String):Void {
		try {
			if (!sys.FileSystem.exists(dir)) return;
			for (entry in sys.FileSystem.readDirectory(dir)) {
				var fullPath = dir + entry;
				if (sys.FileSystem.isDirectory(fullPath)) {
					scanDirectory(fullPath + "/", prefix);
				} else if (entry.endsWith(".hx")) {
					var assetPath = fullPath;
					// Check if already scanned
					var exists = false;
					for (f in allFiles) if (f.path == assetPath) { exists = true; break; }
					if (!exists) {
						var info = createFileInfo(assetPath);
						if (info != null) {
							allFiles.push(info);
							addToCategory(info);
						}
					}
				}
			}
		} catch (e:Dynamic) {}
	}
	#end

	function createFileInfo(filePath:String):HXFileInfo {
		try {
			var content:String = "";
			try { content = Assets.getText(filePath); } catch (e) {
				#if sys
				try { content = sys.io.File.getContent(filePath); } catch (e2) { return null; }
				#else
				return null;
				#end
			}

			if (content == null || content.length == 0) return null;

			var lines = content.split("\n");
			var packageName = extractPackage(content);
			var className = extractClassName(content);
			var imports = extractImports(content);
			var functions = extractFunctions(content);
			var variables = extractVariables(content);
			var fileType = detectFileType(filePath, content, className);
			var ext = fileType.superType;

			return {
				path: filePath,
				fileName: Path.withoutDirectory(filePath),
				baseName: Path.withoutExtension(Path.withoutDirectory(filePath)),
				extension: "hx",
				package: packageName,
				className: className,
				fullClassName: packageName.length > 0 ? packageName + "." + className : className,
				imports: imports,
				functions: functions,
				variables: variables,
				fileType: fileType,
				category: fileType.superType,
				subCategory: fileType.subType,
				content: content,
				lines: lines,
				lineCount: lines.length,
				sizeBytes: content.length,
				hasMain: content.indexOf("static function main") >= 0 || content.indexOf("static public function main") >= 0,
				isInterface: content.indexOf("interface ") >= 0,
				isAbstract: content.indexOf("abstract ") >= 0,
				isEnum: content.indexOf("enum ") >= 0 && content.indexOf("enum abstract") < 0,
				isTypedef: content.indexOf("typedef ") >= 0,
				extendsClass: extractExtends(content),
				implementsList: extractImplements(content),
				lastModified: null,
				isFavorite: false
			};
		} catch (e:Dynamic) {
			trace('Error scanning $filePath: $e');
			return null;
		}
	}

	function extractPackage(content:String):String {
		var match = ~/^package\s+([\w.]+)\s*;/m;
		if (match.match(content)) return match.matched(1);
		return "";
	}

	function extractClassName(content:String):String {
		var match = ~/(?:class|interface|abstract|enum)\s+(\w+)/;
		if (match.match(content)) return match.matched(1);
		return "";
	}

	function extractImports(content:String):Array<String> {
		var imports:Array<String> = [];
		var match = ~/^import\s+([\w.*]+)\s*;/gm;
		var pos = 0;
		while (match.matchSub(content, pos)) {
			imports.push(match.matched(1));
			pos = match.matchedPos().pos + match.matchedPos().len;
		}
		return imports;
	}

	function extractFunctions(content:String):Array<HXFunctionInfo> {
		var funcs:Array<HXFunctionInfo> = [];
		var match = ~/((?:public|private|static|inline|override|dynamic)\s+)*function\s+(\w+)\s*\(([^)]*)\)/g;
		var pos = 0;
		while (match.matchSub(content, pos)) {
			var modifiers = match.matched(1) != null ? match.matched(1).trim() : "";
			var name = match.matched(2);
			var params = match.matched(3);
			funcs.push({
				name: name,
				params: params,
				isPublic: modifiers.indexOf("public") >= 0,
				isStatic: modifiers.indexOf("static") >= 0,
				isOverride: modifiers.indexOf("override") >= 0,
				isInline: modifiers.indexOf("inline") >= 0,
				lineNumber: content.substr(0, match.matchedPos().pos).split("\n").length
			});
			pos = match.matchedPos().pos + match.matchedPos().len;
		}
		return funcs;
	}

	function extractVariables(content:String):Array<HXVariableInfo> {
		var vars:Array<HXVariableInfo> = [];
		var match = ~/((?:public|private|static|var|final)\s+)+var\s+(\w+)\s*(?::\s*(\w+))?\s*(?:=\s*([^;]+))?/g;
		var pos = 0;
		while (match.matchSub(content, pos)) {
			var modifiers = match.matched(1) != null ? match.matched(1).trim() : "";
			vars.push({
				name: match.matched(2),
				type: match.matched(3),
				defaultValue: match.matched(4),
				isPublic: modifiers.indexOf("public") >= 0,
				isStatic: modifiers.indexOf("static") >= 0,
				lineNumber: content.substr(0, match.matchedPos().pos).split("\n").length
			});
			pos = match.matchedPos().pos + match.matchedPos().len;
		}
		return vars;
	}

	function extractExtends(content:String):String {
		var match = ~/class\s+\w+\s+extends\s+([\w.]+)/;
		if (match.match(content)) return match.matched(1);
		return "";
	}

	function extractImplements(content:String):Array<String> {
		var impls:Array<String> = [];
		var match = ~/implements\s+([\w.,\s]+)/;
		if (match.match(content)) {
			for (i in match.matched(1).split(",")) {
				var trimmed = i.trim();
				if (trimmed.length > 0) impls.push(trimmed);
			}
		}
		return impls;
	}

	function detectFileType(path:String, content:String, className:String):HXFileType {
		var superType:String = "Other";
		var subType:String = "";
		var color:Int = 0xFF888888;

		// Detect by content
		if (content.indexOf("extends UIState") >= 0 || content.indexOf("extends MusicBeatState") >= 0) {
			superType = "States"; subType = "Game States"; color = 0xFF4488FF;
		} else if (content.indexOf("extends MusicBeatSubstate") >= 0 || content.indexOf("extends FlxSubState") >= 0 || content.indexOf("extends UISubstateWindow") >= 0) {
			superType = "States"; subType = "Substates"; color = 0xFF44AAFF;
		} else if (content.indexOf("extends UIState") >= 0 && path.indexOf("editors/") >= 0) {
			superType = "Editors"; subType = "Editor States"; color = 0xFF44FF88;
		} else if (path.indexOf("editors/ui/") >= 0) {
			superType = "Editors"; subType = "UI Components"; color = 0xFF88FF44;
		} else if (path.indexOf("editors/") >= 0) {
			superType = "Editors"; subType = "Editor Support"; color = 0xFF44FFAA;
		} else if (path.indexOf("scripts/") >= 0 || path.indexOf("data/scripts") >= 0) {
			superType = "Scripts"; subType = "HScript"; color = 0xFFFFAA44;
		} else if (path.indexOf("states/") >= 0) {
			superType = "Scripts"; subType = "State Scripts"; color = 0xFFFF8844;
		} else if (path.indexOf("game/") >= 0) {
			if (path.indexOf("scoring") >= 0) { superType = "Game"; subType = "Scoring"; color = 0xFFFF4488; }
			else if (path.indexOf("cutscenes") >= 0) { superType = "Game"; subType = "Cutscenes"; color = 0xFFFF44AA; }
			else { superType = "Game"; subType = "Gameplay"; color = 0xFFFF4466; }
		} else if (path.indexOf("backend/") >= 0) {
			if (path.indexOf("scripting") >= 0) { superType = "Backend"; subType = "Scripting"; color = 0xFFAA44FF; }
			else if (path.indexOf("system") >= 0) { superType = "Backend"; subType = "System"; color = 0xFF8844FF; }
			else if (path.indexOf("chart") >= 0) { superType = "Backend"; subType = "Chart"; color = 0xFF6644FF; }
			else if (path.indexOf("assets") >= 0) { superType = "Backend"; subType = "Assets"; color = 0xFFAA66FF; }
			else if (path.indexOf("shaders") >= 0) { superType = "Backend"; subType = "Shaders"; color = 0xFFCC44FF; }
			else if (path.indexOf("utils") >= 0) { superType = "Backend"; subType = "Utilities"; color = 0xFFBB44FF; }
			else if (path.indexOf("week") >= 0) { superType = "Backend"; subType = "Weeks"; color = 0xFFDD44FF; }
			else { superType = "Backend"; subType = "Other"; color = 0xFF9944FF; }
		} else if (path.indexOf("menus/") >= 0) {
			if (path.indexOf("ui/") >= 0) { superType = "Menus"; subType = "Menu UI"; color = 0xFF44FFDD; }
			else if (path.indexOf("credits") >= 0) { superType = "Menus"; subType = "Credits"; color = 0xFF44FFCC; }
			else { superType = "Menus"; subType = "Menu States"; color = 0xFF44FFEE; }
		} else if (path.indexOf("options/") >= 0) {
			superType = "Options"; subType = "Settings"; color = 0xFFDDDD44;
		} else if (path.indexOf("savedata/") >= 0 || path.indexOf("save") >= 0) {
			superType = "Backend"; subType = "Save Data"; color = 0xFFAAAA44;
		} else if (path.indexOf("flixel/") >= 0 || path.indexOf("haxe/") >= 0 || path.indexOf("lime/") >= 0 || path.indexOf("openfl/") >= 0) {
			superType = "Libraries"; subType = "Engine Extensions"; color = 0xFF666666;
		} else if (path.indexOf("hscript/") >= 0) {
			superType = "Libraries"; subType = "HScript"; color = 0xFF777777;
		}

		return {
			superType: superType,
			subType: subType,
			color: color,
			icon: getFileIcon(superType),
			description: getCategoryDescription(superType, subType)
		};
	}

	function getFileIcon(cat:String):Int {
		return switch (cat) {
			case "States": 0;
			case "Editors": 1;
			case "Scripts": 2;
			case "Game": 3;
			case "Backend": 4;
			case "Menus": 5;
			case "Options": 6;
			case "Libraries": 7;
			default: 8;
		};
	}

	function getCategoryDescription(cat:String, sub:String):String {
		return switch (cat) {
			case "States": "Game state classes that control screen flow";
			case "Editors": "In-engine editor tools and their UI components";
			case "Scripts": "HScript files for runtime modding and scripting";
			case "Game": "Core gameplay systems (characters, notes, scoring)";
			case "Backend": "Engine infrastructure (scripting, assets, system)";
			case "Menus": "Menu states and UI elements";
			case "Options": "Settings and option category definitions";
			case "Libraries": "Extended library classes (flixel, hscript, lime)";
			default: "Other engine files";
		};
	}

	// ================================================================
	//  CATEGORY MANAGEMENT
	// ================================================================

	function addToCategory(info:HXFileInfo):Void {
		var catName = info.category;
		if (!categories.exists(catName)) {
			var cat:HXCategory = {
				name: catName,
				subCategories: [],
				files: [],
				color: info.fileType.color,
				icon: info.fileType.icon,
				expanded: true,
				sortOrder: getCategorySortOrder(catName),
				totalFiles: 0,
				description: info.fileType.description
			};
			categories.set(catName, cat);
			rootCategories.push(cat);
		}

		var cat = categories.get(catName);
		cat.files.push(info);
		cat.totalFiles++;

		// Add to subcategory
		if (info.subCategory.length > 0) {
			var subCatFound = false;
			for (sc in cat.subCategories) {
				if (sc.name == info.subCategory) {
					sc.files.push(info);
					sc.totalFiles++;
					subCatFound = true;
					break;
				}
			}
			if (!subCatFound) {
				var subCat:HXCategory = {
					name: info.subCategory,
					subCategories: [],
					files: [info],
					color: info.fileType.color,
					icon: info.fileType.icon,
					expanded: false,
					sortOrder: 0,
					totalFiles: 1,
					description: ""
				};
				cat.subCategories.push(subCat);
			}
		}
	}

	function getCategorySortOrder(name:String):Int {
		return switch (name) {
			case "States": 0;
			case "Editors": 1;
			case "Game": 2;
			case "Backend": 3;
			case "Menus": 4;
			case "Options": 5;
			case "Scripts": 6;
			case "Libraries": 10;
			default: 8;
		};
	}

	// ================================================================
	//  UI BUILDING
	// ================================================================

	function buildTopMenu():Void {
		topMenuSpr = new UITopMenu([
			{
				label: "File",
				childs: [
					{label: "Open in Editor", keybind: [CONTROL, E], onSelect: (_) -> openSelectedInEditor()},
					{label: "Refresh File List", keybind: [F5], onSelect: (_) -> { scanAllFiles(); refreshFileList(); }},
					null,
					{label: "Exit", keybind: [ESCAPE], onSelect: (_) -> exitBrowser()}
				]
			},
			{
				label: "View",
				childs: [
					{label: "Sort by Name", onSelect: (_) -> { currentSort = NAME_ASC; refreshFileList(); }},
					{label: "Sort by Size", onSelect: (_) -> { currentSort = SIZE_DESC; refreshFileList(); }},
					{label: "Sort by Lines", onSelect: (_) -> { currentSort = LINES_DESC; refreshFileList(); }},
					null,
					{label: "Show Hidden Files", onSelect: (_) -> { showHidden = !showHidden; scanAllFiles(); refreshFileList(); }},
					{label: "Expand All", onSelect: (_) -> expandAll()},
					{label: "Collapse All", onSelect: (_) -> collapseAll()}
				]
			},
			{
				label: "Go To",
				childs: [
					{label: "States", onSelect: (_) -> selectCategoryByName("States")},
					{label: "Editors", onSelect: (_) -> selectCategoryByName("Editors")},
					{label: "Game", onSelect: (_) -> selectCategoryByName("Game")},
					{label: "Backend", onSelect: (_) -> selectCategoryByName("Backend")},
					{label: "Scripts", onSelect: (_) -> selectCategoryByName("Scripts")},
					null,
					{label: "Recent Files", onSelect: (_) -> showRecentFiles()}
				]
			}
		]);
		topMenuSpr.cameras = [uiCamera];
		add(topMenuSpr);
	}

	function buildSearchBar():Void {
		searchBox = new UITextBox(CAT_PANEL_WIDTH + 8, TOP_BAR_HEIGHT + 4, "", FILE_LIST_WIDTH - 16, SEARCH_HEIGHT - 8, false, false);
		searchBox.cameras = [uiCamera];
		searchBox.onChange = (text) -> { searchQuery = text; applyFilter(); };
		add(searchBox);

		// Search icon placeholder
		var searchLabel = new UIText(CAT_PANEL_WIDTH + 16, TOP_BAR_HEIGHT + 10, 100, "Search:", 13);
		searchLabel.color = 0xFFAAAAAA;
		searchLabel.cameras = [uiCamera];
		add(searchLabel);
	}

	function buildCategoryPanel():Void {
		categoryPanel = new HXCategoryPanel(0, TOP_BAR_HEIGHT, CAT_PANEL_WIDTH, FlxG.height - TOP_BAR_HEIGHT - STATUS_HEIGHT, this);
		categoryPanel.cameras = [uiCamera];
		add(categoryPanel);
	}

	function buildFileListPanel():Void {
		fileListPanel = new HXFileListPanel(CAT_PANEL_WIDTH, TOP_BAR_HEIGHT + SEARCH_HEIGHT, FILE_LIST_WIDTH, FlxG.height - TOP_BAR_HEIGHT - SEARCH_HEIGHT - STATUS_HEIGHT - INFO_HEIGHT, this);
		fileListPanel.cameras = [uiCamera];
		add(fileListPanel);
	}

	function buildPreviewPanel():Void {
		previewPanel = new HXPreviewPanel(CAT_PANEL_WIDTH + FILE_LIST_WIDTH, TOP_BAR_HEIGHT, PREVIEW_WIDTH, FlxG.height - TOP_BAR_HEIGHT - STATUS_HEIGHT, this);
		previewPanel.cameras = [uiCamera];
		add(previewPanel);
	}

	function buildInfoPanel():Void {
		infoPanel = new HXInfoPanel(CAT_PANEL_WIDTH, FlxG.height - STATUS_HEIGHT - INFO_HEIGHT, FILE_LIST_WIDTH, INFO_HEIGHT, this);
		infoPanel.cameras = [uiCamera];
		add(infoPanel);
	}

	function buildStatusBar():Void {
		statusBar = new HXStatusBar(0, FlxG.height - STATUS_HEIGHT, FlxG.width, STATUS_HEIGHT, this);
		statusBar.cameras = [uiCamera];
		add(statusBar);
	}

	// ================================================================
	//  INTERACTIONS
	// ================================================================

	public function selectCategory(cat:HXCategory):Void {
		selectedCategory = cat;
		filteredFiles = cat.files.copy();
		if (searchQuery.length > 0) applyFilter();
		else sortFiles();
		fileListPanel.refresh();
		refreshStatusBar();
	}

	public function selectCategoryByName(name:String):Void {
		var cat = categories.get(name);
		if (cat != null) selectCategory(cat);
	}

	public function selectFile(file:HXFileInfo):Void {
		selectedFile = file;
		previewPanel.showFile(file);
		infoPanel.showFile(file);

		// Add to recent
		if (!recentFiles.contains(file.path)) {
			recentFiles.unshift(file.path);
			while (recentFiles.length > maxRecent) recentFiles.pop();
		}

		refreshStatusBar();
	}

	public function openSelectedInEditor():Void {
		if (selectedFile != null) {
			FlxG.switchState(new funkin.editors.hxeditor.HXEditorState(selectedFile.path));
		}
	}

	public function openFileInEditor(file:HXFileInfo):Void {
		FlxG.switchState(new funkin.editors.hxeditor.HXEditorState(file.path));
	}

	function exitBrowser():Void {
		FlxG.switchState(new funkin.menus.MainMenuState());
	}

	function expandAll():Void {
		for (cat in rootCategories) {
			cat.expanded = true;
			for (sub in cat.subCategories) sub.expanded = true;
		}
		categoryPanel.refresh();
	}

	function collapseAll():Void {
		for (cat in rootCategories) {
			cat.expanded = false;
			for (sub in cat.subCategories) sub.expanded = false;
		}
		categoryPanel.refresh();
	}

	function showRecentFiles():Void {
		// Show recent files in the file list
		filteredFiles = [];
		for (path in recentFiles) {
			for (f in allFiles) {
				if (f.path == path) { filteredFiles.push(f); break; }
			}
		}
		fileListPanel.refresh();
	}

	// ================================================================
	//  FILTERING & SORTING
	// ================================================================

	function applyFilter():Void {
		if (searchQuery.length == 0) {
			if (selectedCategory != null) filteredFiles = selectedCategory.files.copy();
			else filteredFiles = allFiles.copy();
		} else {
			var q = searchQuery.toLowerCase();
			filteredFiles = allFiles.filter(f ->
				f.fileName.toLowerCase().indexOf(q) >= 0 ||
				f.className.toLowerCase().indexOf(q) >= 0 ||
				f.package.toLowerCase().indexOf(q) >= 0 ||
				f.content.toLowerCase().indexOf(q) >= 0
			);
		}
		sortFiles();
		fileListPanel.refresh();
		refreshStatusBar();
	}

	function sortFiles():Void {
		switch (currentSort) {
			case NAME_ASC: filteredFiles.sort((a, b) -> Reflect.compare(a.fileName.toLowerCase(), b.fileName.toLowerCase()));
			case NAME_DESC: filteredFiles.sort((a, b) -> Reflect.compare(b.fileName.toLowerCase(), a.fileName.toLowerCase()));
			case SIZE_DESC: filteredFiles.sort((a, b) -> b.sizeBytes - a.sizeBytes);
			case SIZE_ASC: filteredFiles.sort((a, b) -> a.sizeBytes - b.sizeBytes);
			case LINES_DESC: filteredFiles.sort((a, b) -> b.lineCount - a.lineCount);
			case LINES_ASC: filteredFiles.sort((a, b) -> a.lineCount - b.lineCount);
		}
	}

	function refreshFileList():Void {
		if (selectedCategory != null) {
			filteredFiles = selectedCategory.files.copy();
		}
		if (searchQuery.length > 0) applyFilter();
		else sortFiles();
		fileListPanel.refresh();
	}

	function refreshStatusBar():Void {
		statusBar.refresh();
	}

	// ================================================================
	//  UPDATE
	// ================================================================

	public override function update(elapsed:Float) {
		super.update(elapsed);

		// Keyboard shortcuts
		if (FlxG.keys.justPressed.ESCAPE) exitBrowser();
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.E) openSelectedInEditor();
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F) {
			// Focus search
			currentFocus = searchBox;
		}
	}

	override function destroy() {
		super.destroy();
	}
}

// ================================================================
//  DATA TYPES
// ================================================================

typedef HXFileInfo = {
	var path:String;
	var fileName:String;
	var baseName:String;
	var extension:String;
	var package:String;
	var className:String;
	var fullClassName:String;
	var imports:Array<String>;
	var functions:Array<HXFunctionInfo>;
	var variables:Array<HXVariableInfo>;
	var fileType:HXFileType;
	var category:String;
	var subCategory:String;
	var content:String;
	var lines:Array<String>;
	var lineCount:Int;
	var sizeBytes:Int;
	var hasMain:Bool;
	var isInterface:Bool;
	var isAbstract:Bool;
	var isEnum:Bool;
	var isTypedef:Bool;
	var extendsClass:String;
	var implementsList:Array<String>;
	var lastModified:Null<Date>;
	var isFavorite:Bool;
}

typedef HXFunctionInfo = {
	var name:String;
	var params:String;
	var isPublic:Bool;
	var isStatic:Bool;
	var isOverride:Bool;
	var isInline:Bool;
	var lineNumber:Int;
}

typedef HXVariableInfo = {
	var name:String;
	var type:String;
	var defaultValue:String;
	var isPublic:Bool;
	var isStatic:Bool;
	var lineNumber:Int;
}

typedef HXFileType = {
	var superType:String;
	var subType:String;
	var color:Int;
	var icon:Int;
	var description:String;
}

typedef HXCategory = {
	var name:String;
	var subCategories:Array<HXCategory>;
	var files:Array<HXFileInfo>;
	var color:Int;
	var icon:Int;
	var expanded:Bool;
	var sortOrder:Int;
	var totalFiles:Int;
	var description:String;
}

enum abstract HXSortMode(Int) {
	var NAME_ASC = 0;
	var NAME_DESC = 1;
	var SIZE_DESC = 2;
	var SIZE_ASC = 3;
	var LINES_DESC = 4;
	var LINES_ASC = 5;
}

// ================================================================
//  UI PANELS
// ================================================================

class HXCategoryPanel extends UIWindow {
	public var browser:HXBrowserState;
	public var buttons:Array<HXCategoryButton> = [];
	public var scrollY:Float = 0;
	public var contentGroup:FlxSpriteGroup;

	public function new(x:Float, y:Float, w:Int, h:Int, browser:HXBrowserState) {
		super(x, y, w, h, "File Categories");
		this.browser = browser;

		contentGroup = new FlxSpriteGroup();
		add(contentGroup);
		refresh();
	}

	public function refresh():Void {
		contentGroup.clear();
		buttons = [];

		var yOff:Float = 4;

		// Header
		var header = new UIText(8, yOff, bWidth - 16, "Browse by Category", 14);
		header.color = 0xFFCCCCCC;
		contentGroup.add(header);
		yOff += 24;

		for (cat in browser.rootCategories) {
			var btn = new HXCategoryButton(4, yOff, bWidth - 8, cat, browser, false);
			contentGroup.add(btn);
			buttons.push(btn);
			yOff += 30;

			if (cat.expanded) {
				for (sub in cat.subCategories) {
					var subBtn = new HXCategoryButton(16, yOff, bWidth - 20, sub, browser, true);
					contentGroup.add(subBtn);
					buttons.push(subBtn);
					yOff += 26;
				}
			}
		}

		// Summary
		yOff += 8;
		var summary = new UIText(8, yOff, bWidth - 16, '${browser.allFiles.length} files in ${browser.rootCategories.length} categories', 11);
		summary.color = 0xFF888888;
		contentGroup.add(summary);
	}
}

class HXCategoryButton extends UISliceSprite {
	public var cat:HXCategory;
	public var browser:HXBrowserState;
	public var isSub:Bool;
	public var label:UIText;
	public var countText:UIText;

	public function new(x:Float, y:Float, w:Int, cat:HXCategory, browser:HXBrowserState, isSub:Bool) {
		super(x, y, w, isSub ? 24 : 28, 'editors/ui/inputbox');
		this.cat = cat;
		this.browser = browser;
		this.isSub = isSub;

		var prefix = isSub ? "  └ " : (cat.expanded ? "▼ " : "▶ ");
		label = new UIText(x + 8, y + 4, w - 60, prefix + cat.name, isSub ? 12 : 13);
		label.color = cat.color;
		members.push(label);

		countText = new UIText(x + w - 50, y + 4, 42, '${cat.totalFiles}', 11);
		countText.color = 0xFF888888;
		countText.alignment = RIGHT;
		members.push(countText);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (selectable && hovered && FlxG.mouse.justReleased) {
			cat.expanded = !cat.expanded;
			browser.selectCategory(cat);
			browser.categoryPanel.refresh();
		}
	}
}

class HXFileListPanel extends UIWindow {
	public var browser:HXBrowserState;
	public var fileButtons:Array<HXFileButton> = [];
	public var contentGroup:FlxSpriteGroup;

	public function new(x:Float, y:Float, w:Int, h:Int, browser:HXBrowserState) {
		super(x, y, w, h, "Files");
		this.browser = browser;

		contentGroup = new FlxSpriteGroup();
		add(contentGroup);
	}

	public function refresh():Void {
		contentGroup.clear();
		fileButtons = [];

		var yOff:Float = 4;
		for (file in browser.filteredFiles) {
			var btn = new HXFileButton(4, yOff, bWidth - 8, file, browser);
			contentGroup.add(btn);
			fileButtons.push(btn);
			yOff += 28;
			if (yOff > bHeight - 30) break; // Don't overflow
		}
	}
}

class HXFileButton extends UISliceSprite {
	public var file:HXFileInfo;
	public var browser:HXBrowserState;
	public var label:UIText;
	public var infoText:UIText;

	public function new(x:Float, y:Float, w:Int, file:HXFileInfo, browser:HXBrowserState) {
		super(x, y, w, 26, 'editors/ui/inputbox');
		this.file = file;
		this.browser = browser;

		label = new UIText(x + 6, y + 4, w - 100, file.fileName, 12);
		label.color = file.fileType.color;
		members.push(label);

		infoText = new UIText(x + w - 90, y + 6, 82, '${file.lineCount} lines', 10);
		infoText.color = 0xFF666666;
		infoText.alignment = RIGHT;
		members.push(infoText);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (selectable && hovered && FlxG.mouse.justReleased) {
			if (FlxG.keys.pressed.CONTROL) {
				browser.openFileInEditor(file);
			} else {
				browser.selectFile(file);
			}
		}
	}
}

class HXPreviewPanel extends UIWindow {
	public var browser:HXBrowserState;
	public var codeText:FlxText;
	public var titleText:UIText;
	public var lineCount:UIText;

	public function new(x:Float, y:Float, w:Int, h:Int, browser:HXBrowserState) {
		super(x, y, w, h, "Preview");
		this.browser = browser;

		titleText = new UIText(x + 8, y + 32, w - 16, "Select a file to preview", 14);
		titleText.color = 0xFFCCCCCC;
		add(titleText);

		codeText = new FlxText(x + 8, y + 56, w - 16, "", 11);
		codeText.color = 0xFFCCCCCC;
		codeText.font = "monospace";
		add(codeText);

		lineCount = new UIText(x + 8, y + h - 24, w - 16, "", 10);
		lineCount.color = 0xFF666666;
		add(lineCount);
	}

	public function showFile(file:HXFileInfo):Void {
		titleText.text = '${file.fileName}  —  ${file.fullClassName}';
		titleText.color = file.fileType.color;

		// Show first 100 lines with basic syntax highlighting
		var displayLines = file.lines.slice(0, 100);
		var display = displayLines.join("\n");
		if (file.lineCount > 100) display += "\n\n... (${file.lineCount - 100} more lines)";
		codeText.text = display;

		lineCount.text = '${file.lineCount} lines | ${formatSize(file.sizeBytes)} | ${file.category}/${file.subCategory}';
	}

	function formatSize(bytes:Int):String {
		if (bytes < 1024) return bytes + " B";
		if (bytes < 1024 * 1024) return Math.round(bytes / 1024) + " KB";
		return (Math.round(bytes / 1024 / 1024 * 100) / 100) + " MB";
	}
}

class HXInfoPanel extends UIWindow {
	public var browser:HXBrowserState;
	public var infoText:UIText;

	public function new(x:Float, y:Float, w:Int, h:Int, browser:HXBrowserState) {
		super(x, y, w, h, "File Info");
		this.browser = browser;

		infoText = new UIText(x + 8, y + 28, w - 16, "", 11);
		infoText.color = 0xFFAAAAAA;
		add(infoText);
	}

	public function showFile(file:HXFileInfo):Void {
		var info = 'Package: ${file.package}\n';
		info += 'Class: ${file.className}';
		if (file.extendsClass.length > 0) info += ' extends ${file.extendsClass}';
		if (file.implementsList.length > 0) info += ' implements ${file.implementsList.join(", ")}';
		info += '\nType: ${file.isInterface ? "interface" : file.isAbstract ? "abstract" : file.isEnum ? "enum" : file.isTypedef ? "typedef" : "class"}';
		info += '\nFunctions: ${file.functions.length} | Variables: ${file.variables.length} | Imports: ${file.imports.length}';
		if (file.functions.length > 0) {
			info += '\n\nFunctions:';
			for (i in 0...Math.min(file.functions.length, 8)) {
				var f = file.functions[i];
				info += '\n  ${f.isPublic ? "+" : "-"}${f.isStatic ? "S" : " "}${f.isOverride ? "O" : " "} ${f.name}(${f.params.substr(0, Math.min(f.params.length, 40))})';
			}
			if (file.functions.length > 8) info += '\n  ... +${file.functions.length - 8} more';
		}
		infoText.text = info;
	}
}

class HXStatusBar extends FlxSprite {
	public var browser:HXBrowserState;
	public var statusLabel:UIText;

	public function new(x:Float, y:Float, w:Int, h:Int, browser:HXBrowserState) {
		super(x, y);
		makeGraphic(w, h, FlxColor.fromRGB(30, 30, 40));
		this.browser = browser;

		statusLabel = new UIText(x + 8, y + 4, w - 16, "", 11);
		statusLabel.color = 0xFF999999;
		add(statusLabel);
	}

	public function refresh():Void {
		var text = 'Files: ${browser.filteredFiles.length}/${browser.allFiles.length}';
		if (browser.selectedCategory != null) text += ' | Category: ${browser.selectedCategory.name}';
		if (browser.selectedFile != null) text += ' | Selected: ${browser.selectedFile.fileName}';
		if (browser.searchQuery.length > 0) text += ' | Search: "${browser.searchQuery}"';
		statusLabel.text = text;
	}
}
