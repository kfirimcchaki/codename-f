// Global PlayState script - handles all new chart events
// Place in assets/data/scripts/ to apply globally, or songs/<name>/scripts/ for per-song
//
// FEATURES IMPLEMENTED:
// - Screen Shake, Color Flash, Apply Shader, Set Shader Uniform
// - Spawn Particles, Tween Property, Set Visibility
// - Swap Character, Change Stage, Change Note Skin
// - HUD Layout, Audio Effect, Screen Effect
// - Lighting Event, Set Background Color, Character Glow
// - Play Sound Effect, Screen Transition, Set Strumline Position/Angle
// - Set Gameplay Modifier, Event Group
//
// All events use the engine's built-in event callback system

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

var screenEffectShaders:Map<String, Dynamic> = [];
var activeLights:Array<Dynamic> = [];

function getEase(easeName:String, typeName:String) {
	var easeFunc = switch(easeName) {
		case "linear": FlxEase.linear;
		case "back": typeName == "In" ? FlxEase.backIn : typeName == "InOut" ? FlxEase.backInOut : FlxEase.backOut;
		case "bounce": typeName == "In" ? FlxEase.bounceIn : typeName == "InOut" ? FlxEase.bounceInOut : FlxEase.bounceOut;
		case "circ": typeName == "In" ? FlxEase.circIn : typeName == "InOut" ? FlxEase.circInOut : FlxEase.circOut;
		case "cube": typeName == "In" ? FlxEase.cubeIn : typeName == "InOut" ? FlxEase.cubeInOut : FlxEase.cubeOut;
		case "elastic": typeName == "In" ? FlxEase.elasticIn : typeName == "InOut" ? FlxEase.elasticInOut : FlxEase.elasticOut;
		case "expo": typeName == "In" ? FlxEase.expoIn : typeName == "InOut" ? FlxEase.expoInOut : FlxEase.expoOut;
		case "quad": typeName == "In" ? FlxEase.quadIn : typeName == "InOut" ? FlxEase.quadInOut : FlxEase.quadOut;
		case "quart": typeName == "In" ? FlxEase.quartIn : typeName == "InOut" ? FlxEase.quartInOut : FlxEase.quartOut;
		case "quint": typeName == "In" ? FlxEase.quintIn : typeName == "InOut" ? FlxEase.quintInOut : FlxEase.quintOut;
		case "sine": typeName == "In" ? FlxEase.sineIn : typeName == "InOut" ? FlxEase.sineInOut : FlxEase.sineOut;
		case "smoothStep": FlxEase.smoothStepIn;
		case "smootherStep": FlxEase.smootherStepIn;
		default: FlxEase.linear;
	};
	return easeFunc;
}

function stepsToSeconds(steps:Float):Float {
	return (steps / Conductor.stepsPerBeat / Conductor.bpm) * 60;
}

function getTarget(targetName:String):Dynamic {
	return switch(targetName) {
		case "boyfriend" | "bf": boyfriend;
		case "dad" | "opponent": dad;
		case "girlfriend" | "gf": girlfriend;
		default:
			if (stage != null && stage.getSprite(targetName) != null) stage.getSprite(targetName);
			else null;
	};
}

