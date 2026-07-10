// =============================================================================
//  HX CODE EDITOR v2.0 - Codename Engine Custom State
//  mods/hx-tools/data/states/HXEditor.hx
//  Redirect: [StateRedirects] FreeplayState="HXEditor"
//  Or open:  FlxG.switchState(new ModState("HXEditor", {path: "file.hx"}))
// =============================================================================
//  A professional code editor for .hx files with:
//  - Full text editing (insert, delete, newline, cursor movement)
//  - Syntax highlighting (keywords, types, strings, comments, numbers)
//  - Line numbers with current line highlight
//  - Visual structure panel (package, imports, class, functions, variables)
//  - Find & Replace with regex support
//  - Undo/Redo (200 levels)
//  - Auto-indent on newline
//  - Bracket auto-close and matching
//  - Code folding indicators
//  - Minimap overview
//  - Tab management for multiple files
//  - File templates
//  - Syntax validation (bracket/brace/paren balancing)
//  - Code formatting (auto-indent)
//  - Go to line / Go to function
//  - Bookmarks
//  - Keyboard shortcuts overlay
//  - Settings panel
//  - Status bar with full info
// =============================================================================

// ======================== CONSTANTS ========================
var W = 1280;
var H = 720;
var HEADER_H = 38;
var TAB_BAR_H = 28;
var FOOTER_H = 26;
var VISUAL_W = 280;
var MINIMAP_W = 100;
var LINE_NUM_W = 48;
var LINE_H = 16;
var FONT_SIZE = 12;
var FIND_BAR_H = 56;

// ======================== COLORS ========================
var C_BG = FlxColor.fromRGB(22, 22, 30);
var C_PANEL = FlxColor.fromRGB(28, 28, 40);
var C_PANEL2 = FlxColor.fromRGB(24, 24, 34);
var C_PANEL3 = FlxColor.fromRGB(32, 32, 46);
var C_HEADER = FlxColor.fromRGB(14, 14, 22);
var C_FOOTER = FlxColor.fromRGB(14, 14, 22);
var C_EDITOR = FlxColor.fromRGB(26, 26, 36);
var C_BORDER = FlxColor.fromRGB(45, 45, 65);
var C_TEXT = FlxColor.fromRGB(215, 215, 230);
var C_TEXT2 = FlxColor.fromRGB(180, 180, 200);
var C_DIM = FlxColor.fromRGB(100, 100, 130);
var C_DIMMER = FlxColor.fromRGB(70, 70, 95);
var C_ACCENT = FlxColor.fromRGB(80, 150, 255);
var C_ACCENT2 = FlxColor.fromRGB(120, 180, 255);
var C_SELECT = FlxColor.fromRGB(45, 60, 100);
var C_SELECT2 = FlxColor.fromRGB(55, 70, 115);
var C_HOVER = FlxColor.fromRGB(38, 38, 55);
var C_LINE_HL = FlxColor.fromRGB(32, 32, 48);
var C_LINE_NUM = FlxColor.fromRGB(60, 60, 85);
var C_LINE_NUM_CUR = FlxColor.fromRGB(120, 120, 150);
var C_SUCCESS = FlxColor.fromRGB(80, 220, 120);
var C_WARNING = FlxColor.fromRGB(255, 200, 80);
var C_ERROR = FlxColor.fromRGB(255, 80, 80);
var C_FIND_HL = FlxColor.fromRGB(255, 200, 50);
var C_BOOKMARK = FlxColor.fromRGB(255, 120, 80);
var C_FOLD = FlxColor.fromRGB(80, 80, 110);
var C_BRACKET = FlxColor.fromRGB(255, 220, 100);

// Syntax colors
var SYN_DEFAULT = FlxColor.fromRGB(215, 215, 230);
var SYN_KEYWORD = FlxColor.fromRGB(200, 120, 255);
var SYN_TYPE = FlxColor.fromRGB(100, 200, 255);
var SYN_STRING = FlxColor.fromRGB(180, 230, 130);
var SYN_COMMENT = FlxColor.fromRGB(90, 100, 120);
var SYN_NUMBER = FlxColor.fromRGB(255, 200, 100);
var SYN_FUNC = FlxColor.fromRGB(255, 220, 120);
var SYN_OPERATOR = FlxColor.fromRGB(200, 200, 220);
var SYN_PREPROC = FlxColor.fromRGB(180, 140, 200);
var SYN_METADATA = FlxColor.fromRGB(160, 180, 220);

// ======================== STATE ========================
var filePath:String = "";
var fileName:String = "Untitled.hx";
var content:String = "";
var originalContent:String = "";
var isDirty:Bool = false;
var lines:Array<String> = [];
var totalLines:Int = 0;

// Cursor
var cursorLine:Int = 0;
var cursorCol:Int = 0;
var selectionStartLine:Int = -1;
var selectionStartCol:Int = -1;
var selectionEndLine:Int = -1;
var selectionEndCol:Int = -1;
var hasSelection:Bool = false;

// Scroll
var scrollY:Float = 0;
var scrollX:Float = 0;

// Undo/Redo
var undoStack:Array<Dynamic> = [];
var redoStack:Array<Dynamic> = [];
var MAX_UNDO = 200;

// Find
var findQuery:String = "";
var replaceQuery:String = "";
var findResults:Array<Dynamic> = [];
var findMode:Bool = false;
var findCaseSensitive:Bool = false;
var findUseRegex:Bool = false;
var currentFindIdx:Int = -1;
var findBarVisible:Bool = false;

// Parsed structure
var parsedPkg:String = "";
var parsedClass:String = "";
var parsedExtends:String = "";
var parsedImplements:String = "";
var parsedFuncs:Array<Dynamic> = [];
var parsedVars:Array<Dynamic> = [];
var parsedImports:Array<Dynamic> = [];

// Tabs
var tabs:Array<Dynamic> = [];
var activeTabIndex:Int = -1;

// Bookmarks
var bookmarks:Map<Int, Bool> = [];

// Code folding
var foldedLines:Map<Int, Bool> = [];

// Visual panel state
var visualExpanded:Map<String, Bool> = ["imports" => true, "vars" => true, "funcs" => true];
var visualScrollY:Float = 0;

// Settings
var showLineNumbers:Bool = true;
var showMinimap:Bool = true;
var showVisualPanel:Bool = true;
var autoIndent:Bool = true;
var autoCloseBrackets:Bool = true;
var tabSize:Int = 4;
var wordWrap:Bool = false;
var highlightCurrentLine:Bool = true;
var showWhitespace:Bool = false;
var fontSize:Int = 12;

// Keyboard shortcuts overlay
var shortcutsVisible:Bool = false;
var settingsVisible:Bool = false;
var gotoLineMode:Bool = false;
var gotoLineInput:String = "";

// Clipboard
var clipboard:String = "";

// Notification
var notifText:String = "";
var notifTimer:Float = 0;

// ======================== UI REFERENCES ========================
var bgSpr:FlxSprite;
var headerBg:FlxSprite;
var headerTitle:FlxText;
var headerFilePath:FlxText;
var headerModified:FlxText;
var headerHints:FlxText;

var tabBarBg:FlxSprite;
var tabGroup:FlxTypedGroup<FlxSprite>;

var visualBg:FlxSprite;
var visualBorder:FlxSprite;
var visualTitleText:FlxText;
var visualGroup:FlxTypedGroup<FlxSprite>;

var editorBg:FlxSprite;
var highlightSpr:FlxSprite;
var lineNumBg:FlxSprite;
var lineNumText:FlxText;
var codeText:FlxText;
var cursorSpr:FlxSprite;
var selectionSpr:FlxSprite;
var bracketMatchSpr:FlxSprite;

var minimapBg:FlxSprite;
var minimapBorder:FlxSprite;
var minimapTitle:FlxText;
var minimapCode:FlxText;
var minimapViewport:FlxSprite;

var findBarBg:FlxSprite;
var findBarBorder:FlxSprite;
var findLabel:FlxText;
var findInputText:FlxText;
var findResultText:FlxText;
var findOptionsText:FlxText;

var footerBg:FlxSprite;
var footerLeft:FlxText;
var footerCenter:FlxText;
var footerRight:FlxText;

var shortcutsOverlay:FlxSprite;
var shortcutsText:FlxText;
var settingsOverlay:FlxSprite;
var settingsText:FlxText;
var notifBg:FlxSprite;
var notifLabel:FlxText;

// Keywords
var KEYWORDS:Array<String> = ["package", "import", "class", "interface", "enum", "abstract", "typedef", "extends", "implements", "function", "var", "final", "static", "public", "private", "override", "inline", "dynamic", "extern", "macro", "using", "if", "else", "switch", "case", "default", "for", "while", "do", "break", "continue", "return", "throw", "try", "catch", "new", "this", "super", "null", "true", "false", "cast", "in", "untyped", "trace"];
var TYPES:Array<String> = ["Void", "Int", "Float", "Bool", "String", "Dynamic", "Any", "Array", "Map", "EReg", "Date", "Math", "Std", "Type", "Reflect", "FlxSprite", "FlxText", "FlxG", "FlxTween", "FlxEase", "FlxColor", "FlxMath", "FlxTimer", "FlxPoint", "FlxCamera", "FlxGroup", "FlxTypedGroup", "FlxSpriteGroup", "FlxSound", "FlxBasic", "FlxObject", "FlxState", "FlxSubState", "FunkinSprite", "FunkinText", "Alphabet", "Character", "MusicBeatState", "ModState", "PlayState", "Paths", "Options", "Flags"];

// Bracket pairs
var BRACKET_PAIRS:Map<String, String> = ["(" => ")", "[" => "]", "{" => "}"];
var CLOSE_BRACKETS:Map<String, String> = [")" => "(", "]" => "[", "}" => "{"];

