#pragma header

uniform float u_intensity;
uniform float u_time;

// Simple pseudo-random
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main()
{
	vec4 color = texture2D(bitmap, openfl_TextureCoordv);

	// Film grain
	float grain = hash(openfl_TextureCoordv * openfl_TextureSize + u_time * 100.0);
	grain = (grain - 0.5) * u_intensity;
	color.rgb += grain;

	// Subtle sepia tint
	color.r *= 1.02;
	color.b *= 0.95;

	gl_FragColor = color;
}
