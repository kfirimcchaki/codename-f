package funkin.visualscripting.nodes;

import funkin.visualscripting.VisualScriptGraph;
import funkin.visualscripting.VSExecutionContext;

/**
 * FEATURE 71 (continued): Base Visual Script Node
 * 
 * All visual script nodes extend this class. Handles ports, execution,
 * data flow, serialization, and UI representation data.
 */
class VSNode {
	public var id:String;
	public var graph:VisualScriptGraph;
	
	// Visual position
	public var x:Float = 0;
	public var y:Float = 0;
	public var width:Float = 200;
	public var height:Float = 100;
	
	// Display
	public var displayName:String = "Node";
	public var category:String = "General";
	public var description:String = "";
	public var color:Int = 0xFF333333;
	public var icon:String = "";
	
	// Ports
	public var inputPorts:Array<VSPort> = [];
	public var outputPorts:Array<VSPort> = [];
	
	// Execution
	public var hasExecutionInput:Bool = true;
	public var hasExecutionOutput:Bool = true;
	
	// State
	public var isCollapsed:Bool = false;
	public var isSelected:Bool = false;
	public var isEnabled:Bool = true;
	public var comment:String = "";
	
	// Runtime values (cached outputs)
	public var outputValues:Map<String, Dynamic> = [];
	
	public function new() {
		outputValues = [];
		setupPorts();
	}
	
	/**
	 * Override this to define the node's ports
	 */
	function setupPorts():Void {
		if (hasExecutionInput) {
			addInputPort("exec_in", "Execution", EXECUTION);
		}
		if (hasExecutionOutput) {
			addOutputPort("exec_out", "Execution", EXECUTION);
		}
	}
	
	/**
	 * Add an input port
	 */
	public function addInputPort(name:String, label:String, type:VSPortType, ?defaultValue:Dynamic, required:Bool = false):VSPort {
		var port:VSPort = {
			name: name,
			label: label,
			type: type,
			direction: INPUT,
			defaultValue: defaultValue,
			required: required
		};
		inputPorts.push(port);
		return port;
	}
	
	/**
	 * Add an output port
	 */
	public function addOutputPort(name:String, label:String, type:VSPortType, ?value:Dynamic):VSPort {
		var port:VSPort = {
			name: name,
			label: label,
			type: type,
			direction: OUTPUT,
			defaultValue: value,
			required: false
		};
		outputPorts.push(port);
		return port;
	}
	
	/**
	 * Get input port by name
	 */
	public function getInputPort(name:String):VSPort {
		for (p in inputPorts) if (p.name == name) return p;
		return null;
	}
	
	/**
	 * Get output port by name
	 */
	public function getOutputPort(name:String):VSPort {
		for (p in outputPorts) if (p.name == name) return p;
		return null;
	}
	
	/**
	 * Get the value of an input port (from connected node or default)
	 */
	public function getInputValue(name:String, context:VSExecutionContext):Dynamic {
		var conn = graph.getConnectionTo(id, name);
		if (conn != null) {
			var sourceNode = graph.nodeMap.get(conn.sourceNodeID);
			if (sourceNode != null) {
				// Evaluate source node if needed
				if (!sourceNode.outputValues.exists(conn.sourcePort)) {
					sourceNode.evaluate(context);
				}
				return sourceNode.outputValues.get(conn.sourcePort);
			}
		}
		
		var port = getInputPort(name);
		return port != null ? port.defaultValue : null;
	}
	
	/**
	 * Evaluate this node's outputs. Override in subclasses.
	 */
	public function evaluate(context:VSExecutionContext):Void {
		// Default: no-op. Subclasses compute their output values.
	}
	
	/**
	 * Execute this node's logic. Override in subclasses.
	 * Returns the next execution output port name, or null to stop.
	 */
	public function execute(context:VSExecutionContext):String {
		evaluate(context);
		return hasExecutionOutput ? "exec_out" : null;
	}
	
	/**
	 * Validate this node. Return any errors.
	 */
	public function validate():Array<VisualScriptGraph.VSGraphError> {
		return [];
	}
	
	/**
	 * Clone this node
	 */
	public function clone():VSNode {
		var data = serialize();
		return VSNodeFactory.createFromData(data);
	}
	
	/**
	 * Serialize to JSON-compatible data
	 */
	public function serialize():Dynamic {
		return {
			className: Type.getClassName(Type.getClass(this)),
			id: id,
			x: x,
			y: y,
			isCollapsed: isCollapsed,
			isEnabled: isEnabled,
			comment: comment,
			inputValues: [for (p in inputPorts) if (p.defaultValue != null) p.name => p.defaultValue],
			outputValues: [for (p in outputPorts) if (outputValues.exists(p.name)) p.name => outputValues.get(p.name)]
		};
	}
	
	/**
	 * Load from serialized data
	 */
	public function deserialize(data:Dynamic):Void {
		id = data.id;
		x = data.x;
		y = data.y;
		isCollapsed = data.isCollapsed != null ? data.isCollapsed : false;
		isEnabled = data.isEnabled != null ? data.isEnabled : true;
		comment = data.comment != null ? data.comment : "";
		
		if (data.inputValues != null) {
			for (name in Reflect.fields(data.inputValues)) {
				var port = getInputPort(name);
				if (port != null) port.defaultValue = Reflect.field(data.inputValues, name);
			}
		}
	}
	
	/**
	 * Clean up resources
	 */
	public function destroy():Void {
		outputValues = null;
	}
}

// ====================== Port Types ======================

typedef VSPort = {
	var name:String;
	var label:String;
	var type:VSPortType;
	var direction:VSPortDirection;
	var ?defaultValue:Dynamic;
	var ?required:Bool;
}

enum abstract VSPortDirection(Int) {
	var INPUT = 0;
	var OUTPUT = 1;
}

enum abstract VSPortType(Int) {
	var EXECUTION = 0;
	var FLOAT = 1;
	var INT = 2;
	var STRING = 3;
	var BOOL = 4;
	var COLOR = 5;
	var VECTOR2 = 6;
	var OBJECT = 7;
	var SPRITE = 8;
	var SOUND = 9;
	var ANY = 10;
	var ARRAY = 11;
	var FUNCTION = 12;
	
	/**
	 * Check if two port types are compatible for connection
	 */
	public static function isCompatible(source:VSPortType, target:VSPortType):Bool {
		if (source == target) return true;
		if (target == ANY) return true;
		if (source == ANY) return true;
		
		// Numeric compatibility
		if ((source == INT || source == FLOAT) && (target == INT || target == FLOAT)) return true;
		
		// Object compatibility
		if (source == SPRITE && target == OBJECT) return true;
		if (source == SOUND && target == OBJECT) return true;
		
		return false;
	}
	
	/**
	 * Get display color for port type
	 */
	public static function getColor(type:VSPortType):Int {
		return switch (type) {
			case EXECUTION: 0xFFFFFFFF;
			case FLOAT: 0xFF66FF66;
			case INT: 0xFF22CC22;
			case STRING: 0xFFFF6666;
			case BOOL: 0xFF6666FF;
			case COLOR: 0xFFFFFF00;
			case VECTOR2: 0xFFFFAA00;
			case OBJECT: 0xFFAA00AA;
			case SPRITE: 0xFF00AAAA;
			case SOUND: 0xFFAA8844;
			case ANY: 0xFF888888;
			case ARRAY: 0xFF44AAFF;
			case FUNCTION: 0xFFFF88FF;
		}
	}
}