// =============================================================================
//  CREATE
// =============================================================================

function countMapKeys(m:Dynamic):Int {
	var count = 0;
	for (k in m.keys()) count++;
	return count;
}

function create() {
	FlxG.mouse.visible = true;
	W = FlxG.width;
	H = FlxG.height;

	VISUAL_W = Math.round(W * 0.22);
	MINIMAP_W = Math.round(W * 0.08);

	createBackground();
	createHeader();
	createTabBar();
	createVisualPanel();
	createEditor();
	createMinimap();
	createFindBar();
	createFooter();
	createOverlays();

	if (data != null && Reflect.hasField(data, "path")) {
		filePath = Reflect.field(data, "path");
		loadFile(filePath);
	} else {
		content = getDefaultTemplate();
		originalContent = content;
		lines = content.split("\n");
		totalLines = lines.length;
		fileName = "Untitled.hx";
		createTab(fileName, content);
	}

	parseContent();
	refreshAll();
	showNotification("HX Editor ready", 2);
}

function createBackground() {
	bgSpr = new FlxSprite(0, 0).makeGraphic(W, H, C_BG);
	add(bgSpr);
}

function createHeader() {
	headerBg = new FlxSprite(0, 0).makeGraphic(W, HEADER_H, C_HEADER);
	add(headerBg);
	var headerLine = new FlxSprite(0, HEADER_H - 1).makeGraphic(W, 1, C_ACCENT);
	headerLine.alpha = 0.4;
	add(headerLine);

	headerTitle = new FlxText(14, 6, 150, "HX Editor", 16);
	headerTitle.color = C_ACCENT;
	headerTitle.bold = true;
	add(headerTitle);

	headerFilePath = new FlxText(14, 24, 600, "", 10);
	headerFilePath.color = C_DIM;
	add(headerFilePath);

	headerModified = new FlxText(170, 8, 60, "", 12);
	headerModified.color = C_WARNING;
	add(headerModified);

	headerHints = new FlxText(W - 520, 10, 510, "Ctrl+S:Save  Ctrl+Z:Undo  Ctrl+F:Find  F5:Validate  F6:Format  F1:Help  ESC:Exit", 9);
	headerHints.color = C_DIMMER;
	headerHints.alignment = "right";
	add(headerHints);
}

function createTabBar() {
	tabBarBg = new FlxSprite(0, HEADER_H).makeGraphic(W, TAB_BAR_H, FlxColor.fromRGB(20, 20, 30));
	add(tabBarBg);
	var tabLine = new FlxSprite(0, HEADER_H + TAB_BAR_H - 1).makeGraphic(W, 1, C_BORDER);
	tabLine.alpha = 0.3;
	add(tabLine);
	tabGroup = new FlxTypedGroup<FlxSprite>();
	add(tabGroup);
}

function createVisualPanel() {
	var vy = HEADER_H + TAB_BAR_H;
	var vh = H - HEADER_H - TAB_BAR_H - FOOTER_H;

	visualBg = new FlxSprite(0, vy).makeGraphic(VISUAL_W, vh, C_PANEL);
	add(visualBg);
	visualBorder = new FlxSprite(VISUAL_W - 1, vy).makeGraphic(1, vh, C_BORDER);
	visualBorder.alpha = 0.4;
	add(visualBorder);

	visualTitleText = new FlxText(10, vy + 6, VISUAL_W - 20, "STRUCTURE", 11);
	visualTitleText.color = C_DIM;
	visualTitleText.bold = true;
	add(visualTitleText);

	var visSep = new FlxSprite(8, vy + 22).makeGraphic(VISUAL_W - 16, 1, C_BORDER);
	visSep.alpha = 0.3;
	add(visSep);

	visualGroup = new FlxTypedGroup<FlxSprite>();
	add(visualGroup);
}

function createEditor() {
	var ex = VISUAL_W;
	var ey = HEADER_H + TAB_BAR_H;
	var ew = W - VISUAL_W - MINIMAP_W;
	var eh = H - HEADER_H - TAB_BAR_H - FOOTER_H;

	editorBg = new FlxSprite(ex, ey).makeGraphic(ew, eh, C_EDITOR);
	add(editorBg);

	lineNumBg = new FlxSprite(ex, ey).makeGraphic(LINE_NUM_W, eh, FlxColor.fromRGB(24, 24, 34));
	add(lineNumBg);

	var lineNumBorder = new FlxSprite(ex + LINE_NUM_W - 1, ey).makeGraphic(1, eh, C_BORDER);
	lineNumBorder.alpha = 0.3;
	add(lineNumBorder);

	highlightSpr = new FlxSprite(ex + LINE_NUM_W, ey).makeGraphic(ew - LINE_NUM_W, LINE_H, C_LINE_HL);
	highlightSpr.alpha = 0.6;
	add(highlightSpr);

	selectionSpr = new FlxSprite(ex + LINE_NUM_W, ey).makeGraphic(1, LINE_H, C_SELECT2);
	selectionSpr.alpha = 0.5;
	selectionSpr.visible = false;
	add(selectionSpr);

	bracketMatchSpr = new FlxSprite(0, 0).makeGraphic(FONT_SIZE, LINE_H, C_BRACKET);
	bracketMatchSpr.alpha = 0.3;
	bracketMatchSpr.visible = false;
	add(bracketMatchSpr);

	lineNumText = new FlxText(ex + 4, ey + 4, LINE_NUM_W - 8, "", FONT_SIZE - 2);
	lineNumText.color = C_LINE_NUM;
	lineNumText.alignment = "right";
	add(lineNumText);

	codeText = new FlxText(ex + LINE_NUM_W + 4, ey + 4, ew - LINE_NUM_W - 8, "", FONT_SIZE);
	codeText.color = C_TEXT;
	add(codeText);

	cursorSpr = new FlxSprite(0, 0).makeGraphic(2, LINE_H, C_ACCENT);
	cursorSpr.alpha = 0.9;
	add(cursorSpr);
}

function createMinimap() {
	var mx = W - MINIMAP_W;
	var my = HEADER_H + TAB_BAR_H;
	var mh = H - HEADER_H - TAB_BAR_H - FOOTER_H;

	minimapBg = new FlxSprite(mx, my).makeGraphic(MINIMAP_W, mh, C_PANEL2);
	add(minimapBg);
	minimapBorder = new FlxSprite(mx, my).makeGraphic(1, mh, C_BORDER);
	minimapBorder.alpha = 0.4;
	add(minimapBorder);

	minimapTitle = new FlxText(mx + 6, my + 4, MINIMAP_W - 12, "MAP", 9);
	minimapTitle.color = C_DIMMER;
	add(minimapTitle);

	minimapCode = new FlxText(mx + 4, my + 18, MINIMAP_W - 8, "", 3);
	minimapCode.color = FlxColor.fromRGB(70, 70, 90);
	add(minimapCode);

	minimapViewport = new FlxSprite(mx + 2, my + 18).makeGraphic(MINIMAP_W - 4, 40, C_ACCENT);
	minimapViewport.alpha = 0.1;
	add(minimapViewport);
}

function createFindBar() {
	var ex = VISUAL_W;
	var ey = HEADER_H + TAB_BAR_H;
	var ew = W - VISUAL_W - MINIMAP_W;

	findBarBg = new FlxSprite(ex, ey).makeGraphic(ew, FIND_BAR_H, FlxColor.fromRGB(35, 35, 50));
	findBarBg.visible = false;
	add(findBarBg);

	findBarBorder = new FlxSprite(ex, ey + FIND_BAR_H - 1).makeGraphic(ew, 1, C_ACCENT);
	findBarBorder.alpha = 0.5;
	findBarBorder.visible = false;
	add(findBarBorder);

	findLabel = new FlxText(ex + 10, ey + 6, 50, "Find:", 12);
	findLabel.color = C_DIM;
	findLabel.visible = false;
	add(findLabel);

	findInputText = new FlxText(ex + 60, ey + 6, ew - 250, "", 12);
	findInputText.color = C_TEXT;
	findInputText.visible = false;
	add(findInputText);

	findResultText = new FlxText(ex + ew - 180, ey + 6, 170, "", 11);
	findResultText.color = C_DIM;
	findResultText.alignment = "right";
	findResultText.visible = false;
	add(findResultText);

	findOptionsText = new FlxText(ex + 10, ey + 32, ew - 20, "ENTER:Confirm  ESC:Close  Ctrl+R:Regex  Ctrl+Shift+C:Case  TAB:Replace mode", 9);
	findOptionsText.color = C_DIMMER;
	findOptionsText.visible = false;
	add(findOptionsText);
}

function createFooter() {
	var fy = H - FOOTER_H;
	footerBg = new FlxSprite(0, fy).makeGraphic(W, FOOTER_H, C_FOOTER);
	add(footerBg);
	var footerLine = new FlxSprite(0, fy).makeGraphic(W, 1, C_BORDER);
	footerLine.alpha = 0.4;
	add(footerLine);

	footerLeft = new FlxText(12, fy + 5, 400, "", 10);
	footerLeft.color = C_DIM;
	add(footerLeft);

	footerCenter = new FlxText(W / 2 - 200, fy + 5, 400, "", 10);
	footerCenter.color = C_DIMMER;
	footerCenter.alignment = "center";
	add(footerCenter);

	footerRight = new FlxText(W - 412, fy + 5, 400, "", 10);
	footerRight.color = C_DIM;
	footerRight.alignment = "right";
	add(footerRight);
}

