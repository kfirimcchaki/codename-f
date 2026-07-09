package funkin.visualscripting;

import haxe.Json;
import haxe.ds.StringMap;
import funkin.visualscripting.nodes.*;

/**
 * FEATURE 71: Visual Scripting Graph System
 * 
 * Core data structure for visual scripting. Stores nodes, connections,
 * and execution flow for a visual HX script that can be serialized/deserialized
 * and compiled to HScript code.
 */
class VisualScriptGraph {
	public var id:String;
	public var name:String;
	public var description:String;
	public var version:String = "1.0.0";
	public var author:String = "";
	
	public var nodes:Array<VSNode> = [];
	public var connections:Array<VSConnection> = [];
	public var variables:Map<String, VSVariable> = [];
	public var groups:Array<VSNodeGroup> = [];
	
	// Runtime state
	public var executionContext:VSExecutionContext;
	public var nodeMap:Map<String, VSNode> = [];
	public var isDirty:Bool = true;
	
	// Metadata
	public var metadata:Map<String, Dynamic> = [];
	public var tags:Array<String> = [];
	
	public function new(?name:String) {
		this.id = generateID();
		this.name = name != null ? name : "Untitled Graph";
		this.executionContext = new VSExecutionContext(this);
	}
	
	public function generateID():String {
		return 'vs_${Date.now().getTime()}_${Std.random(99999)}';
	}
	
	/**
	 * Add a node to the graph
	 */
	public function addNode(node:VSNode):VSNode {
		node.graph = this;
		node.id = node.id != null ? node.id : generateID();
		nodes.push(node);
		nodeMap.set(node.id, node);
		isDirty = true;
		return node;
	}
	
	/**
	 * Remove a node and all its connections
	 */
	public function removeNode(nodeID:String):Void {
		var node = nodeMap.get(nodeID);
		if (node == null) return;
		
		// Remove all connections involving this node
		connections = connections.filter(c -> c.sourceNodeID != nodeID && c.targetNodeID != nodeID);
		
		nodes.remove(node);
		nodeMap.remove(nodeID);
		node.destroy();
		isDirty = true;
	}
	
	/**
	 * Connect two node ports
	 */
	public function connect(sourceNodeID:String, sourcePort:String, targetNodeID:String, targetPort:String):Bool {
		var sourceNode = nodeMap.get(sourceNodeID);
		var targetNode = nodeMap.get(targetNodeID);
		
		if (sourceNode == null || targetNode == null) return false;
		
		var srcPort = sourceNode.getOutputPort(sourcePort);
		var tgtPort = targetNode.getInputPort(targetPort);
		
		if (srcPort == null || tgtPort == null) return false;
		
		// Type checking
		if (!VSPortType.isCompatible(srcPort.type, tgtPort.type)) return false;
		
		// Remove existing connection to input port (inputs can only have one connection)
		connections = connections.filter(c -> !(c.targetNodeID == targetNodeID && c.targetPort == targetPort));
		
		// Check for circular dependency
		if (wouldCreateCycle(sourceNodeID, targetNodeID)) return false;
		
		connections.push({
			id: generateID(),
			sourceNodeID: sourceNodeID,
			sourcePort: sourcePort,
			targetNodeID: targetNodeID,
			targetPort: targetPort
		});
		
		isDirty = true;
		return true;
	}
	
	/**
	 * Disconnect two ports
	 */
	public function disconnect(sourceNodeID:String, sourcePort:String, targetNodeID:String, targetPort:String):Void {
		connections = connections.filter(c -> 
			!(c.sourceNodeID == sourceNodeID && c.sourcePort == sourcePort && 
			  c.targetNodeID == targetNodeID && c.targetPort == targetPort));
		isDirty = true;
	}
	
	/**
	 * Check if connecting source to target would create a cycle
	 */
	function wouldCreateCycle(sourceID:String, targetID:String):Bool {
		var visited:Map<String, Bool> = [];
		return hasCycleDFS(targetID, sourceID, visited);
	}
	
	function hasCycleDFS(current:String, target:String, visited:Map<String, Bool>):Bool {
		if (current == target) return true;
		if (visited.exists(current)) return false;
		visited.set(current, true);
		
		for (conn in connections) {
			if (conn.sourceNodeID == current) {
				if (hasCycleDFS(conn.targetNodeID, target, visited)) return true;
			}
		}
		return false;
	}
	
	/**
	 * Get all nodes of a specific type
	 */
	public function getNodesByType<T:VSNode>(type:Class<T>):Array<T> {
		return [for (n in nodes) if (Std.isOfType(n, type)) cast n];
	}
	
	/**
	 * Get connections from a specific output port
	 */
	public function getConnectionsFrom(nodeID:String, port:String):Array<VSConnection> {
		return connections.filter(c -> c.sourceNodeID == nodeID && c.sourcePort == port);
	}
	
	/**
	 * Get connection to a specific input port
	 */
	public function getConnectionTo(nodeID:String, port:String):VSConnection {
		for (c in connections) {
			if (c.targetNodeID == nodeID && c.targetPort == port) return c;
		}
		return null;
	}
	
	/**
	 * Validate the entire graph for errors
	 */
	public function validate():Array<VSGraphError> {
		var errors:Array<VSGraphError> = [];
		
		for (node in nodes) {
			// Check required inputs
			for (port in node.inputPorts) {
				if (port.required && getConnectionTo(node.id, port.name) == null) {
					errors.push({
						nodeID: node.id,
						portName: port.name,
						message: 'Required input "${port.name}" is not connected on node "${node.displayName}"',
						severity: ERROR
					});
				}
			}
			
			// Node-specific validation
			var nodeErrors = node.validate();
			for (e in nodeErrors) errors.push(e);
		}
		
		return errors;
	}
	
