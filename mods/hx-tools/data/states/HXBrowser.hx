// =============================================================================
//  HX FILE BROWSER v2.0 - Codename Engine Custom State
//  mods/hx-tools/data/states/HXBrowser.hx
//  Redirect: [StateRedirects] StoryMenuState="HXBrowser"
//  Or open:  FlxG.switchState(new ModState("HXBrowser"))
// =============================================================================
//  A professional file browser for all .hx files in the engine.
//  Features: category tree, file list, code preview, search, favorites,
//  recent files, sorting, statistics, keyboard navigation, animations.
// =============================================================================

// ======================== CONSTANTS ========================
var W = 1280;
var H = 720;
var HEADER_H = 38;
var FOOTER_H = 28;
var CAT_W = 280;
var LIST_W = 360;
var INFO_H = 160;
var SEARCH_H = 32;
var BREADCRUMB_H = 26;
var LINE_H = 22;
var FILE_LINE_H = 24;
var CAT_LINE_H = 26;
var SUB_LINE_H = 22;
var PREVIEW_FONT_SIZE = 10;
var TAB_H = 28;

// ======================== COLORS ========================
var C_BG = FlxColor.fromRGB(20, 20, 28);
var C_BG2 = FlxColor.fromRGB(24, 24, 34);
var C_PANEL = FlxColor.fromRGB(28, 28, 40);
var C_PANEL2 = FlxColor.fromRGB(32, 32, 46);
var C_PANEL3 = FlxColor.fromRGB(36, 36, 52);
var C_HEADER = FlxColor.fromRGB(14, 14, 22);
var C_FOOTER = FlxColor.fromRGB(14, 14, 22);
var C_BORDER = FlxColor.fromRGB(45, 45, 65);
var C_TEXT = FlxColor.fromRGB(220, 220, 235);
var C_TEXT2 = FlxColor.fromRGB(180, 180, 200);
var C_DIM = FlxColor.fromRGB(100, 100, 130);
var C_DIMMER = FlxColor.fromRGB(70, 70, 95);
var C_ACCENT = FlxColor.fromRGB(80, 150, 255);
var C_ACCENT2 = FlxColor.fromRGB(120, 180, 255);
var C_SELECT = FlxColor.fromRGB(45, 60, 100);
var C_SELECT2 = FlxColor.fromRGB(55, 70, 115);
var C_HOVER = FlxColor.fromRGB(38, 38, 55);
var C_HOVER2 = FlxColor.fromRGB(42, 42, 62);
var C_SUCCESS = FlxColor.fromRGB(80, 220, 120);
var C_WARNING = FlxColor.fromRGB(255, 200, 80);
var C_ERROR = FlxColor.fromRGB(255, 80, 80);
var C_LINE_NUM = FlxColor.fromRGB(60, 60, 85);
var C_LINE_HL = FlxColor.fromRGB(32, 32, 48);

// Category colors
var CC_STATES = FlxColor.fromRGB(68, 136, 255);
var CC_SUBSTATES = FlxColor.fromRGB(68, 170, 255);
var CC_EDITORS = FlxColor.fromRGB(68, 255, 136);
var CC_EDITORUI = FlxColor.fromRGB(136, 255, 68);
var CC_SCRIPTS = FlxColor.fromRGB(255, 170, 68);
var CC_GAME = FlxColor.fromRGB(255, 68, 102);
var CC_BACKEND = FlxColor.fromRGB(153, 68, 255);
var CC_MENUS = FlxColor.fromRGB(68, 255, 221);
var CC_OPTIONS = FlxColor.fromRGB(221, 221, 68);
var CC_LIBRARIES = FlxColor.fromRGB(102, 102, 102);
var CC_OTHER = FlxColor.fromRGB(136, 136, 136);

// Syntax highlighting colors
var SYN_KEYWORD = FlxColor.fromRGB(200, 120, 255);
var SYN_TYPE = FlxColor.fromRGB(100, 200, 255);
var SYN_STRING = FlxColor.fromRGB(180, 230, 130);
var SYN_COMMENT = FlxColor.fromRGB(90, 100, 120);
var SYN_NUMBER = FlxColor.fromRGB(255, 200, 100);
var SYN_FUNC = FlxColor.fromRGB(255, 220, 120);
var SYN_OPERATOR = FlxColor.fromRGB(200, 200, 220);
var SYN_PREPROC = FlxColor.fromRGB(180, 140, 200);

// ======================== DATA ========================
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
var previewScrollY:Float = 0;
var catScrollY:Float = 0;

// Favorites
var favorites:Map<String, Bool> = [];
var showFavoritesOnly:Bool = false;

// Recent files
var recentFiles:Array<String> = [];
var MAX_RECENT = 30;

// Navigation history
var navHistory:Array<String> = [];
var navHistoryIndex:Int = -1;

// Search mode
var searchMode:Bool = false;
var searchHistory:Array<String> = [];

// Statistics
var totalFiles:Int = 0;
var totalLines:Int = 0;
var totalSize:Int = 0;
var totalFunctions:Int = 0;
var totalVariables:Int = 0;

// Tabs
var openTabs:Array<Dynamic> = [];
var activeTabIndex:Int = -1;

// Settings
var showLineNumbers:Bool = true;
var showHiddenFiles:Bool = false;
var autoPreview:Bool = true;
var previewLines:Int = 80;
var showFileSize:Bool = true;
var showLineCount:Bool = true;
var showFunctionCount:Bool = true;
var caseSensitiveSearch:Bool = false;
var regexSearch:Bool = false;

// Animation
var panelAlpha:Float = 1.0;
var transitionAlpha:Float = 0.0;

// ======================== UI REFERENCES ========================
// Background layers
var bgSpr:FlxSprite;
var bgGradientTop:FlxSprite;
var bgGradientBot:FlxSprite;

// Header
var headerBg:FlxSprite;
var headerTitle:FlxText;
var headerSubtitle:FlxText;
var headerIconSpr:FlxSprite;

// Breadcrumb bar
var breadcrumbBg:FlxSprite;
var breadcrumbText:FlxText;

// Category panel
var catPanelBg:FlxSprite;
var catPanelBorder:FlxSprite;
var catPanelTitle:FlxText;
var catPanelCount:FlxText;
var catItemsGroup:FlxTypedGroup<FlxSprite>;
var catScrollIndicator:FlxSprite;

// Search bar
var searchBg:FlxSprite;
var searchBorder:FlxSprite;
var searchIconText:FlxText;
var searchText:FlxText;
var searchClearBtn:FlxSprite;
var searchOptionsText:FlxText;

// File list panel
var listPanelBg:FlxSprite;
var listPanelBorder:FlxSprite;
var listPanelTitle:FlxText;
var listPanelCount:FlxText;
var listSortText:FlxText;
var listItemsGroup:FlxTypedGroup<FlxSprite>;
var listScrollIndicator:FlxSprite;
var listEmptyText:FlxText;

// Preview panel
var previewPanelBg:FlxSprite;
var previewPanelBorder:FlxSprite;
var previewTitleBg:FlxSprite;
var previewTitleText:FlxText;
var previewPathText:FlxText;
var previewLineNums:FlxText;
var previewCodeText:FlxText;
var previewScrollIndicator:FlxSprite;
var previewOverlayGroup:FlxTypedGroup<FlxSprite>;

// Info panel
var infoPanelBg:FlxSprite;
var infoPanelBorder:FlxSprite;
var infoPanelTitle:FlxText;
var infoContentText:FlxText;
var infoFuncsText:FlxText;

// Footer
var footerBg:FlxSprite;
var footerLeftText:FlxText;
var footerCenterText:FlxText;
var footerRightText:FlxText;

// Tab bar
var tabBarBg:FlxSprite;
var tabItemsGroup:FlxTypedGroup<FlxSprite>;

// Overlays
var shortcutsOverlay:FlxSprite;
var shortcutsText:FlxText;
var shortcutsVisible:Bool = false;

var statsOverlay:FlxSprite;
var statsText:FlxText;
var statsVisible:Bool = false;

var settingsOverlay:FlxSprite;
var settingsGroup:FlxTypedGroup<FlxSprite>;
var settingsVisible:Bool = false;

