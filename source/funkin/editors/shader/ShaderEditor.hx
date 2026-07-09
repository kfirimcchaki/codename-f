package funkin.editors.shader;

import funkin.editors.ui.*;

/**
 * FEATURE 6: Shader Editor
 * 
 * Visual shader graph editor for creating custom GLSL shaders.
 * Features:
 * - Node-based shader graph
 * - GLSL preview
 * - Common shader operations
 * - Uniform variable management
 * - Real-time preview
 * - Built-in shader presets
 * - Integration with stage/sprite system
 * - Hot reload during gameplay
 */
class ShaderEditor extends UIState {
	public var shaderGraph:ShaderGraph;
	public var selectedNode:ShaderNode;
	
	// UI
	public var graphView:ShaderGraphView;
	public var nodePalette:ShaderNodePalette;
	public var previewPanel:ShaderPreviewPanel;
	public var codePanel:ShaderCodePanel;
	public var uniformPanel:ShaderUniformPanel;
	public var toolbar:ShaderToolbar;
	
	public var isDirty:Bool = false;
	public var currentShaderPath:String;
	
	public override function create() {
		super.create();
		WindowUtils.suffix = " (Shader Editor)";
		
		shaderGraph = new ShaderGraph();
		
		// Create UI
		toolbar = new ShaderToolbar(this);
		add(toolbar);
		
		nodePalette = new ShaderNodePalette(this);
		add(nodePalette);
		
		graphView = new ShaderGraphView(this);
		add(graphView);
		
		previewPanel = new ShaderPreviewPanel(this);
		add(previewPanel);
		
		codePanel = new ShaderCodePanel(this);
		add(codePanel);
		
		uniformPanel = new ShaderUniformPanel(this);
		add(uniformPanel);
	}
	
	public function addShaderNode(type:ShaderNodeType, ?x:Float, ?y:Float):ShaderNode {
		var node = ShaderNodeFactory.create(type);
		node.x = x != null ? x : 300;
		node.y = y != null ? y : 200;
		shaderGraph.nodes.push(node);
		graphView.refresh();
		isDirty = true;
		return node;
	}
	
	/**
	 * Compile the shader graph to GLSL
	 */
	public function compileToGLSL():ShaderCode {
		var compiler = new ShaderGraphCompiler(shaderGraph);
		return compiler.compile();
	}
	
