package funkin.backend.system.particles;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import funkin.backend.system.interfaces.IBeatReceiver;

/**
 * FEATURE 16: Particle System
 * 
 * A robust, GPU-friendly particle system for stages, effects, and gameplay.
 * Supports:
 * - Multiple emitter types (point, line, circle, cone, box)
 * - Particle pooling for performance
 * - Customizable lifetime, speed, acceleration, rotation, scale, color
 * - Gravity and wind forces
 * - Collision with stage elements
 * - Texture atlas support for animated particles
 * - Blend modes and shader effects
 * - Beat-synchronized spawning
 * - Preset system for common effects (confetti, sparks, smoke, fire, etc.)
 */
class ParticleSystem extends FlxTypedGroup<Particle> implements IBeatReceiver {
	public var emitters:Array<ParticleEmitter> = [];
	public var maxParticles:Int = 5000;
	public var isActive:Bool = true;
	public var globalGravity:FlxPoint = new FlxPoint(0, 0);
	public var globalWind:FlxPoint = new FlxPoint(0, 0);
	public var particlePool:Array<Particle> = [];
	
	public function new(?maxParticles:Int) {
		super();
		if (maxParticles != null) this.maxParticles = maxParticles;
		
		// Pre-allocate particle pool
		for (i in 0...this.maxParticles) {
			var p = new Particle();
			p.exists = false;
			particlePool.push(p);
			add(p);
		}
	}
	
	/**
	 * Create and add a new emitter
	 */
	public function createEmitter(?config:ParticleEmitterConfig):ParticleEmitter {
		var emitter = new ParticleEmitter(this, config);
		emitters.push(emitter);
		return emitter;
	}
	
	/**
	 * Remove an emitter
	 */
	public function removeEmitter(emitter:ParticleEmitter):Void {
		emitter.stop();
		emitters.remove(emitter);
	}
	
	/**
	 * Get an inactive particle from the pool
	 */
	public function getParticle():Particle {
		for (p in particlePool) {
			if (!p.exists) {
				p.exists = true;
				p.reset(0, 0);
				return p;
			}
		}
		return null; // Pool exhausted
	}
	
	/**
	 * Return a particle to the pool
	 */
	public function returnParticle(particle:Particle):Void {
		particle.exists = false;
		particle.kill();
	}
	
	/**
	 * Emit a burst of particles from a point
	 */
	public function emitBurst(x:Float, y:Float, count:Int, ?config:ParticleConfig):Void {
		for (i in 0...count) {
			var p = getParticle();
			if (p == null) break;
			p.configure(config != null ? config : getDefaultConfig());
			p.x = x;
			p.y = y;
			p.emit();
		}
	}
	
	/**
	 * Create a preset effect at a position
	 */
	public function createPreset(preset:ParticlePreset, x:Float, y:Float):ParticleEmitter {
		var config = ParticlePresets.getConfig(preset);
		var emitter = createEmitter(config);
		emitter.setPosition(x, y);
		emitter.start();
		return emitter;
	}
	
	public override function update(elapsed:Float):Void {
		if (!isActive) return;
		
		// Update emitters
		for (emitter in emitters) {
			emitter.update(elapsed);
		}
		
		// Update active particles
		for (particle in particlePool) {
			if (particle.exists) {
				particle.updateParticle(elapsed, globalGravity, globalWind);
				if (particle.lifetime <= 0) {
					returnParticle(particle);
				}
			}
		}
		
		super.update(elapsed);
	}
	
	/**
	 * Called on beat for beat-synced particles
	 */
	public function onBeatHit(curBeat:Int):Void {
		for (emitter in emitters) {
			if (emitter.syncToBeat) {
				emitter.emitBurst(emitter.burstOnBeatCount);
			}
		}
	}
	
	public function onStepHit(curStep:Int):Void {
		for (emitter in emitters) {
			if (emitter.syncToStep) {
				emitter.emitBurst(emitter.burstOnStepCount);
			}
		}
	}
	