var contextMenuGroup:FlxTypedGroup<FlxSprite>;
var contextMenuVisible:Bool = false;
var contextMenuItems:Array<Dynamic> = [];

// Tooltip
var tooltipBg:FlxSprite;
var tooltipText:FlxText;
var tooltipVisible:Bool = false;

// Notification
var notifBg:FlxSprite;
var notifText:FlxText;
var notifTimer:Float = 0;
var notifVisible:Bool = false;

// ======================== KEYWORDS FOR SYNTAX HIGHLIGHTING ========================
var HAXE_KEYWORDS:Array<String> = [
	"package", "import", "class", "interface", "enum", "abstract", "typedef",
	"extends", "implements", "function", "var", "final", "static", "public",
	"private", "override", "inline", "dynamic", "extern", "macro", "using",
	"if", "else", "switch", "case", "default", "for", "while", "do",
	"break", "continue", "return", "throw", "try", "catch", "new",
	"this", "super", "null", "true", "false", "cast", "in", "untyped"
];

var HAXE_TYPES:Array<String> = [
	"Void", "Int", "Float", "Bool", "String", "Dynamic", "Any",
	"Array", "Map", "StringMap", "IntMap", "EReg", "Date", "Math",
	"Std", "Type", "Reflect", "Lambda", "Json", "Xml",
	"FlxSprite", "FlxText", "FlxG", "FlxTween", "FlxEase", "FlxColor",
	"FlxMath", "FlxTimer", "FlxPoint", "FlxCamera", "FlxGroup",
	"FlxTypedGroup", "FlxSpriteGroup", "FlxSound", "FlxBasic",
	"FlxObject", "FlxState", "FlxSubState", "FlxButton",
	"FunkinSprite", "FunkinText", "Alphabet", "Character",
	"MusicBeatState", "MusicBeatSubstate", "UIState",
	"ModState", "ModSubState", "PlayState", "Paths", "Options", "Flags"
];

// =============================================================================
//  CREATE
// =============================================================================
function create() {
	FlxG.mouse.visible = true;
	W = FlxG.width;
	H = FlxG.height;

	// Recalculate layout
	CAT_W = Math.round(W * 0.22);
	LIST_W = Math.round(W * 0.28);

	createBackground();
	createHeader();
	createBreadcrumbBar();
	createCategoryPanel();
	createSearchBar();
	createFileListPanel();
	createPreviewPanel();
	createInfoPanel();
	createFooter();
	createTabBar();
	createOverlays();

	scanAllFiles();
	calculateStatistics();

	if (rootCats.length > 0) {
		selectCategory(rootCats[0]);
	}

	showNotification("HX Browser ready — " + allFiles.length + " files found", 3);
	refreshAll();
}

// ======================== BACKGROUND ========================
function createBackground() {
	bgSpr = new FlxSprite(0, 0).makeGraphic(W, H, C_BG);
	add(bgSpr);

	bgGradientTop = new FlxSprite(0, 0).makeGraphic(W, 80, FlxColor.fromRGB(25, 25, 38));
	bgGradientTop.alpha = 0.5;
	add(bgGradientTop);

	bgGradientBot = new FlxSprite(0, H - 60).makeGraphic(W, 60, FlxColor.fromRGB(15, 15, 22));
	bgGradientBot.alpha = 0.4;
	add(bgGradientBot);
}

// ======================== HEADER ========================
function createHeader() {
	headerBg = new FlxSprite(0, 0).makeGraphic(W, HEADER_H, C_HEADER);
	add(headerBg);

	var headerLine = new FlxSprite(0, HEADER_H - 1).makeGraphic(W, 1, C_ACCENT);
	headerLine.alpha = 0.4;
	add(headerLine);

	headerTitle = new FlxText(14, 8, 250, "HX File Browser", 18);
	headerTitle.color = C_ACCENT;
	headerTitle.bold = true;
	add(headerTitle);

	headerSubtitle = new FlxText(14, 26, 300, "Codename Engine Source Explorer", 9);
	headerSubtitle.color = C_DIM;
	add(headerSubtitle);

	var rightHint = new FlxText(W - 500, 10, 490, "F1:Shortcuts  F2:Sort  F3:Stats  F4:Settings  Ctrl+E:Edit  Ctrl+F:Search  TAB:Switch Cat", 9);
	rightHint.color = C_DIMMER;
	rightHint.alignment = RIGHT;
	add(rightHint);
}

// ======================== BREADCRUMB BAR ========================
function createBreadcrumbBar() {
	var by = HEADER_H;
	breadcrumbBg = new FlxSprite(0, by).makeGraphic(W, BREADCRUMB_H, C_BG2);
	add(breadcrumbBg);

	var breadcrumbBorder = new FlxSprite(0, by + BREADCRUMB_H - 1).makeGraphic(W, 1, C_BORDER);
	breadcrumbBorder.alpha = 0.3;
	add(breadcrumbBorder);

	breadcrumbText = new FlxText(14, by + 5, W - 28, "Home  >  All Files", 11);
	breadcrumbText.color = C_DIM;
	add(breadcrumbText);
}

// ======================== CATEGORY PANEL ========================
function createCategoryPanel() {
	var py = HEADER_H + BREADCRUMB_H;
	var ph = H - HEADER_H - BREADCRUMB_H - FOOTER_H - INFO_H;

	catPanelBg = new FlxSprite(0, py).makeGraphic(CAT_W, ph, C_PANEL);
	add(catPanelBg);

	catPanelBorder = new FlxSprite(CAT_W - 1, py).makeGraphic(1, ph, C_BORDER);
	catPanelBorder.alpha = 0.4;
	add(catPanelBorder);

	catPanelTitle = new FlxText(12, py + 6, CAT_W - 80, "CATEGORIES", 11);
	catPanelTitle.color = C_DIM;
	catPanelTitle.bold = true;
	add(catPanelTitle);

	catPanelCount = new FlxText(CAT_W - 70, py + 6, 60, "", 10);
	catPanelCount.color = C_DIMMER;
	catPanelCount.alignment = RIGHT;
	add(catPanelCount);

	var catSep = new FlxSprite(8, py + 22).makeGraphic(CAT_W - 16, 1, C_BORDER);
	catSep.alpha = 0.3;
	add(catSep);

	catItemsGroup = new FlxTypedGroup<FlxSprite>();
	add(catItemsGroup);

	catScrollIndicator = new FlxSprite(CAT_W - 4, py + 24).makeGraphic(3, 40, C_ACCENT);
	catScrollIndicator.alpha = 0.3;
	catScrollIndicator.visible = false;
	add(catScrollIndicator);
}

// ======================== SEARCH BAR ========================
function createSearchBar() {
	var sy = HEADER_H + BREADCRUMB_H;
	var sx = CAT_W;

	searchBg = new FlxSprite(sx, sy).makeGraphic(LIST_W, SEARCH_H, C_BG2);
	add(searchBg);

	searchBorder = new FlxSprite(sx + 4, sy + 4).makeGraphic(LIST_W - 8, SEARCH_H - 8, C_PANEL2);
	searchBorder.alpha = 0.6;
	add(searchBorder);

	searchIconText = new FlxText(sx + 10, sy + 7, 20, "Q", 13);
	searchIconText.color = C_DIM;
	add(searchIconText);

	searchText = new FlxText(sx + 32, sy + 7, LIST_W - 80, "Press S to search...", 12);
	searchText.color = C_DIMMER;
	add(searchText);

	searchOptionsText = new FlxText(sx + LIST_W - 120, sy + 8, 110, "", 9);
	searchOptionsText.color = C_DIMMER;
	searchOptionsText.alignment = RIGHT;
	add(searchOptionsText);

	var searchSep = new FlxSprite(sx, sy + SEARCH_H - 1).makeGraphic(LIST_W, 1, C_BORDER);
	searchSep.alpha = 0.3;
	add(searchSep);
}

