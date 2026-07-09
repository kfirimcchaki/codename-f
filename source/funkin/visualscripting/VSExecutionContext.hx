package funkin.visualscripting;

import funkin.visualscripting.nodes.VSNode;

/**
 * FEATURE 77: Visual Scripting Variable & Execution System
 * 
 * Manages runtime execution state, variable scope, and flow control
 * for visual script graphs.
 */
class VSExecutionContext {
	public var graph:VisualScriptGraph;
	public var variables:Map<String, Dynamic> = [];
	public var localScopes:Array<Map<String, Dynamic>> = [];
	public var callStack:Array<VSCallFrame> = [];
	public var returnValue:Dynamic = null;
	
	public var isRunning:Bool = false;
	public var maxIterations:Int = 100000;
	public var currentIteration:Int = 0;
	public var breakRequested:Bool = false;
	public var continueRequested:Bool = false;
	
	// Event listeners registered by nodes
	public var eventListeners:Map<String, Array<VSNode>> = [];
	
	// Timing
	public var startTime:Float = 0;
	public var maxExecutionTime:Float = 5000; // ms
	
	public function new(graph:VisualScriptGraph) {
		this.graph = graph;
		reset();
	}
	
	public function reset():Void {
		variables = [];
		localScopes = [];
		callStack = [];
		returnValue = null;
		isRunning = false;
		currentIteration = 0;
		breakRequested = false;
		continueRequested = false;
		eventListeners = [];
		
		// Load graph variables with defaults
		for (name => varData in graph.variables) {
			variables.set(name, varData.defaultValue);
		}
	}
	
	/**
	 * Set a variable value
	 */
	public function setVariable(name:String, value:Dynamic):Void {
		if (localScopes.length > 0) {
			localScopes[localScopes.length - 1].set(name, value);
		} else {
			variables.set(name, value);
		}
	}
	
	/**
	 * Get a variable value (searches local scopes first)
	 */
	public function getVariable(name:String):Dynamic {
		// Search local scopes from innermost to outermost
		for (i in 0...localScopes.length) {
			var idx = localScopes.length - 1 - i;
			if (localScopes[idx].exists(name)) return localScopes[idx].get(name);
		}
		return variables.get(name);
	}
	
	/**
	 * Push a new local scope
	 */
	public function pushScope():Void {
		localScopes.push(new Map<String, Dynamic>());
	}
	
	/**
	 * Pop the current local scope
	 */
	public function popScope():Map<String, Dynamic> {
		return localScopes.length > 0 ? localScopes.pop() : null;
	}
	
	/**
	 * Execute a node and follow execution flow
	 */
	public function executeNode(node:VSNode):Void {
		if (node == null || !node.isEnabled) return;
		if (!isRunning) {
			isRunning = true;
			startTime = Sys.time() * 1000;
		}
		
		// Safety checks
		currentIteration++;
		if (currentIteration > maxIterations) {
			trace('VisualScript: Max iterations exceeded in graph "${graph.name}"');
			isRunning = false;
			return;
		}
		
		var elapsed = (Sys.time() * 1000) - startTime;
		if (elapsed > maxExecutionTime) {
			trace('VisualScript: Execution timeout in graph "${graph.name}"');
			isRunning = false;
			return;
		}
		
		// Push call frame
		callStack.push({
			nodeID: node.id,
			nodeName: node.displayName,
			timestamp: Sys.time()
		});
		
		// Execute the node
		var nextPort = node.execute(this);
		
		// Pop call frame
		callStack.pop();
		
		// Follow execution to next node
		if (nextPort != null) {
			var connections = graph.getConnectionsFrom(node.id, nextPort);
			for (conn in connections) {
				if (conn.targetPort == "exec_in") {
					var nextNode = graph.nodeMap.get(conn.targetNodeID);
					if (nextNode != null) {
						executeNode(nextNode);
					}
				}
			}
		}
	}
	
	/**
	 * Register an event listener node
	 */
	public function registerEventListener(eventName:String, node:VSNode):Void {
		if (!eventListeners.exists(eventName)) {
			eventListeners.set(eventName, []);
		}
		eventListeners.get(eventName).push(node);
	}
	
	/**
	 * Fire an event, executing all listener nodes
	 */
	public function fireEvent(eventName:String, ?args:Map<String, Dynamic>):Void {
		var listeners = eventListeners.get(eventName);
		if (listeners == null) return;
		
		if (args != null) {
			for (k => v in args) setVariable(k, v);
		}
		
		for (node in listeners) {
			currentIteration = 0;
			executeNode(node);
		}
	}
	
	/**
	 * Handle break in loops
	 */
	public function handleBreak():Void {
		breakRequested = true;
	}
	
	/**
	 * Handle continue in loops
	 */
	public function handleContinue():Void {
		continueRequested = true;
	}
	
	/**
	 * Get current call stack depth
	 */
	public function getCallDepth():Int {
		return callStack.length;
	}
	
	/**
	 * Get a debug string of the call stack
	 */
	public function getCallStackDebug():String {
		return callStack.map(f -> '  at ${f.nodeName} (${f.nodeID})').join('\n');
	}
}

typedef VSCallFrame = {
	var nodeID:String;
	var nodeName:String;
	var timestamp:Float;
}
