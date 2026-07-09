// Example mod global script
// This script runs on every song when the mod is loaded
// Place in mods/<modname>/data/scripts/

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

// Mod-wide variables
public var modVersion = "1.0.0";
public var enableCustomEffects = true;

function postCreate() {
	trace('[ExampleMod] Loaded v$modVersion');

	if (enableCustomEffects) {
		// Add a subtle vignette to the game camera
		try {
			var vignette = new CustomShader('engine/vignette');
			vignette.u_intensity = 0.3;
			vignette.u_roundness = 2.5;
			camGame.addShader(vignette);
		} catch(e) {}
	}
}

function onBeatHit() {
	if (!enableCustomEffects) return;

	// Subtle camera zoom on every 4th beat
	if (curBeat % 4 == 0) {
		camGame.zoom += 0.015;
		camHUD.zoom += 0.01;
	}
}

function onNoteHit(event) {
	// Add a small flash on note hits
	if (event.note.strumLine == playerStrums) {
		// Optional: custom hit effects per mod
	}
}