// ======================== FILE LIST PANEL ========================
function createFileListPanel() {
	var py = HEADER_H + BREADCRUMB_H + SEARCH_H;
	var ph = H - HEADER_H - BREADCRUMB_H - SEARCH_H - FOOTER_H - INFO_H;

	listPanelBg = new FlxSprite(CAT_W, py).makeGraphic(LIST_W, ph, C_PANEL);
	add(listPanelBg);

	listPanelBorder = new FlxSprite(CAT_W + LIST_W - 1, py).makeGraphic(1, ph, C_BORDER);
	listPanelBorder.alpha = 0.4;
	add(listPanelBorder);

	listPanelTitle = new FlxText(CAT_W + 12, py + 6, LIST_W - 120, "FILES", 11);
	listPanelTitle.color = C_DIM;
	listPanelTitle.bold = true;
	add(listPanelTitle);

	listPanelCount = new FlxText(CAT_W + LIST_W - 110, py + 6, 100, "", 10);
	listPanelCount.color = C_DIMMER;
	listPanelCount.alignment = RIGHT;
	add(listPanelCount);

	listSortText = new FlxText(CAT_W + 12, py + 6, LIST_W - 24, "", 9);
	listSortText.color = C_DIMMER;
	listSortText.alignment = RIGHT;
	add(listSortText);

	var listSep = new FlxSprite(CAT_W + 8, py + 22).makeGraphic(LIST_W - 16, 1, C_BORDER);
	listSep.alpha = 0.3;
	add(listSep);

	listItemsGroup = new FlxTypedGroup<FlxSprite>();
	add(listItemsGroup);

	listScrollIndicator = new FlxSprite(CAT_W + LIST_W - 4, py + 24).makeGraphic(3, 40, C_ACCENT);
	listScrollIndicator.alpha = 0.3;
	listScrollIndicator.visible = false;
	add(listScrollIndicator);

	listEmptyText = new FlxText(CAT_W + 20, py + 40, LIST_W - 40, "No files found.\n\nTry a different search or category.", 12);
	listEmptyText.color = C_DIM;
	listEmptyText.alignment = CENTER;
	listEmptyText.visible = false;
	add(listEmptyText);
}

// ======================== PREVIEW PANEL ========================
function createPreviewPanel() {
	var px = CAT_W + LIST_W;
	var pw = W - px;
	var py = HEADER_H + BREADCRUMB_H;
	var ph = H - HEADER_H - BREADCRUMB_H - FOOTER_H;

	previewPanelBg = new FlxSprite(px, py).makeGraphic(pw, ph, C_PANEL2);
	add(previewPanelBg);

	previewTitleBg = new FlxSprite(px, py).makeGraphic(pw, 52, C_PANEL3);
	add(previewTitleBg);

	var previewBorder = new FlxSprite(px, py).makeGraphic(1, ph, C_BORDER);
	previewBorder.alpha = 0.4;
	add(previewBorder);

	var previewTitleSep = new FlxSprite(px, py + 52).makeGraphic(pw, 1, C_BORDER);
	previewTitleSep.alpha = 0.3;
	add(previewTitleSep);

	previewTitleText = new FlxText(px + 12, py + 6, pw - 24, "Preview", 14);
	previewTitleText.color = C_ACCENT;
	previewTitleText.bold = true;
	add(previewTitleText);

	previewPathText = new FlxText(px + 12, py + 28, pw - 24, "Select a file to preview", 10);
	previewPathText.color = C_DIM;
	add(previewPathText);

	previewLineNums = new FlxText(px + 4, py + 58, 38, "", PREVIEW_FONT_SIZE);
	previewLineNums.color = C_LINE_NUM;
	add(previewLineNums);

	previewCodeText = new FlxText(px + 46, py + 58, pw - 54, "", PREVIEW_FONT_SIZE);
	previewCodeText.color = C_TEXT2;
	add(previewCodeText);

	previewScrollIndicator = new FlxSprite(px + pw - 4, py + 58).makeGraphic(3, 40, C_ACCENT);
	previewScrollIndicator.alpha = 0.3;
	previewScrollIndicator.visible = false;
	add(previewScrollIndicator);

	previewOverlayGroup = new FlxTypedGroup<FlxSprite>();
	add(previewOverlayGroup);
}

// ======================== INFO PANEL ========================
function createInfoPanel() {
	var ix = CAT_W;
	var iy = H - FOOTER_H - INFO_H;
	var iw = LIST_W;

	infoPanelBg = new FlxSprite(ix, iy).makeGraphic(iw, INFO_H, C_PANEL);
	add(infoPanelBg);

	var infoTopBorder = new FlxSprite(ix, iy).makeGraphic(iw, 1, C_BORDER);
	infoTopBorder.alpha = 0.4;
	add(infoTopBorder);

	infoPanelTitle = new FlxText(ix + 12, iy + 4, iw - 24, "FILE INFO", 10);
	infoPanelTitle.color = C_DIM;
	infoPanelTitle.bold = true;
	add(infoPanelTitle);

	var infoSep = new FlxSprite(ix + 8, iy + 18).makeGraphic(iw - 16, 1, C_BORDER);
	infoSep.alpha = 0.3;
	add(infoSep);

	infoContentText = new FlxText(ix + 12, iy + 22, iw - 24, "", 10);
	infoContentText.color = C_TEXT2;
	add(infoContentText);

	infoFuncsText = new FlxText(ix + 12, iy + 80, iw - 24, "", 9);
	infoFuncsText.color = C_DIM;
	add(infoFuncsText);
}

// ======================== FOOTER ========================
function createFooter() {
	var fy = H - FOOTER_H;
	footerBg = new FlxSprite(0, fy).makeGraphic(W, FOOTER_H, C_FOOTER);
	add(footerBg);

	var footerLine = new FlxSprite(0, fy).makeGraphic(W, 1, C_BORDER);
	footerLine.alpha = 0.4;
	add(footerLine);

	footerLeftText = new FlxText(12, fy + 6, 400, "", 10);
	footerLeftText.color = C_DIM;
	add(footerLeftText);

	footerCenterText = new FlxText(W / 2 - 200, fy + 6, 400, "", 10);
	footerCenterText.color = C_DIMMER;
	footerCenterText.alignment = CENTER;
	add(footerCenterText);

	footerRightText = new FlxText(W - 412, fy + 6, 400, "", 10);
	footerRightText.color = C_DIM;
	footerRightText.alignment = RIGHT;
	add(footerRightText);
}

// ======================== TAB BAR ========================
function createTabBar() {
	tabBarBg = new FlxSprite(CAT_W + LIST_W, H - FOOTER_H - TAB_H).makeGraphic(W - CAT_W - LIST_W, TAB_H, C_PANEL3);
	tabBarBg.alpha = 0.5;
	add(tabBarBg);

	tabItemsGroup = new FlxTypedGroup<FlxSprite>();
	add(tabItemsGroup);
}

