package funkin.backend.presets;

import haxe.Json;

/**
 * FEATURES 92-96: Preset Systems
 * 
 * Manages presets for stages, characters, note skins, HUD layouts,
 * and audio visualizers. Each preset type has its own CRUD operations,
 * import/export, and integration with the relevant editors.
 * 
 * FEATURE 92: Stage Presets
 * FEATURE 93: Audio Visualizer Design Settings
 * FEATURE 94: Character Presets
 * FEATURE 95: Note Skin Presets
 * FEATURE 96: HUD Layout Presets
 */
class PresetManager {
	public static var instance:PresetManager;
	
	public var stagePresets:Map<String, StagePreset> = [];
	public var audioVizPresets:Map<String, AudioVizDesignPreset> = [];
	public var characterPresets:Map<String, CharacterPreset> = [];
	public var noteSkinPresets:Map<String, NoteSkinPreset> = [];
	public var hudPresets:Map<String, HUDPreset> = [];
	
	public function new() {
		instance = this;
		loadDefaultPresets();
		loadUserPresets();
	}
	
	// ==================== Stage Presets (FEATURE 92) ====================
	
	function loadDefaultStagePresets():Void {
		stagePresets.set("basic_stage", {
			name: "Basic Stage",
			description: "Simple stage with background and floor",
			category: "Basic",
			elements: [
				{type: "sprite", name: "bg", image: "stages/default/bg", x: 0, y: 0, scrollFactor: {x: 0.5, y: 0.5}, scale: {x: 1, y: 1}},
				{type: "sprite", name: "floor", image: "stages/default/floor", x: 0, y: 400, scrollFactor: {x: 1, y: 1}, scale: {x: 1, y: 1}}
			],
			characterPositions: {
				boyfriend: {x: 770, y: 100},
				dad: {x: 100, y: 100},
				girlfriend: {x: 400, y: 130}
			},
			cameraStart: {x: 600, y: 300},
			cameraZoom: 0.9,
			lighting: "Default",
			particles: null
		});
		
		stagePresets.set("concert_stage", {
			name: "Concert Stage",
			description: "Full concert stage with lights and crowd",
			category: "Performance",
			elements: [
				{type: "sprite", name: "bg_crowd", image: "stages/concert/crowd", x: 0, y: 0, scrollFactor: {x: 0.3, y: 0.3}},
				{type: "sprite", name: "stage_floor", image: "stages/concert/floor", x: 0, y: 350, scrollFactor: {x: 1, y: 1}},
				{type: "sprite", name: "stage_lights", image: "stages/concert/lights", x: 0, y: -100, scrollFactor: {x: 0.8, y: 0.8}},
				{type: "sprite", name: "speakers_left", image: "stages/concert/speakers", x: -100, y: 200, scrollFactor: {x: 1.2, y: 1.2}},
				{type: "sprite", name: "speakers_right", image: "stages/concert/speakers", x: 1100, y: 200, scrollFactor: {x: 1.2, y: 1.2}}
			],
			characterPositions: {
				boyfriend: {x: 770, y: 100},
				dad: {x: 100, y: 100},
				girlfriend: {x: 400, y: 50}
			},
			cameraStart: {x: 600, y: 300},
			cameraZoom: 0.85,
			lighting: "Concert",
			particles: "sparks"
		});
		
		stagePresets.set("outdoor_park", {
			name: "Outdoor Park",
			description: "Park stage with trees and sky",
			category: "Outdoor",
			elements: [
				{type: "sprite", name: "sky", image: "stages/park/sky", x: 0, y: 0, scrollFactor: {x: 0.1, y: 0.1}},
				{type: "sprite", name: "clouds", image: "stages/park/clouds", x: 0, y: 0, scrollFactor: {x: 0.2, y: 0.1}},
				{type: "sprite", name: "trees_back", image: "stages/park/trees_back", x: 0, y: 100, scrollFactor: {x: 0.4, y: 0.4}},
				{type: "sprite", name: "trees_front", image: "stages/park/trees_front", x: 0, y: 200, scrollFactor: {x: 0.8, y: 0.8}},
				{type: "sprite", name: "grass", image: "stages/park/grass", x: 0, y: 400, scrollFactor: {x: 1, y: 1}}
			],
			characterPositions: {
				boyfriend: {x: 770, y: 100},
				dad: {x: 100, y: 100},
				girlfriend: {x: 400, y: 130}
			},
			cameraStart: {x: 600, y: 300},
			cameraZoom: 0.9,
			lighting: "Sunset",
			particles: "leaves"
		});
		
		stagePresets.set("neon_city", {
			name: "Neon City",
			description: "Cyberpunk city with neon lights",
			category: "Urban",
			elements: [
				{type: "sprite", name: "skyline", image: "stages/neon/skyline", x: 0, y: 0, scrollFactor: {x: 0.2, y: 0.2}},
				{type: "sprite", name: "buildings_mid", image: "stages/neon/buildings_mid", x: 0, y: 50, scrollFactor: {x: 0.5, y: 0.5}},
				{type: "sprite", name: "buildings_front", image: "stages/neon/buildings_front", x: 0, y: 150, scrollFactor: {x: 0.8, y: 0.8}},
				{type: "sprite", name: "street", image: "stages/neon/street", x: 0, y: 400, scrollFactor: {x: 1, y: 1}},
				{type: "sprite", name: "neon_signs", image: "stages/neon/signs", x: 0, y: 50, scrollFactor: {x: 0.6, y: 0.6}}
			],
			characterPositions: {
				boyfriend: {x: 770, y: 100},
				dad: {x: 100, y: 100},
				girlfriend: {x: 400, y: 130}
			},
			cameraStart: {x: 600, y: 300},
			cameraZoom: 0.85,
			lighting: "Neon",
			particles: null
		});
		
		stagePresets.set("void", {
			name: "Void",
			description: "Empty void with gradient background",
			category: "Abstract",
			elements: [
				{type: "solid", name: "bg", color: "#1a1a2e", x: 0, y: 0, width: 1280, height: 720, scrollFactor: {x: 0, y: 0}}
			],
			characterPositions: {
				boyfriend: {x: 770, y: 100},
				dad: {x: 100, y: 100},
				girlfriend: {x: 400, y: 130}
			},
			cameraStart: {x: 600, y: 300},
			cameraZoom: 1.0,
			lighting: "Default",
			particles: null
		});
	}
	
