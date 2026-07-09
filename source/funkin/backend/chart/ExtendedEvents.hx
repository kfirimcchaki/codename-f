package funkin.backend.chart;

/**
 * FEATURES 79-90: Extended Chart Events
 * 
 * Additional built-in chart events that extend the engine's capabilities.
 * These are registered with the existing EventsData system.
 */
class ExtendedEvents {
	/**
	 * Register all extended events with EventsData
	 */
	public static function register():Void {
		// ===== FEATURE 79: Screen Shake Event =====
		EventsData.eventsList.push("Screen Shake");
		EventsData.eventsParams.set("Screen Shake", [
			{name: "Camera", type: TDropDown(['camGame', 'camHUD', 'both']), defValue: "camGame"},
			{name: "Intensity", type: TFloat(0, 2, 0.01, 2), defValue: 0.05},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Intensity X", type: TFloat(0, 2, 0.01, 2), defValue: 0.05},
			{name: "Intensity Y", type: TFloat(0, 2, 0.01, 2), defValue: 0.05},
			{name: "Rotation Shake", type: TFloat(0, 360, 1, 0), defValue: 0}
		]);
		
		// ===== FEATURE 80: Color Flash Event =====
		EventsData.eventsList.push("Color Flash");
		EventsData.eventsParams.set("Color Flash", [
			{name: "Color", type: TColorWheel, defValue: "#FFFFFF"},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Camera", type: TDropDown(['camGame', 'camHUD']), defValue: "camGame"},
			{name: "Blend Mode", type: TDropDown(['normal', 'add', 'multiply', 'screen']), defValue: "add"},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'cubicOut', 'expoOut']), defValue: "quadOut"}
		]);
		
		// ===== FEATURE 81: Shader Apply Event =====
		EventsData.eventsList.push("Apply Shader");
		EventsData.eventsParams.set("Apply Shader", [
			{name: "Shader Path", type: TString, defValue: "shaders/example"},
			{name: "Target", type: TDropDown(['camGame', 'camHUD', 'stage', 'boyfriend', 'dad', 'girlfriend']), defValue: "camGame"},
			{name: "Duration (steps, 0=permanent)", type: TFloat(0, 9999, 0.25, 2), defValue: 0},
			{name: "Transition Time (steps)", type: TFloat(0, 9999, 0.25, 2), defValue: 1}
		]);
		
		// ===== FEATURE 81b: Set Shader Uniform Event =====
		EventsData.eventsList.push("Set Shader Uniform");
		EventsData.eventsParams.set("Set Shader Uniform", [
			{name: "Shader Target", type: TDropDown(['camGame', 'camHUD', 'stage', 'boyfriend', 'dad', 'girlfriend']), defValue: "camGame"},
			{name: "Uniform Name", type: TString, defValue: "u_time"},
			{name: "Value Type", type: TDropDown(['float', 'int', 'bool', 'vec2', 'vec3', 'vec4']), defValue: "float"},
			{name: "Value", type: TString, defValue: "0"},
			{name: "Tween to Value?", type: TBool, defValue: false},
			{name: "Tween Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}
		]);
		
		// ===== FEATURE 82: Particle Spawn Event =====
		EventsData.eventsList.push("Spawn Particles");
		EventsData.eventsParams.set("Spawn Particles", [
			{name: "Preset", type: TDropDown(['confetti', 'sparks', 'smoke', 'fire', 'bubbles', 'rain', 'snow', 'leaves', 'music_notes', 'explosion', 'hearts', 'stars', 'custom']), defValue: "sparks"},
			{name: "X Position", type: TFloat(-10000, 10000, 10, 0), defValue: 0},
			{name: "Y Position", type: TFloat(-10000, 10000, 10, 0), defValue: 0},
			{name: "Count", type: TInt(1, 1000, 1), defValue: 10},
			{name: "Duration (steps, 0=burst)", type: TFloat(0, 9999, 0.25, 2), defValue: 0},
			{name: "Emitter Shape", type: TDropDown(['point', 'line', 'circle', 'cone', 'box', 'ring']), defValue: "point"}
		]);
		
		// ===== FEATURE 83: Tween Property Event =====
		EventsData.eventsList.push("Tween Property");
		EventsData.eventsParams.set("Tween Property", [
			{name: "Target", type: TString, defValue: "boyfriend"},
			{name: "Property", type: TString, defValue: "x"},
			{name: "Value", type: TFloat(-99999, 99999, 1, 2), defValue: 0},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'back', 'bounce', 'circ', 'cube', 'elastic', 'expo', 'quad', 'quart', 'quint', 'sine', 'smoothStep', 'smootherStep']), defValue: "quadOut"},
			{name: "Type", type: TDropDown(['In', 'Out', 'InOut']), defValue: "Out"},
			{name: "Is Offset?", type: TBool, defValue: false}
		]);
		
		// ===== FEATURE 84: Sprite Visibility Event =====
		EventsData.eventsList.push("Set Visibility");
		EventsData.eventsParams.set("Set Visibility", [
			{name: "Target", type: TString, defValue: "stage"},
			{name: "Property", type: TDropDown(['visible', 'alpha', 'both']), defValue: "both"},
			{name: "Value", type: TFloat(0, 1, 0.01, 2), defValue: 1},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'cubicOut', 'expoOut']), defValue: "linear"}
		]);
		
		// ===== FEATURE 85: Character Swap Event =====
		EventsData.eventsList.push("Swap Character");
		EventsData.eventsParams.set("Swap Character", [
			{name: "Position", type: TDropDown(['boyfriend', 'dad', 'girlfriend', 'custom']), defValue: "boyfriend"},
			{name: "New Character", type: TCharacter, defValue: "bf"},
			{name: "Transition", type: TDropDown(['instant', 'fade', 'slide', 'flash']), defValue: "instant"},
			{name: "Transition Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 2}
		]);
		
		// ===== FEATURE 86: Stage Transition Event =====
		EventsData.eventsList.push("Change Stage");
		EventsData.eventsParams.set("Change Stage", [
			{name: "New Stage", type: TStage, defValue: "stage"},
			{name: "Transition", type: TDropDown(['instant', 'fade', 'slide', 'zoom', 'wipe']), defValue: "fade"},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Transition Color", type: TColorWheel, defValue: "#000000"},
			{name: "Keep Characters", type: TBool, defValue: false}
		]);
		
		// ===== FEATURE 87: Note Skin Change Event =====
		EventsData.eventsList.push("Change Note Skin");
		EventsData.eventsParams.set("Change Note Skin", [
			{name: "Note Skin", type: TString, defValue: "NOTE_assets"},
			{name: "Strum Line", type: TStrumLine, defValue: -1},
			{name: "Transition", type: TDropDown(['instant', 'fade', 'pop']), defValue: "instant"},
			{name: "Also Change Splashes", type: TBool, defValue: true}
		]);
		
		// ===== FEATURE 88: HUD Layout Event =====
		EventsData.eventsList.push("HUD Layout");
		EventsData.eventsParams.set("HUD Layout", [
			{name: "Action", type: TDropDown(['move', 'scale', 'rotate', 'fade', 'show', 'hide']), defValue: "move"},
			{name: "Element", type: TDropDown(['healthbar', 'score', 'timebar', 'combo', 'all', 'custom']), defValue: "healthbar"},
			{name: "X", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Y", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'cubicOut', 'backOut']), defValue: "quadOut"}
		]);
		
		// ===== FEATURE 89: Audio Effect Event =====
		EventsData.eventsList.push("Audio Effect");
		EventsData.eventsParams.set("Audio Effect", [
			{name: "Effect", type: TDropDown(['volume', 'pitch', 'pan', 'lowpass', 'highpass', 'reverb', 'distortion', 'mute_track']), defValue: "volume"},
			{name: "Target", type: TDropDown(['inst', 'player_vocals', 'opponent_vocals', 'all']), defValue: "all"},
			{name: "Value", type: TFloat(-10, 10, 0.01, 2), defValue: 1},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'sineOut']), defValue: "linear"}
		]);
		
		// ===== FEATURE 90: Timeline Group Event =====
		EventsData.eventsList.push("Event Group");
		EventsData.eventsParams.set("Event Group", [
			{name: "Group Name", type: TString, defValue: "myGroup"},
			{name: "Repeat Count", type: TInt(1, 100, 1), defValue: 1},
			{name: "Repeat Interval (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Loop?", type: TBool, defValue: false},
			{name: "Reverse on Repeat?", type: TBool, defValue: false}
		]);
		
		// ===== Additional Utility Events =====
		
		EventsData.eventsList.push("Set Gameplay Modifier");
		EventsData.eventsParams.set("Set Gameplay Modifier", [
			{name: "Modifier ID", type: TString, defValue: "drunk"},
			{name: "Value", type: TFloat(-9999, 9999, 0.01, 2), defValue: 1},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}
		]);
		
		EventsData.eventsList.push("Play Video");
		EventsData.eventsParams.set("Play Video", [
			{name: "Video Path", type: TString, defValue: "videos/example"},
			{name: "Play Mode", type: TDropDown(['overlay', 'fullscreen', 'background']), defValue: "overlay"},
			{name: "Pause Song?", type: TBool, defValue: false},
			{name: "Skip With Input?", type: TBool, defValue: true}
		]);
		
		EventsData.eventsList.push("Screen Transition");
		EventsData.eventsParams.set("Screen Transition", [
			{name: "Type", type: TDropDown(['fade', 'slide_left', 'slide_right', 'slide_up', 'slide_down', 'wipe', 'circle', 'pixelate', 'custom']), defValue: "fade"},
			{name: "Direction", type: TDropDown(['in', 'out']), defValue: "out"},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Color", type: TColorWheel, defValue: "#000000"},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'cubicOut']), defValue: "linear"}
		]);
		
		EventsData.eventsList.push("Set Strumline Position");
		EventsData.eventsParams.set("Set Strumline Position", [
			{name: "Strumline", type: TStrumLine, defValue: 0},
			{name: "X", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Y", type: TFloat(-9999, 9999, 10, 0), defValue: 50},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Ease", type: TDropDown(['linear', 'quadOut', 'backOut', 'elasticOut']), defValue: "quadOut"}
		]);
		
		EventsData.eventsList.push("Set Strumline Angle");
		EventsData.eventsParams.set("Set Strumline Angle", [
			{name: "Strumline", type: TStrumLine, defValue: 0},
			{name: "Angle", type: TFloat(-360, 360, 1, 0), defValue: 0},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}
		]);
		
		EventsData.eventsList.push("Lighting Event");
		EventsData.eventsParams.set("Lighting Event", [
			{name: "Action", type: TDropDown(['set_ambient', 'set_directional', 'add_point_light', 'spotlight', 'remove_light']), defValue: "set_ambient"},
			{name: "Color", type: TColorWheel, defValue: "#FFFFFF"},
			{name: "Intensity", type: TFloat(0, 10, 0.1, 2), defValue: 1},
			{name: "X", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Y", type: TFloat(-9999, 9999, 10, 0), defValue: 0},
			{name: "Radius", type: TFloat(0, 10000, 10, 0), defValue: 500},
			{name: "Duration (steps)", type: TFloat(0, 9999, 0.25, 2), defValue: 0}
		]);
		
		EventsData.eventsList.push("Set Background Color");
		EventsData.eventsParams.set("Set Background Color", [
			{name: "Color", type: TColorWheel, defValue: "#000000"},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Target", type: TDropDown(['camGame', 'camHUD']), defValue: "camGame"}
		]);
		
		EventsData.eventsList.push("Character Glow");
		EventsData.eventsParams.set("Character Glow", [
			{name: "Character", type: TStrumLine, defValue: 0},
			{name: "Color", type: TColorWheel, defValue: "#FFFFFF"},
			{name: "Intensity", type: TFloat(0, 5, 0.1, 2), defValue: 1},
			{name: "Duration (steps)", type: TFloat(0, 9999, 0.25, 2), defValue: 4},
			{name: "Fade In (steps)", type: TFloat(0, 9999, 0.25, 2), defValue: 1}
		]);
		
		EventsData.eventsList.push("Screen Effect");
		EventsData.eventsParams.set("Screen Effect", [
			{name: "Effect", type: TDropDown(['chromatic_aberration', 'vignette', 'blur', 'pixelate', 'glitch', 'scanlines', 'film_grain', 'bloom', 'crt']), defValue: "blur"},
			{name: "Intensity", type: TFloat(0, 10, 0.01, 2), defValue: 1},
			{name: "Tween?", type: TBool, defValue: true},
			{name: "Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4},
			{name: "Camera", type: TDropDown(['camGame', 'camHUD', 'both']), defValue: "camGame"}
		]);
		
		EventsData.eventsList.push("Play Sound Effect");
		EventsData.eventsParams.set("Play Sound Effect", [
			{name: "Sound Path", type: TString, defValue: "sounds/example"},
			{name: "Volume", type: TFloat(0, 2, 0.05, 2), defValue: 1},
			{name: "Pan", type: TFloat(-1, 1, 0.05, 2), defValue: 0},
			{name: "Pitch", type: TFloat(0.1, 5, 0.05, 2), defValue: 1}
		]);
		
		EventsData.eventsList.push("Stop Song");
		EventsData.eventsParams.set("Stop Song", [
			{name: "Fade Out?", type: TBool, defValue: true},
			{name: "Fade Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}
		]);
		
		EventsData.eventsList.push("Resume Song");
		EventsData.eventsParams.set("Resume Song", [
			{name: "Fade In?", type: TBool, defValue: true},
			{name: "Fade Duration (steps)", type: TFloat(0.25, 9999, 0.25, 2), defValue: 4}
		]);
		
		EventsData.eventsList.push("Set Note Type");
		EventsData.eventsParams.set("Set Note Type", [
			{name: "Note Type", type: TString, defValue: ""},
			{name: "Strumline", type: TStrumLine, defValue: 0},
			{name: "Apply To Future Notes?", type: TBool, defValue: true}
		]);
		
		EventsData.eventsList.push("Dialogue Event");
		EventsData.eventsParams.set("Dialogue Event", [
			{name: "Action", type: TDropDown(['show', 'next', 'hide', 'set_text', 'show_character', 'hide_character']), defValue: "show"},
			{name: "Text", type: TString, defValue: ""},
			{name: "Character", type: TString, defValue: ""},
			{name: "Box Style", type: TString, defValue: "default"},
			{name: "Pause Song?", type: TBool, defValue: false}
		]);
		
		trace('ExtendedEvents: Registered ${EventsData.eventsList.length} total events');
	}
}
