package funkin.game.modifiers;

import haxe.Json;
import flixel.util.FlxSignal;

/**
 * FEATURE 97: Gameplay Modifiers System
 * 
 * Comprehensive gameplay modifier system inspired by DDR/ITG/StepMania.
 * Features:
 * - Predefined modifiers (speed, flip, mirror, etc.)
 * - Custom modifier creation
 * - Modifier stacking with priority
 * - Per-song modifier presets
 * - Score multiplier calculation
 * - Visual preview of modifiers
 * - Moddable modifier definitions
 */
class GameplayModifierManager {
	public static var instance:GameplayModifierManager;
	
	public var modifiers:Map<String, GameplayModifier> = [];
	public var activeModifiers:Map<String, Dynamic> = [];
	public var modifierPresets:Map<String, ModifierPreset> = [];
	
	public var onModifierChanged:FlxTypedSignal<String, Dynamic->Void> = new FlxTypedSignal();
	public var onModifiersReset:FlxSignal = new FlxSignal();
	
	public function new() {
		instance = this;
		registerDefaultModifiers();
		loadPresets();
	}
	
	function registerDefaultModifiers():Void {
		// ==================== Speed Modifiers ====================
		register({
			id: "scroll_speed_mult",
			name: "Scroll Speed",
			description: "Multiply the scroll speed",
			category: SPEED,
			type: FLOAT_VALUE,
			defaultValue: 1.0,
			minValue: 0.25,
			maxValue: 5.0,
			step: 0.25,
			scoreMultiplier: (v) -> v == 1.0 ? 1.0 : 0.9 + (v * 0.1),
			apply: function(value:Dynamic, context:ModifierContext) {
				context.scrollSpeedMultiplier = cast value;
			}
		});
		
		register({
			id: "x_mod",
			name: "X Mod",
			description: "Notes accelerate as they approach the strumline",
			category: SPEED,
			type: FLOAT_VALUE,
			defaultValue: 1.0,
			minValue: 0.5,
			maxValue: 3.0,
			step: 0.25,
			scoreMultiplier: (v) -> 1.0 + (v - 1.0) * 0.1,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.accelerationMod = cast value;
			}
		});
		