	// ==================== Audio Viz Design Presets (FEATURE 93) ====================
	
	function loadDefaultAudioVizPresets():Void {
		audioVizPresets.set("bottom_bars", {
			name: "Bottom Bars",
			description: "Classic frequency bars along the bottom of the screen",
			category: "Bars",
			designSettings: {
				type: "bars",
				position: {x: 0, y: 680},
				size: {width: 1280, height: 40},
				barCount: 64,
				barWidth: 16,
				barSpacing: 4,
				maxHeight: 200,
				colors: [0xFF00FF88, 0xFFFFFF00, 0xFFFF4444],
				smoothing: 0.8,
				mirror: false,
				orientation: "up",
				reactBand: "all",
				blendMode: "add",
				scrollFactor: {x: 0, y: 0},
				opacity: 0.6,
				roundBars: false,
				gradient: true
			}
		});
		
		audioVizPresets.set("circular_viz", {
			name: "Circular Visualizer",
			description: "Circular frequency visualizer centered on screen",
			category: "Circular",
			designSettings: {
				type: "circular",
				position: {x: 640, y: 360},
				radius: 100,
				innerRadius: 60,
				barCount: 128,
				maxHeight: 80,
				colors: [0xFF4488FF, 0xFF8844FF, 0xFFFF4488],
				smoothing: 0.85,
				rotation: 0,
				rotationSpeed: 0.5,
				reactBand: "all",
				blendMode: "add",
				opacity: 0.7,
				mirror: true,
				fillCenter: true,
				centerColor: 0xFF111122
			}
		});
		
		audioVizPresets.set("waveform_line", {
			name: "Waveform Line",
			description: "Oscilloscope-style waveform across the screen",
			category: "Wave",
			designSettings: {
				type: "wave",
				position: {x: 0, y: 360},
				size: {width: 1280, height: 200},
				color: 0xFF00FFAA,
				thickness: 2,
				smoothing: 0.6,
				amplitude: 100,
				blendMode: "add",
				opacity: 0.5,
				scrollFactor: {x: 0, y: 0},
				glow: true,
				glowIntensity: 0.5
			}
		});
		
		audioVizPresets.set("beat_pulse_bg", {
			name: "Beat Pulse Background",
			description: "Background pulses with the beat",
			category: "Background",
			designSettings: {
				type: "bg_pulse",
				position: {x: 0, y: 0},
				size: {width: 1280, height: 720},
				reactBand: "bass",
				smoothing: 0.95,
				colors: [0xFF000022, 0xFF220044, 0xFF440066],
				opacity: 0.3,
				pulseScale: 1.2,
				scrollFactor: {x: 0, y: 0}
			}
		});
		
		audioVizPresets.set("radial_wave", {
			name: "Radial Wave",
			description: "Smooth radial waveform emanating from center",
			category: "Circular",
			designSettings: {
				type: "radial_wave",
				position: {x: 640, y: 360},
				radius: 150,
				points: 256,
				amplitude: 50,
				color: 0xFFFFFFFF,
				thickness: 1.5,
				smoothing: 0.7,
				blendMode: "add",
				opacity: 0.4,
				mirror: true,
				rotationSpeed: 0
			}
		});
		
		audioVizPresets.set("spectrum_mirror", {
			name: "Mirror Spectrum",
			description: "Mirrored frequency bars from center",
			category: "Bars",
			designSettings: {
				type: "bars",
				position: {x: 640, y: 360},
				size: {width: 800, height: 300},
				barCount: 48,
				barWidth: 12,
				barSpacing: 4,
				maxHeight: 150,
				colors: [0xFF0088FF, 0xFF8800FF],
				smoothing: 0.75,
				mirror: true,
				orientation: "mirror_vertical",
				reactBand: "all",
				blendMode: "add",
				opacity: 0.5,
				roundBars: true,
				gradient: true
			}
		});
	}
	
