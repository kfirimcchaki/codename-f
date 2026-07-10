// Particle System HScript - Global utility for spawning particles via events
// Add this to assets/data/scripts/ or reference from song scripts

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

public var particleGroups:Array<FlxTypedGroup<FlxSprite>> = [];

/**
 * Spawn a burst of particles at position
 * @param x X position
 * @param y Y position
 * @param count Number of particles
 * @param preset Preset name (confetti, sparks, smoke, fire, etc.)
 * @param color Optional color override
 */
public function spawnParticleBurst(x:Float, y:Float, count:Int, preset:String, ?color:Int) {
	var group = new FlxTypedGroup<FlxSprite>();
	add(group);
	particleGroups.push(group);

	for (i in 0...count) {
		var p = new FlxSprite(x, y);
		p.makeGraphic(4, 4, color != null ? color : getPresetColor(preset));
		p.antialiasing = true;

		var angle = FlxG.random.float(0, 360);
		var speed = getPresetSpeed(preset);
		var life = getPresetLifetime(preset);

		var rad = angle * Math.PI / 180;
		var vx = Math.cos(rad) * speed;
		var vy = Math.sin(rad) * speed;

		group.add(p);

		// Animate
		FlxTween.tween(p, {
			x: p.x + vx * life,
			y: p.y + vy * life + (getPresetGravity(preset) * life * life * 0.5),
			alpha: 0,
			angle: FlxG.random.float(-360, 360)
		}, life, {
			ease: FlxEase.quadOut,
			onComplete: function(t) {
				group.remove(p, true);
				p.destroy();
				if (group.countLiving() <= 0) {
					remove(group, true);
					group.destroy();
					particleGroups.remove(group);
				}
			}
		});

		// Scale down
		FlxTween.tween(p.scale, {x: 0, y: 0}, life, {ease: FlxEase.quadIn});
	}
}

/**
 * Spawn a continuous emitter (lasts for duration)
 */
public function spawnParticleEmitter(x:Float, y:Float, preset:String, duration:Float, rate:Float) {
	var elapsed:Float = 0;
	var interval:Float = 1.0 / rate;

	// Use onUpdate to emit particles over time
	var emitterActive = true;

	FlxG.sound.play(Paths.sound('editors/scrollMenu'), 0.001); // dummy to track time

	var timer = FlxTween.tween({}, {}, duration, {
		onUpdate: function(t) {
			if (!emitterActive) return;
			elapsed += FlxG.elapsed;
			while (elapsed >= interval) {
				elapsed -= interval;
				spawnParticleBurst(x, y, 1, preset);
			}
		},
		onComplete: function(t) {
			emitterActive = false;
		}
	});
}

function getPresetColor(preset:String):Int {
	return switch(preset) {
		case "confetti": FlxG.random.getObject([0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFFFF00, 0xFFFF00FF, 0xFF00FFFF]);
		case "sparks": 0xFFFFFF00;
		case "smoke": 0xFF888888;
		case "fire": 0xFFFF4400;
		case "bubbles": 0xFF88CCFF;
		case "rain": 0xFF6688AA;
		case "snow": 0xFFFFFFFF;
		case "leaves": 0xFF88AA22;
		case "music_notes": 0xFFFFFFFF;
		case "explosion": 0xFFFFFF00;
		case "hearts": 0xFFFF4488;
		case "stars": 0xFFFFFF88;
		default: 0xFFFFFFFF;
	};
}

function getPresetSpeed(preset:String):Float {
	return switch(preset) {
		case "confetti": FlxG.random.float(100, 300);
		case "sparks": FlxG.random.float(200, 500);
		case "smoke": FlxG.random.float(20, 60);
		case "fire": FlxG.random.float(40, 120);
		case "bubbles": FlxG.random.float(20, 80);
		case "rain": FlxG.random.float(400, 600);
		case "snow": FlxG.random.float(20, 70);
		case "leaves": FlxG.random.float(20, 60);
		case "explosion": FlxG.random.float(300, 700);
		case "hearts": FlxG.random.float(30, 90);
		case "stars": FlxG.random.float(10, 30);
		default: FlxG.random.float(50, 200);
	};
}

function getPresetLifetime(preset:String):Float {
	return switch(preset) {
		case "confetti": 3.0;
		case "sparks": 0.5;
		case "smoke": 3.0;
		case "fire": 1.5;
		case "bubbles": 4.0;
		case "rain": 1.0;
		case "snow": 5.0;
		case "leaves": 8.0;
		case "explosion": 1.0;
		case "hearts": 3.0;
		case "stars": 2.0;
		default: 2.0;
	};
}

function getPresetGravity(preset:String):Float {
	return switch(preset) {
		case "confetti": 300;
		case "sparks": 200;
		case "smoke": -50;
		case "fire": -100;
		case "bubbles": -30;
		case "rain": 0;
		case "snow": 0;
		case "leaves": 10;
		case "explosion": 200;
		case "hearts": -20;
		case "stars": 0;
		default: 0;
	};
}