		// ==================== Direction Modifiers ====================
		register({
			id: "mirror",
			name: "Mirror",
			description: "Flip the note field horizontally",
			category: DIRECTION,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.1 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.mirror = cast value;
			}
		});
		
		register({
			id: "flip",
			name: "Flip",
			description: "Flip the note field vertically",
			category: DIRECTION,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.1 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.flip = cast value;
			}
		});
		
		register({
			id: "shuffle",
			name: "Shuffle",
			description: "Randomly rearrange note columns",
			category: DIRECTION,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.2 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.shuffle = cast value;
			}
		});
		
		register({
			id: "random",
			name: "Random",
			description: "Notes appear in random columns",
			category: DIRECTION,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.5 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.random = cast value;
			}
		});
		
		// ==================== Visual Modifiers ====================
		register({
			id: "hidden",
			name: "Hidden",
			description: "Notes fade out as they approach the strumline",
			category: VISUAL,
			type: FLOAT_VALUE,
			defaultValue: 0.0,
			minValue: 0.0,
			maxValue: 1.0,
			step: 0.25,
			scoreMultiplier: (v) -> 1.0 + v * 0.3,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.hiddenAmount = cast value;
			}
		});
		
		register({
			id: "sudden",
			name: "Sudden",
			description: "Notes appear suddenly close to the strumline",
			category: VISUAL,
			type: FLOAT_VALUE,
			defaultValue: 0.0,
			minValue: 0.0,
			maxValue: 1.0,
			step: 0.25,
			scoreMultiplier: (v) -> 1.0 + v * 0.3,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.suddenAmount = cast value;
			}
		});
		
		register({
			id: "invisible_notes",
			name: "Invisible Notes",
			description: "Notes are completely invisible (memorization required)",
			category: VISUAL,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 2.0 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.invisibleNotes = cast value;
			}
		});
		
		register({
			id: "tiny_notes",
			name: "Tiny Notes",
			description: "Notes are smaller than normal",
			category: VISUAL,
			type: FLOAT_VALUE,
			defaultValue: 1.0,
			minValue: 0.1,
			maxValue: 1.0,
			step: 0.1,
			scoreMultiplier: (v) -> 1.0 + (1.0 - v) * 0.5,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.noteScale = cast value;
			}
		});
		
		// ==================== Difficulty Modifiers ====================
		register({
			id: "no_miss",
			name: "No Miss",
			description: "Instant game over on any miss",
			category: DIFFICULTY,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.5 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.noMiss = cast value;
			}
		});
		
		register({
			id: "one_hp",
			name: "One HP",
			description: "Start with minimum health",
			category: DIFFICULTY,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.3 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.startHealth = cast value ? 0.1 : null;
			}
		});
		
		register({
			id: "no_camera",
			name: "Static Camera",
			description: "Camera doesn't move or zoom",
			category: DIFFICULTY,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.0 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.staticCamera = cast value;
			}
		});
		
		register({
			id: "ghost_tapping_off",
			name: "Strict Input",
			description: "Ghost tapping disabled - pressing with no note penalizes",
			category: DIFFICULTY,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.1 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.disableGhostTapping = cast value;
			}
		});
		
		register({
			id: "bot_play",
			name: "Bot Play",
			description: "Auto-play all notes (no score)",
			category: DIFFICULTY,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> 0.0, // Bot play = no score
			apply: function(value:Dynamic, context:ModifierContext) {
				context.botPlay = cast value;
			}
		});
		
		register({
			id: "practice",
			name: "Practice",
			description: "Can't die, but no score saved",
			category: DIFFICULTY,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> 0.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.practiceMode = cast value;
			}
		});
		
		// ==================== Audio Modifiers ====================
		register({
			id: "muted_vocals",
			name: "Muted Vocals",
			description: "Player vocal track is muted",
			category: AUDIO,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> v ? 1.15 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.mutedPlayerVocals = cast value;
			}
		});
		
		register({
			id: "pitch_shift",
			name: "Pitch Shift",
			description: "Change the pitch of the song",
			category: AUDIO,
			type: FLOAT_VALUE,
			defaultValue: 1.0,
			minValue: 0.5,
			maxValue: 2.0,
			step: 0.1,
			scoreMultiplier: (v) -> v != 1.0 ? 1.1 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.pitchShift = cast value;
			}
		});
		
		register({
			id: "speed_up",
			name: "Song Speed",
			description: "Speed up or slow down the song",
			category: AUDIO,
			type: FLOAT_VALUE,
			defaultValue: 1.0,
			minValue: 0.5,
			maxValue: 2.0,
			step: 0.1,
			scoreMultiplier: (v) -> v >= 1.0 ? 1.0 + (v - 1.0) * 0.5 : 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.songSpeed = cast value;
			}
		});
		
		// ==================== Fun Modifiers ====================
		register({
			id: "drunk",
			name: "Drunk",
			description: "Notes wave left and right",
			category: FUN,
			type: FLOAT_VALUE,
			defaultValue: 0.0,
			minValue: 0.0,
			maxValue: 1.0,
			step: 0.25,
			scoreMultiplier: (v) -> 1.0 + v * 0.2,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.drunkAmount = cast value;
			}
		});
		
		register({
			id: "tipsy",
			name: "Tipsy",
			description: "Notes wobble randomly",
			category: FUN,
			type: FLOAT_VALUE,
			defaultValue: 0.0,
			minValue: 0.0,
			maxValue: 1.0,
			step: 0.25,
			scoreMultiplier: (v) -> 1.0 + v * 0.15,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.tipsyAmount = cast value;
			}
		});
		
		register({
			id: "beat_rotate",
			name: "Beat Rotation",
			description: "Notes rotate to the beat",
			category: FUN,
			type: FLOAT_VALUE,
			defaultValue: 0.0,
			minValue: 0.0,
			maxValue: 1.0,
			step: 0.25,
			scoreMultiplier: (v) -> 1.0 + v * 0.1,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.beatRotation = cast value;
			}
		});
		
		register({
			id: "rainbow",
			name: "Rainbow",
			description: "Notes cycle through rainbow colors",
			category: FUN,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.rainbow = cast value;
			}
		});
		
		register({
			id: "spin_field",
			name: "Spin",
			description: "The note field spins",
			category: FUN,
			type: FLOAT_VALUE,
			defaultValue: 0.0,
			minValue: 0.0,
			maxValue: 5.0,
			step: 0.5,
			scoreMultiplier: (v) -> 1.0 + v * 0.1,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.spinSpeed = cast value;
			}
		});
		
		// ==================== Accessibility Modifiers ====================
		register({
			id: "colorblind_mode",
			name: "Colorblind Mode",
			description: "Add patterns/symbols to distinguish note directions",
			category: ACCESSIBILITY,
			type: DROPDOWN,
			dropdownOptions: ["Off", "Protanopia", "Deuteranopia", "Tritanopia", "Achromatopsia"],
			defaultValue: "Off",
			scoreMultiplier: (v) -> 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.colorblindMode = cast value;
			}
		});
		
		register({
			id: "reduced_motion",
			name: "Reduced Motion",
			description: "Minimize camera movement and visual effects",
			category: ACCESSIBILITY,
			type: BOOL,
			defaultValue: false,
			scoreMultiplier: (v) -> 1.0,
			apply: function(value:Dynamic, context:ModifierContext) {
				context.reducedMotion = cast value;
			}
		});
	}
	
	public function register(data:ModifierData):Void {
		modifiers.set(data.id, {
			id: data.id,
			name: data.name,
			description: data.description,
			category: data.category,
			type: data.type,
			defaultValue: data.defaultValue,
			minValue: data.minValue,
			maxValue: data.maxValue,
			step: data.step,
			dropdownOptions: data.dropdownOptions,
			scoreMultiplier: data.scoreMultiplier,
			apply: data.apply,
			isEnabled: false,
			currentValue: data.defaultValue
		});
	}
	
	/**
	 * Set a modifier's value
	 */
	public function setModifier(id:String, value:Dynamic):Void {
		var mod = modifiers.get(id);
		if (mod == null) return;
		
		mod.currentValue = value;
		mod.isEnabled = value != mod.defaultValue;
		
		if (mod.isEnabled) {
			activeModifiers.set(id, value);
		} else {
			activeModifiers.remove(id);
		}
		
		onModifierChanged.dispatch(id, value);
	}
	
	/**
	 * Get a modifier's current value
	 */
	public function getModifierValue(id:String):Dynamic {
		var mod = modifiers.get(id);
		return mod != null ? mod.currentValue : null;
	}
	
	/**
	 * Check if a modifier is active
	 */
	public function isModifierActive(id:String):Bool {
		return activeModifiers.exists(id);
	}
	
	/**
	 * Reset all modifiers to defaults
	 */
	public function resetAll():Void {
		for (id => mod in modifiers) {
			mod.currentValue = mod.defaultValue;
			mod.isEnabled = false;
		}
		activeModifiers = [];
		onModifiersReset.dispatch();
	}
	
	/**
	 * Calculate score multiplier from active modifiers
	 */
	public function calculateScoreMultiplier():Float {
		var mult:Float = 1.0;
		for (id => mod in modifiers) {
			if (mod.isEnabled && mod.scoreMultiplier != null) {
				mult *= mod.scoreMultiplier(mod.currentValue);
			}
		}
		return mult;
	}
	
	/**
	 * Build a modifier context for gameplay
	 */
	public function buildContext():ModifierContext {
		var context:ModifierContext = {};
		for (id => mod in modifiers) {
			if (mod.isEnabled && mod.apply != null) {
				mod.apply(mod.currentValue, context);
			}
		}
		context.scoreMultiplier = calculateScoreMultiplier();
		return context;
	}
	
	/**
	 * Get modifiers by category
	 */
	public function getByCategory(category:ModifierCategory):Array<GameplayModifier> {
		return [for (m in modifiers) if (m.category == category) m];
	}
	
	/**
	 * Get all categories that have active modifiers
	 */
	public function getActiveCategories():Array<ModifierCategory> {
		var cats:Map<ModifierCategory, Bool> = [];
		for (m in modifiers) if (m.isEnabled) cats.set(m.category, true);
		return [for (c in cats.keys()) c];
	}
	
	// ==================== Presets ====================
	
	public function savePreset(name:String):Void {
		var preset:ModifierPreset = {
			name: name,
			modifiers: [for (id => mod in modifiers) if (mod.isEnabled) {id: id, value: mod.currentValue}],
			createdAt: Date.now().toString()
		};
		modifierPresets.set(name, preset);
	}
	
	public function loadPreset(name:String):Void {
		var preset = modifierPresets.get(name);
		if (preset == null) return;
		
		resetAll();
		for (entry in preset.modifiers) {
			setModifier(entry.id, entry.value);
		}
	}
	
	public function deletePreset(name:String):Void {
		modifierPresets.remove(name);
	}
	
	function loadPresets():Void {
		// Load from save file
	}
}

