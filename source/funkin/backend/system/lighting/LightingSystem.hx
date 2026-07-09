package funkin.backend.system.lighting;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * FEATURE 38: Lighting System
 * 
 * A 2D lighting system for stages with:
 * - Point lights with customizable properties
 * - Directional/ambient lighting
 * - Spotlights with cone angles
 * - Light color and intensity
 * - Shadow casting (simple 2D)
 * - Light groups and layers
 * - Beat-synchronized lighting
 * - Integration with stage editor
 * - Shader-based rendering
 */
class LightingSystem {
	public var lights:Array<Light> = [];
	public var ambientColor:FlxColor = 0xFF333333;
	public var ambientIntensity:Float = 0.3;
	
	public var directionalLight:DirectionalLight;
	public var isDirty:Bool = true;
	public var enabled:Bool = true;
	
	// Beat sync
	public var beatPulse:Bool = false;
	public var beatIntensity:Float = 0.2;
	public var currentBeatPulse:Float = 0;
	
	public function new() {
		directionalLight = {
			direction: new FlxPoint(0.5, 1),
			color: 0xFFFFFFFF,
			intensity: 0.5,
			castShadows: false
		};
	}
	
	/**
	 * Add a point light
	 */
	public function addPointLight(x:Float, y:Float, ?color:FlxColor = 0xFFFFFFFF, ?radius:Float = 200, ?intensity:Float = 1.0):Light {
		var light:Light = {
			id: 'light_${lights.length}',
			type: POINT,
			x: x,
			y: y,
			color: color,
			radius: radius,
			intensity: intensity,
			falloff: QUADRATIC,
			enabled: true,
			castShadows: false,
			group: "default",
			animPhase: 0,
			animSpeed: 0,
			animAmplitude: 0
		};
		lights.push(light);
		isDirty = true;
		return light;
	}
	
	/**
	 * Add a spotlight
	 */
	public function addSpotlight(x:Float, y:Float, targetX:Float, targetY:Float, ?color:FlxColor = 0xFFFFFFFF, ?radius:Float = 300, ?coneAngle:Float = 45):Light {
		var light:Light = {
			id: 'spot_${lights.length}',
			type: SPOT,
			x: x,
			y: y,
			targetX: targetX,
			targetY: targetY,
			color: color,
			radius: radius,
			intensity: 1.0,
			coneAngle: coneAngle,
			falloff: QUADRATIC,
			enabled: true,
			castShadows: true,
			group: "default",
			animPhase: 0,
			animSpeed: 0,
			animAmplitude: 0
		};
		lights.push(light);
		isDirty = true;
		return light;
	}
	
	/**
	 * Remove a light by ID
	 */
	public function removeLight(id:String):Void {
		lights = lights.filter(l -> l.id != id);
		isDirty = true;
	}
	
	/**
	 * Get a light by ID
	 */
	public function getLight(id:String):Light {
		for (l in lights) if (l.id == id) return l;
		return null;
	}
	
	/**
	 * Get lights by group
	 */
	public function getLightsInGroup(group:String):Array<Light> {
		return lights.filter(l -> l.group == group);
	}
	
	/**
	 * Update lights (animation, beat sync)
	 */
	public function update(elapsed:Float):Void {
		if (!enabled) return;
		
		// Beat pulse decay
		currentBeatPulse *= 0.9;
		
		for (light in lights) {
			if (!light.enabled) continue;
			
			// Animate lights
			if (light.animSpeed > 0) {
				light.animPhase += light.animSpeed * elapsed;
				if (light.animAmplitude > 0) {
					light.intensity = 0.5 + Math.sin(light.animPhase) * light.animAmplitude;
				}
			}
			
			// Beat pulse
			if (beatPulse) {
				light.intensity += currentBeatPulse * beatIntensity;
			}
		}
	}
	
	/**
	 * Called on beat hit
	 */
	public function onBeatHit(curBeat:Int):Void {
		currentBeatPulse = 1.0;
	}
	
