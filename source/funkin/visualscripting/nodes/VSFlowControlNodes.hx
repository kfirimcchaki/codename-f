package funkin.visualscripting.nodes;

import funkin.visualscripting.VSExecutionContext;

// ====================== FLOW CONTROL NODES ======================

class VSIfNode extends VSNode {
	public function new() {
		super();
		displayName = "Branch";
		category = "Flow Control";
		color = 0xFF8B0000;
		description = "Branches execution based on a condition";
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("condition", "Condition", BOOL, false, true);
		addOutputPort("exec_true", "True", EXECUTION);
		addOutputPort("exec_false", "False", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var condition = getInputValue("condition", context);
		return condition == true ? "exec_true" : "exec_false";
	}
}

class VSForLoopNode extends VSNode {
	public var indexVariable:String = "i";
	
	public function new() {
		super();
		displayName = "For Loop";
		category = "Flow Control";
		color = 0xFF8B0000;
		description = "Loops from a start to end value";
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("from", "From", INT, 0);
		addInputPort("to", "To", INT, 10);
		addInputPort("step", "Step", INT, 1);
		addOutputPort("exec_body", "Loop Body", EXECUTION);
		addOutputPort("exec_done", "Completed", EXECUTION);
		addOutputPort("index", "Index", INT, 0);
	}
	
	override function execute(context:VSExecutionContext):String {
		var from:Int = cast getInputValue("from", context);
		var to:Int = cast getInputValue("to", context);
		var step:Int = cast getInputValue("step", context);
		
		if (step == 0) step = 1;
		
		var bodyConns = graph.getConnectionsFrom(id, "exec_body");
		var bodyNode = bodyConns.length > 0 ? graph.nodeMap.get(bodyConns[0].targetNodeID) : null;
		
		var i = from;
		while ((step > 0 && i < to) || (step < 0 && i > to)) {
			outputValues.set("index", i);
			context.setVariable(indexVariable, i);
			
			if (bodyNode != null) {
				context.executeNode(bodyNode);
			}
			
			if (context.breakRequested) {
				context.breakRequested = false;
				break;
			}
			if (context.continueRequested) {
				context.continueRequested = false;
			}
			
			i += step;
		}
		
		return "exec_done";
	}
}

class VSWhileLoopNode extends VSNode {
	public function new() {
		super();
		displayName = "While Loop";
		category = "Flow Control";
		color = 0xFF8B0000;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("condition", "Condition", BOOL, true);
		addOutputPort("exec_body", "Loop Body", EXECUTION);
		addOutputPort("exec_done", "Completed", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		var bodyConns = graph.getConnectionsFrom(id, "exec_body");
		var bodyNode = bodyConns.length > 0 ? graph.nodeMap.get(bodyConns[0].targetNodeID) : null;
		
		while (getInputValue("condition", context) == true) {
			if (bodyNode != null) context.executeNode(bodyNode);
			if (context.breakRequested) { context.breakRequested = false; break; }
		}
		
		return "exec_done";
	}
}

class VSSwitchNode extends VSNode {
	public var cases:Array<Dynamic> = [0, 1, 2];
	
	public function new() {
		super();
		displayName = "Switch";
		category = "Flow Control";
		color = 0xFF8B0000;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("value", "Value", ANY, 0);
		addOutputPort("exec_default", "Default", EXECUTION);
		for (i in 0...cases.length) {
			addOutputPort('case_$i', 'Case ${cases[i]}', EXECUTION);
		}
	}
}

class VSBreakNode extends VSNode {
	public function new() {
		super();
		displayName = "Break";
		category = "Flow Control";
		color = 0xFF8B0000;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		context.handleBreak();
		return null;
	}
}

class VSContinueNode extends VSNode {
	public function new() {
		super();
		displayName = "Continue";
		category = "Flow Control";
		color = 0xFF8B0000;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
	}
	
	override function execute(context:VSExecutionContext):String {
		context.handleContinue();
		return null;
	}
}

class VSReturnNode extends VSNode {
	public function new() {
		super();
		displayName = "Return";
		category = "Flow Control";
		color = 0xFF8B0000;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("value", "Value", ANY, null);
	}
	