// ==================== Data Types ====================

typedef GameplayModifier = {
	var id:String;
	var name:String;
	var description:String;
	var category:ModifierCategory;
	var type:ModifierValueType;
	var defaultValue:Dynamic;
	var ?minValue:Float;
	var ?maxValue:Float;
	var ?step:Float;
	var ?dropdownOptions:Array<String>;
	var ?scoreMultiplier:Dynamic->Float;
	var ?apply:Dynamic->ModifierContext->Void;
	var isEnabled:Bool;
	var currentValue:Dynamic;
}

typedef ModifierData = {
	var id:String;
	var name:String;
	var description:String;
	var category:ModifierCategory;
	var type:ModifierValueType;
	var defaultValue:Dynamic;
	var ?minValue:Float;
	var ?maxValue:Float;
	var ?step:Float;
	var ?dropdownOptions:Array<String>;
	var ?scoreMultiplier:Dynamic->Float;
	var ?apply:Dynamic->ModifierContext->Void;
}

typedef ModifierContext = {
	var ?scrollSpeedMultiplier:Float;
	var ?accelerationMod:Float;
	var ?mirror:Bool;
	var ?flip:Bool;
	var ?shuffle:Bool;
	var ?random:Bool;
	var ?hiddenAmount:Float;
	var ?suddenAmount:Float;
	var ?invisibleNotes:Bool;
	var ?noteScale:Float;
	var ?noMiss:Bool;
	var ?startHealth:Float;
	var ?staticCamera:Bool;
	var ?disableGhostTapping:Bool;
	var ?botPlay:Bool;
	var ?practiceMode:Bool;
	var ?mutedPlayerVocals:Bool;
	var ?pitchShift:Float;
	var ?songSpeed:Float;
	var ?drunkAmount:Float;
	var ?tipsyAmount:Float;
	var ?beatRotation:Float;
	var ?rainbow:Bool;
	var ?spinSpeed:Float;
	var ?colorblindMode:String;
	var ?reducedMotion:Bool;
	var ?scoreMultiplier:Float;
}

typedef ModifierPreset = {
	var name:String;
	var modifiers:Array<{id:String, value:Dynamic}>;
	var createdAt:String;
}

enum abstract ModifierCategory(Int) {
	var SPEED = 0;
	var DIRECTION = 1;
	var VISUAL = 2;
	var DIFFICULTY = 3;
	var AUDIO = 4;
	var FUN = 5;
	var ACCESSIBILITY = 6;
}

enum abstract ModifierValueType(Int) {
	var BOOL = 0;
	var FLOAT_VALUE = 1;
	var INT_VALUE = 2;
	var STRING_VALUE = 3;
	var DROPDOWN = 4;
}