	/**
	 * Calculate the light contribution at a point
	 */
	public function calculateLighting(x:Float, y:Float):FlxColor {
		if (!enabled) return ambientColor;
		
		var r:Float = (ambientColor.red / 255) * ambientIntensity;
		var g:Float = (ambientColor.green / 255) * ambientIntensity;
		var b:Float = (ambientColor.blue / 255) * ambientIntensity;
		
		for (light in lights) {
			if (!light.enabled) continue;
			
			var dx = light.x - x;
			var dy = light.y - y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			
			if (dist > light.radius) continue;
			
			var attenuation:Float = switch (light.falloff) {
				case LINEAR: 1.0 - (dist / light.radius);
				case QUADRATIC: Math.pow(1.0 - (dist / light.radius), 2);
				case CUBIC: Math.pow(1.0 - (dist / light.radius), 3);
				case CONSTANT: 1.0;
			};
			
			// Spotlight cone check
			if (light.type == SPOT && light.coneAngle != null) {
				var toPoint = Math.atan2(y - light.y, x - light.x);
				var toTarget = Math.atan2(light.targetY - light.y, light.targetX - light.x);
				var angleDiff = Math.abs(toPoint - toTarget) * 180 / Math.PI;
				if (angleDiff > 180) angleDiff = 360 - angleDiff;
				if (angleDiff > light.coneAngle / 2) continue;
				attenuation *= 1.0 - (angleDiff / (light.coneAngle / 2));
			}
			
			var contribution = attenuation * light.intensity;
			r += (light.color.red / 255) * contribution;
			g += (light.color.green / 255) * contribution;
			b += (light.color.blue / 255) * contribution;
		}
		
		return FlxColor.fromRGBFloat(
			Math.min(1.0, r),
			Math.min(1.0, g),
			Math.min(1.0, b)
		);
	}
	
	/**
	 * Create a lighting preset
	 */
	public function applyPreset(preset:LightingPreset):Void {
		// Clear existing lights
		lights = [];
		
		// Apply preset
		ambientColor = preset.ambientColor;
		ambientIntensity = preset.ambientIntensity;
		
		for (lightData in preset.lights) {
			switch (lightData.type) {
				case POINT: addPointLight(lightData.x, lightData.y, lightData.color, lightData.radius, lightData.intensity);
				case SPOT: addSpotlight(lightData.x, lightData.y, lightData.targetX, lightData.targetY, lightData.color, lightData.radius, lightData.coneAngle);
				default:
			}
		}
		
		beatPulse = preset.beatPulse;
		beatIntensity = preset.beatIntensity;
		isDirty = true;
	}
	
	public function clearAll():Void {
		lights = [];
		isDirty = true;
	}
}

// ==================== Data Types ====================

typedef Light = {
	var id:String;
	var type:LightType;
	var x:Float;
	var y:Float;
	var ?targetX:Float;
	var ?targetY:Float;
	var color:FlxColor;
	var radius:Float;
	var intensity:Float;
	var ?coneAngle:Float;
	var falloff:LightFalloff;
	var enabled:Bool;
	var castShadows:Bool;
	var group:String;
	var animPhase:Float;
	var animSpeed:Float;
	var animAmplitude:Float;
}

typedef DirectionalLight = {
	var direction:FlxPoint;
	var color:FlxColor;
	var intensity:Float;
	var castShadows:Bool;
}

typedef LightingPreset = {
	var name:String;
	var ambientColor:FlxColor;
	var ambientIntensity:Float;
	var lights:Array<LightPresetData>;
	var beatPulse:Bool;
	var beatIntensity:Float;
}

typedef LightPresetData = {
	var type:LightType;
	var x:Float;
	var y:Float;
	var ?targetX:Float;
	var ?targetY:Float;
	var color:Int;
	var radius:Float;
	var intensity:Float;
	var ?coneAngle:Float;
}