// ======================== OVERLAYS ========================
function createOverlays() {
	// Shortcuts overlay
	shortcutsOverlay = new FlxSprite(W / 2 - 280, H / 2 - 220).makeGraphic(560, 440, C_PANEL);
	shortcutsOverlay.alpha = 0.97;
	shortcutsOverlay.visible = false;
	add(shortcutsOverlay);

	var shortcutsBorder = new FlxSprite(W / 2 - 280, H / 2 - 220).makeGraphic(560, 440, C_ACCENT);
	shortcutsBorder.alpha = 0.15;
	shortcutsBorder.visible = false;
	add(shortcutsBorder);

	shortcutsText = new FlxText(W / 2 - 260, H / 2 - 200, 520, "", 12);
	shortcutsText.color = C_TEXT;
	shortcutsText.visible = false;
	add(shortcutsText);

	var scTitle = "KEYBOARD SHORTCUTS\n\n";
	var scNav = "Navigation:\n  UP/DOWN        Navigate file list\n  TAB            Switch category\n  LEFT/RIGHT     Expand/collapse category\n  PAGEUP/DOWN    Scroll file list by page\n  HOME/END       Jump to first/last file\n  ENTER          Open file in editor\n  Ctrl+E         Open file in editor\n  BACKSPACE      Go back in history\n\n";
	var scSearch = "Search:\n  S              Activate search\n  Ctrl+F         Activate search\n  ENTER          Confirm search\n  ESC            Cancel search\n  Ctrl+R         Toggle regex search\n  Ctrl+Shift+C   Toggle case sensitivity\n\n";
	var scView = "View:\n  F1             Toggle shortcuts overlay\n  F2             Cycle sort mode (Name/Size/Lines)\n  F3             Toggle statistics overlay\n  F4             Toggle settings panel\n  Ctrl+W         Toggle favorites filter\n  Ctrl+H         Toggle hidden files\n  ESC            Exit to main menu\n  Mouse Wheel    Scroll active panel";
	shortcutsText.text = scTitle + scNav + scSearch + scView;

	// Stats overlay
	statsOverlay = new FlxSprite(W / 2 - 220, H / 2 - 160).makeGraphic(440, 320, C_PANEL);
	statsOverlay.alpha = 0.97;
	statsOverlay.visible = false;
	add(statsOverlay);

	statsText = new FlxText(W / 2 - 200, H / 2 - 140, 400, "", 12);
	statsText.color = C_TEXT;
	statsText.visible = false;
	add(statsText);

	// Settings overlay
	settingsOverlay = new FlxSprite(W / 2 - 200, H / 2 - 180).makeGraphic(400, 360, C_PANEL);
	settingsOverlay.alpha = 0.97;
	settingsOverlay.visible = false;
	add(settingsOverlay);

	settingsGroup = new FlxTypedGroup<FlxSprite>();
	settingsGroup.visible = false;
	add(settingsGroup);

	// Context menu
	contextMenuGroup = new FlxTypedGroup<FlxSprite>();
	contextMenuGroup.visible = false;
	add(contextMenuGroup);

	// Tooltip
	tooltipBg = new FlxSprite(0, 0).makeGraphic(200, 24, C_HEADER);
	tooltipBg.alpha = 0.95;
	tooltipBg.visible = false;
	add(tooltipBg);

	tooltipText = new FlxText(4, 4, 192, "", 10);
	tooltipText.color = C_TEXT;
	tooltipText.visible = false;
	add(tooltipText);

	// Notification
	notifBg = new FlxSprite(W / 2 - 200, 50).makeGraphic(400, 32, C_PANEL3);
	notifBg.alpha = 0.95;
	notifBg.visible = false;
	add(notifBg);

	notifText = new FlxText(W / 2 - 190, 56, 380, "", 12);
	notifText.color = C_TEXT;
	notifText.alignment = CENTER;
	notifText.visible = false;
	add(notifText);
}

// =============================================================================
//  FILE SCANNING
// =============================================================================
function scanAllFiles() {
	allFiles = [];
	categories = [];
	rootCats = [];

	scanDir("source/");
	scanDir("mods/");

	for (f in allFiles) categorize(f);
	rootCats.sort(function(a, b) return Reflect.compare(a.order, b.order));
	for (c in rootCats) {
		if (c.subs != null) c.subs.sort(function(a, b) return Reflect.compare(a.name, b.name));
	}
	filteredFiles = allFiles.copy();
	totalFiles = allFiles.length;
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
					if (!showHiddenFiles && entry.startsWith(".")) continue;
					if (!fileExists(full)) {
						var info = makeFileInfo(full);
						if (info != null) allFiles.push(info);
					}
				}
			} catch(e2:Dynamic) {}
		}
	} catch(e:Dynamic) {}
}

function fileExists(path:String):Bool {
	for (f in allFiles) if (f.path == path) return true;
	return false;
}

function makeFileInfo(path:String):Dynamic {
	try {
		var c:String = sys.io.File.getContent(path);
		if (c == null || c.length == 0) return null;

		var lns = c.split("\n");
		var pkg = ""; var cls = ""; var ext = "";

		var pkgReg = new EReg("^package\\s+([\\w.]+)\\s*;", "m");
		if (pkgReg.match(c)) pkg = pkgReg.matched(1);

		var clsReg = new EReg("(?:class|interface|abstract|enum)\\s+(\\w+)", "");
		if (clsReg.match(c)) cls = clsReg.matched(1);
		else cls = haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(path));

		var extReg = new EReg("extends\\s+([\\w.]+)", "");
		if (extReg.match(c)) ext = extReg.matched(1);

		var implReg = new EReg("implements\\s+([\\w., ]+)", "");
		var impls = "";
		if (implReg.match(c)) impls = implReg.matched(1);

		var funcs:Array<Dynamic> = [];
		var funcReg = new EReg("((?:public|private|static|inline|override|dynamic)\\s+)*function\\s+(\\w+)\\s*\\(([^)]*)\\)", "g");
		var pos = 0;
		while (funcReg.matchSub(c, pos)) {
			var mods = funcReg.matched(1) != null ? funcReg.matched(1) : "";
			var params = funcReg.matched(3) != null ? funcReg.matched(3) : "";
			funcs.push({
				name: funcReg.matched(2),
				params: params,
				pub: mods.indexOf("public") >= 0,
				stat: mods.indexOf("static") >= 0,
				over: mods.indexOf("override") >= 0,
				inl: mods.indexOf("inline") >= 0,
				line: c.substr(0, funcReg.matchedPos().pos).split("\n").length
			});
			pos = funcReg.matchedPos().pos + funcReg.matchedPos().len;
		}

		var vars:Array<Dynamic> = [];
		var varReg = new EReg("((?:public|private|static|final)\\s+)*var\\s+(\\w+)\\s*(?::\\s*([\\w<>, ]+))?\\s*(?:=\\s*([^;]+))?;", "g");
		pos = 0;
		while (varReg.matchSub(c, pos)) {
			var mods = varReg.matched(1) != null ? varReg.matched(1) : "";
			vars.push({
				name: varReg.matched(2),
				type: varReg.matched(3),
				defVal: varReg.matched(4),
				pub: mods.indexOf("public") >= 0,
				stat: mods.indexOf("static") >= 0,
				fin: mods.indexOf("final") >= 0,
				line: c.substr(0, varReg.matchedPos().pos).split("\n").length
			});
			pos = varReg.matchedPos().pos + varReg.matchedPos().len;
		}

		var importCount = 0;
		var impReg = new EReg("^import\\s+", "gm");
		pos = 0;
		while (impReg.matchSub(c, pos)) {
			importCount++;
			pos = impReg.matchedPos().pos + impReg.matchedPos().len;
		}

		var isScript = path.indexOf("data/scripts") >= 0 || path.indexOf("data/states") >= 0;
		var hasCreate = c.indexOf("function create") >= 0;
		var hasUpdate = c.indexOf("function update") >= 0;

		var cat = detectCat(path, c);

		return {
			path: path,
			fileName: haxe.io.Path.withoutDirectory(path),
			baseName: haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(path)),
			package: pkg,
			className: cls,
			extendsCls: ext,
			implementsList: impls,
			funcs: funcs,
			vars: vars,
			importCount: importCount,
			category: cat.main,
			subCategory: cat.sub,
			color: cat.color,
			content: c,
			lines: lns,
			lineCount: lns.length,
			size: c.length,
			isScript: isScript,
			hasCreate: hasCreate,
			hasUpdate: hasUpdate,
			isFavorite: favorites.exists(path)
		};
	} catch(e:Dynamic) { return null; }
}

