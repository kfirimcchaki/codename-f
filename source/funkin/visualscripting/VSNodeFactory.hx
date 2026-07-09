package funkin.visualscripting;

import funkin.visualscripting.nodes.*;

/**
 * FEATURE 71 (Factory): Creates VS nodes from serialized data or type name.
 */
class VSNodeFactory {
	public static var registeredNodes:Map<String, Class<VSNode>> = [];
	
	public static function init():Void {
		// Flow Control
		register("VSIfNode", VSIfNode);
		register("VSForLoopNode", VSForLoopNode);
		register("VSWhileLoopNode", VSWhileLoopNode);
		register("VSSwitchNode", VSSwitchNode);
		register("VSBreakNode", VSBreakNode);
		register("VSContinueNode", VSContinueNode);
		register("VSReturnNode", VSReturnNode);
		register("VSSequenceNode", VSSequenceNode);
		register("VSGateNode", VSGateNode);
		register("VSMultiGateNode", VSMultiGateNode);
		register("VSFlipFlopNode", VSFlipFlopNode);
		register("VSDelayNode", VSDelayNode);
		
		// Math
		register("VSMathNode", VSMathNode);
		register("VSCompareNode", VSCompareNode);
		register("VSRandomNode", VSRandomNode);
		register("VSMathFunctionNode", VSMathFunctionNode);
		register("VSLerpNode", VSLerpNode);
		register("VSMapRangeNode", VSMapRangeNode);
		register("VSModuloNode", VSModuloNode);
		register("VSNegateNode", VSNegateNode);
		register("VSAbsNode", VSAbsNode);
		register("VSClampNode", VSClampNode);
		
		// Variables
		register("VSGetVariableNode", VSGetVariableNode);
		register("VSSetVariableNode", VSSetVariableNode);
		register("VSConstantNode", VSConstantNode);
		register("VSGetPropertyNode", VSGetPropertyNode);
		register("VSSetPropertyNode", VSSetPropertyNode);
		register("VSArrayNode", VSArrayNode);
		register("VSArrayAccessNode", VSArrayAccessNode);
		register("VSArrayAddNode", VSArrayAddNode);
		register("VSArrayRemoveNode", VSArrayRemoveNode);
		
		// String
		register("VSStringConcatNode", VSStringConcatNode);
		register("VSStringSplitNode", VSStringSplitNode);
		register("VSStringLengthNode", VSStringLengthNode);
		register("VSStringContainsNode", VSStringContainsNode);
		register("VSStringReplaceNode", VSStringReplaceNode);
		register("VSStringFormatNode", VSStringFormatNode);
		
		// Functions
		register("VSFunctionDefNode", VSFunctionDefNode);
		register("VSCallFunctionNode", VSCallFunctionNode);
		
		// Events
		register("VSOnEventNode", VSOnEventNode);
		register("VSFireEventNode", VSFireEventNode);
		register("VSOnBeatNode", VSOnBeatNode);
		register("VSOnStepNode", VSOnStepNode);
		register("VSOnNoteHitNode", VSOnNoteHitNode);
		register("VSOnNoteMissNode", VSOnNoteMissNode);
		register("VSOnCountdownNode", VSOnCountdownNode);
		register("VSOnSongStartNode", VSOnSongStartNode);
		register("VSOnSongEndNode", VSOnSongEndNode);
		
		// Sprites
		register("VSSpawnSpriteNode", VSSpawnSpriteNode);
		register("VSGetSpriteNode", VSGetSpriteNode);
		register("VSSetSpritePropertyNode", VSSetSpritePropertyNode);
		register("VSPlayAnimationNode", VSPlayAnimationNode);
		register("VSRemoveSpriteNode", VSRemoveSpriteNode);
		register("VSSetSpriteAlphaNode", VSSetSpriteAlphaNode);
		register("VSSetSpriteScaleNode", VSSetSpriteScaleNode);
		register("VSSetSpritePositionNode", VSSetSpritePositionNode);
		register("VSSetSpriteAngleNode", VSSetSpriteAngleNode);
		register("VSSetSpriteColorNode", VSSetSpriteColorNode);
		register("VSSetScrollFactorNode", VSSetScrollFactorNode);
		
		// Audio
		register("VSPlaySoundNode", VSPlaySoundNode);
		register("VSPlayMusicNode", VSPlayMusicNode);
		register("VSStopSoundNode", VSStopSoundNode);
		register("VSSetVolumeNode", VSSetVolumeNode);
		register("VSSetPitchNode", VSSetPitchNode);
		register("VSFadeAudioNode", VSFadeAudioNode);
		register("VSPlayVocalNode", VSPlayVocalNode);
		
		// Camera
		register("VSCameraShakeNode", VSCameraShakeNode);
		register("VSCameraFlashNode", VSCameraFlashNode);
		register("VSCameraZoomNode", VSCameraZoomNode);
		register("VSCameraPanNode", VSCameraPanNode);
		register("VSCameraFollowNode", VSCameraFollowNode);
		register("VSCameraFadeNode", VSCameraFadeNode);
		
		// Tweens
		register("VSTweenNode", VSTweenNode);
		register("VSTweenPositionNode", VSTweenPositionNode);
		register("VSTweenAlphaNode", VSTweenAlphaNode);
		register("VSTweenScaleNode", VSTweenScaleNode);
		register("VSTweenAngleNode", VSTweenAngleNode);
		register("VSTweenColorNode", VSTweenColorNode);
		register("VSCancelTweenNode", VSCancelTweenNode);
		
		// Shaders
		register("VSApplyShaderNode", VSApplyShaderNode);
		register("VSSetShaderUniformNode", VSSetShaderUniformNode);
		register("VSRemoveShaderNode", VSRemoveShaderNode);
		
		// Particles
		register("VSSpawnParticlesNode", VSSpawnParticlesNode);
		
		// Utility
		register("VSLogNode", VSLogNode);
		register("VSCommentNode", VSCommentNode);
		register("VSRerouteNode", VSRerouteNode);
		register("VSGroupNode", VSGroupNode);
	}
	
	public static function register(name:String, cls:Class<VSNode>):Void {
		registeredNodes.set(name, cls);
	}
	
	public static function create(typeName:String):VSNode {
		var cls = registeredNodes.get(typeName);
		if (cls == null) {
			trace('VSNodeFactory: Unknown node type "$typeName"');
			return null;
		}
		return Type.createInstance(cls, []);
	}
	
	public static function createFromData(data:Dynamic):VSNode {
		var className = data.className;
		// Extract short name from full class path
		var shortName = className;
		if (className != null && className.indexOf(".") >= 0) {
			shortName = className.substr(className.lastIndexOf(".") + 1);
		}
		
		var node = create(shortName);
		if (node != null) {
			node.deserialize(data);
		}
		return node;
	}
	
	public static function getRegisteredCategories():Array<String> {
		var cats:Map<String, Bool> = [];
		for (name => cls in registeredNodes) {
			var node = Type.createInstance(cls, []);
			cats.set(node.category, true);
		}
		return [for (c in cats.keys()) c];
	}
	
	public static function getNodesInCategory(category:String):Array<{name:String, displayName:String, cls:Class<VSNode>}> {
		var result:Array<{name:String, displayName:String, cls:Class<VSNode>}> = [];
		for (name => cls in registeredNodes) {
			var node = Type.createInstance(cls, []);
			if (node.category == category) {
				result.push({name: name, displayName: node.displayName, cls: cls});
			}
		}
		result.sort((a, b) -> Reflect.compare(a.displayName, b.displayName));
		return result;
	}
}