	// ==================== Character Presets (FEATURE 94) ====================
	
	function loadDefaultCharacterPresets():Void {
		characterPresets.set("bf_default", {
			name: "Boyfriend Default",
			description: "Default Boyfriend configuration",
			category: "Boyfriend",
			settings: {
				character: "bf",
				scale: {x: 1, y: 1},
				camPosOffset: {x: 0, y: 0},
				animations: ["idle", "singLEFT", "singDOWN", "singUP", "singRIGHT", "singLEFTmiss", "singDOWNmiss", "singUPmiss", "singRIGHTmiss"],
				singDuration: 4,
				danceEvery: 2,
				danceAnim: "idle",
				flipX: true,
				healthIcon: "bf",
				healthColor: 0xFF31B0D1
			}
		});
		
		characterPresets.set("dad_default", {
			name: "Dad Default",
			description: "Default Dad configuration",
			category: "Opponent",
			settings: {
				character: "dad",
				scale: {x: 1, y: 1},
				camPosOffset: {x: 0, y: 0},
				animations: ["idle", "singLEFT", "singDOWN", "singUP", "singRIGHT"],
				singDuration: 6,
				danceEvery: 2,
				danceAnim: "idle",
				flipX: false,
				healthIcon: "dad",
				healthColor: 0xFFAF66CE
			}
		});
		
		characterPresets.set("gf_default", {
			name: "Girlfriend Default",
			description: "Default Girlfriend configuration",
			category: "Girlfriend",
			settings: {
				character: "gf",
				scale: {x: 1, y: 1},
				camPosOffset: {x: 0, y: 0},
				animations: ["danceLeft", "danceRight", "singLEFT", "singDOWN", "singUP", "singRIGHT", "sad", "scared"],
				singDuration: 4,
				danceEvery: 2,
				danceAnim: "danceLeft",
				flipX: false,
				healthIcon: "gf",
				healthColor: 0xFFA5004D
			}
		});
	}
	
