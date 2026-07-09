package funkin.visualscripting.nodes;

import funkin.visualscripting.VSExecutionContext;

// ====================== VARIABLE NODES ======================

class VSGetVariableNode extends VSNode {
	public var variableName:String = "";
	
	public function new() {
		super();
		displayName = "Get Variable";
		category = "Variables";
		color = 0xFF00648B;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addOutputPort("value", "Value", ANY);
	}
	
	override function evaluate(context:VSExecutionContext) {
		outputValues.set("value", context.getVariable(variableName));
	}
}

class VSSetVariableNode extends VSNode {
	public var variableName:String = "";
	
	public function new() {
		super();
		displayName = "Set Variable";
		category = "Variables";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("value", "Value", ANY, null);
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("value", "Value", ANY);
	}
	
	override function execute(context:VSExecutionContext):String {
		var value = getInputValue("value", context);
		context.setVariable(variableName, value);
		outputValues.set("value", value);
		return "exec_out";
	}
}

class VSConstantNode extends VSNode {
	public var value:Dynamic = 0;
	
	public function new() {
		super();
		displayName = "Constant";
		category = "Variables";
		color = 0xFF00648B;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addOutputPort("value", "Value", ANY, value);
	}
	
	override function evaluate(context:VSExecutionContext) {
		outputValues.set("value", value);
	}
}

class VSGetPropertyNode extends VSNode {
	public var propertyName:String = "";
	
	public function new() {
		super();
		displayName = "Get Property";
		category = "Variables";
		color = 0xFF00648B;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("object", "Object", OBJECT, null);
		addOutputPort("value", "Value", ANY);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var obj = getInputValue("object", context);
		if (obj != null) {
			outputValues.set("value", Reflect.getProperty(obj, propertyName));
		}
	}
}

class VSSetPropertyNode extends VSNode {
	public var propertyName:String = "";
	
	public function new() {
		super();
		displayName = "Set Property";
		category = "Variables";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("object", "Object", OBJECT, null);
		addInputPort("value", "Value", ANY, null);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var obj = getInputValue("object", context);
		var value = getInputValue("value", context);
		if (obj != null) {
			Reflect.setProperty(obj, propertyName, value);
		}
		return "exec_out";
	}
}

class VSArrayNode extends VSNode {
	public var itemPorts:Array<String> = ["item_0", "item_1", "item_2"];
	
	public function new() {
		super();
		displayName = "Make Array";
		category = "Variables";
		color = 0xFF00648B;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		for (p in itemPorts) {
			addInputPort(p, p.replace("item_", "Item "), ANY, null);
		}
		addOutputPort("array", "Array", ARRAY);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var arr:Array<Dynamic> = [];
		for (p in itemPorts) {
			arr.push(getInputValue(p, context));
		}
		outputValues.set("array", arr);
	}
}

class VSArrayAccessNode extends VSNode {
	public function new() {
		super();
		displayName = "Array Get";
		category = "Variables";
		color = 0xFF00648B;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("array", "Array", ARRAY, null);
		addInputPort("index", "Index", INT, 0);
		addOutputPort("value", "Value", ANY);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var arr:Array<Dynamic> = cast getInputValue("array", context);
		var idx:Int = cast getInputValue("index", context);
		outputValues.set("value", arr != null && idx >= 0 && idx < arr.length ? arr[idx] : null);
	}
}

class VSArrayAddNode extends VSNode {
	public function new() {
		super();
		displayName = "Array Add";
		category = "Variables";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("array", "Array", ARRAY, null);
		addInputPort("value", "Value", ANY, null);
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("array", "Array", ARRAY);
	}
	
	override function execute(context:VSExecutionContext):String {
		var arr:Array<Dynamic> = cast getInputValue("array", context);
		var value = getInputValue("value", context);
		if (arr != null) arr.push(value);
		outputValues.set("array", arr);
		return "exec_out";
	}
}

class VSArrayRemoveNode extends VSNode {
	public function new() {
		super();
		displayName = "Array Remove";
		category = "Variables";
		color = 0xFF00648B;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("array", "Array", ARRAY, null);
		addInputPort("value", "Value", ANY, null);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var arr:Array<Dynamic> = cast getInputValue("array", context);
		var value = getInputValue("value", context);
		if (arr != null) arr.remove(value);
		return "exec_out";
	}
}

// ====================== STRING NODES ======================

class VSStringConcatNode extends VSNode {
	public function new() {
		super();
		displayName = "Concat";
		category = "String";
		color = 0xFF8B6400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("a", "A", STRING, "");
		addInputPort("b", "B", STRING, "");
		addOutputPort("result", "Result", STRING);
	}
	