function detectCat(path:String, c:String):Dynamic {
	var main = "Other"; var sub = ""; var col = CC_OTHER;

	if (c.indexOf("extends UIState") >= 0 && path.indexOf("editors/") >= 0)
		{ main = "Editors"; sub = "Editor States"; col = CC_EDITORS; }
	else if (c.indexOf("extends MusicBeatState") >= 0 || (c.indexOf("extends UIState") >= 0 && path.indexOf("editors/") < 0))
		{ main = "States"; sub = "Game States"; col = CC_STATES; }
	else if (c.indexOf("extends MusicBeatSubstate") >= 0 || c.indexOf("extends FlxSubState") >= 0 || c.indexOf("extends UISubstateWindow") >= 0)
		{ main = "States"; sub = "Substates"; col = CC_SUBSTATES; }
	else if (path.indexOf("editors/ui/") >= 0)
		{ main = "Editors"; sub = "UI Components"; col = CC_EDITORUI; }
	else if (path.indexOf("editors/") >= 0)
		{ main = "Editors"; sub = "Editor Support"; col = CC_EDITORS; }
	else if (path.indexOf("data/scripts") >= 0 || path.indexOf("data/states") >= 0)
		{ main = "Scripts"; sub = "HScript Files"; col = CC_SCRIPTS; }
	else if (path.indexOf("scripts/") >= 0)
		{ main = "Scripts"; sub = "Script Support"; col = CC_SCRIPTS; }
	else if (path.indexOf("game/scoring") >= 0)
		{ main = "Game"; sub = "Scoring"; col = CC_GAME; }
	else if (path.indexOf("game/cutscenes") >= 0)
		{ main = "Game"; sub = "Cutscenes"; col = CC_GAME; }
	else if (path.indexOf("game/") >= 0)
		{ main = "Game"; sub = "Gameplay"; col = CC_GAME; }
	else if (path.indexOf("backend/scripting") >= 0)
		{ main = "Backend"; sub = "Scripting"; col = CC_BACKEND; }
	else if (path.indexOf("backend/system") >= 0)
		{ main = "Backend"; sub = "System"; col = CC_BACKEND; }
	else if (path.indexOf("backend/chart") >= 0)
		{ main = "Backend"; sub = "Chart"; col = CC_BACKEND; }
	else if (path.indexOf("backend/assets") >= 0)
		{ main = "Backend"; sub = "Assets"; col = CC_BACKEND; }
	else if (path.indexOf("backend/shaders") >= 0)
		{ main = "Backend"; sub = "Shaders"; col = CC_BACKEND; }
	else if (path.indexOf("backend/utils") >= 0)
		{ main = "Backend"; sub = "Utilities"; col = CC_BACKEND; }
	else if (path.indexOf("backend/week") >= 0)
		{ main = "Backend"; sub = "Weeks"; col = CC_BACKEND; }
	else if (path.indexOf("backend/") >= 0)
		{ main = "Backend"; sub = "Core"; col = CC_BACKEND; }
	else if (path.indexOf("menus/ui") >= 0)
		{ main = "Menus"; sub = "Menu UI"; col = CC_MENUS; }
	else if (path.indexOf("menus/credits") >= 0)
		{ main = "Menus"; sub = "Credits"; col = CC_MENUS; }
	else if (path.indexOf("menus/") >= 0)
		{ main = "Menus"; sub = "Menu States"; col = CC_MENUS; }
	else if (path.indexOf("options/") >= 0)
		{ main = "Options"; sub = "Settings"; col = CC_OPTIONS; }
	else if (path.indexOf("savedata") >= 0)
		{ main = "Backend"; sub = "Save Data"; col = CC_BACKEND; }
	else if (path.indexOf("flixel/") >= 0 || path.indexOf("haxe/") >= 0 || path.indexOf("lime/") >= 0 || path.indexOf("openfl/") >= 0 || path.indexOf("hscript/") >= 0 || path.indexOf("flx3d/") >= 0 || path.indexOf("external/") >= 0)
		{ main = "Libraries"; sub = "Engine Extensions"; col = CC_LIBRARIES; }

	return { main: main, sub: sub, color: col };
}

function categorize(info:Dynamic) {
	var cn = info.category;
	if (!categories.exists(cn)) {
		var cat = {
			name: cn, subs: [], files: [], color: info.color,
			expanded: true, order: getCatOrder(cn), total: 0
		};
		categories.set(cn, cat);
		rootCats.push(cat);
	}
	var cat = categories.get(cn);
	cat.files.push(info);
	cat.total++;
	if (info.subCategory != null && info.subCategory.length > 0) {
		var found = false;
		for (s in cat.subs) {
			if (s.name == info.subCategory) { s.files.push(info); s.total++; found = true; break; }
		}
		if (!found) cat.subs.push({ name: info.subCategory, files: [info], total: 1, expanded: false });
	}
}

function getCatOrder(n:String):Int {
	if (n == "States") return 0;
	if (n == "Editors") return 1;
	if (n == "Game") return 2;
	if (n == "Backend") return 3;
	if (n == "Menus") return 4;
	if (n == "Options") return 5;
	if (n == "Scripts") return 6;
	if (n == "Libraries") return 10;
	return 8;
}

function calculateStatistics() {
	totalFiles = allFiles.length;
	totalLines = 0; totalSize = 0; totalFunctions = 0; totalVariables = 0;
	for (f in allFiles) {
		totalLines += f.lineCount;
		totalSize += f.size;
		totalFunctions += f.funcs.length;
		totalVariables += f.vars.length;
	}
}

// =============================================================================
//  SELECTION & REFRESH
// =============================================================================
function selectCategory(cat:Dynamic) {
	selectedCat = cat;
	if (showFavoritesOnly) {
		filteredFiles = [];
		for (f in cat.files) { if (f.isFavorite) filteredFiles.push(f); }
	} else {
		filteredFiles = cat.files.copy();
	}
	if (searchQuery.length > 0) applySearchFilter();
	sortFiles();
	fileIndex = filteredFiles.length > 0 ? 0 : -1;
	if (fileIndex >= 0) selectFile(filteredFiles[0]);
	refreshAll();
}

function selectFile(file:Dynamic) {
	selectedFile = file;
	if (file != null) {
		addToRecent(file.path);
		updateBreadcrumb();
	}
	refreshList();
	refreshPreview();
	refreshInfo();
	refreshStatus();
}

function addToRecent(path:String) {
	for (i in 0...recentFiles.length) {
		if (recentFiles[i] == path) { recentFiles.splice(i, 1); break; }
	}
	recentFiles.unshift(path);
	while (recentFiles.length > MAX_RECENT) recentFiles.pop();
}

function updateBreadcrumb() {
	if (selectedFile != null) {
		var parts = selectedFile.path.split("/");
		var crumb = "";
		for (i in 0...Math.min(parts.length, 5)) {
			if (i > 0) crumb += " > ";
			crumb += parts[parts.length - 1 - i];
		}
		breadcrumbText.text = crumb;
	} else if (selectedCat != null) {
		breadcrumbText.text = "Home > " + selectedCat.name;
	} else {
		breadcrumbText.text = "Home";
	}
}

function sortFiles() {
	var sortLabel = "";
	switch(sortMode) {
		case 0:
			filteredFiles.sort(function(a, b) return Reflect.compare(a.fileName.toLowerCase(), b.fileName.toLowerCase()));
			sortLabel = "Sort: A-Z";
		case 1:
			filteredFiles.sort(function(a, b) return b.size - a.size);
			sortLabel = "Sort: Size (desc)";
		case 2:
			filteredFiles.sort(function(a, b) return b.lineCount - a.lineCount);
			sortLabel = "Sort: Lines (desc)";
		case 3:
			filteredFiles.sort(function(a, b) return b.funcs.length - a.funcs.length);
			sortLabel = "Sort: Functions (desc)";
		case 4:
			filteredFiles.sort(function(a, b) return Reflect.compare(a.category, b.category));
			sortLabel = "Sort: Category";
	}
	listSortText.text = sortLabel;
}

function applySearchFilter() {
	if (searchQuery.length == 0) return;
	var q = caseSensitiveSearch ? searchQuery : searchQuery.toLowerCase();
	var results:Array<Dynamic> = [];
	for (f in filteredFiles) {
		var match = false;
		var fn = caseSensitiveSearch ? f.fileName : f.fileName.toLowerCase();
		var cn = caseSensitiveSearch ? f.className : f.className.toLowerCase();
		var pk = caseSensitiveSearch ? f.package : f.package.toLowerCase();

		if (fn.indexOf(q) >= 0 || cn.indexOf(q) >= 0 || pk.indexOf(q) >= 0) match = true;

		if (!match && regexSearch) {
			try {
				var flags = caseSensitiveSearch ? "" : "i";
				var reg = new EReg(searchQuery, flags);
				if (reg.match(f.fileName) || reg.match(f.className) || reg.match(f.package)) match = true;
			} catch(e:Dynamic) {}
		}

		if (!match) {
			var content = caseSensitiveSearch ? f.content : f.content.toLowerCase();
			if (content.indexOf(q) >= 0) match = true;
		}

		if (match) results.push(f);
	}
	filteredFiles = results;
}