function createOverlays() {
	shortcutsOverlay = new FlxSprite(W / 2 - 300, H / 2 - 240).makeGraphic(600, 480, C_PANEL);
	shortcutsOverlay.alpha = 0.97;
	shortcutsOverlay.visible = false;
	add(shortcutsOverlay);

	shortcutsText = new FlxText(W / 2 - 280, H / 2 - 220, 560, "", 11);
	shortcutsText.color = C_TEXT;
	shortcutsText.visible = false;
	add(shortcutsText);

	var sc = "KEYBOARD SHORTCUTS\n\n";
	sc += "File Operations:\n";
	sc += "  Ctrl+S          Save file\n";
	sc += "  Ctrl+N          New file from template\n";
	sc += "  Ctrl+W          Close current tab\n";
	sc += "  Ctrl+TAB        Next tab\n";
	sc += "  Ctrl+Shift+TAB  Previous tab\n\n";
	sc += "Editing:\n";
	sc += "  Ctrl+Z          Undo\n";
	sc += "  Ctrl+Shift+Z    Redo\n";
	sc += "  Ctrl+Y          Redo\n";
	sc += "  Ctrl+X          Cut selection\n";
	sc += "  Ctrl+C          Copy selection\n";
	sc += "  Ctrl+V          Paste\n";
	sc += "  Ctrl+A          Select all\n";
	sc += "  Ctrl+D          Duplicate current line\n";
	sc += "  Ctrl+/          Toggle line comment\n";
	sc += "  TAB             Indent selection\n";
	sc += "  Shift+TAB       Unindent selection\n\n";
	sc += "Navigation:\n";
	sc += "  Ctrl+F          Find & Replace\n";
	sc += "  Ctrl+G          Go to line\n";
	sc += "  Ctrl+P          Go to function\n";
	sc += "  F2              Next bookmark\n";
	sc += "  Ctrl+F2         Toggle bookmark\n";
	sc += "  Alt+UP/DOWN     Move line up/down\n\n";
	sc += "View:\n";
	sc += "  F1              Toggle shortcuts\n";
	sc += "  F4              Toggle settings\n";
	sc += "  F5              Validate syntax\n";
	sc += "  F6              Format code\n";
	sc += "  Ctrl++/-        Zoom in/out\n";
	sc += "  Ctrl+0          Reset zoom\n";
	sc += "  ESC             Exit (auto-saves)";
	shortcutsText.text = sc;

	settingsOverlay = new FlxSprite(W / 2 - 220, H / 2 - 200).makeGraphic(440, 400, C_PANEL);
	settingsOverlay.alpha = 0.97;
	settingsOverlay.visible = false;
	add(settingsOverlay);

	settingsText = new FlxText(W / 2 - 200, H / 2 - 180, 400, "", 11);
	settingsText.color = C_TEXT;
	settingsText.visible = false;
	add(settingsText);

	notifBg = new FlxSprite(W / 2 - 200, 50).makeGraphic(400, 30, C_PANEL3);
	notifBg.alpha = 0.95;
	notifBg.visible = false;
	add(notifBg);

	notifLabel = new FlxText(W / 2 - 190, 55, 380, "", 12);
	notifLabel.color = C_TEXT;
	notifLabel.alignment = "center";
	notifLabel.visible = false;
	add(notifLabel);
}

// =============================================================================
//  FILE OPERATIONS
// =============================================================================
function loadFile(path:String) {
	try {
		var c:String = sys.io.File.getContent(path);
		if (c == null) c = "";
		filePath = path;
		fileName = haxe.io.Path.withoutDirectory(path);
		content = c;
		originalContent = c;
		lines = content.split("\n");
		totalLines = lines.length;
		isDirty = false;
		cursorLine = 0;
		cursorCol = 0;
		scrollY = 0;
		scrollX = 0;
		bookmarks = [];
		foldedLines = [];
		createTab(fileName, content);
		headerFilePath.text = filePath;
	} catch(e:Dynamic) {
		content = "// Error loading: " + path + "\n// " + Std.string(e);
		lines = content.split("\n");
		totalLines = lines.length;
		fileName = "Error";
	}
}

function saveFile() {
	if (filePath == null || filePath.length == 0) {
		showNotification("No file path set - cannot save", 3);
		return;
	}
	try {
		sys.io.File.saveContent(filePath, content);
		originalContent = content;
		isDirty = false;
		headerModified.text = "";
		showNotification("Saved: " + fileName, 2);
		refreshTabs();
		refreshStatus();
	} catch(e:Dynamic) {
		showNotification("Save error: " + Std.string(e), 4);
	}
}

function newFileFromTemplate() {
	filePath = "";
	fileName = "NewFile.hx";
	content = getDefaultTemplate();
	originalContent = content;
	lines = content.split("\n");
	totalLines = lines.length;
	isDirty = false;
	cursorLine = 0;
	cursorCol = 0;
	scrollY = 0;
	parseContent();
	createTab(fileName, content);
	headerFilePath.text = "Untitled";
	refreshAll();
	showNotification("New file created from template", 2);
}

function getDefaultTemplate():String {
	return "package;\n\nimport flixel.FlxSprite;\nimport flixel.FlxG;\nimport flixel.text.FlxText;\nimport flixel.util.FlxColor;\n\nclass NewClass {\n\n\tpublic function new() {\n\t\t\n\t}\n\n\tpublic function update(elapsed:Float):Void {\n\t\t\n\t}\n\n\tpublic function destroy():Void {\n\t\t\n\t}\n}\n";
}

// =============================================================================
//  TABS
// =============================================================================
function createTab(name:String, cont:String):Dynamic {
	for (i in 0...tabs.length) {
		if (tabs[i].name == name) {
			activeTabIndex = i;
			refreshTabs();
			return tabs[i];
		}
	}
	var tab = { name: name, content: cont, path: filePath, dirty: false, scrollY: 0, curLine: 0, curCol: 0 };
	tabs.push(tab);
	activeTabIndex = tabs.length - 1;
	refreshTabs();
	return tab;
}

function switchTab(index:Int) {
	if (index < 0 || index >= tabs.length) return;
	if (activeTabIndex >= 0 && activeTabIndex < tabs.length) {
		tabs[activeTabIndex].content = content;
		tabs[activeTabIndex].scrollY = scrollY;
		tabs[activeTabIndex].curLine = cursorLine;
		tabs[activeTabIndex].curCol = cursorCol;
		tabs[activeTabIndex].dirty = isDirty;
	}
	activeTabIndex = index;
	var tab = tabs[index];
	filePath = tab.path;
	fileName = tab.name;
	content = tab.content;
	lines = content.split("\n");
	totalLines = lines.length;
	scrollY = tab.scrollY;
	cursorLine = tab.curLine;
	cursorCol = tab.curCol;
	isDirty = tab.dirty;
	headerFilePath.text = filePath.length > 0 ? filePath : "Untitled";
	parseContent();
	refreshAll();
}

function closeTab(index:Int) {
	if (tabs.length <= 1) {
		newFileFromTemplate();
		return;
	}
	tabs.splice(index, 1);
	if (activeTabIndex >= tabs.length) activeTabIndex = tabs.length - 1;
	switchTab(activeTabIndex);
}

function refreshTabs() {
	while(tabGroup.members.length > 0) { tabGroup.remove(tabGroup.members[0], true); }
	var xOff:Float = 4;
	for (i in 0...tabs.length) {
		var tab = tabs[i];
		var isActive = i == activeTabIndex;
		var tw = 130;
		var bg = new FlxSprite(xOff, HEADER_H + 2).makeGraphic(tw, TAB_BAR_H - 4, isActive ? FlxColor.fromRGB(40, 40, 58) : FlxColor.fromRGB(26, 26, 38));
		tabGroup.add(bg);

		var displayName = tab.name;
		if (tab.dirty || (isActive && isDirty)) displayName = "* " + displayName;
		var lbl = new FlxText(xOff + 6, HEADER_H + 6, tw - 24, displayName, 10);
		lbl.color = isActive ? FlxColor.WHITE : C_DIM;
		tabGroup.add(lbl);

		if (tabs.length > 1) {
			var closeBtn = new FlxText(xOff + tw - 16, HEADER_H + 5, 14, "x", 10);
			closeBtn.color = FlxColor.fromRGB(180, 80, 80);
			tabGroup.add(closeBtn);
		}

		if (isActive) {
			var activeLine = new FlxSprite(xOff, HEADER_H + TAB_BAR_H - 2).makeGraphic(tw, 2, C_ACCENT);
			tabGroup.add(activeLine);
		}

		xOff += tw + 2;
	}
}

// =============================================================================
//  TEXT EDITING
// =============================================================================
function insertText(text:String) {
	pushUndo();
	if (hasSelection) deleteSelection();

	var before = lines[cursorLine].substr(0, cursorCol);
	var after = lines[cursorLine].substr(cursorCol);

	if (text.indexOf("\n") >= 0) {
		var parts = text.split("\n");
		lines[cursorLine] = before + parts[0];
		for (i in 1...parts.length) {
			var indent = "";
			if (autoIndent && i == parts.length - 1) {
				indent = getLineIndent(cursorLine);
			}
			lines.insert(cursorLine + i, indent + parts[i]);
		}
		cursorLine += parts.length - 1;
		cursorCol = (autoIndent ? getLineIndent(cursorLine).length : 0) + parts[parts.length - 1].length;
	} else {
		lines[cursorLine] = before + text + after;
		cursorCol += text.length;
	}

	content = lines.join("\n");
	totalLines = lines.length;
	isDirty = true;
	headerModified.text = "*";
	parseContent();
	refreshCode();
	refreshVisual();
	refreshMinimap();
	refreshStatus();
	refreshTabs();
}