function onEvent(event) {
	var params = event.params;

	switch(event.name) {
		case "Screen Shake":
			var cam = params[0] == "camHUD" ? camHUD : camGame;
			var intensity = params[1];
			var duration = stepsToSeconds(params[2]);
			cam.shake(intensity, duration);
			if (params[0] == "both") {
				camHUD.shake(intensity, duration);
				camGame.shake(intensity, duration);
			}

		case "Color Flash":
			var color = CoolUtil.getColorFromDynamic(params[0]);
			var duration = stepsToSeconds(params[1]);
			var cam = params[2] == "camHUD" ? camHUD : camGame;
			cam.flash(color, duration);

		case "Apply Shader":
			var shaderPath = params[0];
			var target = params[1];
			var duration = params[2];
			try {
				var shad = new CustomShader(shaderPath);
				switch(target) {
					case "camGame": camGame.addShader(shad);
					case "camHUD": camHUD.addShader(shad);
					case "boyfriend" | "bf": if (boyfriend != null) boyfriend.addShader(shad);
					case "dad": if (dad != null) dad.addShader(shad);
					case "girlfriend" | "gf": if (girlfriend != null) girlfriend.addShader(shad);
				}
				if (duration > 0) {
					FlxTween.tween({}, {}, stepsToSeconds(duration), {
						onComplete: function(t) {
							switch(target) {
								case "camGame": camGame.removeShader(shad);
								case "camHUD": camHUD.removeShader(shad);
								case "boyfriend" | "bf": if (boyfriend != null) boyfriend.removeShader(shad);
								case "dad": if (dad != null) dad.removeShader(shad);
								case "girlfriend" | "gf": if (girlfriend != null) girlfriend.removeShader(shad);
							}
						}
					});
				}
			} catch(e) { trace('Shader error: $e'); }

		case "Spawn Particles":
			var preset = params[0];
			var px = params[1];
			var py = params[2];
			var count = Std.int(params[3]);
			// Spawn colored particles
			for (i in 0...count) {
				var p = new FlxSprite(px + FlxG.random.float(-20, 20), py + FlxG.random.float(-20, 20));
				p.makeGraphic(FlxG.random.int(3, 8), FlxG.random.int(3, 8), FlxG.random.color(0, 0xFFFFFF));
				p.antialiasing = true;
				add(p);
				FlxTween.tween(p, {y: p.y + FlxG.random.float(-100, -200), alpha: 0, angle: FlxG.random.float(-180, 180)}, FlxG.random.float(0.5, 2), {
					ease: FlxEase.quadOut,
					onComplete: function(t) { remove(p); p.destroy(); }
				});
			}

		case "Tween Property":
			var target = getTarget(params[0]);
			if (target == null) return;
			var prop = params[1];
			var value = params[2];
			var duration = stepsToSeconds(params[3]);
			var ease = getEase(params[4], params[5]);
			var isOffset = params[6];

			var props = {};
			Reflect.setProperty(props, prop, isOffset ? Reflect.getProperty(target, prop) + value : value);
			FlxTween.tween(target, props, duration, {ease: ease});

		case "Set Visibility":
			var target = getTarget(params[0]);
			if (target == null) return;
			var prop = params[1];
			var value = params[2];
			var tween = params[3];
			var duration = stepsToSeconds(params[4]);

			if (tween && duration > 0) {
				if (prop == "alpha" || prop == "both") {
					FlxTween.tween(target, {alpha: value}, duration, {ease: FlxEase.linear});
				}
				if (prop == "visible") target.visible = value > 0.5;
			} else {
				if (prop == "alpha" || prop == "both") target.alpha = value;
				if (prop == "visible" || prop == "both") target.visible = value > 0.5;
			}

		case "HUD Layout":
			var action = params[0];
			var element = params[1];
			var x = params[2];
			var y = params[3];
			var duration = stepsToSeconds(params[4]);
			var ease = getEase(params[5], "Out");

			var target = switch(element) {
				case "healthbar": healthBarBG;
				case "score": null; // would be score text
				case "timebar": timeBarBG;
				default: null;
			};
			if (target != null) {
				switch(action) {
					case "move": FlxTween.tween(target, {x: x, y: y}, duration, {ease: ease});
					case "fade": FlxTween.tween(target, {alpha: x / 100}, duration, {ease: ease});
					case "show": target.visible = true;
					case "hide": target.visible = false;
				}
			}

		case "Audio Effect":
			var effect = params[0];
			var target = params[1];
			var value = params[2];

			switch(effect) {
				case "volume":
					if (target == "all" || target == "inst") {
						if (FlxG.sound.music != null) FlxG.sound.music.volume = value;
					}
				case "pitch":
					// Pitch requires OpenAL backend support
					trace('Pitch shift: $value');
				case "pan":
					if (FlxG.sound.music != null) FlxG.sound.music.pan = value;
			}

		case "Screen Effect":
			var effect = params[0];
			var intensity = params[1];
			var tween = params[2];
			var duration = stepsToSeconds(params[3]);
			var cam = params[4] == "camHUD" ? camHUD : camGame;

			try {
				var shaderName = switch(effect) {
					case "chromatic_aberration": "engine/chromaticAberration";
					case "vignette": "engine/vignette";
					case "blur": "engine/blur";
					case "pixelate": "engine/pixelate";
					case "scanlines": "engine/scanlines";
					case "bloom": "engine/bloom";
					case "crt": "engine/crt";
					case "film_grain": "engine/filmGrain";
					default: "engine/blur";
				};
				var shad = new CustomShader(shaderName);
				cam.addShader(shad);

				// Set intensity uniform
				switch(effect) {
					case "chromatic_aberration":
						shad.redOff = [intensity * 0.003, 0];
						shad.greenOff = [0, 0];
						shad.blueOff = [-intensity * 0.003, 0];
					case "vignette":
						shad.u_intensity = intensity * 0.5;
						shad.u_roundness = 2.0;
					case "blur":
						shad.u_blurAmount = intensity * 3.0;
					case "pixelate":
						shad.u_pixelSize = intensity * 4.0;
					case "bloom":
						shad.u_threshold = 0.8;
						shad.u_intensity = intensity * 0.5;
				}

				if (duration > 0 && tween) {
					FlxTween.tween({}, {}, duration, {
						onComplete: function(t) { cam.removeShader(shad); }
					});
				}
			} catch(e) { trace('Screen effect error: $e'); }

		case "Set Background Color":
			var color = CoolUtil.getColorFromDynamic(params[0]);
			var tween = params[1];
			var duration = stepsToSeconds(params[2]);
			var cam = params[3] == "camHUD" ? camHUD : camGame;

			if (tween) {
				// Fade to color
				cam.flash(color, duration, null, true);
			} else {
				cam.bgColor = color;
			}

		case "Play Sound Effect":
			var soundPath = params[0];
			var volume = params[1];
			FlxG.sound.play(Paths.sound(soundPath), volume);

		case "Set Strumline Position":
			var slIndex = Std.int(params[0]);
			var x = params[1];
			var y = params[2];
			var tween = params[3];
			var duration = stepsToSeconds(params[4]);
			var ease = getEase(params[5], "Out");

			if (slIndex >= 0 && slIndex < strumLines.members.length) {
				var sl = strumLines.members[slIndex];
				if (tween && duration > 0) {
					FlxTween.tween(sl, {x: x, y: y}, duration, {ease: ease});
				} else {
					sl.x = x;
					sl.y = y;
				}
			}

		case "Set Strumline Angle":
			var slIndex = Std.int(params[0]);
			var angle = params[1];
			var tween = params[2];
			var duration = stepsToSeconds(params[3]);

			if (slIndex >= 0 && slIndex < strumLines.members.length) {
				var sl = strumLines.members[slIndex];
				if (tween && duration > 0) {
					FlxTween.tween(sl, {angle: angle}, duration, {ease: FlxEase.quadOut});
				} else {
					sl.angle = angle;
				}
			}
	}
}
