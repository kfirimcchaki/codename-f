// HX Tools - Global integration script
// Place in: mods/hx-tools/data/scripts/
//
// This script adds HX Browser and HX Editor access to the engine.
// It hooks into the main menu and PlayState to provide quick access.
//
// HOW TO USE:
//   1. Open HX Browser: Press F3 from the main menu (with dev mode on)
//   2. Open HX Editor: Press Ctrl+E on any file in the Browser
//   3. Or redirect states in your mod config:
//      "MainMenuState" -> redirect as needed
//
// You can also open these states from any script:
//   FlxG.switchState(new funkin.backend.scripting.ModState("HXBrowser"));
//   FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: "source/funkin/game/PlayState.hx"}));

// Hook into MainMenuState to add F3 shortcut for HX Browser
function postCreate() {
	// Add a small indicator text if we're on the main menu
	try {
		if (FlxG.state != null && Std.isOfType(FlxG.state, funkin.menus.MainMenuState)) {
			var indicator = new FlxText(FlxG.width - 200, FlxG.height - 24, 190, "F3: HX Browser", 11);
			indicator.color = 0xFF666688;
			indicator.scrollFactor.set();
			indicator.cameras = [FlxG.state.camList[0]];
			FlxG.state.add(indicator);
		}
	} catch(e:Dynamic) {}
}

function postUpdate(elapsed) {
	// F3 to open HX Browser from anywhere (when not in an editor)
	if (FlxG.keys.justPressed.F3) {
		try {
			// Don't open if already in browser/editor
			if (FlxG.state != null) {
				var stateName = Type.getClassName(Type.getClass(FlxG.state));
				if (stateName != null && (stateName.indexOf("ModState") >= 0)) return;
			}
			FlxG.switchState(new funkin.backend.scripting.ModState("HXBrowser"));
		} catch(e:Dynamic) {
			trace("HX Tools: Could not open browser - " + e);
		}
	}
}