	/**
	 * Compile the graph to HScript code
	 */
	public function compileToHScript():String {
		var compiler = new VSCompiler(this);
		return compiler.compile();
	}
	
	/**
	 * Execute the graph at runtime
	 */
	public function execute(?context:Map<String, Dynamic>):Dynamic {
		executionContext.reset();
		if (context != null) {
			for (k => v in context) {
				executionContext.setVariable(k, v);
			}
		}
		
		// Find entry point nodes (nodes with no execution input connections)
		var entryPoints = nodes.filter(n -> {
			if (!n.hasExecutionInput) return false;
			for (conn in connections) {
				if (conn.targetNodeID == n.id && conn.targetPort == "exec_in") return false;
			}
			return true;
		});
		
		if (entryPoints.length == 0) {
			// Try OnEvent nodes
			entryPoints = nodes.filter(n -> n is VSOnEventNode);
		}
		
		// Execute each entry point
		for (entry in entryPoints) {
			executionContext.executeNode(entry);
		}
		
		return executionContext.returnValue;
	}
	
	/**
	 * Serialize graph to JSON
	 */
	public function serialize():String {
		var data = {
			id: id,
			name: name,
			description: description,
			version: version,
			author: author,
			tags: tags,
			metadata: [for (k => v in metadata) k => v],
			variables: [for (k => v in variables) {
				name: k,
				type: v.type,
				defaultValue: v.defaultValue,
				description: v.description
			}],
			groups: [for (g in groups) {
				name: g.name,
				color: g.color,
				x: g.x,
				y: g.y,
				width: g.width,
				height: g.height,
				nodeIDs: g.nodeIDs
			}],
			nodes: [for (n in nodes) n.serialize()],
			connections: [for (c in connections) {
				id: c.id,
				sourceNodeID: c.sourceNodeID,
				sourcePort: c.sourcePort,
				targetNodeID: c.targetNodeID,
				targetPort: c.targetPort
			}]
		};
		
		return Json.stringify(data, null, "\t");
	}
	
	/**
	 * Deserialize graph from JSON
	 */
	public static function deserialize(json:String):VisualScriptGraph {
		var data:Dynamic = Json.parse(json);
		var graph = new VisualScriptGraph(data.name);
		graph.id = data.id;
		graph.description = data.description != null ? data.description : "";
		graph.version = data.version != null ? data.version : "1.0.0";
		graph.author = data.author != null ? data.author : "";
		graph.tags = data.tags != null ? data.tags : [];
		
		// Deserialize variables
		if (data.variables != null) {
			for (v in cast(data.variables, Array<Dynamic>)) {
				graph.variables.set(v.name, {
					type: v.type,
					defaultValue: v.defaultValue,
					description: v.description != null ? v.description : ""
				});
			}
		}
		
		// Deserialize groups
		if (data.groups != null) {
			for (g in cast(data.groups, Array<Dynamic>)) {
				graph.groups.push({
					name: g.name,
					color: g.color,
					x: g.x,
					y: g.y,
					width: g.width,
					height: g.height,
					nodeIDs: g.nodeIDs != null ? g.nodeIDs : []
				});
			}
		}
		
		// Deserialize nodes
		if (data.nodes != null) {
			for (nData in cast(data.nodes, Array<Dynamic>)) {
				var node = VSNodeFactory.createFromData(nData);
				if (node != null) {
					graph.addNode(node);
				}
			}
		}
		
		// Deserialize connections
		if (data.connections != null) {
			for (c in cast(data.connections, Array<Dynamic>)) {
				graph.connections.push({
					id: c.id,
					sourceNodeID: c.sourceNodeID,
					sourcePort: c.sourcePort,
					targetNodeID: c.targetNodeID,
					targetPort: c.targetPort
				});
			}
		}
		
		graph.isDirty = false;
		return graph;
	}
	
	/**
	 * Duplicate the entire graph
	 */
	public function duplicate():VisualScriptGraph {
		return deserialize(serialize());
	}
	
	/**
	 * Merge another graph into this one
	 */
	public function merge(other:VisualScriptGraph, offsetX:Float = 0, offsetY:Float = 0):Void {
		for (node in other.nodes) {
			var cloned = node.clone();
			cloned.x += offsetX;
			cloned.y += offsetY;
			addNode(cloned);
		}
		
		for (varName => varData in other.variables) {
			if (!variables.exists(varName)) {
				variables.set(varName, varData);
			}
		}
		
		isDirty = true;
	}
}

// ====================== Data Types ======================

typedef VSConnection = {
	var id:String;
	var sourceNodeID:String;
	var sourcePort:String;
	var targetNodeID:String;
	var targetPort:String;
}

typedef VSVariable = {
	var type:String;
	var defaultValue:Dynamic;
	var description:String;
}

typedef VSNodeGroup = {
	var name:String;
	var color:Int;
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
	var nodeIDs:Array<String>;
}

typedef VSGraphError = {
	var nodeID:String;
	var ?portName:String;
	var message:String;
	var severity:VSErrorSeverity;
}

enum abstract VSErrorSeverity(Int) {
	var INFO = 0;
	var WARNING = 1;
	var ERROR = 2;
}