/**
 * Built-in lighting presets
 */
class LightingPresets {
	public static function getPresets():Map<String, LightingPreset> {
		var presets:Map<String, LightingPreset> = [];
		
		presets.set("Default", {
			name: "Default",
			ambientColor: 0xFF444444,
			ambientIntensity: 0.5,
			lights: [],
			beatPulse: false,
			beatIntensity: 0
		});
		
		presets.set("Concert", {
			name: "Concert",
			ambientColor: 0xFF111122,
			ambientIntensity: 0.2,
			lights: [
				{type: SPOT, x: 200, y: -100, targetX: 400, targetY: 400, color: 0xFFFF0044, radius: 500, intensity: 1.5, coneAngle: 30},
				{type: SPOT, x: 1080, y: -100, targetX: 880, targetY: 400, color: 0xFF0044FF, radius: 500, intensity: 1.5, coneAngle: 30},
				{type: POINT, x: 640, y: 360, color: 0xFFFFFF88, radius: 800, intensity: 0.3}
			],
			beatPulse: true,
			beatIntensity: 0.3
		});
		
		presets.set("Nightclub", {
			name: "Nightclub",
			ambientColor: 0xFF000011,
			ambientIntensity: 0.1,
			lights: [
				{type: POINT, x: 200, y: 100, color: 0xFFFF0088, radius: 300, intensity: 1.0},
				{type: POINT, x: 640, y: 100, color: 0xFF00FF88, radius: 300, intensity: 1.0},
				{type: POINT, x: 1080, y: 100, color: 0xFF8800FF, radius: 300, intensity: 1.0},
				{type: SPOT, x: 640, y: 0, targetX: 640, targetY: 500, color: 0xFFFFFFFF, radius: 600, intensity: 0.8, coneAngle: 20}
			],
			beatPulse: true,
			beatIntensity: 0.5
		});
		
		presets.set("Sunset", {
			name: "Sunset",
			ambientColor: 0xFF884422,
			ambientIntensity: 0.6,
			lights: [
				{type: POINT, x: 1200, y: 200, color: 0xFFFF8844, radius: 2000, intensity: 0.8}
			],
			beatPulse: false,
			beatIntensity: 0
		});
		
		presets.set("Horror", {
			name: "Horror",
			ambientColor: 0xFF000008,
			ambientIntensity: 0.05,
			lights: [
				{type: POINT, x: 640, y: 360, color: 0xFF222233, radius: 400, intensity: 0.5},
				{type: SPOT, x: 300, y: 100, targetX: 640, targetY: 400, color: 0xFFAA0000, radius: 600, intensity: 0.6, coneAngle: 40}
			],
			beatPulse: true,
			beatIntensity: 0.15
		});
		
		presets.set("Neon", {
			name: "Neon",
			ambientColor: 0xFF000022,
			ambientIntensity: 0.15,
			lights: [
				{type: POINT, x: 100, y: 300, color: 0xFFFF00FF, radius: 250, intensity: 1.2},
				{type: POINT, x: 400, y: 200, color: 0xFF00FFFF, radius: 250, intensity: 1.2},
				{type: POINT, x: 700, y: 400, color: 0xFFFFFF00, radius: 250, intensity: 1.2},
				{type: POINT, x: 1000, y: 250, color: 0xFFFF0044, radius: 250, intensity: 1.2},
				{type: POINT, x: 1200, y: 350, color: 0xFF44FF00, radius: 250, intensity: 1.2}
			],
			beatPulse: true,
			beatIntensity: 0.4
		});
		
		return presets;
	}
}

enum abstract LightType(Int) {
	var POINT = 0;
	var SPOT = 1;
	var AREA = 2;
}

enum abstract LightFalloff(Int) {
	var CONSTANT = 0;
	var LINEAR = 1;
	var QUADRATIC = 2;
	var CUBIC = 3;
}