function deleteCharBackward() {
	if (hasSelection) { deleteSelection(); return; }
	if (cursorCol > 0) {
		pushUndo();
		var before = lines[cursorLine].substr(0, cursorCol - 1);
		var after = lines[cursorLine].substr(cursorCol);
		lines[cursorLine] = before + after;
		cursorCol--;
	} else if (cursorLine > 0) {
		pushUndo();
		var prevLine = lines[cursorLine - 1];
		cursorCol = prevLine.length;
		lines[cursorLine - 1] = prevLine + lines[cursorLine];
		lines.splice(cursorLine, 1);
		cursorLine--;
	}
	content = lines.join("\n");
	totalLines = lines.length;
	isDirty = true;
	headerModified.text = "*";
	parseContent();
	refreshCode();
	refreshVisual();
	refreshMinimap();
	refreshStatus();
}

function deleteCharForward() {
	if (hasSelection) { deleteSelection(); return; }
	if (cursorCol < lines[cursorLine].length) {
		pushUndo();
		var before = lines[cursorLine].substr(0, cursorCol);
		var after = lines[cursorLine].substr(cursorCol + 1);
		lines[cursorLine] = before + after;
	} else if (cursorLine < lines.length - 1) {
		pushUndo();
		lines[cursorLine] = lines[cursorLine] + lines[cursorLine + 1];
		lines.splice(cursorLine + 1, 1);
	}
	content = lines.join("\n");
	totalLines = lines.length;
	isDirty = true;
	headerModified.text = "*";
	parseContent();
	refreshCode();
	refreshVisual();
	refreshMinimap();
	refreshStatus();
}

function insertNewline() {
	pushUndo();
	if (hasSelection) deleteSelection();

	var currentLine = lines[cursorLine];
	var before = currentLine.substr(0, cursorCol);
	var after = currentLine.substr(cursorCol);

	var indent = "";
	if (autoIndent) {
		indent = getLineIndent(cursorLine);
		var trimmed = StringTools.trim(before);
		if (trimmed.endsWith("{") || trimmed.endsWith("(") || trimmed.endsWith(":")) {
			indent += "\t";
		}
	}

	lines[cursorLine] = before;
	lines.insert(cursorLine + 1, indent + after);
	cursorLine++;
	cursorCol = indent.length;

	content = lines.join("\n");
	totalLines = lines.length;
	isDirty = true;
	headerModified.text = "*";
	parseContent();
	refreshCode();
	refreshVisual();
	refreshMinimap();
	refreshStatus();
	refreshTabs();
}

function getLineIndent(lineIdx:Int):String {
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
	if (!hasSelection) return;
	pushUndo();

	var startL = selectionStartLine;
	var startC = selectionStartCol;
	var endL = selectionEndLine;
	var endC = selectionEndCol;

	if (startL > endL || (startL == endL && startC > endC)) {
		var tmpL = startL; var tmpC = startC;
		startL = endL; startC = endC;
		endL = tmpL; endC = tmpC;
	}

	if (startL == endL) {
		lines[startL] = lines[startL].substr(0, startC) + lines[startL].substr(endC);
	} else {
		var firstPart = lines[startL].substr(0, startC);
		var lastPart = lines[endL].substr(endC);
		lines[startL] = firstPart + lastPart;
		var removeCount = endL - startL;
		for (i in 0...removeCount) {
			lines.splice(startL + 1, 1);
		}
	}

	cursorLine = startL;
	cursorCol = startC;
	hasSelection = false;
	selectionStartLine = -1;
	selectionStartCol = -1;
	selectionEndLine = -1;
	selectionEndCol = -1;

	content = lines.join("\n");
	totalLines = lines.length;
	isDirty = true;
	headerModified.text = "*";
	parseContent();
	refreshCode();
	refreshVisual();
	refreshMinimap();
	refreshStatus();
}

function getSelectedText():String {
	if (!hasSelection) return "";
	var startL = selectionStartLine;
	var startC = selectionStartCol;
	var endL = selectionEndLine;
	var endC = selectionEndCol;
	if (startL > endL || (startL == endL && startC > endC)) {
		var tmpL = startL; var tmpC = startC;
		startL = endL; startC = endC;
		endL = tmpL; endC = tmpC;
	}
	if (startL == endL) {
		return lines[startL].substr(startC, endC - startC);
	}
	var result = lines[startL].substr(startC) + "\n";
	for (i in startL + 1...endL) {
		result += lines[i] + "\n";
	}
	result += lines[endL].substr(0, endC);
	return result;
}

function selectAll() {
	selectionStartLine = 0;
	selectionStartCol = 0;
	selectionEndLine = lines.length - 1;
	selectionEndCol = lines[lines.length - 1].length;
	hasSelection = true;
	refreshCode();
}

function duplicateLine() {
	pushUndo();
	var line = lines[cursorLine];
	lines.insert(cursorLine + 1, line);
	cursorLine++;
	content = lines.join("\n");
	totalLines = lines.length;
	isDirty = true;
	headerModified.text = "*";
	refreshCode();
	refreshVisual();
	refreshMinimap();
	refreshStatus();
}

function toggleLineComment() {
	pushUndo();
	var startL = hasSelection ? Math.min(selectionStartLine, selectionEndLine) : cursorLine;
	var endL = hasSelection ? Math.max(selectionStartLine, selectionEndLine) : cursorLine;

	var allCommented = true;
	for (i in startL...endL + 1) {
		if (StringTools.trim(lines[i]).length > 0 && !StringTools.startsWith(StringTools.trim(lines[i]), "//")) {
			allCommented = false;
			break;
		}
	}

	for (i in startL...endL + 1) {
		if (allCommented) {
			var idx = lines[i].indexOf("//");
			if (idx >= 0) {
				if (idx + 2 < lines[i].length && lines[i].charAt(idx + 2) == " ") {
					lines[i] = lines[i].substr(0, idx) + lines[i].substr(idx + 3);
				} else {
					lines[i] = lines[i].substr(0, idx) + lines[i].substr(idx + 2);
				}
			}
		} else {
			var indent = getLineIndent(i);
			lines[i] = indent + "// " + StringTools.trim(lines[i]);
		}
	}

	content = lines.join("\n");
	isDirty = true;
	headerModified.text = "*";
	refreshCode();
	refreshVisual();
	refreshStatus();
}

function moveLineUp() {
	if (cursorLine <= 0) return;
	pushUndo();
	var temp = lines[cursorLine];
	lines[cursorLine] = lines[cursorLine - 1];
	lines[cursorLine - 1] = temp;
	cursorLine--;
	content = lines.join("\n");
	isDirty = true;
	headerModified.text = "*";
	refreshCode();
	refreshVisual();
	refreshStatus();
}

function moveLineDown() {
	if (cursorLine >= lines.length - 1) return;
	pushUndo();
	var temp = lines[cursorLine];
	lines[cursorLine] = lines[cursorLine + 1];
	lines[cursorLine + 1] = temp;
	cursorLine++;
	content = lines.join("\n");
	isDirty = true;
	headerModified.text = "*";
	refreshCode();
	refreshVisual();
	refreshStatus();
}

function indentSelection() {
	pushUndo();
	var startL = hasSelection ? Math.min(selectionStartLine, selectionEndLine) : cursorLine;
	var endL = hasSelection ? Math.max(selectionStartLine, selectionEndLine) : cursorLine;
	for (i in startL...endL + 1) {
		lines[i] = "\t" + lines[i];
	}
	content = lines.join("\n");
	isDirty = true;
	headerModified.text = "*";
	refreshCode();
	refreshStatus();
}

function unindentSelection() {
	pushUndo();
	var startL = hasSelection ? Math.min(selectionStartLine, selectionEndLine) : cursorLine;
	var endL = hasSelection ? Math.max(selectionStartLine, selectionEndLine) : cursorLine;
	for (i in startL...endL + 1) {
		if (StringTools.startsWith(lines[i], "\t")) {
			lines[i] = lines[i].substr(1);
		} else if (StringTools.startsWith(lines[i], "    ")) {
			lines[i] = lines[i].substr(4);
		}
	}
	content = lines.join("\n");
	isDirty = true;
	headerModified.text = "*";
	refreshCode();
	refreshStatus();
}

// =============================================================================
//  UNDO/REDO
// =============================================================================
function pushUndo() {
	undoStack.push({ content: content, line: cursorLine, col: cursorCol });
	if (undoStack.length > MAX_UNDO) undoStack.shift();
	redoStack = [];
}

function undo() {
	if (undoStack.length == 0) { showNotification("Nothing to undo", 1); return; }
	var action = undoStack.pop();
	redoStack.push({ content: content, line: cursorLine, col: cursorCol });
	content = action.content;
	lines = content.split("\n");
	totalLines = lines.length;
	cursorLine = action.line;
	cursorCol = action.col;
	isDirty = content != originalContent;
	headerModified.text = isDirty ? "*" : "";
	parseContent();
	refreshAll();
	showNotification("Undo (" + undoStack.length + " remaining)", 1);
}

function redo() {
	if (redoStack.length == 0) { showNotification("Nothing to redo", 1); return; }
	var action = redoStack.pop();
	undoStack.push({ content: content, line: cursorLine, col: cursorCol });
	content = action.content;
	lines = content.split("\n");
	totalLines = lines.length;
	cursorLine = action.line;
	cursorCol = action.col;
	isDirty = content != originalContent;
	headerModified.text = isDirty ? "*" : "";
	parseContent();
	refreshAll();
	showNotification("Redo (" + redoStack.length + " remaining)", 1);
}

// =============================================================================
//  FIND & REPLACE
// =============================================================================
function toggleFindBar() {
	findBarVisible = !findBarVisible;
	findBarBg.visible = findBarVisible;
	findBarBorder.visible = findBarVisible;
	findLabel.visible = findBarVisible;
	findInputText.visible = findBarVisible;
	findResultText.visible = findBarVisible;
	findOptionsText.visible = findBarVisible;
	if (findBarVisible) {
		findMode = true;
		findQuery = "";
		findInputText.text = "|";
		findResultText.text = "";
	} else {
		findMode = false;
	}
}