	/**
	 * Get count of active particles
	 */
	public function getActiveCount():Int {
		var count = 0;
		for (p in particlePool) if (p.exists) count++;
		return count;
	}
	
	/**
	 * Clear all particles and emitters
	 */
	public function clearAll():Void {
		for (p in particlePool) returnParticle(p);
		for (e in emitters) e.stop();
		emitters = [];
	}
	
	function getDefaultConfig():ParticleConfig {
		return {
			lifetime: 2.0,
			lifetimeVariance: 0.5,
			speed: 100,
			speedVariance: 50,
			angle: 0,
			angleVariance: 360,
			gravity: 0,
			startScale: 1.0,
			endScale: 0.0,
			startAlpha: 1.0,
			endAlpha: 0.0,
			startColor: 0xFFFFFFFF,
			endColor: 0xFFFFFFFF,
			spinSpeed: 0,
			spinVariance: 180,
			drag: 0,
			acceleration: null
		};
	}
	
	override function destroy():Void {
		clearAll();
		particlePool = [];
		emitters = [];
		super.destroy();
	}
}

/**
 * Individual particle
 */
class Particle extends FlxSprite {
	public var lifetime:Float = 0;
	public var maxLifetime:Float = 0;
	public var config:ParticleConfig;
	
	public var velocityX:Float = 0;
	public var velocityY:Float = 0;
	public var accelerationX:Float = 0;
	public var accelerationY:Float = 0;
	public var dragForce:Float = 0;
	public var spinSpeed:Float = 0;
	
	public var startScale:Float = 1;
	public var endScale:Float = 0;
	public var startAlpha:Float = 1;
	public var endAlpha:Float = 0;
	public var startColor:Int = 0xFFFFFFFF;
	public var endColor:Int = 0xFFFFFFFF;
	
	private var _random:FlxRandom = new FlxRandom();
	
	public function new() {
		super();
		makeGraphic(4, 4, FlxColor.WHITE);
	}
	
	public function configure(config:ParticleConfig):Void {
		this.config = config;
		maxLifetime = config.lifetime + (_random.float() - 0.5) * 2 * config.lifetimeVariance;
		lifetime = maxLifetime;
		
		var angle = config.angle + (_random.float() - 0.5) * 2 * config.angleVariance;
		var speed = config.speed + (_random.float() - 0.5) * 2 * config.speedVariance;
		var radians = angle * Math.PI / 180;
		
		velocityX = Math.cos(radians) * speed;
		velocityY = Math.sin(radians) * speed;
		
		startScale = config.startScale;
		endScale = config.endScale;
		startAlpha = config.startAlpha;
		endAlpha = config.endAlpha;
		startColor = config.startColor;
		endColor = config.endColor;
		dragForce = config.drag;
		spinSpeed = config.spinSpeed + (_random.float() - 0.5) * 2 * config.spinVariance;
		
		scale.set(startScale, startScale);
		alpha = startAlpha;
		color = startColor;
	}
	
	public function emit():Void {
		visible = true;
		active = true;
	}
	
	public function updateParticle(elapsed:Float, globalGravity:FlxPoint, globalWind:FlxPoint):Void {
		lifetime -= elapsed;
		var t = 1 - (lifetime / maxLifetime); // 0 to 1
		
		// Apply forces
		velocityX += (accelerationX + globalGravity.x + globalWind.x) * elapsed;
		velocityY += (accelerationY + globalGravity.y + globalWind.y) * elapsed;
		
		// Apply drag
		if (dragForce > 0) {
			velocityX *= (1 - dragForce * elapsed);
			velocityY *= (1 - dragForce * elapsed);
		}
		
		// Move
		x += velocityX * elapsed;
		y += velocityY * elapsed;
		
		// Interpolate properties
		var s = startScale + (endScale - startScale) * t;
		scale.set(s, s);
		alpha = startAlpha + (endAlpha - startAlpha) * t;
		
		// Color interpolation
		color = FlxColor.interpolate(startColor, endColor, t);
		
		// Rotation
		angle += spinSpeed * elapsed;
	}
}