function refreshAll() {
	refreshCats();
	refreshList();
	refreshPreview();
	refreshInfo();
	refreshStatus();
	refreshSearchBar();
}

// ======================== REFRESH CATEGORIES ========================
function refreshCats() {
	catItemsGroup.clear();
	var y:Float = HEADER_H + BREADCRUMB_H + 28;
	var visibleH = H - HEADER_H - BREADCRUMB_H - FOOTER_H - INFO_H - 28;
	var maxItems = Std.int(visibleH / CAT_LINE_H);
	var startIdx = Std.int(catScrollY / CAT_LINE_H);
	var itemIdx = 0;

	for (cat in rootCats) {
		if (itemIdx >= startIdx && itemIdx < startIdx + maxItems) {
			var isSel = cat == selectedCat;
			var arrow = cat.expanded ? "v " : "> ";

			var bg = new FlxSprite(4, y).makeGraphic(CAT_W - 8, CAT_LINE_H - 2, isSel ? C_SELECT : C_HOVER);
			bg.alpha = isSel ? 0.8 : 0.0;
			catItemsGroup.add(bg);

			var colorBar = new FlxSprite(4, y).makeGraphic(3, CAT_LINE_H - 2, cat.color);
			colorBar.alpha = isSel ? 1.0 : 0.5;
			catItemsGroup.add(colorBar);

			var lbl = new FlxText(14, y + 4, CAT_W - 70, arrow + cat.name, 12);
			lbl.color = isSel ? FlxColor.WHITE : cat.color;
			lbl.bold = isSel;
			catItemsGroup.add(lbl);

			var countLbl = new FlxText(CAT_W - 55, y + 5, 45, "" + cat.total, 10);
			countLbl.color = C_DIMMER;
			countLbl.alignment = RIGHT;
			catItemsGroup.add(countLbl);

			y += CAT_LINE_H;
		}
		itemIdx++;

		if (cat.expanded) {
			for (sub in cat.subs) {
				if (itemIdx >= startIdx && itemIdx < startIdx + maxItems) {
					var subBg = new FlxSprite(16, y).makeGraphic(CAT_W - 20, SUB_LINE_H - 2, C_HOVER);
					subBg.alpha = 0.0;
					catItemsGroup.add(subBg);

					var subColorBar = new FlxSprite(16, y).makeGraphic(2, SUB_LINE_H - 2, cat.color);
					subColorBar.alpha = 0.3;
					catItemsGroup.add(subColorBar);

					var subLbl = new FlxText(26, y + 3, CAT_W - 80, "  " + sub.name, 10);
					subLbl.color = cat.color;
					subLbl.alpha = 0.7;
					catItemsGroup.add(subLbl);

					var subCount = new FlxText(CAT_W - 50, y + 4, 40, "" + sub.total, 9);
					subCount.color = C_DIMMER;
					subCount.alignment = RIGHT;
					catItemsGroup.add(subCount);

					y += SUB_LINE_H;
				}
				itemIdx++;
			}
		}
	}

	catPanelCount.text = rootCats.length + " cats";

	if (itemIdx > maxItems) {
		catScrollIndicator.visible = true;
		var ratio = visibleH / (itemIdx * CAT_LINE_H);
		catScrollIndicator.scale.set(1, Math.max(20, visibleH * ratio));
		catScrollIndicator.updateHitbox();
	} else {
		catScrollIndicator.visible = false;
	}
}

// ======================== REFRESH FILE LIST ========================
function refreshList() {
	listItemsGroup.clear();
	var py = HEADER_H + BREADCRUMB_H + SEARCH_H + 24;
	var visibleH = H - HEADER_H - BREADCRUMB_H - SEARCH_H - FOOTER_H - INFO_H - 24;
	var maxItems = Std.int(visibleH / FILE_LINE_H);
	var startIdx = Std.int(listScrollY / FILE_LINE_H);

	listPanelCount.text = filteredFiles.length + " files";
	listEmptyText.visible = filteredFiles.length == 0;

	for (i in 0...Math.min(filteredFiles.length - startIdx, maxItems)) {
		var idx = i + startIdx;
		if (idx < 0 || idx >= filteredFiles.length) continue;
		var f = filteredFiles[idx];
		var isSel = f == selectedFile;
		var y = py + (i * FILE_LINE_H);

		var bg = new FlxSprite(CAT_W + 4, y).makeGraphic(LIST_W - 8, FILE_LINE_H - 2, isSel ? C_SELECT : C_HOVER);
		bg.alpha = isSel ? 0.8 : 0.0;
		listItemsGroup.add(bg);

		var colorDot = new FlxSprite(CAT_W + 8, y + 7).makeGraphic(8, 8, f.color);
		colorDot.alpha = 0.8;
		listItemsGroup.add(colorDot);

		var favIcon = "";
		if (f.isFavorite) favIcon = "* ";

		var nameL = new FlxText(CAT_W + 22, y + 3, LIST_W - 130, favIcon + f.fileName, 11);
		nameL.color = isSel ? FlxColor.WHITE : f.color;
		nameL.bold = isSel;
		listItemsGroup.add(nameL);

		var infoStr = "";
		if (showLineCount) infoStr += f.lineCount + "ln";
		if (showFileSize) infoStr += (infoStr.length > 0 ? " " : "") + formatSize(f.size);
		if (showFunctionCount && f.funcs.length > 0) infoStr += (infoStr.length > 0 ? " " : "") + f.funcs.length + "fn";

		var infoL = new FlxText(CAT_W + LIST_W - 105, y + 4, 95, infoStr, 9);
		infoL.color = isSel ? C_TEXT2 : C_DIM;
		infoL.alignment = RIGHT;
		listItemsGroup.add(infoL);
	}

	if (filteredFiles.length > maxItems) {
		listScrollIndicator.visible = true;
		var ratio = visibleH / (filteredFiles.length * FILE_LINE_H);
		listScrollIndicator.scale.set(1, Math.max(20, visibleH * ratio));
		listScrollIndicator.updateHitbox();
		var scrollRatio = listScrollY / ((filteredFiles.length - maxItems) * FILE_LINE_H);
		listScrollIndicator.y = py + scrollRatio * (visibleH - listScrollIndicator.height);
	} else {
		listScrollIndicator.visible = false;
	}
}

// ======================== REFRESH PREVIEW ========================
function refreshPreview() {
	previewOverlayGroup.clear();

	if (selectedFile == null) {
		previewTitleText.text = "Preview";
		previewTitleText.color = C_DIM;
		previewPathText.text = "Select a file to preview";
		previewLineNums.text = "";
		previewCodeText.text = "";
		return;
	}

	var f = selectedFile;
	previewTitleText.text = f.fileName;
	previewTitleText.color = f.color;
	previewPathText.text = f.path + "  |  " + f.lineCount + " lines  |  " + formatSize(f.size);

	var startLine = Std.int(previewScrollY / (PREVIEW_FONT_SIZE + 3));
	var px = CAT_W + LIST_W;
	var pw = W - px;
	var ph = H - HEADER_H - BREADCRUMB_H - FOOTER_H - 58;
	var maxLines = Std.int(ph / (PREVIEW_FONT_SIZE + 3));

	var lnBuf = new StringBuf();
	var codeBuf = new StringBuf();
	var endLine = Math.min(startLine + maxLines, f.lines.length);

	for (i in startLine...endLine) {
		lnBuf.add("" + (i + 1) + "\n");
		codeBuf.add(f.lines[i] + "\n");
	}

	previewLineNums.text = lnBuf.toString();
	previewCodeText.text = codeBuf.toString();

	if (f.lines.length > maxLines) {
		previewScrollIndicator.visible = true;
		var ratio = ph / (f.lines.length * (PREVIEW_FONT_SIZE + 3));
		previewScrollIndicator.scale.set(1, Math.max(20, ph * ratio));
		previewScrollIndicator.updateHitbox();
	} else {
		previewScrollIndicator.visible = false;
	}
}