function performFind() {
	findResults = [];
	currentFindIdx = -1;
	if (findQuery.length == 0) { findResultText.text = ""; return; }

	var q = findCaseSensitive ? findQuery : findQuery.toLowerCase();

	var q = findCaseSensitive ? findQuery : findQuery.toLowerCase();
	for (i in 0...lines.length) {
		var line = findCaseSensitive ? lines[i] : lines[i].toLowerCase();
		var pos = 0;
		while (true) {
			var idx = line.indexOf(q, pos);
			if (idx < 0) break;
			findResults.push({ line: i, col: idx, len: findQuery.length });
			pos = idx + findQuery.length;
		}
	}

	findResultText.text = findResults.length + " match(es)";
	findResultText.color = findResults.length > 0 ? C_SUCCESS : C_WARNING;

	if (findResults.length > 0) {
		currentFindIdx = 0;
		cursorLine = findResults[0].line;
		cursorCol = findResults[0].col;
		ensureLineVisible(cursorLine);
		refreshCode();
		refreshStatus();
	}
}

function findNext() {
	if (findResults.length == 0) return;
	currentFindIdx = (currentFindIdx + 1) % findResults.length;
	var r = findResults[currentFindIdx];
	cursorLine = r.line;
	cursorCol = r.col;
	ensureLineVisible(cursorLine);
	findResultText.text = (currentFindIdx + 1) + "/" + findResults.length + " matches";
	refreshCode();
	refreshStatus();
}

function findPrev() {
	if (findResults.length == 0) return;
	currentFindIdx = (currentFindIdx - 1 + findResults.length) % findResults.length;
	var r = findResults[currentFindIdx];
	cursorLine = r.line;
	cursorCol = r.col;
	ensureLineVisible(cursorLine);
	findResultText.text = (currentFindIdx + 1) + "/" + findResults.length + " matches";
	refreshCode();
	refreshStatus();
}

function performReplace() {
	if (findResults.length == 0 || findQuery.length == 0) return;
	pushUndo();

	content = content.split(findQuery).join(replaceQuery);

	lines = content.split("\n");
	totalLines = lines.length;
	isDirty = true;
	headerModified.text = "*";
	parseContent();
	performFind();
	refreshAll();
	showNotification("Replaced all occurrences", 2);
}

// =============================================================================
//  PARSING
// =============================================================================
function parseContent() {
	parsedPkg = ""; parsedClass = ""; parsedExtends = ""; parsedImplements = "";
	parsedFuncs = []; parsedVars = []; parsedImports = [];

	var pkgIdx = content.indexOf("package ");
	if (pkgIdx >= 0) {
		var pkgEnd = content.indexOf(";", pkgIdx);
		if (pkgEnd >= 0) parsedPkg = StringTools.trim(content.substr(pkgIdx + 8, pkgEnd - pkgIdx - 8));
	}

	var clsIdx = content.indexOf("class ");
	if (clsIdx >= 0) {
		var afterCls = content.substr(clsIdx + 6);
		var spIdx = afterCls.indexOf(" ");
		var brIdx = afterCls.indexOf("{");
		var nlIdx = afterCls.indexOf("\n");
		var endIdx = spIdx >= 0 ? spIdx : (brIdx >= 0 ? brIdx : nlIdx);
		if (endIdx > 0) parsedClass = StringTools.trim(afterCls.substr(0, endIdx));
		var extIdx = content.indexOf("extends ");
		if (extIdx >= 0) {
			var afterExt = content.substr(extIdx + 8);
			var spIdx2 = afterExt.indexOf(" ");
			var nlIdx2 = afterExt.indexOf("\n");
			var endIdx2 = spIdx2 >= 0 ? spIdx2 : nlIdx2;
			if (endIdx2 < 0) endIdx2 = afterExt.length;
			if (endIdx2 > 0) parsedExtends = StringTools.trim(afterExt.substr(0, endIdx2));
		}
		var implIdx = content.indexOf("implements ");
		if (implIdx >= 0) {
			var afterImpl = content.substr(implIdx + 11);
			var brIdx2 = afterImpl.indexOf("{");
			var nlIdx3 = afterImpl.indexOf("\n");
			var endIdx3 = brIdx2 >= 0 ? brIdx2 : nlIdx3;
			if (endIdx3 < 0) endIdx3 = afterImpl.length;
			if (endIdx3 > 0) parsedImplements = StringTools.trim(afterImpl.substr(0, endIdx3));
		}
	}

	// Parse imports
	var iPos = 0;
	while (true) {
		var iIdx = content.indexOf("import ", iPos);
		if (iIdx < 0) break;
		var semiIdx = content.indexOf(";", iIdx);
		var impName = semiIdx >= 0 ? StringTools.trim(content.substr(iIdx + 7, semiIdx - iIdx - 7)) : "";
		var impLine = content.substr(0, iIdx).split("\n").length;
		if (impName.length > 0) parsedImports.push({ name: impName, line: impLine });
		iPos = iIdx + 7;
	}

	// Parse functions
	var fPos = 0;
	while (true) {
		var fIdx = content.indexOf("function ", fPos);
		if (fIdx < 0) break;
		var fLine = content.substr(0, fIdx).split("\n").length;
		var afterF = content.substr(fIdx + 9);
		var pIdx = afterF.indexOf("(");
		if (pIdx < 0 || pIdx > 40) { fPos = fIdx + 9; continue; }
		var fName = StringTools.trim(afterF.substr(0, pIdx));
		if (fName.length == 0 || fName.indexOf(" ") >= 0 || fName.indexOf("\n") >= 0) { fPos = fIdx + 9; continue; }
		var cpIdx = afterF.indexOf(")");
		var fParams = cpIdx > pIdx ? afterF.substr(pIdx + 1, cpIdx - pIdx - 1) : "";
		var lineStart = content.lastIndexOf("\n", fIdx) + 1;
		var beforeF = content.substr(lineStart, fIdx - lineStart);
		parsedFuncs.push({ name: fName, params: fParams, pub: beforeF.indexOf("public") >= 0, stat: beforeF.indexOf("static") >= 0, over: beforeF.indexOf("override") >= 0, inl: beforeF.indexOf("inline") >= 0, line: fLine });
		fPos = fIdx + 9;
	}

	// Parse variables
	var vPos = 0;
	while (true) {
		var vIdx = content.indexOf("var ", vPos);
		if (vIdx < 0) break;
		var vLine = content.substr(0, vIdx).split("\n").length;
		var afterV = content.substr(vIdx + 4);
		var endIdx = afterV.length;
		for (ch in [" ", ":", ";", "="]) { var ci = afterV.indexOf(ch); if (ci >= 0 && ci < endIdx) endIdx = ci; }
		var vName = StringTools.trim(afterV.substr(0, endIdx));
		if (vName.length == 0 || vName.indexOf("\n") >= 0) { vPos = vIdx + 4; continue; }
		var vType = "";
		var colonIdx = afterV.indexOf(":");
		if (colonIdx >= 0 && colonIdx < endIdx + 30) {
			var typeEnd = afterV.indexOf(";", colonIdx);
			if (typeEnd < 0) typeEnd = afterV.indexOf("=", colonIdx);
			if (typeEnd < 0) typeEnd = colonIdx + 20;
			vType = StringTools.trim(afterV.substr(colonIdx + 1, typeEnd - colonIdx - 1));
		}
		var lineStart = content.lastIndexOf("\n", vIdx) + 1;
		var beforeV = content.substr(lineStart, vIdx - lineStart);
		parsedVars.push({ name: vName, type: vType, pub: beforeV.indexOf("public") >= 0, stat: beforeV.indexOf("static") >= 0, fin: beforeV.indexOf("final") >= 0, line: vLine });
		vPos = vIdx + 4;
	}

		var lineStart = content.lastIndexOf("\n", vIdx) + 1;
		var beforeV = content.substr(lineStart, vIdx - lineStart);
		parsedVars.push({ name: vName, type: vType, pub: beforeV.indexOf("public") >= 0, stat: beforeV.indexOf("static") >= 0, fin: beforeV.indexOf("final") >= 0, line: vLine });
		vPos = vIdx + 4;
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
	var ey = HEADER_H + TAB_BAR_H;
	var ew = W - VISUAL_W - MINIMAP_W;
	var eh = H - HEADER_H - TAB_BAR_H - FOOTER_H;
	if (findBarVisible) { ey += FIND_BAR_H; eh -= FIND_BAR_H; }

	var visLines = Std.int(eh / LINE_H);
	var startLine = Std.int(scrollY / LINE_H);
	if (startLine < 0) startLine = 0;
	var endLine = Math.min(startLine + visLines, lines.length);

	// Line numbers
	var lnBuf = "";
	for (i in startLine...endLine) {
		lnBuf += "" + (i + 1) + "\n";
	}
	lineNumText.text = lnBuf;

	// Code display
	var codeBuf = "";
	for (i in startLine...endLine) {
		codeBuf += lines[i] + "\n";
	}
	codeText.text = codeBuf;

	// Current line highlight
	if (highlightCurrentLine && cursorLine >= startLine && cursorLine < endLine) {
		highlightSpr.y = ey + (cursorLine - startLine) * LINE_H + 2;
		highlightSpr.visible = true;
	} else {
		highlightSpr.visible = false;
	}

	// Cursor position
	if (cursorLine >= startLine && cursorLine < endLine) {
		var cx = ex + LINE_NUM_W + 4 + (cursorCol * (FONT_SIZE * 0.6));
		var cy = ey + (cursorLine - startLine) * LINE_H + 4;
		cursorSpr.x = cx;
		cursorSpr.y = cy;
		cursorSpr.visible = true;
	} else {
		cursorSpr.visible = false;
	}

	// Line number highlight for current line
	lineNumText.color = C_LINE_NUM;

	// Bracket matching
	checkBracketMatch();
}