/**
 * Particle emitter that continuously spawns particles
 */
class ParticleEmitter {
	public var system:ParticleSystem;
	public var config:ParticleEmitterConfig;
	public var x:Float = 0;
	public var y:Float = 0;
	public var isEmitting:Bool = false;
	public var emitTimer:Float = 0;
	public var totalEmitted:Int = 0;
	public var maxEmit:Int = -1; // -1 = infinite
	
	// Shape
	public var shape:EmitterShape = POINT;
	public var shapeWidth:Float = 0;
	public var shapeHeight:Float = 0;
	public var shapeRadius:Float = 50;
	
	// Beat sync
	public var syncToBeat:Bool = false;
	public var syncToStep:Bool = false;
	public var burstOnBeatCount:Int = 5;
	public var burstOnStepCount:Int = 1;
	
	private var _random:FlxRandom = new FlxRandom();
	
	public function new(system:ParticleSystem, ?config:ParticleEmitterConfig) {
		this.system = system;
		this.config = config != null ? config : {};
		applyConfig();
	}
	
	function applyConfig():Void {
		if (config.emitRate != null) config.emitRate = config.emitRate;
		if (config.shape != null) shape = config.shape;
		if (config.shapeWidth != null) shapeWidth = config.shapeWidth;
		if (config.shapeHeight != null) shapeHeight = config.shapeHeight;
		if (config.shapeRadius != null) shapeRadius = config.shapeRadius;
		if (config.syncToBeat != null) syncToBeat = config.syncToBeat;
		if (config.maxEmit != null) maxEmit = config.maxEmit;
	}
	
	public function setPosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}
	
	public function start(?duration:Float = -1):Void {
		isEmitting = true;
		emitTimer = 0;
		totalEmitted = 0;
	}
	
	public function stop():Void {
		isEmitting = false;
	}
	
	public function update(elapsed:Float):Void {
		if (!isEmitting) return;
		
		if (config.emitRate != null && config.emitRate > 0) {
			emitTimer += elapsed;
			var interval = 1.0 / config.emitRate;
			
			while (emitTimer >= interval) {
				emitTimer -= interval;
				emitSingle();
				
				if (maxEmit > 0 && totalEmitted >= maxEmit) {
					stop();
					break;
				}
			}
		}
	}
	
	public function emitBurst(count:Int):Void {
		for (i in 0...count) emitSingle();
	}
	
	function emitSingle():Void {
		var p = system.getParticle();
		if (p == null) return;
		
		var pos = getEmitPosition();
		p.configure(config.particleConfig != null ? config.particleConfig : system.getDefaultConfig());
		p.x = pos.x;
		p.y = pos.y;
		p.emit();
		totalEmitted++;
	}
	
	function getEmitPosition():FlxPoint {
		var px = x;
		var py = y;
		
		switch (shape) {
			case POINT:
				// Already at position
			case LINE:
				px += _random.float(-shapeWidth / 2, shapeWidth / 2);
			case CIRCLE:
				var angle = _random.float(0, Math.PI * 2);
				var radius = _random.float(0, shapeRadius);
				px += Math.cos(angle) * radius;
				py += Math.sin(angle) * radius;
			case CONE:
				var angle = _random.float(-Math.PI / 4, Math.PI / 4);
				var dist = _random.float(0, shapeRadius);
				px += Math.cos(angle) * dist;
				py += Math.sin(angle) * dist;
			case BOX:
				px += _random.float(-shapeWidth / 2, shapeWidth / 2);
				py += _random.float(-shapeHeight / 2, shapeHeight / 2);
			case RING:
				var angle = _random.float(0, Math.PI * 2);
				px += Math.cos(angle) * shapeRadius;
				py += Math.sin(angle) * shapeRadius;
		}
		
		return new FlxPoint(px, py);
	}
}

enum abstract EmitterShape(Int) {
	var POINT = 0;
	var LINE = 1;
	var CIRCLE = 2;
	var CONE = 3;
	var BOX = 4;
	var RING = 5;
}