// ======================== REFRESH INFO ========================
function refreshInfo() {
	if (selectedFile == null) {
		infoContentText.text = "";
		infoFuncsText.text = "";
		return;
	}

	var f = selectedFile;
	var info = "";
	info += "Package: " + (f.package.length > 0 ? f.package : "(none)") + "\n";
	info += "Class: " + f.className;
	if (f.extendsCls != null && f.extendsCls.length > 0) info += " extends " + f.extendsCls;
	if (f.implementsList != null && f.implementsList.length > 0) info += "\nImplements: " + f.implementsList;
	info += "\nCategory: " + f.category;
	if (f.subCategory != null && f.subCategory.length > 0) info += " / " + f.subCategory;
	info += "\nLines: " + f.lineCount + "  |  Size: " + formatSize(f.size) + "  |  Imports: " + f.importCount;
	info += "\nFunctions: " + f.funcs.length + "  |  Variables: " + f.vars.length;
	if (f.isScript) info += "\n[HScript] create:" + f.hasCreate + " update:" + f.hasUpdate;
	if (f.isFavorite) info += "\n* Favorited";
	infoContentText.text = info;

	var funcStr = "";
	if (f.funcs.length > 0) {
		funcStr = "Functions:";
		var show = Math.min(f.funcs.length, 6);
		for (i in 0...show) {
			var fn = f.funcs[i];
			var pfx = fn.pub ? "+" : "-";
			if (fn.stat) pfx += "S";
			if (fn.over) pfx += "O";
			if (fn.inl) pfx += "I";
			funcStr += "\n  " + pfx + " " + fn.name + "(" + StringTools.trim(fn.params).substr(0, 30) + ") L" + fn.line;
		}
		if (f.funcs.length > show) funcStr += "\n  ... +" + (f.funcs.length - show) + " more";
	}
	infoFuncsText.text = funcStr;
}

// ======================== REFRESH STATUS ========================
function refreshStatus() {
	var left = "Files: " + filteredFiles.length + "/" + allFiles.length;
	if (selectedCat != null) left += "  |  Category: " + selectedCat.name;
	if (showFavoritesOnly) left += "  |  [Favorites Only]";
	footerLeftText.text = left;

	var center = "";
	if (selectedFile != null) {
		center = selectedFile.fileName + "  |  " + selectedFile.lineCount + " lines  |  " + formatSize(selectedFile.size);
	}
	footerCenterText.text = center;

	var right = "F1:Help  F2:Sort  F3:Stats  TAB:Cat  Ctrl+E:Edit  ESC:Exit";
	footerRightText.text = right;
}

// ======================== REFRESH SEARCH BAR ========================
function refreshSearchBar() {
	if (searchMode) {
		searchBorder.color = C_ACCENT;
		searchBorder.alpha = 0.8;
		searchIconText.color = C_ACCENT;
	} else {
		searchBorder.color = C_PANEL2;
		searchBorder.alpha = 0.6;
		searchIconText.color = C_DIM;
	}

	var optStr = "";
	if (caseSensitiveSearch) optStr += "Aa ";
	if (regexSearch) optStr += ".* ";
	searchOptionsText.text = optStr;
}

function formatSize(bytes:Int):String {
	if (bytes < 1024) return bytes + " B";
	if (bytes < 1048576) return Math.round(bytes / 1024) + " KB";
	return (Math.round(bytes / 1048576 * 100) / 100) + " MB";
}

// ======================== NOTIFICATIONS ========================
function showNotification(msg:String, duration:Float) {
	notifText.text = msg;
	notifBg.visible = true;
	notifText.visible = true;
	notifTimer = duration;
	notifBg.alpha = 0.95;
	notifText.alpha = 1.0;
}

// ======================== SEARCH ========================
function doSearch() {
	if (searchQuery.length == 0) {
		if (selectedCat != null) {
			if (showFavoritesOnly) {
				filteredFiles = [];
				for (f in selectedCat.files) { if (f.isFavorite) filteredFiles.push(f); }
			} else {
				filteredFiles = selectedCat.files.copy();
			}
		} else {
			filteredFiles = allFiles.copy();
		}
	} else {
		if (selectedCat != null) {
			if (showFavoritesOnly) {
				filteredFiles = [];
				for (f in selectedCat.files) { if (f.isFavorite) filteredFiles.push(f); }
			} else {
				filteredFiles = selectedCat.files.copy();
			}
		} else {
			filteredFiles = allFiles.copy();
		}
		applySearchFilter();
	}
	sortFiles();
	listScrollY = 0;
	fileIndex = filteredFiles.length > 0 ? 0 : -1;
	if (fileIndex >= 0) selectFile(filteredFiles[0]);
	refreshList();
	refreshStatus();
}

// =============================================================================
//  UPDATE
// =============================================================================
var lastElapsed:Float = 0;