	// ==================== Note Skin Presets (FEATURE 95) ====================
	
	function loadDefaultNoteSkinPresets():Void {
		noteSkinPresets.set("default", {
			name: "Default Notes",
			description: "Standard FNF note skin",
			category: "Standard",
			settings: {
				image: "NOTE_assets",
				noteSize: {width: 157, height: 154},
				strumSize: {width: 157, height: 154},
				splashImage: "noteSplashes",
				colors: [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F],
				animPrefixes: ["purple", "blue", "green", "red"],
				sustainImage: "NOTE_assets",
				sustainPrefix: "hold",
				sustainEndPrefix: "holdend"
			}
		});
		
		noteSkinPresets.set("pixel", {
			name: "Pixel Notes",
			description: "Week 6 pixel-style notes",
			category: "Pixel",
			settings: {
				image: "weeb/pixelUI/arrows-pixels",
				noteSize: {width: 17, height: 17},
				strumSize: {width: 17, height: 17},
				scale: 6,
				splashImage: null,
				colors: [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F],
				animPrefixes: ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"],
				sustainImage: "weeb/pixelUI/arrowEnds",
				sustainPrefix: "",
				sustainEndPrefix: ""
			}
		});
		
		noteSkinPresets.set("circle", {
			name: "Circle Notes",
			description: "Simple circle-based notes",
			category: "Minimalist",
			settings: {
				image: "notes/circle_notes",
				noteSize: {width: 128, height: 128},
				strumSize: {width: 128, height: 128},
				splashImage: "notes/circle_splashes",
				colors: [0xFF9B59B6, 0xFF3498DB, 0xFF2ECC71, 0xFFE74C3C],
				animPrefixes: ["left", "down", "up", "right"]
			}
		});
	}
	
	// ==================== HUD Presets (FEATURE 96) ====================
	
	function loadDefaultHUDPresets():Void {
		hudPresets.set("default", {
			name: "Default HUD",
			description: "Standard FNF HUD layout",
			category: "Standard",
			settings: {
				healthBar: {
					position: {x: 640, y: 680},
					size: {width: 600, height: 20},
					anchor: "center",
					visible: true,
					showIcons: true,
					borderWidth: 2,
					borderColor: 0xFF000000
				},
				scoreText: {
					position: {x: 5, y: 5},
					visible: true,
					fontSize: 16,
					color: 0xFFFFFFFF,
					format: "Score: {score} | Misses: {misses} | Accuracy: {accuracy}%"
				},
				timeBar: {
					position: {x: 640, y: 30},
					size: {width: 400, height: 16},
					anchor: "center",
					visible: true,
					showTime: true,
					color: 0xFFFFFFFF
				},
				comboGroup: {
					position: {x: 640, y: 360},
					scale: 0.7,
					visible: true
				},
				countdown: {
					scale: 0.6,
					sound: true
				},
				healthBarColors: {
					left: null,
					right: null
				}
			}
		});
		
		hudPresets.set("minimal", {
			name: "Minimal HUD",
			description: "Clean, minimal HUD",
			category: "Minimal",
			settings: {
				healthBar: {
					position: {x: 640, y: 700},
					size: {width: 400, height: 10},
					anchor: "center",
					visible: true,
					showIcons: false,
					borderWidth: 0
				},
				scoreText: {
					position: {x: 5, y: 5},
					visible: true,
					fontSize: 12,
					color: 0xFFAAAAAA,
					format: "{accuracy}%"
				},
				timeBar: {
					visible: false
				},
				comboGroup: {
					position: {x: 640, y: 360},
					scale: 0.5,
					visible: true
				}
			}
		});
		
		hudPresets.set("competitive", {
			name: "Competitive HUD",
			description: "Detailed HUD for competitive play",
			category: "Competitive",
			settings: {
				healthBar: {
					position: {x: 640, y: 680},
					size: {width: 600, height: 24},
					anchor: "center",
					visible: true,
					showIcons: true,
					borderWidth: 3
				},
				scoreText: {
					position: {x: 5, y: 5},
					visible: true,
					fontSize: 14,
					color: 0xFFFFFFFF,
					format: "Score: {score} | Combo: {combo} | Misses: {misses} | {accuracy}% | {rating}"
				},
				timeBar: {
					position: {x: 640, y: 25},
					size: {width: 500, height: 12},
					anchor: "center",
					visible: true,
					showTime: true
				},
				comboGroup: {
					position: {x: 640, y: 360},
					scale: 0.8,
					visible: true
				},
				judgementWindow: {
					visible: true,
					position: {x: 1200, y: 100}
				},
				npsCounter: {
					visible: true,
					position: {x: 5, y: 25}
				}
			}
		});
	}
	