	override function execute(context:VSExecutionContext):String {
		context.returnValue = getInputValue("value", context);
		return null;
	}
}

class VSSequenceNode extends VSNode {
	public var outputCount:Int = 3;
	
	public function new() {
		super();
		displayName = "Sequence";
		category = "Flow Control";
		color = 0xFF8B0000;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("reset", "Reset", EXECUTION);
		for (i in 0...outputCount) {
			addOutputPort('then_$i', 'Then $i', EXECUTION);
		}
	}
}

class VSGateNode extends VSNode {
	public function new() {
		super();
		displayName = "Gate";
		category = "Flow Control";
		color = 0xFF8B0000;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Enter", EXECUTION);
		addInputPort("open", "Open", EXECUTION);
		addInputPort("close", "Close", EXECUTION);
		addInputPort("start_enabled", "Start Enabled", BOOL, true);
		addOutputPort("exec_out", "Exit", EXECUTION);
	}
}

class VSMultiGateNode extends VSNode {
	public function new() {
		super();
		displayName = "Multi Gate";
		category = "Flow Control";
		color = 0xFF8B0000;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("reset", "Reset", EXECUTION);
		addInputPort("loop", "Loop", BOOL, false);
		addOutputPort("out_0", "Out 0", EXECUTION);
		addOutputPort("out_1", "Out 1", EXECUTION);
		addOutputPort("out_2", "Out 2", EXECUTION);
	}
}

class VSFlipFlopNode extends VSNode {
	public function new() {
		super();
		displayName = "Flip Flop";
		category = "Flow Control";
		color = 0xFF8B0000;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addOutputPort("exec_a", "A", EXECUTION);
		addOutputPort("exec_b", "B", EXECUTION);
		addOutputPort("is_a", "Is A", BOOL);
	}
}

class VSDelayNode extends VSNode {
	public function new() {
		super();
		displayName = "Delay";
		category = "Flow Control";
		color = 0xFF8B0000;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Execute", EXECUTION);
		addInputPort("duration", "Duration (ms)", FLOAT, 1000);
		addOutputPort("exec_out", "After Delay", EXECUTION);
	}
}

// ====================== MATH NODES ======================

class VSMathNode extends VSNode {
	public var operation:String = "+";
	
	public function new() {
		super();
		displayName = "Math";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("a", "A", FLOAT, 0);
		addInputPort("b", "B", FLOAT, 0);
		addOutputPort("result", "Result", FLOAT);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var a:Float = cast getInputValue("a", context);
		var b:Float = cast getInputValue("b", context);
		var result:Float = switch (operation) {
			case "+": a + b;
			case "-": a - b;
			case "*": a * b;
			case "/": b != 0 ? a / b : 0;
			case "^": Math.pow(a, b);
			case "%": b != 0 ? a % b : 0;
			default: a + b;
		}
		outputValues.set("result", result);
	}
}

class VSCompareNode extends VSNode {
	public var comparison:String = "==";
	
	public function new() {
		super();
		displayName = "Compare";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("a", "A", ANY, 0);
		addInputPort("b", "B", ANY, 0);
		addOutputPort("result", "Result", BOOL);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var a:Dynamic = getInputValue("a", context);
		var b:Dynamic = getInputValue("b", context);
		var result:Bool = switch (comparison) {
			case "==": a == b;
			case "!=": a != b;
			case ">": cast(a, Float) > cast(b, Float);
			case "<": cast(a, Float) < cast(b, Float);
			case ">=": cast(a, Float) >= cast(b, Float);
			case "<=": cast(a, Float) <= cast(b, Float);
			default: a == b;
		}
		outputValues.set("result", result);
	}
}

class VSRandomNode extends VSNode {
	public function new() {
		super();
		displayName = "Random";
		category = "Math";
		color = 0xFF006400;
	}
	
	override function setupPorts() {
		addInputPort("exec_in", "Generate", EXECUTION);
		addInputPort("min", "Min", FLOAT, 0);
		addInputPort("max", "Max", FLOAT, 1);
		addOutputPort("exec_out", "Done", EXECUTION);
		addOutputPort("result", "Result", FLOAT);
	}
	