function update(elapsed:Float) {
	lastElapsed = elapsed;

	// Notification fade
	if (notifTimer > 0) {
		notifTimer -= elapsed;
		if (notifTimer <= 0) {
			notifBg.visible = false;
			notifText.visible = false;
		} else if (notifTimer < 0.5) {
			notifBg.alpha = notifTimer * 2;
			notifText.alpha = notifTimer * 2;
		}
	}

	// Close overlays with ESC
	if (FlxG.keys.justPressed.ESCAPE) {
		if (shortcutsVisible) { shortcutsVisible = false; shortcutsOverlay.visible = false; shortcutsText.visible = false; return; }
		if (statsVisible) { statsVisible = false; statsOverlay.visible = false; statsText.visible = false; return; }
		if (settingsVisible) { settingsVisible = false; settingsOverlay.visible = false; settingsGroup.visible = false; return; }
		if (contextMenuVisible) { contextMenuVisible = false; contextMenuGroup.visible = false; return; }
		if (searchMode) {
			searchMode = false;
			searchQuery = "";
			searchText.text = "Press S to search...";
			searchText.color = C_DIMMER;
			refreshSearchBar();
			doSearch();
			return;
		}
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

	// F2: Sort
	if (FlxG.keys.justPressed.F2) {
		sortMode = (sortMode + 1) % 5;
		sortFiles();
		refreshList();
		showNotification("Sort: " + ["A-Z", "Size", "Lines", "Functions", "Category"][sortMode], 1.5);
		return;
	}

	// F3: Stats
	if (FlxG.keys.justPressed.F3) {
		statsVisible = !statsVisible;
		statsOverlay.visible = statsVisible;
		statsText.visible = statsVisible;
		if (statsVisible) {
			var s = "ENGINE STATISTICS\n\n";
			s += "Total Files:     " + totalFiles + "\n";
			s += "Total Lines:     " + totalLines + "\n";
			s += "Total Size:      " + formatSize(totalSize) + "\n";
			s += "Total Functions: " + totalFunctions + "\n";
			s += "Total Variables: " + totalVariables + "\n\n";
			s += "BY CATEGORY:\n";
			for (cat in rootCats) {
				var catLines = 0;
				for (f in cat.files) catLines += f.lineCount;
				s += "  " + cat.name + ": " + cat.total + " files, " + catLines + " lines\n";
			}
			s += "\nRECENT FILES:\n";
			for (i in 0...Math.min(recentFiles.length, 10)) {
				s += "  " + (i + 1) + ". " + haxe.io.Path.withoutDirectory(recentFiles[i]) + "\n";
			}
			statsText.text = s;
		}
		return;
	}

	// F4: Settings
	if (FlxG.keys.justPressed.F4) {
		settingsVisible = !settingsVisible;
		settingsOverlay.visible = settingsVisible;
		settingsGroup.visible = settingsVisible;
		if (settingsVisible) refreshSettings();
		return;
	}

	// Ctrl+E: Open in editor
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.E && selectedFile != null) {
		FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: selectedFile.path}));
		return;
	}

	// Ctrl+F: Search
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.F) {
		searchMode = true;
		searchQuery = "";
		searchText.text = "|";
		searchText.color = C_TEXT;
		refreshSearchBar();
		return;
	}

	// Ctrl+R: Toggle regex
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.R) {
		regexSearch = !regexSearch;
		refreshSearchBar();
		if (searchQuery.length > 0) doSearch();
		showNotification("Regex search: " + (regexSearch ? "ON" : "OFF"), 1.5);
		return;
	}

	// Ctrl+W: Toggle favorites
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.W) {
		showFavoritesOnly = !showFavoritesOnly;
		if (selectedCat != null) selectCategory(selectedCat);
		showNotification("Favorites filter: " + (showFavoritesOnly ? "ON" : "OFF"), 1.5);
		return;
	}

	// Ctrl+D: Toggle favorite
	if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.D && selectedFile != null) {
		if (favorites.exists(selectedFile.path)) {
			favorites.remove(selectedFile.path);
			selectedFile.isFavorite = false;
			showNotification("Removed from favorites", 1.5);
		} else {
			favorites.set(selectedFile.path, true);
			selectedFile.isFavorite = true;
			showNotification("Added to favorites", 1.5);
		}
		refreshInfo();
		refreshList();
		return;
	}

	// S: Activate search
	if (FlxG.keys.justPressed.S && !searchMode) {
		searchMode = true;
		searchQuery = "";
		searchText.text = "|";
		searchText.color = C_TEXT;
		refreshSearchBar();
		return;
	}

	// TAB: Switch category
	if (FlxG.keys.justPressed.TAB && !searchMode) {
		catIndex = (catIndex + 1) % rootCats.length;
		selectCategory(rootCats[catIndex]);
		return;
	}

	// LEFT: Expand/collapse
	if (FlxG.keys.justPressed.LEFT && !searchMode) {
		if (selectedCat != null) {
			selectedCat.expanded = !selectedCat.expanded;
			refreshCats();
		}
		return;
	}

	// RIGHT: Expand
	if (FlxG.keys.justPressed.RIGHT && !searchMode) {
		if (selectedCat != null && !selectedCat.expanded) {
			selectedCat.expanded = true;
			refreshCats();
		}
		return;
	}

	// ENTER: Open in editor
	if (FlxG.keys.justPressed.ENTER && !searchMode && selectedFile != null) {
		FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: selectedFile.path}));
		return;
	}

	// Search mode input
	if (searchMode) {
		if (FlxG.keys.justPressed.BACKSPACE) {
			searchQuery = searchQuery.substr(0, Math.max(0, searchQuery.length - 1));
			searchText.text = searchQuery + "|";
			doSearch();
			return;
		}
		if (FlxG.keys.justPressed.ENTER) {
			searchMode = false;
			searchText.text = searchQuery.length > 0 ? searchQuery : "Press S to search...";
			searchText.color = searchQuery.length > 0 ? C_TEXT : C_DIMMER;
			refreshSearchBar();
			if (searchQuery.length > 0) {
				searchHistory.unshift(searchQuery);
				while (searchHistory.length > 20) searchHistory.pop();
			}
			return;
		}
		for (code in 32...127) {
			if (FlxG.keys.justPressed(cast code)) {
				searchQuery += String.fromCharCode(code);
				searchText.text = searchQuery + "|";
				doSearch();
				break;
			}
		}
		return;
	}

	// File list navigation
	if (FlxG.keys.justPressed.DOWN) {
		if (filteredFiles.length > 0) {
			fileIndex = Math.min(filteredFiles.length - 1, fileIndex + 1);
			selectFile(filteredFiles[fileIndex]);
			ensureFileVisible();
		}
	}
	if (FlxG.keys.justPressed.UP) {
		if (filteredFiles.length > 0) {
			fileIndex = Math.max(0, fileIndex - 1);
			selectFile(filteredFiles[fileIndex]);
			ensureFileVisible();
		}
	}
	if (FlxG.keys.justPressed.PAGEDOWN) {
		if (filteredFiles.length > 0) {
			var page = Std.int((H - HEADER_H - BREADCRUMB_H - SEARCH_H - FOOTER_H - INFO_H - 24) / FILE_LINE_H);
			fileIndex = Math.min(filteredFiles.length - 1, fileIndex + page);
			selectFile(filteredFiles[fileIndex]);
			ensureFileVisible();
		}
	}
	if (FlxG.keys.justPressed.PAGEUP) {
		if (filteredFiles.length > 0) {
			var page = Std.int((H - HEADER_H - BREADCRUMB_H - SEARCH_H - FOOTER_H - INFO_H - 24) / FILE_LINE_H);
			fileIndex = Math.max(0, fileIndex - page);
			selectFile(filteredFiles[fileIndex]);
			ensureFileVisible();
		}
	}
	if (FlxG.keys.justPressed.HOME) {
		if (filteredFiles.length > 0) {
			fileIndex = 0;
			listScrollY = 0;
			selectFile(filteredFiles[0]);
		}
	}
	if (FlxG.keys.justPressed.END) {
		if (filteredFiles.length > 0) {
			fileIndex = filteredFiles.length - 1;
			selectFile(filteredFiles[fileIndex]);
			ensureFileVisible();
		}
	}

	// Preview scroll
	if (FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel != 0) {
		if (selectedFile != null) {
			previewScrollY -= FlxG.mouse.wheel * 30;
			if (previewScrollY < 0) previewScrollY = 0;
			var maxScroll = (selectedFile.lineCount * (PREVIEW_FONT_SIZE + 3)) - (H - HEADER_H - BREADCRUMB_H - FOOTER_H - 58);
			if (maxScroll < 0) maxScroll = 0;
			if (previewScrollY > maxScroll) previewScrollY = maxScroll;
			refreshPreview();
		}
	}

	// Mouse wheel scroll file list
	if (FlxG.mouse.wheel != 0 && !FlxG.keys.pressed.SHIFT) {
		listScrollY -= FlxG.mouse.wheel * FILE_LINE_H * 3;
		if (listScrollY < 0) listScrollY = 0;
		var visibleH = H - HEADER_H - BREADCRUMB_H - SEARCH_H - FOOTER_H - INFO_H - 24;
		var maxScroll = (filteredFiles.length * FILE_LINE_H) - visibleH;
		if (maxScroll < 0) maxScroll = 0;
		if (listScrollY > maxScroll) listScrollY = maxScroll;
		refreshList();
	}
}

function ensureFileVisible() {
	var visibleH = H - HEADER_H - BREADCRUMB_H - SEARCH_H - FOOTER_H - INFO_H - 24;
	var maxItems = Std.int(visibleH / FILE_LINE_H);
	var fileY = fileIndex * FILE_LINE_H;

	if (fileY < listScrollY) {
		listScrollY = fileY;
	} else if (fileY > listScrollY + (maxItems - 1) * FILE_LINE_H) {
		listScrollY = fileY - (maxItems - 1) * FILE_LINE_H;
	}
	refreshList();
}

function refreshSettings() {
	settingsGroup.clear();
	var sx = W / 2 - 180;
	var sy = H / 2 - 160;

	var title = new FlxText(sx + 10, sy + 8, 360, "SETTINGS", 14);
	title.color = C_ACCENT;
	title.bold = true;
	settingsGroup.add(title);

	var settings = [
		{ name: "Show Line Numbers", value: showLineNumbers },
		{ name: "Show Hidden Files", value: showHiddenFiles },
		{ name: "Auto Preview", value: autoPreview },
		{ name: "Show File Size", value: showFileSize },
		{ name: "Show Line Count", value: showLineCount },
		{ name: "Show Function Count", value: showFunctionCount },
		{ name: "Case Sensitive Search", value: caseSensitiveSearch },
		{ name: "Regex Search", value: regexSearch }
	];

	for (i in 0...settings.length) {
		var s = settings[i];
		var y = sy + 36 + (i * 28);

		var bg = new FlxSprite(sx + 10, y).makeGraphic(360, 24, C_HOVER);
		bg.alpha = 0.3;
		settingsGroup.add(bg);

		var lbl = new FlxText(sx + 16, y + 4, 250, s.name, 12);
		lbl.color = C_TEXT;
		settingsGroup.add(lbl);

		var valText = new FlxText(sx + 280, y + 4, 80, s.value ? "[ON]" : "[OFF]", 12);
		valText.color = s.value ? C_SUCCESS : C_DIM;
		valText.alignment = RIGHT;
		settingsGroup.add(valText);
	}

	var hint = new FlxText(sx + 10, sy + 280, 360, "Press 1-8 to toggle settings. F4 or ESC to close.", 10);
	hint.color = C_DIM;
	settingsGroup.add(hint);
}