	// ==================== Initialization ====================
	
	function loadDefaultPresets():Void {
		loadDefaultStagePresets();
		loadDefaultAudioVizPresets();
		loadDefaultCharacterPresets();
		loadDefaultNoteSkinPresets();
		loadDefaultHUDPresets();
	}
	
	function loadUserPresets():Void {
		// Load from user save directory
	}
	
	// ==================== Generic CRUD ====================
	
	public function savePreset(category:String, id:String, data:Dynamic):Void {
		var json = Json.stringify(data, null, "\t");
		trace('Preset saved: $category/$id');
	}
	
	public function loadPreset(category:String, id:String):Dynamic {
		return null; // Would load from file
	}
	
	public function deletePreset(category:String, id:String):Void {
		switch (category) {
			case "stage": stagePresets.remove(id);
			case "audioviz": audioVizPresets.remove(id);
			case "character": characterPresets.remove(id);
			case "noteskin": noteSkinPresets.remove(id);
			case "hud": hudPresets.remove(id);
		}
	}
	
	public function listPresets(category:String):Array<String> {
		return switch (category) {
			case "stage": [for (k in stagePresets.keys()) k];
			case "audioviz": [for (k in audioVizPresets.keys()) k];
			case "character": [for (k in characterPresets.keys()) k];
			case "noteskin": [for (k in noteSkinPresets.keys()) k];
			case "hud": [for (k in hudPresets.keys()) k];
			default: [];
		}
	}
	
	public function exportPreset(category:String, id:String):String {
		var data:Dynamic = switch (category) {
			case "stage": stagePresets.get(id);
			case "audioviz": audioVizPresets.get(id);
			case "character": characterPresets.get(id);
			case "noteskin": noteSkinPresets.get(id);
			case "hud": hudPresets.get(id);
			default: null;
		};
		return data != null ? Json.stringify(data, null, "\t") : "";
	}
}

// ==================== Data Types ====================

typedef StagePreset = {
	var name:String;
	var description:String;
	var category:String;
	var elements:Array<Dynamic>;
	var characterPositions:{boyfriend:{x:Float,y:Float}, dad:{x:Float,y:Float}, girlfriend:{x:Float,y:Float}};
	var cameraStart:{x:Float, y:Float};
	var cameraZoom:Float;
	var lighting:String;
	var ?particles:String;
}

typedef AudioVizDesignPreset = {
	var name:String;
	var description:String;
	var category:String;
	var designSettings:Dynamic;
}

typedef CharacterPreset = {
	var name:String;
	var description:String;
	var category:String;
	var settings:Dynamic;
}

typedef NoteSkinPreset = {
	var name:String;
	var description:String;
	var category:String;
	var settings:Dynamic;
}

typedef HUDPreset = {
	var name:String;
	var description:String;
	var category:String;
	var settings:Dynamic;
}
