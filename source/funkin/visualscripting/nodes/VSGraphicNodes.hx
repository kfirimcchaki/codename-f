package funkin.visualscripting.nodes;

import funkin.visualscripting.VSExecutionContext;

// ====================== SPRITE NODES ======================

class VSSpawnSpriteNode extends VSNode {
	public function new() {
		super();
		displayName = "Spawn Sprite";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("imagePath", "Image Path", STRING, "images/example");
		addInputPort("x", "X", FLOAT, 0);
		addInputPort("y", "Y", FLOAT, 0);
		addInputPort("name", "Name", STRING, "mySprite");
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("sprite", "Sprite", SPRITE);
	}
	
	override function execute(context:VSExecutionContext):String {
		// Runtime: create sprite and add to state
		var name:String = cast getInputValue("name", context);
		context.setVariable(name, {
			_type: "sprite",
			imagePath: getInputValue("imagePath", context),
			x: getInputValue("x", context),
			y: getInputValue("y", context)
		});
		outputValues.set("sprite", context.getVariable(name));
		return "exec_out";
	}
}

class VSGetSpriteNode extends VSNode {
	public function new() {
		super();
		displayName = "Get Sprite";
		category = "Sprites";
		color = 0xFF008B8B;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("name", "Name", STRING, "mySprite");
		addOutputPort("sprite", "Sprite", SPRITE);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var name:String = cast getInputValue("name", context);
		outputValues.set("sprite", context.getVariable(name));
	}
}

class VSSetSpritePropertyNode extends VSNode {
	public var property:String = "x";
	
	public function new() {
		super();
		displayName = "Set Sprite Prop";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("value", "Value", ANY, null);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var sprite = getInputValue("sprite", context);
		var value = getInputValue("value", context);
		if (sprite != null) Reflect.setProperty(sprite, property, value);
		return "exec_out";
	}
}

class VSPlayAnimationNode extends VSNode {
	public function new() {
		super();
		displayName = "Play Animation";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("animName", "Animation", STRING, "idle");
		addInputPort("force", "Force", BOOL, false);
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var sprite = getInputValue("sprite", context);
		var animName:String = cast getInputValue("animName", context);
		var force:Bool = getInputValue("force", context) == true;
		if (sprite != null) {
			var anim = Reflect.getProperty(sprite, "animation");
			if (anim != null) {
				Reflect.callMethod(anim, Reflect.field(anim, "play"), [animName, force]);
			}
		}
		return "exec_out";
	}
}

class VSRemoveSpriteNode extends VSNode {
	public function new() {
		super();
		displayName = "Remove Sprite";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		return "exec_out";
	}
}

class VSSetSpriteAlphaNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Alpha";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("alpha", "Alpha", FLOAT, 1);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var sprite = getInputValue("sprite", context);
		if (sprite != null) Reflect.setProperty(sprite, "alpha", getInputValue("alpha", context));
		return "exec_out";
	}
}

class VSSetSpriteScaleNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Scale";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("scaleX", "Scale X", FLOAT, 1);
		addInputPort("scaleY", "Scale Y", FLOAT, 1);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var sprite = getInputValue("sprite", context);
		if (sprite != null) {
			var scale = Reflect.getProperty(sprite, "scale");
			if (scale != null) {
				Reflect.setProperty(scale, "x", getInputValue("scaleX", context));
				Reflect.setProperty(scale, "y", getInputValue("scaleY", context));
			}
		}
		return "exec_out";
	}
}

class VSSetSpritePositionNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Position";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("x", "X", FLOAT, 0);
		addInputPort("y", "Y", FLOAT, 0);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var sprite = getInputValue("sprite", context);
		if (sprite != null) {
			Reflect.setProperty(sprite, "x", getInputValue("x", context));
			Reflect.setProperty(sprite, "y", getInputValue("y", context));
		}
		return "exec_out";
	}
}

class VSSetSpriteAngleNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Angle";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("angle", "Angle", FLOAT, 0);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var sprite = getInputValue("sprite", context);
		if (sprite != null) Reflect.setProperty(sprite, "angle", getInputValue("angle", context));
		return "exec_out";
	}
}

class VSSetSpriteColorNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Color";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("color", "Color", COLOR, 0xFFFFFFFF);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var sprite = getInputValue("sprite", context);
		if (sprite != null) Reflect.setProperty(sprite, "color", getInputValue("color", context));
		return "exec_out";
	}
}

class VSSetScrollFactorNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Scroll Factor";
		category = "Sprites";
		color = 0xFF008B8B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("scrollX", "Scroll X", FLOAT, 1);
		addInputPort("scrollY", "Scroll Y", FLOAT, 1);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var sprite = getInputValue("sprite", context);
		if (sprite != null) {
			var sf = Reflect.getProperty(sprite, "scrollFactor");
			if (sf != null) {
				Reflect.setProperty(sf, "x", getInputValue("scrollX", context));
				Reflect.setProperty(sf, "y", getInputValue("scrollY", context));
			}
		}
		return "exec_out";
	}
}

// ====================== AUDIO NODES ======================

class VSPlaySoundNode extends VSNode {
	public function new() {
		super();
		displayName = "Play Sound";
		category = "Audio";
		color = 0xFF8B8B00;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("path", "Sound Path", STRING, "sounds/example");
		addInputPort("volume", "Volume", FLOAT, 1.0);
		addInputPort("looped", "Looped", BOOL, false);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		return "exec_out";
	}
}

class VSPlayMusicNode extends VSNode {
	public function new() {
		super();
		displayName = "Play Music";
		category = "Audio";
		color = 0xFF8B8B00;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("path", "Music Path", STRING, "music/example");
		addInputPort("volume", "Volume", FLOAT, 1.0);
		addInputPort("looped", "Looped", BOOL, true);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		return "exec_out";
	}
}