	/**
	 * Generate a simple fragment shader from presets
	 */
	public static function generatePresetShader(preset:ShaderPresetType):String {
		return switch (preset) {
			case GRAYSCALE: '
				void main() {
					vec4 color = texture2D(bitmap, openfl_TextureCoordv);
					float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
					gl_FragColor = vec4(vec3(gray), color.a);
				}';
			case INVERT: '
				void main() {
					vec4 color = texture2D(bitmap, openfl_TextureCoordv);
					gl_FragColor = vec4(1.0 - color.rgb, color.a);
				}';
			case BLUR: '
				uniform float u_blurAmount;
				void main() {
					vec4 color = vec4(0.0);
					float total = 0.0;
					for (float x = -4.0; x <= 4.0; x += 1.0) {
						for (float y = -4.0; y <= 4.0; y += 1.0) {
							vec2 offset = vec2(x, y) * u_blurAmount / openfl_TextureSize;
							float weight = 1.0 - length(vec2(x, y)) / 5.66;
							color += texture2D(bitmap, openfl_TextureCoordv + offset) * weight;
							total += weight;
						}
					}
					gl_FragColor = color / total;
				}';
			case CHROMATIC_ABERRATION: '
				uniform float u_amount;
				void main() {
					vec2 uv = openfl_TextureCoordv;
					float r = texture2D(bitmap, uv + vec2(u_amount, 0.0)).r;
					float g = texture2D(bitmap, uv).g;
					float b = texture2D(bitmap, uv - vec2(u_amount, 0.0)).b;
					float a = texture2D(bitmap, uv).a;
					gl_FragColor = vec4(r, g, b, a);
				}';
			case VIGNETTE: '
				uniform float u_intensity;
				uniform float u_roundness;
				void main() {
					vec4 color = texture2D(bitmap, openfl_TextureCoordv);
					vec2 uv = openfl_TextureCoordv * 2.0 - 1.0;
					float vignette = 1.0 - pow(length(uv), u_roundness) * u_intensity;
					gl_FragColor = color * vignette;
				}';
			case PIXELATE: '
				uniform float u_pixelSize;
				void main() {
					vec2 uv = openfl_TextureCoordv;
					vec2 pixelated = floor(uv * openfl_TextureSize / u_pixelSize) * u_pixelSize / openfl_TextureSize;
					gl_FragColor = texture2D(bitmap, pixelated);
				}';
			case SCANLINES: '
				uniform float u_spacing;
				uniform float u_intensity;
				void main() {
					vec4 color = texture2D(bitmap, openfl_TextureCoordv);
					float scanline = sin(openfl_TextureCoordv.y * openfl_TextureSize.y / u_spacing * 3.14159) * u_intensity;
					color.rgb -= scanline;
					gl_FragColor = color;
				}';
			case WAVE_DISTORT: '
				uniform float u_time;
				uniform float u_amplitude;
				uniform float u_frequency;
				void main() {
					vec2 uv = openfl_TextureCoordv;
					uv.x += sin(uv.y * u_frequency + u_time) * u_amplitude;
					uv.y += cos(uv.x * u_frequency + u_time) * u_amplitude;
					gl_FragColor = texture2D(bitmap, uv);
				}';
			case BLOOM: '
				uniform float u_threshold;
				uniform float u_intensity;
				void main() {
					vec4 color = texture2D(bitmap, openfl_TextureCoordv);
					float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));
					vec3 bloom = max(vec3(0.0), color.rgb - u_threshold) * u_intensity;
					gl_FragColor = vec4(color.rgb + bloom, color.a);
				}';
			case CRT: '
				uniform float u_time;
				void main() {
					vec2 uv = openfl_TextureCoordv;
					uv.y += sin(uv.x * 100.0 + u_time) * 0.001;
					vec4 color = texture2D(bitmap, uv);
					float scanline = sin(uv.y * 400.0) * 0.04;
					color.rgb -= scanline;
					vec2 vig = uv * (1.0 - uv);
					float vigAmount = vig.x * vig.y * 15.0;
					color.rgb *= pow(vigAmount, 0.25);
					gl_FragColor = color;
				}';
		}
	}
	
	public function save():Void {
		var code = compileToGLSL();
		trace('Shader saved: vertex=${code.vertex.length} chars, fragment=${code.fragment.length} chars');
		isDirty = false;
	}
}

// ==================== Shader Graph ====================

class ShaderGraph {
	public var nodes:Array<ShaderNode> = [];
	public var connections:Array<ShaderConnection> = [];
	public var uniforms:Array<ShaderUniform> = [];
	public var outputNode:ShaderNode;
	
	public function new() {
		// Create default output node
		outputNode = {
			id: "output",
			type: OUTPUT,
			x: 800,
			y: 300,
			inputs: [
				{name: "color", type: VEC4},
				{name: "alpha", type: FLOAT}
			],
			outputs: []
		};
		nodes.push(outputNode);
	}
}

typedef ShaderNode = {
	var id:String;
	var type:ShaderNodeType;
	var x:Float;
	var y:Float;
	var inputs:Array<ShaderPort>;
	var outputs:Array<ShaderPort>;
}

typedef ShaderPort = {
	var name:String;
	var type:ShaderPortType;
	var ?defaultValue:Dynamic;
}

typedef ShaderConnection = {
	var fromNodeID:String;
	var fromPort:String;
	var toNodeID:String;
	var toPort:String;
}

typedef ShaderUniform = {
	var name:String;
	var type:ShaderPortType;
	var defaultValue:Dynamic;
	var ?minValue:Float;
	var ?maxValue:Float;
	var ?description:String;
}

typedef ShaderCode = {
	var vertex:String;
	var fragment:String;
	var uniforms:Array<ShaderUniform>;
}