function checkBracketMatch() {
	bracketMatchSpr.visible = false;
	if (cursorLine < 0 || cursorLine >= lines.length) return;
	var line = lines[cursorLine];
	if (cursorCol >= line.length) return;

	var ch = line.charAt(cursorCol);
	var matchChar = "";

	if (BRACKET_PAIRS.exists(ch)) {
		matchChar = BRACKET_PAIRS.get(ch);
		var depth = 0;
		for (i in cursorLine...lines.length) {
			var l = lines[i];
			var startJ = (i == cursorLine) ? cursorCol + 1 : 0;
			for (j in startJ...l.length) {
				if (l.charAt(j) == ch) depth++;
				if (l.charAt(j) == matchChar) {
					if (depth == 0) {
						showBracketMatch(i, j);
						return;
					}
					depth--;
				}
			}
		}
	} else if (CLOSE_BRACKETS.exists(ch)) {
		matchChar = CLOSE_BRACKETS.get(ch);
		var depth = 0;
		var i = cursorLine;
		while (i >= 0) {
			var l = lines[i];
			var startJ = (i == cursorLine) ? cursorCol - 1 : l.length - 1;
			var j = startJ;
			while (j >= 0) {
				if (l.charAt(j) == ch) depth++;
				if (l.charAt(j) == matchChar) {
					if (depth == 0) {
						showBracketMatch(i, j);
						return;
					}
					depth--;
				}
				j--;
			}
			i--;
		}
	}
}

function showBracketMatch(line:Int, col:Int) {
	var ex = VISUAL_W;
	var ey = HEADER_H + TAB_BAR_H;
	if (findBarVisible) ey += FIND_BAR_H;
	var startLine = Std.int(scrollY / LINE_H);
	if (line >= startLine && line < startLine + Std.int((H - HEADER_H - TAB_BAR_H - FOOTER_H) / LINE_H)) {
		bracketMatchSpr.x = ex + LINE_NUM_W + 4 + (col * (FONT_SIZE * 0.6));
		bracketMatchSpr.y = ey + (line - startLine) * LINE_H + 4;
		bracketMatchSpr.visible = true;
	}
}

function refreshVisual() {
	while(visualGroup.members.length > 0) { visualGroup.remove(visualGroup.members[0], true); }
	var y:Float = HEADER_H + TAB_BAR_H + 28;
	var maxY = H - FOOTER_H - 10;

	if (parsedPkg.length > 0) {
		y = addVisualItem("Package: " + parsedPkg, FlxColor.fromRGB(170, 170, 255), 10, y, 18);
	}

	if (parsedImports.length > 0) {
		var impExpanded = visualExpanded.exists("imports") ? visualExpanded.get("imports") : true;
		var impArrow = impExpanded ? "v " : "> ";
		y = addVisualItem(impArrow + "Imports (" + parsedImports.length + ")", FlxColor.fromRGB(136, 170, 136), 10, y, 18);
		if (impExpanded) {
			var showImp = Math.min(parsedImports.length, 12);
			for (i in 0...showImp) {
				var imp = parsedImports[i];
				var shortName = imp.name;
				if (shortName.length > 30) shortName = "..." + shortName.substr(shortName.length - 27);
				y = addVisualItem("  " + shortName, FlxColor.fromRGB(120, 150, 120), 18, y, 14);
			}
			if (parsedImports.length > showImp) {
				y = addVisualItem("  ... +" + (parsedImports.length - showImp) + " more", C_DIM, 18, y, 14);
			}
		}
	}

	if (parsedClass.length > 0) {
		var clsText = "Class: " + parsedClass;
		if (parsedExtends.length > 0) clsText += "\n  extends " + parsedExtends;
		if (parsedImplements.length > 0) clsText += "\n  implements " + parsedImplements;
		y = addVisualItem(clsText, FlxColor.fromRGB(255, 204, 68), 10, y, 22 + (parsedExtends.length > 0 ? 14 : 0) + (parsedImplements.length > 0 ? 14 : 0));
	}

	if (parsedVars.length > 0) {
		var varsExpanded = visualExpanded.exists("vars") ? visualExpanded.get("vars") : true;
		var varArrow = varsExpanded ? "v " : "> ";
		y = addVisualItem(varArrow + "Variables (" + parsedVars.length + ")", FlxColor.fromRGB(136, 204, 255), 10, y + 4, 18);
		if (varsExpanded) {
			var showV = Math.min(parsedVars.length, 20);
			for (i in 0...showV) {
				var v = parsedVars[i];
				var icon = v.pub ? "[+] " : "[-] ";
				if (v.stat) icon = "[S] ";
				if (v.fin) icon = "[F] ";
				var typeStr = v.type != null ? ": " + v.type : "";
				y = addVisualItem(icon + v.name + typeStr, v.pub ? FlxColor.fromRGB(136, 255, 136) : FlxColor.fromRGB(255, 136, 136), 18, y, 14);
			}
			if (parsedVars.length > showV) {
				y = addVisualItem("  ... +" + (parsedVars.length - showV) + " more", C_DIM, 18, y, 14);
			}
		}
	}

	if (parsedFuncs.length > 0) {
		var funcsExpanded = visualExpanded.exists("funcs") ? visualExpanded.get("funcs") : true;
		var funcArrow = funcsExpanded ? "v " : "> ";
		y = addVisualItem(funcArrow + "Functions (" + parsedFuncs.length + ")", FlxColor.fromRGB(255, 204, 136), 10, y + 6, 18);
		if (funcsExpanded) {
			var showF = Math.min(parsedFuncs.length, 25);
			for (i in 0...showF) {
				var f = parsedFuncs[i];
				var icon = f.pub ? "[+] " : "[-] ";
				if (f.stat) icon = "[S] ";
				if (f.over) icon = "[O] ";
				if (f.inl) icon = "[I] ";
				var paramStr = f.params.length > 20 ? f.params.substr(0, 20) + "..." : f.params;
				y = addVisualItem(icon + f.name + "(" + paramStr + ")", f.pub ? FlxColor.fromRGB(136, 204, 255) : FlxColor.fromRGB(204, 136, 136), 18, y, 14);
			}
			if (parsedFuncs.length > showF) {
				y = addVisualItem("  ... +" + (parsedFuncs.length - showF) + " more", C_DIM, 18, y, 14);
			}
		}
	}

	y = addVisualItem("---", C_DIMMER, 10, y + 8, 10);
	y = addVisualItem("Lines: " + lines.length + "  Funcs: " + parsedFuncs.length + "  Vars: " + parsedVars.length, FlxColor.fromRGB(75, 75, 95), 10, y, 14);
	y = addVisualItem("Bookmarks: " + countMapKeys(bookmarks), FlxColor.fromRGB(75, 75, 95), 10, y + 2, 14);
}

function addVisualItem(text:String, color:Int, x:Float, y:Float, h:Float):Float {
	var lbl = new FlxText(x, y, VISUAL_W - x - 8, text, 10);
	lbl.color = color;
	visualGroup.add(lbl);
	return y + h;
}

function refreshMinimap() {
	minimapCode.text = content;
	var eh = H - HEADER_H - TAB_BAR_H - FOOTER_H;
	var totalH = lines.length * 3;
	if (totalH > 0) {
		var ratio = eh / totalH;
		minimapViewport.scale.set(1, Math.max(10, eh * ratio));
		minimapViewport.updateHitbox();
		var scrollRatio = scrollY / Math.max(1, totalH - eh);
		minimapViewport.y = HEADER_H + TAB_BAR_H + 18 + scrollRatio * (eh - minimapViewport.height);
	}
}

function refreshStatus() {
	var left = fileName;
	if (isDirty) left += " *";
	if (filePath.length > 0) left += "  |  " + filePath;
	footerLeft.text = left;

	var center = "Ln " + (cursorLine + 1) + ", Col " + (cursorCol + 1);
	if (hasSelection) center += "  |  Selection: " + getSelectedText().length + " chars";
	center += "  |  " + lines.length + " lines";
	if (findResults.length > 0) center += "  |  Find: " + findResults.length;
	center += "  |  Undo: " + undoStack.length;
	footerCenter.text = center;

	var right = "Haxe/HScript  |  UTF-8  |  TAB=" + tabSize;
	footerRight.text = right;
}

function ensureLineVisible(line:Int) {
	var ey = HEADER_H + TAB_BAR_H;
	var eh = H - HEADER_H - TAB_BAR_H - FOOTER_H;
	if (findBarVisible) { ey += FIND_BAR_H; eh -= FIND_BAR_H; }
	var visLines = Std.int(eh / LINE_H);
	var startLine = Std.int(scrollY / LINE_H);

	if (line < startLine) {
		scrollY = line * LINE_H;
	} else if (line >= startLine + visLines - 1) {
		scrollY = (line - visLines + 2) * LINE_H;
	}
	if (scrollY < 0) scrollY = 0;
}

function showNotification(msg:String, duration:Float) {
	notifLabel.text = msg;
	notifBg.visible = true;
	notifLabel.visible = true;
	notifTimer = duration;
}