class VSStopSoundNode extends VSNode {
	public function new() {
		super();
		displayName = "Stop Sound";
		category = "Audio";
		color = 0xFF8B8B00;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sound", "Sound", SOUND, null);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSSetVolumeNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Volume";
		category = "Audio";
		color = 0xFF8B8B00;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sound", "Sound", SOUND, null);
		addInputPort("volume", "Volume", FLOAT, 1.0);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSSetPitchNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Pitch";
		category = "Audio";
		color = 0xFF8B8B00;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sound", "Sound", SOUND, null);
		addInputPort("pitch", "Pitch", FLOAT, 1.0);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSFadeAudioNode extends VSNode {
	public function new() {
		super();
		displayName = "Fade Audio";
		category = "Audio";
		color = 0xFF8B8B00;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sound", "Sound", SOUND, null);
		addInputPort("fromVol", "From Volume", FLOAT, 1.0);
		addInputPort("toVol", "To Volume", FLOAT, 0.0);
		addInputPort("duration", "Duration", FLOAT, 1.0);
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSPlayVocalNode extends VSNode {
	public function new() {
		super();
		displayName = "Play Vocal";
		category = "Audio";
		color = 0xFF8B8B00;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("character", "Character", STRING, "bf");
		addInputPort("path", "Path", STRING, "");
		addInputPort("volume", "Volume", FLOAT, 1.0);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

// ====================== CAMERA NODES ======================

class VSCameraShakeNode extends VSNode {
	public function new() {
		super();
		displayName = "Camera Shake";
		category = "Camera";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("intensity", "Intensity", FLOAT, 0.05);
		addInputPort("duration", "Duration", FLOAT, 0.5);
		addInputPort("camera", "Camera", STRING, "camGame");
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSCameraFlashNode extends VSNode {
	public function new() {
		super();
		displayName = "Camera Flash";
		category = "Camera";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("color", "Color", COLOR, 0xFFFFFFFF);
		addInputPort("duration", "Duration", FLOAT, 0.5);
		addInputPort("camera", "Camera", STRING, "camHUD");
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSCameraZoomNode extends VSNode {
	public function new() {
		super();
		displayName = "Camera Zoom";
		category = "Camera";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("zoom", "Zoom", FLOAT, 1.0);
		addInputPort("duration", "Duration", FLOAT, 0.5);
		addInputPort("ease", "Ease", STRING, "linear");
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSCameraPanNode extends VSNode {
	public function new() {
		super();
		displayName = "Camera Pan";
		category = "Camera";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("x", "X", FLOAT, 0);
		addInputPort("y", "Y", FLOAT, 0);
		addInputPort("duration", "Duration", FLOAT, 1);
		addInputPort("ease", "Ease", STRING, "linear");
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSCameraFollowNode extends VSNode {
	public function new() {
		super();
		displayName = "Camera Follow";
		category = "Camera";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("target", "Target", SPRITE, null);
		addInputPort("lerp", "Lerp", FLOAT, 0.05);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSCameraFadeNode extends VSNode {
	public function new() {
		super();
		displayName = "Camera Fade";
		category = "Camera";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("color", "Color", COLOR, 0xFF000000);
		addInputPort("duration", "Duration", FLOAT, 1);
		addInputPort("fadeIn", "Fade In", BOOL, false);
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

// ====================== TWEEN NODES ======================

class VSTweenNode extends VSNode {
	public function new() {
		super();
		displayName = "Tween";
		category = "Tweens";
		color = 0xFF644400;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("target", "Target", OBJECT, null);
		addInputPort("properties", "Properties", OBJECT, null);
		addInputPort("duration", "Duration", FLOAT, 1.0);
		addInputPort("ease", "Ease", STRING, "linear");
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
		addOutputPort("tween", "Tween", OBJECT);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSTweenPositionNode extends VSNode {
	public function new() {
		super();
		displayName = "Tween Position";
		category = "Tweens";
		color = 0xFF644400;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("x", "X", FLOAT, 0);
		addInputPort("y", "Y", FLOAT, 0);
		addInputPort("duration", "Duration", FLOAT, 1.0);
		addInputPort("ease", "Ease", STRING, "quadOut");
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSTweenAlphaNode extends VSNode {
	public function new() {
		super();
		displayName = "Tween Alpha";
		category = "Tweens";
		color = 0xFF644400;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("alpha", "Alpha", FLOAT, 1);
		addInputPort("duration", "Duration", FLOAT, 1.0);
		addInputPort("ease", "Ease", STRING, "quadOut");
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSTweenScaleNode extends VSNode {
	public function new() {
		super();
		displayName = "Tween Scale";
		category = "Tweens";
		color = 0xFF644400;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("scaleX", "Scale X", FLOAT, 1);
		addInputPort("scaleY", "Scale Y", FLOAT, 1);
		addInputPort("duration", "Duration", FLOAT, 1.0);
		addInputPort("ease", "Ease", STRING, "quadOut");
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSTweenAngleNode extends VSNode {
	public function new() {
		super();
		displayName = "Tween Angle";
		category = "Tweens";
		color = 0xFF644400;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("angle", "Angle", FLOAT, 0);
		addInputPort("duration", "Duration", FLOAT, 1.0);
		addInputPort("ease", "Ease", STRING, "quadOut");
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSTweenColorNode extends VSNode {
	public function new() {
		super();
		displayName = "Tween Color";
		category = "Tweens";
		color = 0xFF644400;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("sprite", "Sprite", SPRITE, null);
		addInputPort("fromColor", "From Color", COLOR, 0xFFFFFFFF);
		addInputPort("toColor", "To Color", COLOR, 0xFFFFFFFF);
		addInputPort("duration", "Duration", FLOAT, 1.0);
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("exec_finished", "Finished", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSCancelTweenNode extends VSNode {
	public function new() {
		super();
		displayName = "Cancel Tween";
		category = "Tweens";
		color = 0xFF644400;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("tween", "Tween", OBJECT, null);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

// ====================== SHADER NODES ======================

class VSApplyShaderNode extends VSNode {
	public function new() {
		super();
		displayName = "Apply Shader";
		category = "Shaders";
		color = 0xFF8B008B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("target", "Target", SPRITE, null);
		addInputPort("shaderPath", "Shader Path", STRING, "shaders/example");
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSSetShaderUniformNode extends VSNode {
	public function new() {
		super();
		displayName = "Set Uniform";
		category = "Shaders";
		color = 0xFF8B008B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("shader", "Shader", OBJECT, null);
		addInputPort("uniformName", "Uniform Name", STRING, "u_time");
		addInputPort("value", "Value", ANY, 0);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

class VSRemoveShaderNode extends VSNode {
	public function new() {
		super();
		displayName = "Remove Shader";
		category = "Shaders";
		color = 0xFF8B008B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("target", "Target", SPRITE, null);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}

// ====================== PARTICLE NODES ======================

class VSSpawnParticlesNode extends VSNode {
	public function new() {
		super();
		displayName = "Spawn Particles";
		category = "Particles";
		color = 0xFF008B00;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("x", "X", FLOAT, 0);
		addInputPort("y", "Y", FLOAT, 0);
		addInputPort("count", "Count", INT, 10);
		addInputPort("image", "Image", STRING, "");
		addInputPort("lifetime", "Lifetime", FLOAT, 2.0);
		addInputPort("speed", "Speed", FLOAT, 100);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String { return "exec_out"; }
}