	override function execute(context:VSExecutionContext):String {
		var min:Float = cast getInputValue("min", context);
		var max:Float = cast getInputValue("max", context);
		outputValues.set("result", min + Math.random() * (max - min));
		return "exec_out";
	}
}

class VSMathFunctionNode extends VSNode {
	public var mathFunc:String = "sin";
	
	public function new() {
		super();
		displayName = "Math Function";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("value", "Value", FLOAT, 0);
		addOutputPort("result", "Result", FLOAT);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var val:Float = cast getInputValue("value", context);
		var result:Float = switch (mathFunc) {
			case "sin": Math.sin(val);
			case "cos": Math.cos(val);
			case "tan": Math.tan(val);
			case "abs": Math.abs(val);
			case "sqrt": Math.sqrt(val);
			case "floor": Math.floor(val);
			case "ceil": Math.ceil(val);
			case "round": Math.round(val);
			case "log": Math.log(val);
			case "exp": Math.exp(val);
			default: val;
		}
		outputValues.set("result", result);
	}
}

class VSLerpNode extends VSNode {
	public function new() {
		super();
		displayName = "Lerp";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("a", "A", FLOAT, 0);
		addInputPort("b", "B", FLOAT, 1);
		addInputPort("alpha", "Alpha", FLOAT, 0.5);
		addOutputPort("result", "Result", FLOAT);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var a:Float = cast getInputValue("a", context);
		var b:Float = cast getInputValue("b", context);
		var alpha:Float = cast getInputValue("alpha", context);
		outputValues.set("result", a + (b - a) * alpha);
	}
}

class VSMapRangeNode extends VSNode {
	public function new() {
		super();
		displayName = "Map Range";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("value", "Value", FLOAT, 0.5);
		addInputPort("inMin", "In Min", FLOAT, 0);
		addInputPort("inMax", "In Max", FLOAT, 1);
		addInputPort("outMin", "Out Min", FLOAT, 0);
		addInputPort("outMax", "Out Max", FLOAT, 100);
		addOutputPort("result", "Result", FLOAT);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var value:Float = cast getInputValue("value", context);
		var inMin:Float = cast getInputValue("inMin", context);
		var inMax:Float = cast getInputValue("inMax", context);
		var outMin:Float = cast getInputValue("outMin", context);
		var outMax:Float = cast getInputValue("outMax", context);
		var range = inMax - inMin;
		if (range == 0) range = 1;
		outputValues.set("result", outMin + (value - inMin) / range * (outMax - outMin));
	}
}

class VSModuloNode extends VSNode {
	public function new() {
		super();
		displayName = "Modulo";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("a", "Value", FLOAT, 0);
		addInputPort("b", "Modulus", FLOAT, 2);
		addOutputPort("result", "Result", FLOAT);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var a:Float = cast getInputValue("a", context);
		var b:Float = cast getInputValue("b", context);
		outputValues.set("result", b != 0 ? a % b : 0);
	}
}

class VSNegateNode extends VSNode {
	public function new() {
		super();
		displayName = "Not";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("value", "Value", BOOL, false);
		addOutputPort("result", "Result", BOOL);
	}
	
	override function evaluate(context:VSExecutionContext) {
		outputValues.set("result", !(getInputValue("value", context) == true));
	}
}

class VSAbsNode extends VSNode {
	public function new() {
		super();
		displayName = "Absolute";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("value", "Value", FLOAT, 0);
		addOutputPort("result", "Result", FLOAT);
	}
	
	override function evaluate(context:VSExecutionContext) {
		outputValues.set("result", Math.abs(cast(getInputValue("value", context), Float)));
	}
}

class VSClampNode extends VSNode {
	public function new() {
		super();
		displayName = "Clamp";
		category = "Math";
		color = 0xFF006400;
		hasExecutionInput = false;
		hasExecutionOutput = false;
	}
	
	override function setupPorts() {
		addInputPort("value", "Value", FLOAT, 0);
		addInputPort("min", "Min", FLOAT, 0);
		addInputPort("max", "Max", FLOAT, 1);
		addOutputPort("result", "Result", FLOAT);
	}
	
	override function evaluate(context:VSExecutionContext) {
		var val:Float = cast getInputValue("value", context);
		var min:Float = cast getInputValue("min", context);
		var max:Float = cast getInputValue("max", context);
		outputValues.set("result", Math.max(min, Math.min(max, val)));
	}
}