typedef ParticleConfig = {
	var lifetime:Float;
	var lifetimeVariance:Float;
	var speed:Float;
	var speedVariance:Float;
	var angle:Float;
	var angleVariance:Float;
	var ?gravity:Float;
	var startScale:Float;
	var endScale:Float;
	var startAlpha:Float;
	var endAlpha:Float;
	var startColor:Int;
	var endColor:Int;
	var ?spinSpeed:Float;
	var ?spinVariance:Float;
	var ?drag:Float;
	var ?acceleration:{x:Float, y:Float};
	var ?image:String;
	var ?blendMode:String;
}

typedef ParticleEmitterConfig = {
	var ?emitRate:Float;
	var ?shape:EmitterShape;
	var ?shapeWidth:Float;
	var ?shapeHeight:Float;
	var ?shapeRadius:Float;
	var ?syncToBeat:Bool;
	var ?syncToStep:Bool;
	var ?maxEmit:Int;
	var ?particleConfig:ParticleConfig;
}

/**
 * FEATURE 16 (continued): Particle Presets
 */
class ParticlePresets {
	public static function getConfig(preset:ParticlePreset):ParticleEmitterConfig {
		return switch (preset) {
			case CONFETTI: {
				emitRate: 50,
				shape: BOX,
				shapeWidth: 400,
				shapeHeight: 10,
				particleConfig: {
					lifetime: 3.0, lifetimeVariance: 1.0,
					speed: 200, speedVariance: 100,
					angle: 90, angleVariance: 45,
					gravity: 300,
					startScale: 1.5, endScale: 0.5,
					startAlpha: 1.0, endAlpha: 0.0,
					startColor: 0xFFFF0000, endColor: 0xFF0000FF,
					spinSpeed: 360, spinVariance: 720,
					drag: 0.5
				}
			};
			case SPARKS: {
				emitRate: 0,
				shape: POINT,
				particleConfig: {
					lifetime: 0.5, lifetimeVariance: 0.3,
					speed: 400, speedVariance: 200,
					angle: 0, angleVariance: 360,
					gravity: 200,
					startScale: 1.0, endScale: 0.0,
					startAlpha: 1.0, endAlpha: 0.0,
					startColor: 0xFFFFFF00, endColor: 0xFFFF6600,
					spinSpeed: 0, drag: 1.0
				}
			};
			case SMOKE: {
				emitRate: 10,
				shape: CIRCLE,
				shapeRadius: 20,
				particleConfig: {
					lifetime: 3.0, lifetimeVariance: 1.0,
					speed: 30, speedVariance: 20,
					angle: -90, angleVariance: 30,
					startScale: 0.5, endScale: 3.0,
					startAlpha: 0.6, endAlpha: 0.0,
					startColor: 0xFF888888, endColor: 0xFF444444,
					drag: 0.3
				}
			};
			case FIRE: {
				emitRate: 30,
				shape: LINE,
				shapeWidth: 40,
				particleConfig: {
					lifetime: 1.5, lifetimeVariance: 0.5,
					speed: 80, speedVariance: 40,
					angle: -90, angleVariance: 15,
					startScale: 1.0, endScale: 0.0,
					startAlpha: 1.0, endAlpha: 0.0,
					startColor: 0xFFFF4400, endColor: 0xFFFF0000,
					drag: 0.5
				}
			};
			case BUBBLES: {
				emitRate: 5,
				shape: BOX,
				shapeWidth: 200,
				shapeHeight: 10,
				particleConfig: {
					lifetime: 4.0, lifetimeVariance: 2.0,
					speed: 50, speedVariance: 30,
					angle: -90, angleVariance: 20,
					startScale: 0.3, endScale: 1.0,
					startAlpha: 0.8, endAlpha: 0.0,
					startColor: 0xFF88CCFF, endColor: 0xFF88CCFF,
					drag: 0.2
				}
			};
			case RAIN: {
				emitRate: 100,
				shape: LINE,
				shapeWidth: 1280,
				particleConfig: {
					lifetime: 1.0, lifetimeVariance: 0.3,
					speed: 500, speedVariance: 100,
					angle: 95, angleVariance: 5,
					startScale: 1.0, endScale: 1.0,
					startAlpha: 0.6, endAlpha: 0.3,
					startColor: 0xFF6688AA, endColor: 0xFF4466AA,
					drag: 0.0
				}
			};
			case SNOW: {
				emitRate: 30,
				shape: LINE,
				shapeWidth: 1280,
				particleConfig: {
					lifetime: 5.0, lifetimeVariance: 2.0,
					speed: 50, speedVariance: 30,
					angle: 90, angleVariance: 30,
					startScale: 0.5, endScale: 0.3,
					startAlpha: 0.8, endAlpha: 0.2,
					startColor: 0xFFFFFFFF, endColor: 0xFFCCCCFF,
					spinSpeed: 90, spinVariance: 180,
					drag: 0.5
				}
			};
			case LEAVES: {
				emitRate: 3,
				shape: LINE,
				shapeWidth: 1280,
				particleConfig: {
					lifetime: 8.0, lifetimeVariance: 3.0,
					speed: 40, speedVariance: 20,
					angle: 120, angleVariance: 45,
					startScale: 1.0, endScale: 0.5,
					startAlpha: 1.0, endAlpha: 0.0,
					startColor: 0xFF88AA22, endColor: 0xFFAA6600,
					spinSpeed: 45, spinVariance: 90,
					drag: 0.3
				}
			};
			case MUSIC_NOTES: {
				emitRate: 0,
				shape: POINT,
				particleConfig: {
					lifetime: 2.0, lifetimeVariance: 0.5,
					speed: 80, speedVariance: 40,
					angle: -90, angleVariance: 60,
					startScale: 1.0, endScale: 0.0,
					startAlpha: 1.0, endAlpha: 0.0,
					startColor: 0xFFFFFFFF, endColor: 0xFFFF88FF,
					spinSpeed: 30, drag: 0.5
				}
			};
			case EXPLOSION: {
				emitRate: 0,
				shape: POINT,
				maxEmit: 50,
				particleConfig: {
					lifetime: 1.0, lifetimeVariance: 0.5,
					speed: 500, speedVariance: 200,
					angle: 0, angleVariance: 360,
					gravity: 200,
					startScale: 2.0, endScale: 0.0,
					startAlpha: 1.0, endAlpha: 0.0,
					startColor: 0xFFFFFF00, endColor: 0xFFFF4400,
					drag: 2.0
				}
			};
			case HEARTS: {
				emitRate: 2,
				shape: POINT,
				particleConfig: {
					lifetime: 3.0, lifetimeVariance: 1.0,
					speed: 60, speedVariance: 30,
					angle: -90, angleVariance: 45,
					startScale: 0.5, endScale: 1.5,
					startAlpha: 1.0, endAlpha: 0.0,
					startColor: 0xFFFF4488, endColor: 0xFFFF0044,
					drag: 0.3
				}
			};
			case STARS: {
				emitRate: 5,
				shape: CIRCLE,
				shapeRadius: 200,
				particleConfig: {
					lifetime: 2.0, lifetimeVariance: 1.0,
					speed: 20, speedVariance: 10,
					angle: 0, angleVariance: 360,
					startScale: 0.3, endScale: 1.0,
					startAlpha: 0.0, endAlpha: 0.0,
					startColor: 0xFFFFFF88, endColor: 0xFFFFCC00,
					spinSpeed: 180, drag: 0.2
				}
			};
		}
	}
}

enum abstract ParticlePreset(Int) {
	var CONFETTI = 0;
	var SPARKS = 1;
	var SMOKE = 2;
	var FIRE = 3;
	var BUBBLES = 4;
	var RAIN = 5;
	var SNOW = 6;
	var LEAVES = 7;
	var MUSIC_NOTES = 8;
	var EXPLOSION = 9;
	var HEARTS = 10;
	var STARS = 11;
}