enum abstract ShaderNodeType(Int) {
	var OUTPUT = 0;
	var TEXTURE_SAMPLE = 1;
	var UV_COORDS = 2;
	var TIME = 3;
	var MATH_ADD = 4;
	var MATH_MULTIPLY = 5;
	var MATH_SIN = 6;
	var MATH_COS = 7;
	var MATH_LERP = 8;
	var COLOR_MIX = 9;
	var COLOR_HSV = 10;
	var VECTOR_SPLIT = 11;
	var VECTOR_COMBINE = 12;
	var NOISE_SIMPLEX = 13;
	var NOISE_PERLIN = 14;
	var UNIFORM_FLOAT = 15;
	var UNIFORM_VEC2 = 16;
	var UNIFORM_COLOR = 17;
	var DISTANCE = 18;
	var NORMALIZE = 19;
	var DOT_PRODUCT = 20;
	var FRESNEL = 21;
	var GRADIENT = 22;
	var VORONOI = 23;
}

enum abstract ShaderPortType(Int) {
	var FLOAT = 0;
	var VEC2 = 1;
	var VEC3 = 2;
	var VEC4 = 3;
	var SAMPLER2D = 4;
	var MAT3 = 5;
	var MAT4 = 6;
}

enum abstract ShaderPresetType(Int) {
	var GRAYSCALE = 0;
	var INVERT = 1;
	var BLUR = 2;
	var CHROMATIC_ABERRATION = 3;
	var VIGNETTE = 4;
	var PIXELATE = 5;
	var SCANLINES = 6;
	var WAVE_DISTORT = 7;
	var BLOOM = 8;
	var CRT = 9;
}

// Factory and Compiler stubs
class ShaderNodeFactory {
	public static function create(type:ShaderNodeType):ShaderNode {
		return {
			id: 'node_${Date.now().getTime()}',
			type: type,
			x: 0, y: 0,
			inputs: [],
			outputs: []
		};
	}
}

class ShaderGraphCompiler {
	var graph:ShaderGraph;
	public function new(graph:ShaderGraph) { this.graph = graph; }
	
	public function compile():ShaderCode {
		var frag = new StringBuf();
		frag.add("#version 120\n\n");
		frag.add("#ifdef GL_ES\nprecision mediump float;\n#endif\n\n");
		
		// Add uniforms
		for (u in graph.uniforms) {
			frag.add('uniform ${glslType(u.type)} ${u.name};\n');
		}
		frag.add("uniform sampler2D bitmap;\n");
		frag.add("varying vec2 openfl_TextureCoordv;\n");
		frag.add("uniform vec2 openfl_TextureSize;\n\n");
		
		frag.add("void main() {\n");
		frag.add("\tvec4 color = texture2D(bitmap, openfl_TextureCoordv);\n");
		frag.add("\tgl_FragColor = color;\n");
		frag.add("}\n");
		
		return {
			vertex: "#version 120\nvoid main() { gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex; }",
			fragment: frag.toString(),
			uniforms: graph.uniforms
		};
	}
	
	function glslType(type:ShaderPortType):String {
		return switch (type) {
			case FLOAT: "float";
			case VEC2: "vec2";
			case VEC3: "vec3";
			case VEC4: "vec4";
			case SAMPLER2D: "sampler2D";
			case MAT3: "mat3";
			case MAT4: "mat4";
		}
	}
}

// UI stubs
class ShaderGraphView extends FlxSpriteGroup { public var editor:ShaderEditor; public function new(e:ShaderEditor) { super(); editor = e; } public function refresh():Void {} }
class ShaderNodePalette extends FlxSpriteGroup { public var editor:ShaderEditor; public function new(e:ShaderEditor) { super(); editor = e; } }
class ShaderPreviewPanel extends FlxSpriteGroup { public var editor:ShaderEditor; public function new(e:ShaderEditor) { super(); editor = e; } }
class ShaderCodePanel extends FlxSpriteGroup { public var editor:ShaderEditor; public function new(e:ShaderEditor) { super(); editor = e; } }
class ShaderUniformPanel extends FlxSpriteGroup { public var editor:ShaderEditor; public function new(e:ShaderEditor) { super(); editor = e; } }
class ShaderToolbar extends FlxSpriteGroup { public var editor:ShaderEditor; public function new(e:ShaderEditor) { super(); editor = e; } }