	override function evaluate(context:VSExecutionContext) {
		outputValues.set("result", Std.string(getInputValue("a", context)) + Std.string(getInputValue("b", context)));
	}
}

class VSStringSplitNode extends VSNode {
	public function new() {
		super();
		displayName = "Split";
		category = "String";
		color = 0xFF8B6400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("str", "String", STRING, "");
		addInputPort("delimiter", "Delimiter", STRING, " ");
		addOutputPort("array", "Parts", ARRAY);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var str:String = cast getInputValue("str", context);
		var delim:String = cast getInputValue("delimiter", context);
		outputValues.set("array", str != null ? str.split(delim) : []);
	}
}

class VSStringLengthNode extends VSNode {
	public function new() {
		super();
		displayName = "Length";
		category = "String";
		color = 0xFF8B6400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("str", "String", STRING, "");
		addOutputPort("length", "Length", INT);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var str:String = cast getInputValue("str", context);
		outputValues.set("length", str != null ? str.length : 0);
	}
}

class VSStringContainsNode extends VSNode {
	public function new() {
		super();
		displayName = "Contains";
		category = "String";
		color = 0xFF8B6400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("str", "String", STRING, "");
		addInputPort("search", "Search", STRING, "");
		addOutputPort("result", "Contains", BOOL);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var str:String = cast getInputValue("str", context);
		var search:String = cast getInputValue("search", context);
		outputValues.set("result", str != null && search != null && str.indexOf(search) >= 0);
	}
}

class VSStringReplaceNode extends VSNode {
	public function new() {
		super();
		displayName = "Replace";
		category = "String";
		color = 0xFF8B6400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("str", "String", STRING, "");
		addInputPort("find", "Find", STRING, "");
		addInputPort("replace", "Replace", STRING, "");
		addOutputPort("result", "Result", STRING);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var str:String = cast getInputValue("str", context);
		var find:String = cast getInputValue("find", context);
		var replace:String = cast getInputValue("replace", context);
		outputValues.set("result", str != null ? StringTools.replace(str, find, replace) : "");
	}
}

class VSStringFormatNode extends VSNode {
	public var format:String = "{0}";
	
	public function new() {
		super();
		displayName = "Format";
		category = "String";
		color = 0xFF8B6400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("arg0", "Arg 0", ANY, "");
		addInputPort("arg1", "Arg 1", ANY, "");
		addInputPort("arg2", "Arg 2", ANY, "");
		addOutputPort("result", "Result", STRING);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var result = format;
		for (i in 0...3) {
			var val = getInputValue('arg$i', context);
			result = StringTools.replace(result, '{$i}', Std.string(val));
		}
		outputValues.set("result", result);
	}
}

// ====================== FUNCTION NODES ======================

class VSFunctionDefNode extends VSNode {
	public var functionName:String = "myFunction";
	public var parameters:Array<{name:String, type:VSPortType, defaultValue:Dynamic}> = [];
	public var hasReturnValue:Bool = false;
	
	public function new() {
		super();
		displayName = "Function";
		category = "Functions";
		color = 0xFF640064;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addOutputPort("exec_out", "Done", EXECUTION);
		if (hasReturnValue) {
			addInputPort("return_value", "Return Value", ANY, null);
		}
	}
}

class VSCallFunctionNode extends VSNode {
	public var functionName:String = "";
	public var argumentNames:Array<String> = ["arg0", "arg1", "arg2"];
	
	public function new() {
		super();
		displayName = "Call Function";
		category = "Functions";
		color = 0xFF640064;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		for (arg in argumentNames) {
			addInputPort(arg, arg, ANY, null);
		}
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("result", "Return", ANY);
	}
	
	override function execute(context:VSExecutionContext):String {
		// Find the function definition node
		var funcNodes = graph.getNodesByType(VSFunctionDefNode);
		for (fn in funcNodes) {
			if (fn.functionName == functionName) {
				// Set parameter values
				for (i in 0...fn.parameters.length) {
					if (i < argumentNames.length) {
						context.setVariable(fn.parameters[i].name, getInputValue(argumentNames[i], context));
					}
				}
				context.executeNode(fn);
				outputValues.set("result", context.returnValue);
				break;
			}
		}
		return "exec_out";
	}
}

// ====================== EVENT NODES ======================

class VSOnEventNode extends VSNode {
	public var eventName:String = "customEvent";
	
	public function new() {
		super();
		displayName = "On Event";
		category = "Events";
		color = 0xFF8B0064;
		hasExecutionInput = false;
	}
	
	override function setupPorts() {
		addOutputPort("exec_out", "Execute", EXECUTION);
	}
}

