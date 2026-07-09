package funkin.backend.chart;

import funkin.backend.assets.Paths;
import haxe.Json;
import haxe.io.Path;
import hscript.Interp;
import hscript.Parser;
import openfl.Assets;

using StringTools;

class EventsData {
	public static var defaultEventsList:Array<String> = ["HScript Call", "Camera Movement", "Camera Position", "Add Camera Zoom", "Camera Bop", "Camera Zoom", "Camera Modulo Change", "Camera Flash", "BPM Change", "Continuous BPM Change", "Time Signature Change", "Scroll Speed Change", "Alt Animation Toggle", "Play Animation", "Screen Shake", "Color Flash", "Apply Shader", "Set Shader Uniform", "Spawn Particles", "Tween Property", "Set Visibility", "Swap Character", "Change Stage", "Change Note Skin", "HUD Layout", "Audio Effect", "Event Group", "Screen Effect", "Set Strumline Position", "Set Strumline Angle", "Lighting Event", "Play Sound Effect", "Screen Transition", "Character Glow", "Set Background Color", "Set Gameplay Modifier"];
	public static var defaultEventsParams:Map<String, Array<EventParamInfo>> = [
		"HScript Call" => [
			{name: "Function Name", type: TString, defValue: "myFunc"},
			{name: "Function Parameters (String split with commas)", type: TString, defValue: ""}
		],
		"Camera Movement" => [
			{name: "Camera Target", type: TStrumLine, defValue: 0},
			{name: "Tween Movement?", type: TBool, defValue: true, saveIfDefault: false},
			{name: "Tween Time (Steps, IF NOT CLASSIC)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4, saveIfDefault: false},
			{  // since its the most used event even by default, we'll set saveIfDefault false to avoid filling up with unnecessary parameters the files  - Nex
				name: "Tween Ease (ex: circ, quad, cube)",
				type: TDropDown(['CLASSIC', 'linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep']),
				defValue: "CLASSIC",
				saveIfDefault: false
			},
			{
				name: "Tween Type (excluded if CLASSIC or linear, ex: InOut)",
				type: TDropDown(['In', 'Out', 'InOut']),
				defValue: "In",
				saveIfDefault: false
			}
		],
		"Camera Position" => [
			{name: "X", type: TFloat(null, null, 10, 3), defValue: 0},
			{name: "Y", type: TFloat(null, null, 10, 3), defValue: 0},
			{name: "Tween Movement?", type: TBool, defValue: true, saveIfDefault: false},
			{name: "Tween Time (Steps, IF NOT CLASSIC)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4, saveIfDefault: false},
			{
				name: "Tween Ease (ex: circ, quad, cube)",
				type: TDropDown(['CLASSIC', 'linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep']),
				defValue: "CLASSIC",
				saveIfDefault: false
			},
			{
				name: "Tween Type (excluded if CLASSIC or linear, ex: InOut)",
				type: TDropDown(['In', 'Out', 'InOut']),
				defValue: "In",
				saveIfDefault: false
			},
			{name: "Is Offset?", type: TBool, defValue: false, saveIfDefault: false}
		],
		"Add Camera Zoom" => [
			{name: "Amount", type: TFloat(-10, 10, 0.01, 2), defValue: 0.05},
			{name: "Camera", type: TDropDown(['camGame', 'camHUD']), defValue: "camGame"}
		],
		"Camera Bop" => [
			{name: "Amount", type: TFloat(-10, 10, 0.1, 2), defValue: 0.1}
		],
		"Camera Zoom" => [
			{name: "Tween Zoom?", type: TBool, defValue: true},
			{name: "New Zoom", type: TFloat(-10, 10, 0.01, 2), defValue: 1},
			{name: "Camera", type: TDropDown(['camGame', 'camHUD']), defValue: "camGame"},
			{name: "Tween Time (Steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{
				name: "Tween Ease (ex: circ, quad, cube)",
				type: TDropDown(['linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep']),
				defValue: "linear"
			},
			{
				name: "Tween Type (excluded if linear, ex: InOut)",
				type: TDropDown(['In', 'Out', 'InOut']),
				defValue: "In"
			},
			{name: "Mode", type: TDropDown(['direct', 'stage']), defValue: "direct"},
			{name: "Multiplicative?", type: TBool, defValue: false}
		],
		"Camera Modulo Change" => [
			{name: "Modulo Interval", type: TInt(1, 9999999, 1), defValue: 4},
			{name: "Bump Strength", type: TFloat(0.1, 10, 0.01, 2), defValue: 1},
			{name: "Every Beat Type", type: TDropDown(['BEAT', 'MEASURE', 'STEP']), defValue: 'BEAT'},
			{name: "Beat Offset", type: TFloat(-10, 10, 0.25, 2), defValue: 0}
		],
		"Camera Flash" => [
			{name: "Reversed?", type: TBool, defValue: false},
			{name: "Color", type: TColorWheel, defValue: "#FFFFFF"},
			{name: "Time (Steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Camera", type: TDropDown(['camGame', 'camHUD']), defValue: "camHUD"}
		],
		"BPM Change" => [{name: "Target BPM", type: TFloat(1.00, 9999, 0.001, 3), defValue: 100}],
		"Continuous BPM Change" => [{name: "Target BPM", type: TFloat(1.00, 9999, 0.001, 3), defValue: 100}, {name: "Time (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}],
		"Time Signature Change" => [{name: "Target Numerator", type: TFloat(1), defValue: 4}, {name: "Target Denominator", type: TFloat(1), defValue: 4}, {name: "Denominator is Steps Per Beat", type: TBool, defValue: false}],
		"Scroll Speed Change" => [
			{name: "Tween Speed?", type: TBool, defValue: true},
			{name: "New Speed", type: TFloat(0.01, 99, 0.01, 2), defValue: 1.},
			{name: "Tween Time (Steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{
				name: "Tween Ease (ex: circ, quad, cube)",
				type: TDropDown(['linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep']),
				defValue: "linear"
			},
			{
				name: "Tween Type (excluded if linear, ex: InOut)",
				type: TDropDown(['In', 'Out', 'InOut']),
				defValue: "In"
			},
			{name: "Multiplicative?", type: TBool, defValue: false}
		],
		"Alt Animation Toggle" => [{name: "Enable On Sing Poses", type: TBool, defValue: true}, {name: "Enable On Idle", type: TBool, defValue: true}, {name: "Strumline", type: TStrumLine, defValue: 0}],
		"Play Animation" => [
			{name: "Character", type: TStrumLine, defValue: 0},
			{name: "Animation", type: TString, defValue: "animation"},
			{name: "Is forced?", type: TBool, defValue: true},
			{
				name: "Animation Context",
				type: TDropDown(["NONE", "SING", "DANCE", "MISS", "LOCK"]),
				defValue: "NONE"
			}
		],
		"Screen Shake" => [
			{name: "Camera", type: TDropDown(['camGame', 'camHUD', 'both']), defValue: "camGame"},
			{name: "Intensity", type: TFloat(0, 2, 0.01, 2), defValue: 0.05},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Intensity X", type: TFloat(0, 2, 0.01, 2), defValue: 0.05},
			{name: "Intensity Y", type: TFloat(0, 2, 0.01, 2), defValue: 0.05},
			{name: "Rotation Shake", type: TFloat(0, 360, 1, 0), defValue: 0}
		],
		"Color Flash" => [
			{name: "Color", type: TColorWheel, defValue: "#FFFFFF"},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Camera", type: TDropDown(['camGame', 'camHUD']), defValue: "camGame"},
			{name: "Blend Mode", type: TDropDown(['normal', 'add', 'multiply', 'screen']), defValue: "add"},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'cubicOut', 'expoOut']), defValue: "quadOut"}
		],
		"Apply Shader" => [
			{name: "Shader Path", type: TString, defValue: "engine/chromaticAberration"},
			{name: "Target", type: TDropDown(['camGame', 'camHUD', 'stage', 'boyfriend', 'dad', 'girlfriend']), defValue: "camGame"},
			{name: "Duration (steps, 0=permanent)", type: TFloat(0, 9999, 0.25, 2), defValue: 0},
			{name: "Transition Time (steps)", type: TFloat(0, 9999, 0.25, 2), defValue: 1}
		],
		"Set Shader Uniform" => [
			{name: "Shader Target", type: TDropDown(['camGame', 'camHUD', 'boyfriend', 'dad', 'girlfriend']), defValue: "camGame"},
			{name: "Uniform Name", type: TString, defValue: "u_time"},
			{name: "Value Type", type: TDropDown(['float', 'int', 'bool', 'vec2', 'vec3', 'vec4']), defValue: "float"},
			{name: "Value", type: TString, defValue: "0"},
			{name: "Tween to Value?", type: TBool, defValue: false},
			{name: "Tween Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}
		],
		"Spawn Particles" => [
			{name: "Preset", type: TDropDown(['confetti', 'sparks', 'smoke', 'fire', 'bubbles', 'rain', 'snow', 'leaves', 'music_notes', 'explosion', 'hearts', 'stars']), defValue: "sparks"},
			{name: "X Position", type: TFloat(-10000, 10000, 10, 0), defValue: 0},
			{name: "Y Position", type: TFloat(-10000, 10000, 10, 0), defValue: 0},
			{name: "Count", type: TInt(1, 1000, 1), defValue: 10},
			{name: "Duration (steps, 0=burst)", type: TFloat(0, 9999, 0.25, 2), defValue: 0},
			{name: "Emitter Shape", type: TDropDown(['point', 'line', 'circle', 'cone', 'box', 'ring']), defValue: "point"}
		],
		"Tween Property" => [
			{name: "Target", type: TString, defValue: "boyfriend"},
			{name: "Property", type: TString, defValue: "x"},
			{name: "Value", type: TFloat(-99999, 99999, 1, 2), defValue: 0},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine']), defValue: "quad"},
			{name: "Type", type: TDropDown(['In', 'Out', 'InOut']), defValue: "Out"},
			{name: "Is Offset?", type: TBool, defValue: false}
		],
		"Set Visibility" => [
			{name: "Target", type: TString, defValue: "boyfriend"},
			{name: "Property", type: TDropDown(['visible', 'alpha', 'both']), defValue: "both"},
			{name: "Value", type: TFloat(0, 1, 0.01, 2), defValue: 1},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'cubicOut', 'expoOut']), defValue: "linear"}
		],
		"Swap Character" => [
			{name: "Position", type: TDropDown(['boyfriend', 'dad', 'girlfriend']), defValue: "boyfriend"},
			{name: "New Character", type: TCharacter, defValue: "bf"},
			{name: "Transition", type: TDropDown(['instant', 'fade', 'slide', 'flash']), defValue: "instant"},
			{name: "Transition Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 2}
		],
		"Change Stage" => [
			{name: "New Stage", type: TStage, defValue: "stage"},
			{name: "Transition", type: TDropDown(['instant', 'fade', 'slide', 'zoom', 'wipe']), defValue: "fade"},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Transition Color", type: TColorWheel, defValue: "#000000"},
			{name: "Keep Characters", type: TBool, defValue: false}
		],
		"Change Note Skin" => [
			{name: "Note Skin", type: TString, defValue: "NOTE_assets"},
			{name: "Strum Line", type: TStrumLine, defValue: -1},
			{name: "Transition", type: TDropDown(['instant', 'fade', 'pop']), defValue: "instant"},
			{name: "Also Change Splashes", type: TBool, defValue: true}
		],
		"HUD Layout" => [
			{name: "Action", type: TDropDown(['move', 'scale', 'rotate', 'fade', 'show', 'hide']), defValue: "move"},
			{name: "Element", type: TDropDown(['healthbar', 'score', 'timebar', 'combo', 'all']), defValue: "healthbar"},
			{name: "X", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Y", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'cubicOut', 'backOut']), defValue: "quadOut"}
		],
		"Audio Effect" => [
			{name: "Effect", type: TDropDown(['volume', 'pitch', 'pan', 'lowpass', 'highpass', 'reverb', 'distortion', 'mute_track']), defValue: "volume"},
			{name: "Target", type: TDropDown(['inst', 'player_vocals', 'opponent_vocals', 'all']), defValue: "all"},
			{name: "Value", type: TFloat(-10, 10, 0.01, 2), defValue: 1},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'sineOut']), defValue: "linear"}
		],
		"Event Group" => [
			{name: "Group Name", type: TString, defValue: "myGroup"},
			{name: "Repeat Count", type: TInt(1, 100, 1), defValue: 1},
			{name: "Repeat Interval (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Loop?", type: TBool, defValue: false},
			{name: "Reverse on Repeat?", type: TBool, defValue: false}
		],
		"Screen Effect" => [
			{name: "Effect", type: TDropDown(['chromatic_aberration', 'vignette', 'blur', 'pixelate', 'glitch', 'scanlines', 'film_grain', 'bloom', 'crt']), defValue: "blur"},
			{name: "Intensity", type: TFloat(0, 10, 0.01, 2), defValue: 1},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Camera", type: TDropDown(['camGame', 'camHUD', 'both']), defValue: "camGame"}
		],
		"Set Strumline Position" => [
			{name: "Strumline", type: TStrumLine, defValue: 0},
			{name: "X", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Y", type: TFloat(-9999, 9999, 10, 0), defValue: 50},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'backOut', 'elasticOut']), defValue: "quadOut"}
		],
		"Set Strumline Angle" => [
			{name: "Strumline", type: TStrumLine, defValue: 0},
			{name: "Angle", type: TFloat(-360, 360, 1, 0), defValue: 0},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}
		],
		"Lighting Event" => [
			{name: "Action", type: TDropDown(['set_ambient', 'set_directional', 'add_point_light', 'spotlight', 'remove_light']), defValue: "add_point_light"},
			{name: "Color", type: TColorWheel, defValue: "#FFFFFF"},
			{name: "Intensity", type: TFloat(0, 10, 0.1, 2), defValue: 1},
			{name: "X", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Y", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Radius", type: TFloat(0, 10000, 10, 0), defValue: 500},
			{name: "Duration (steps)", type: TFloat(0, 9999, 0.25, 2), defValue: 0}
		],
		"Play Sound Effect" => [
			{name: "Sound Path", type: TString, defValue: "sounds/example"},
			{name: "Volume", type: TFloat(0, 2, 0.05, 2), defValue: 1},
			{name: "Pan", type: TFloat(-1, 1, 0.05, 2), defValue: 0},
			{name: "Pitch", type: TFloat(0.1, 5, 0.05, 2), defValue: 1}
		],
		"Screen Transition" => [
			{name: "Type", type: TDropDown(['fade', 'slide_left', 'slide_right', 'slide_up', 'slide_down', 'wipe', 'circle', 'pixelate']), defValue: "fade"},
			{name: "Direction", type: TDropDown(['in', 'out']), defValue: "out"},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Color", type: TColorWheel, defValue: "#000000"},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'cubicOut']), defValue: "linear"}
		],
		"Character Glow" => [
			{name: "Character", type: TStrumLine, defValue: 0},
			{name: "Color", type: TColorWheel, defValue: "#FFFFFF"},
			{name: "Intensity", type: TFloat(0, 5, 0.1, 2), defValue: 1},
			{name: "Duration (steps)", type: TFloat(0, 9999, 0.25, 2), defValue: 4},
			{name: "Fade In (steps)", type: TFloat(0, 9999, 0.25, 2), defValue: 1}
		],
		"Set Background Color" => [
			{name: "Color", type: TColorWheel, defValue: "#000000"},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Target", type: TDropDown(['camGame', 'camHUD']), defValue: "camGame"}
		],
		"Set Gameplay Modifier" => [
			{name: "Modifier ID", type: TString, defValue: "drunk"},
			{name: "Value", type: TFloat(-9999, 9999, 0.01, 2), defValue: 1},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}
		],
	];

	public static var eventsList:Array<String> = defaultEventsList.copy();
	public static var eventsParams:Map<String, Array<EventParamInfo>> = defaultEventsParams.copy();

	public static function getEventParams(name:String):Array<EventParamInfo> {
		return eventsParams.exists(name) ? eventsParams.get(name) : [];
	}

	public static function reloadEvents() {
		eventsList = defaultEventsList.copy();
		eventsParams = defaultEventsParams.copy();

		var hscriptInterp:Interp = new Interp();
		hscriptInterp.variables.set("Bool", TBool);
		hscriptInterp.variables.set("Int", function (?min:Int, ?max:Int, ?step:Float):EventParamType {return TInt(min, max, step);});
		hscriptInterp.variables.set("Float", function (?min:Float, ?max:Float, ?step:Float, ?precision:Int):EventParamType {return TFloat(min, max, step, precision);});
		hscriptInterp.variables.set("String", TString);
		hscriptInterp.variables.set("StrumLine", TStrumLine);
		hscriptInterp.variables.set("ColorWheel", TColorWheel);
		hscriptInterp.variables.set("DropDown", Reflect.makeVarArgs(function(args:Array<Dynamic>):EventParamType {
			var flatArgs = CoolUtil.deepFlatten(args);
			if(flatArgs.length == 0) return TDropDown(["null"]);
			return TDropDown([for (arg in flatArgs) Std.string(arg)]);
		}));
		hscriptInterp.variables.set("Character", TCharacter);
		hscriptInterp.variables.set("Stage", TStage);

		var hscriptParser:Parser = new Parser();
		hscriptParser.allowJSON = hscriptParser.allowMetadata = false;

		for (file in Paths.getFolderContent('data/events/', true, BOTH)) {
			var ext = Path.extension(file);
			if (ext != "json" && ext != "pack") continue;
			var eventName:String = CoolUtil.getFilename(file);
			var fileTxt:String = Assets.getText(file);

			if (ext == "pack") {
				var arr = fileTxt.split("________PACKSEP________");
				eventName = Path.withoutExtension(arr[0]);
				fileTxt = arr[2];
			}

			if (fileTxt.trim() == "") continue;

			if (!eventsList.contains(eventName)) {
				eventsList.push(eventName);
				eventsParams.set(eventName, []);
			}

			try {
				var data:EventInfoFile = cast Json.parse(fileTxt);
				if (data == null || data.params == null) continue;

				var finalParams:Array<EventParamInfo> = [];
				for (paramData in data.params) {
					try {
						finalParams.push({
							name: paramData.name,
							type: hscriptInterp.expr(hscriptParser.parseString(paramData.type)),
							defValue: paramData.defaultValue,
							saveIfDefault: paramData.saveIfDefault
						});
					} catch (e) {trace('Error parsing event param ${paramData.name} - ${eventName}: $e'); finalParams.push(null);}
				}
				eventsParams.set(eventName, finalParams);
			} catch (e) {trace('Error parsing file $file: $e');}
		}

		hscriptInterp = null; hscriptParser = null;
	}
}

typedef EventInfoFile = {
	var params:Array<{
		var name:String;
		var type:String;
		var defaultValue:Dynamic;
		var ?saveIfDefault:Bool;
	}>;
}

typedef EventInfo = {
	var params:Array<EventParamInfo>;
}

typedef EventParamInfo = {
	var name:String;
	var type:EventParamType;
	var defValue:Dynamic;
	var ?saveIfDefault:Bool;
}

enum EventParamType {
	TBool;
	TInt(?min:Int, ?max:Int, ?step:Float);
	TFloat(?min:Float, ?max:Float, ?step:Float, ?precision:Int);
	TString;
	TStrumLine;
	TColorWheel;
	TDropDown(?options:Array<String>);
	TCharacter;
	TStage;
}