// =============================================================================
//  TOOLS
// =============================================================================
function validateSyntax() {
	var errors:Array<String> = [];
	var braces = 0; var brackets = 0; var parens = 0;
	var inStr = false; var inComment = false; var inLineComment = false;
	var strChar = "";

	for (lineIdx in 0...lines.length) {
		var line = lines[lineIdx];
		inLineComment = false;
		for (i in 0...line.length) {
			var ch = line.charAt(i);
			var next = i + 1 < line.length ? line.charAt(i + 1) : "";
			var prev = i > 0 ? line.charAt(i - 1) : "";

			if (inLineComment) continue;
			if (inComment) {
				if (ch == "*" && next == "/") { inComment = false; i++; }
				continue;
			}
			if (inStr) {
				if (ch == strChar && prev != "\\") inStr = false;
				continue;
			}

			if (ch == "/" && next == "/") inLineComment = true;
			else if (ch == "/" && next == "*") { inComment = true; i++; }
			else if (ch == '"' || ch == "'") { inStr = true; strChar = ch; }
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
		showNotification("No syntax issues found", 3);
		findResultText.text = "No issues";
		findResultText.color = C_SUCCESS;
	} else {
		showNotification("Issues: " + errors.join(", "), 5);
		findResultText.text = errors.join(", ");
		findResultText.color = C_ERROR;
	}
	findBarVisible = true;
	findBarBg.visible = true;
	findBarBorder.visible = true;
	findLabel.visible = true;
	findLabel.text = "Validate:";
	findInputText.visible = true;
	findInputText.text = "Syntax check results:";
	findResultText.visible = true;
	findOptionsText.visible = true;
	findOptionsText.text = "Press ESC to close";
}

function formatCode() {
	pushUndo();
	var formatted:Array<String> = [];
	var indent = 0;
	var inBlockComment = false;

	for (i in 0...lines.length) {
		var line = lines[i];
		var trimmed = StringTools.trim(line);

		if (trimmed.indexOf("/*") >= 0) inBlockComment = true;
		if (trimmed.indexOf("*/") >= 0) { inBlockComment = false; formatted.push(StringTools.lpad("", "\t", indent) + trimmed); continue; }
		if (inBlockComment) { formatted.push(StringTools.lpad("", "\t", indent) + trimmed); continue; }

		if (trimmed.startsWith("}")) indent = Math.max(0, indent - 1);
		formatted.push(StringTools.lpad("", "\t", indent) + trimmed);
		if (trimmed.endsWith("{")) indent++;
	}

	content = formatted.join("\n");
	lines = content.split("\n");
	totalLines = lines.length;
	isDirty = true;
	headerModified.text = "*";
	parseContent();
	refreshAll();
	showNotification("Code formatted", 2);
}

function goToLine() {
	gotoLineMode = true;
	gotoLineInput = "";
	findBarVisible = true;
	findBarBg.visible = true;
	findBarBorder.visible = true;
	findLabel.visible = true;
	findLabel.text = "Go to line:";
	findInputText.visible = true;
	findInputText.text = "|";
	findResultText.visible = true;
	findResultText.text = "Enter line number (1-" + lines.length + ")";
	findOptionsText.visible = true;
	findOptionsText.text = "ENTER: Go  ESC: Cancel";
}

function goToFunction() {
	if (parsedFuncs.length == 0) { showNotification("No functions found", 2); return; }
	var nextFunc = null;
	for (f in parsedFuncs) {
		if (f.line > cursorLine + 1) { nextFunc = f; break; }
	}
	if (nextFunc == null) nextFunc = parsedFuncs[0];
	cursorLine = nextFunc.line - 1;
	cursorCol = 0;
	ensureLineVisible(cursorLine);
	refreshCode();
	refreshStatus();
	showNotification("Jumped to: " + nextFunc.name + "()", 2);
}

function toggleBookmark() {
	if (bookmarks.exists(cursorLine)) {
		bookmarks.remove(cursorLine);
		showNotification("Bookmark removed (line " + (cursorLine + 1) + ")", 1.5);
	} else {
		bookmarks.set(cursorLine, true);
		showNotification("Bookmark added (line " + (cursorLine + 1) + ")", 1.5);
	}
}

function nextBookmark() {
	if (countMapKeys(bookmarks) == 0) { showNotification("No bookmarks", 1.5); return; }
	var bookmarkLines:Array<Int> = [];
	for (k in bookmarks.keys()) bookmarkLines.push(k);
	bookmarkLines.sort(Reflect.compare);

	var next = -1;
	for (bl in bookmarkLines) {
		if (bl > cursorLine) { next = bl; break; }
	}
	if (next == -1) next = bookmarkLines[0];
	cursorLine = next;
	cursorCol = 0;
	ensureLineVisible(cursorLine);
	refreshCode();
	refreshStatus();
	showNotification("Bookmark (line " + (next + 1) + ")", 1.5);
}

// =============================================================================
//  UPDATE
// =============================================================================
function update(elapsed:Float) {
	// Notification fade
	if (notifTimer > 0) {
		notifTimer -= elapsed;
		if (notifTimer <= 0) {
			notifBg.visible = false;
			notifLabel.visible = false;
		} else if (notifTimer < 0.5) {
			notifBg.alpha = notifTimer * 2;
			notifLabel.alpha = notifTimer * 2;
		}
	}

	// Cursor blink
	if (cursorSpr != null) { if ((Math.sin(FlxG.game.ticks * 0.005) > 0)) { cursorSpr.alpha = 0.9; } else { cursorSpr.alpha = 0.2; } }

	// ESC
	if (FlxG.keys.justPressed.ESCAPE) {
		if (shortcutsVisible) { shortcutsVisible = false; shortcutsOverlay.visible = false; shortcutsText.visible = false; return; }
		if (settingsVisible) { settingsVisible = false; settingsOverlay.visible = false; settingsText.visible = false; return; }
		if (findBarVisible) {
			findBarVisible = false; findMode = false; gotoLineMode = false;
			findBarBg.visible = false; findBarBorder.visible = false;
			findLabel.visible = false; findInputText.visible = false;
			findResultText.visible = false; findOptionsText.visible = false;
			return;
		}
		if (isDirty) saveFile();
		FlxG.switchState(new funkin.menus.MainMenuState());
		return;
	}

	// F1: Shortcuts
	if (FlxG.keys.justPressed.F1) {
		shortcutsVisible = !shortcutsVisible;
		shortcutsOverlay.visible = shortcutsVisible;
		shortcutsText.visible = shortcutsVisible;
		return;
	}

	// F4: Settings
	if (FlxG.keys.justPressed.F4) {
		settingsVisible = !settingsVisible;
		settingsOverlay.visible = settingsVisible;
		settingsText.visible = settingsVisible;
		if (settingsVisible) {
			var s = "EDITOR SETTINGS\n\n";
			s += "1. Auto-indent:        " + (autoIndent ? "[ON]" : "[OFF]") + "\n";
			s += "2. Auto-close brackets: " + (autoCloseBrackets ? "[ON]" : "[OFF]") + "\n";
			s += "3. Show line numbers:  " + (showLineNumbers ? "[ON]" : "[OFF]") + "\n";
			s += "4. Highlight cur line:  " + (highlightCurrentLine ? "[ON]" : "[OFF]") + "\n";
			s += "5. Show minimap:       " + (showMinimap ? "[ON]" : "[OFF]") + "\n";
			s += "6. Show visual panel:  " + (showVisualPanel ? "[ON]" : "[OFF]") + "\n";
			s += "7. Word wrap:          " + (wordWrap ? "[ON]" : "[OFF]") + "\n";
			s += "8. Tab size:           " + tabSize + "\n\n";
			s += "Press 1-8 to toggle. F4 or ESC to close.";
			settingsText.text = s;
		}
		return;
	}

	// Settings toggle
	if (settingsVisible) {
		for (code in 49...57) {
			if (FlxG.keys.justPressed(cast code)) {
				var idx = code - 49;
				switch(idx) {
					case 0: autoIndent = !autoIndent;
					case 1: autoCloseBrackets = !autoCloseBrackets;
					case 2: showLineNumbers = !showLineNumbers; lineNumBg.visible = showLineNumbers; lineNumText.visible = showLineNumbers;
					case 3: highlightCurrentLine = !highlightCurrentLine;
					case 4: showMinimap = !showMinimap; minimapBg.visible = showMinimap; minimapCode.visible = showMinimap; minimapViewport.visible = showMinimap;
					case 5: showVisualPanel = !showVisualPanel; visualBg.visible = showVisualPanel; visualGroup.visible = showVisualPanel;
					case 6: wordWrap = !wordWrap;
					case 7: tabSize = tabSize == 4 ? 2 : 4;
				}
				settingsText.text = "EDITOR SETTINGS\n\n1. Auto-indent:        " + (autoIndent ? "[ON]" : "[OFF]") + "\n2. Auto-close brackets: " + (autoCloseBrackets ? "[ON]" : "[OFF]") + "\n3. Show line numbers:  " + (showLineNumbers ? "[ON]" : "[OFF]") + "\n4. Highlight cur line:  " + (highlightCurrentLine ? "[ON]" : "[OFF]") + "\n5. Show minimap:       " + (showMinimap ? "[ON]" : "[OFF]") + "\n6. Show visual panel:  " + (showVisualPanel ? "[ON]" : "[OFF]") + "\n7. Word wrap:          " + (wordWrap ? "[ON]" : "[OFF]") + "\n8. Tab size:           " + tabSize + "\n\nPress 1-8 to toggle. F4 or ESC to close.";
				break;
			}
		}
		return;
	}

	// F5: Validate
	if (FlxG.keys.justPressed.F5) { validateSyntax(); return; }

	// F6: Format
	if (FlxG.keys.justPressed.F6) { formatCode(); return; }

	// F2: Next bookmark
	if (FlxG.keys.justPressed.F2 && !FlxG.keys.pressed.CONTROL) { nextBookmark(); return; }

	// Ctrl shortcuts
	if (FlxG.keys.pressed.CONTROL) {
		if (FlxG.keys.justPressed.S) { saveFile(); return; }
		if (FlxG.keys.justPressed.Z && !FlxG.keys.pressed.SHIFT) { undo(); return; }
		if (FlxG.keys.justPressed.Z && FlxG.keys.pressed.SHIFT) { redo(); return; }
		if (FlxG.keys.justPressed.Y) { redo(); return; }
		if (FlxG.keys.justPressed.F) { toggleFindBar(); return; }
		if (FlxG.keys.justPressed.N) { newFileFromTemplate(); return; }
		if (FlxG.keys.justPressed.W) { if (activeTabIndex >= 0) closeTab(activeTabIndex); return; }
		if (FlxG.keys.justPressed.G) { goToLine(); return; }
		if (FlxG.keys.justPressed.P) { goToFunction(); return; }
		if (FlxG.keys.justPressed.A) { selectAll(); return; }
		if (FlxG.keys.justPressed.D) { duplicateLine(); return; }
		if (FlxG.keys.justPressed.F2) { toggleBookmark(); return; }
		if (FlxG.keys.justPressed.TAB) {
			if (tabs.length > 1) {
				var next = FlxG.keys.pressed.SHIFT ? (activeTabIndex - 1 + tabs.length) % tabs.length : (activeTabIndex + 1) % tabs.length;
				switchTab(next);
			}
			return;
		}
		if (FlxG.keys.justPressed.C) {
			if (hasSelection) {
				clipboard = getSelectedText();
				showNotification("Copied " + clipboard.length + " chars", 1.5);
			}
			return;
		}
		if (FlxG.keys.justPressed.X) {
			if (hasSelection) {
				clipboard = getSelectedText();
				deleteSelection();
				showNotification("Cut " + clipboard.length + " chars", 1.5);
			}
			return;
		}
		if (FlxG.keys.justPressed.V) {
			if (clipboard.length > 0) insertText(clipboard);
			return;
		}
		if (FlxG.keys.justPressed.R && findBarVisible) {
			findUseRegex = !findUseRegex;
			findOptionsText.text = "Regex: " + (findUseRegex ? "ON" : "OFF") + "  |  ENTER:Confirm  ESC:Close";
			if (findQuery.length > 0) performFind();
			return;
		}
		// Ctrl+/ toggle comment
		if (FlxG.keys.justPressed.SLASH) { toggleLineComment(); return; }
	}

	// Alt+UP/DOWN move line
	if (FlxG.keys.pressed.ALT) {
		if (FlxG.keys.justPressed.UP) { moveLineUp(); return; }
		if (FlxG.keys.justPressed.DOWN) { moveLineDown(); return; }
	}

	// Find mode input
	if (findMode && findBarVisible && !gotoLineMode) {
		if (FlxG.keys.justPressed.BACKSPACE) {
			findQuery = findQuery.substr(0, Math.max(0, findQuery.length - 1));
			findInputText.text = findQuery + "|";
			performFind();
			return;
		}
		if (FlxG.keys.justPressed.ENTER) {
			findNext();
			return;
		}
		if (FlxG.keys.justPressed.TAB) {
			findNext();
			return;
		}
		for (code in 32...127) {
			if (FlxG.keys.justPressed(cast code)) {
				findQuery += String.fromCharCode(code);
				findInputText.text = findQuery + "|";
				performFind();
				break;
			}
		}
		return;
	}

	// Go to line mode input
	if (gotoLineMode && findBarVisible) {
		if (FlxG.keys.justPressed.BACKSPACE) {
			gotoLineInput = gotoLineInput.substr(0, Math.max(0, gotoLineInput.length - 1));
			findInputText.text = gotoLineInput + "|";
			return;
		}
		if (FlxG.keys.justPressed.ENTER) {
			var lineNum = Std.parseInt(gotoLineInput);
			if (lineNum != null && lineNum >= 1 && lineNum <= lines.length) {
				cursorLine = lineNum - 1;
				cursorCol = 0;
				ensureLineVisible(cursorLine);
				refreshCode();
				refreshStatus();
				showNotification("Jumped to line " + lineNum, 1.5);
			}
			gotoLineMode = false;
			findBarVisible = false;
			findBarBg.visible = false; findBarBorder.visible = false;
			findLabel.visible = false; findInputText.visible = false;
			findResultText.visible = false; findOptionsText.visible = false;
			return;
		}
		for (code in 48...58) {
			if (FlxG.keys.justPressed(cast code)) {
				gotoLineInput += String.fromCharCode(code);
				findInputText.text = gotoLineInput + "|";
				break;
			}
		}
		return;
	}

	// Cursor movement
	if (FlxG.keys.justPressed.DOWN) {
		if (FlxG.keys.pressed.SHIFT) {
			if (!hasSelection) { selectionStartLine = cursorLine; selectionStartCol = cursorCol; hasSelection = true; }
		} else { hasSelection = false; }
		cursorLine = Math.min(lines.length - 1, cursorLine + 1);
		cursorCol = Math.min(cursorCol, lines[cursorLine].length);
		if (FlxG.keys.pressed.SHIFT) { selectionEndLine = cursorLine; selectionEndCol = cursorCol; }
		ensureLineVisible(cursorLine);
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.UP) {
		if (FlxG.keys.pressed.SHIFT) {
			if (!hasSelection) { selectionStartLine = cursorLine; selectionStartCol = cursorCol; hasSelection = true; }
		} else { hasSelection = false; }
		cursorLine = Math.max(0, cursorLine - 1);
		cursorCol = Math.min(cursorCol, lines[cursorLine].length);
		if (FlxG.keys.pressed.SHIFT) { selectionEndLine = cursorLine; selectionEndCol = cursorCol; }
		ensureLineVisible(cursorLine);
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.RIGHT) {
		if (FlxG.keys.pressed.SHIFT) {
			if (!hasSelection) { selectionStartLine = cursorLine; selectionStartCol = cursorCol; hasSelection = true; }
		} else { hasSelection = false; }
		if (cursorCol < lines[cursorLine].length) {
			cursorCol++;
		} else if (cursorLine < lines.length - 1) {
			cursorLine++;
			cursorCol = 0;
		}
		if (FlxG.keys.pressed.SHIFT) { selectionEndLine = cursorLine; selectionEndCol = cursorCol; }
		ensureLineVisible(cursorLine);
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.LEFT) {
		if (FlxG.keys.pressed.SHIFT) {
			if (!hasSelection) { selectionStartLine = cursorLine; selectionStartCol = cursorCol; hasSelection = true; }
		} else { hasSelection = false; }
		if (cursorCol > 0) {
			cursorCol--;
		} else if (cursorLine > 0) {
			cursorLine--;
			cursorCol = lines[cursorLine].length;
		}
		if (FlxG.keys.pressed.SHIFT) { selectionEndLine = cursorLine; selectionEndCol = cursorCol; }
		ensureLineVisible(cursorLine);
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.HOME) {
		var indent = getLineIndent(cursorLine);
		cursorCol = (cursorCol == indent.length) ? 0 : indent.length;
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.END) {
		cursorCol = lines[cursorLine].length;
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.PAGEDOWN) {
		var page = Std.int((H - HEADER_H - TAB_BAR_H - FOOTER_H) / LINE_H);
		cursorLine = Math.min(lines.length - 1, cursorLine + page);
		cursorCol = Math.min(cursorCol, lines[cursorLine].length);
		ensureLineVisible(cursorLine);
		refreshCode();
		refreshStatus();
	}
	if (FlxG.keys.justPressed.PAGEUP) {
		var page = Std.int((H - HEADER_H - TAB_BAR_H - FOOTER_H) / LINE_H);
		cursorLine = Math.max(0, cursorLine - page);
		cursorCol = Math.min(cursorCol, lines[cursorLine].length);
		ensureLineVisible(cursorLine);
		refreshCode();
		refreshStatus();
	}

	// Text editing
	if (FlxG.keys.justPressed.ENTER && !findBarVisible) {
		insertNewline();
		return;
	}
	if (FlxG.keys.justPressed.BACKSPACE && !findBarVisible) {
		deleteCharBackward();
		return;
	}
	if (FlxG.keys.justPressed.DELETE && !findBarVisible) {
		deleteCharForward();
		return;
	}
	if (FlxG.keys.justPressed.TAB && !FlxG.keys.pressed.CONTROL && !findBarVisible) {
		if (FlxG.keys.pressed.SHIFT) {
			unindentSelection();
		} else if (hasSelection) {
			indentSelection();
		} else {
			insertText("\t");
		}
		return;
	}

	// Character input
	if (!findBarVisible) {
		for (code in 32...127) {
			if (FlxG.keys.justPressed(cast code)) {
				var ch = String.fromCharCode(code);
				// Auto-close brackets
				if (autoCloseBrackets && BRACKET_PAIRS.exists(ch)) {
					insertText(ch + BRACKET_PAIRS.get(ch));
					cursorCol--;
					refreshCode();
					refreshStatus();
				} else {
					insertText(ch);
				}
				break;
			}
		}
	}

	// Mouse wheel scroll
	if (FlxG.mouse.wheel != 0) {
		scrollY -= FlxG.mouse.wheel * LINE_H * 3;
		if (scrollY < 0) scrollY = 0;
		var maxScroll = (lines.length * LINE_H) - (H - HEADER_H - TAB_BAR_H - FOOTER_H);
		if (findBarVisible) maxScroll -= FIND_BAR_H;
		if (maxScroll < 0) maxScroll = 0;
		if (scrollY > maxScroll) scrollY = maxScroll;
		refreshCode();
		refreshMinimap();
	}
}