class VSFireEventNode extends VSNode {
	public var eventName:String = "customEvent";
	
	public function new() {
		super();
		displayName = "Fire Event";
		category = "Events";
		color = 0xFF8B0064;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("arg0", "Arg 0", ANY, null);
		addInputPort("arg1", "Arg 1", ANY, null);
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var args = new Map<String, Dynamic>();
		args.set("arg0", getInputValue("arg0", context));
		args.set("arg1", getInputValue("arg1", context));
		context.fireEvent(eventName, args);
		return "exec_out";
	}
}

class VSOnBeatNode extends VSNode {
	public function new() {
		super();
		displayName = "On Beat";
		category = "Events";
		color = 0xFF8B0064;
		hasExecutionInput = false;
	}
	
	override function setupPorts() {
		addOutputPort("exec_out", "Execute", EXECUTION);
		addOutputPort("curBeat", "Beat #", INT);
	}
}

class VSOnStepNode extends VSNode {
	public function new() {
		super();
		displayName = "On Step";
		category = "Events";
		color = 0xFF8B0064;
		hasExecutionInput = false;
	}
	
	override function setupPorts() {
		addOutputPort("exec_out", "Execute", EXECUTION);
		addOutputPort("curStep", "Step #", INT);
	}
}

class VSOnNoteHitNode extends VSNode {
	public function new() {
		super();
		displayName = "On Note Hit";
		category = "Events";
		color = 0xFF8B0064;
		hasExecutionInput = false;
	}
	
	override function setupPorts() {
		addOutputPort("exec_out", "Execute", EXECUTION);
		addOutputPort("noteID", "Note ID", INT);
		addOutputPort("strumLine", "Strum Line", INT);
		addOutputPort("rating", "Rating", STRING);
	}
}

class VSOnNoteMissNode extends VSNode {
	public function new() {
		super();
		displayName = "On Note Miss";
		category = "Events";
		color = 0xFF8B0064;
		hasExecutionInput = false;
	}
	
	override function setupPorts() {
		addOutputPort("exec_out", "Execute", EXECUTION);
		addOutputPort("noteID", "Note ID", INT);
		addOutputPort("strumLine", "Strum Line", INT);
	}
}

class VSOnCountdownNode extends VSNode {
	public function new() {
		super();
		displayName = "On Countdown";
		category = "Events";
		color = 0xFF8B0064;
		hasExecutionInput = false;
	}
	
	override function setupPorts() {
		addOutputPort("exec_out", "Execute", EXECUTION);
		addOutputPort("step", "Step", STRING);
	}
}

class VSOnSongStartNode extends VSNode {
	public function new() {
		super();
		displayName = "On Song Start";
		category = "Events";
		color = 0xFF8B0064;
		hasExecutionInput = false;
	}
	
	override function setupPorts() {
		addOutputPort("exec_out", "Execute", EXECUTION);
	}
}

class VSOnSongEndNode extends VSNode {
	public function new() {
		super();
		displayName = "On Song End";
		category = "Events";
		color = 0xFF8B0064;
		hasExecutionInput = false;
	}
	
	override function setupPorts() {
		addOutputPort("exec_out", "Execute", EXECUTION);
	}
}

// ====================== UTILITY NODES ======================

class VSLogNode extends VSNode {
	public function new() {
		super();
		displayName = "Log";
		category = "Utility";
		color = 0xFF444444;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("message", "Message", STRING, "Hello!");
		addOutputPort("exec_out", "Done", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		trace('[VisualScript] ${getInputValue("message", context)}');
		return "exec_out";
	}
}

class VSCommentNode extends VSNode {
	public var commentText:String = "Comment";
	
	public function new() {
		super();
		displayName = "Comment";
		category = "Utility";
		color = 0xFF444444;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {}
}

class VSRerouteNode extends VSNode {
	public function new() {
		super();
		displayName = "Reroute";
		category = "Utility";
		color = 0xFF444444;
		hasExecutionInput = false;
		hasExecutionOutput = false;
		width = 30;
		height = 30;
	}
	
	override function setupPorts() {
		addInputPort("in", "", ANY, null);
		addOutputPort("out", "", ANY);
	}
	
	override function evaluate(context:VSExecutionContext) {
		outputValues.set("out", getInputValue("in", context));
	}
}

class VSGroupNode extends VSNode {
	public var groupName:String = "Group";
	public var groupColor:Int = 0xFF333333;
	
	public function new() {
		super();
		displayName = "Group";
		category = "Utility";
		color = 0xFF333333;
		hasExecutionInput = false;
		hasExecutionOutput = false;
		width = 300;
		height = 200;
	}
	
	override function setupPorts() {}
}
