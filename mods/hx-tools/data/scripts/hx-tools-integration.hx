// HX Tools - Global integration script
// Place in: mods/hx-tools/data/scripts/hx-tools-integration.hx
//
// This adds F3 shortcut to open HX Browser from anywhere.
// It runs as a global script when the mod is enabled.
//
// Open from any script:
//   FlxG.switchState(new funkin.backend.scripting.ModState("HXBrowser"));
//   FlxG.switchState(new funkin.backend.scripting.ModState("HXEditor", {path: "source/funkin/game/PlayState.hx"}));

function postUpdate(elapsed) {
	// F3 to open HX Browser from anywhere
	if (FlxG.keys.justPressed.F3) {
		try {
			FlxG.switchState(new funkin.backend.scripting.ModState("HXBrowser"));
		} catch(e:Dynamic) {
			trace("HX Tools: Could not open browser - " + e);
		}
	}
}
