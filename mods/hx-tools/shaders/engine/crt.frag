#pragma header

uniform float u_time;
uniform float u_curvature;
uniform float u_scanlineIntensity;

void main()
{
	vec2 uv = openfl_TextureCoordv;

	// CRT barrel distortion
	vec2 centered = uv * 2.0 - 1.0;
	centered *= 1.0 + pow(abs(centered.yx), vec2(u_curvature)) * 0.1;
	uv = centered * 0.5 + 0.5;

	// Out of bounds = black
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}

	vec4 color = texture2D(bitmap, uv);

	// Scanlines
	float scanline = sin(uv.y * openfl_TextureSize.y * 1.5) * u_scanlineIntensity;
	color.rgb -= scanline;

	// RGB subpixels
	float r = texture2D(bitmap, uv + vec2(0.001, 0.0)).r;
	float g = color.g;
	float b = texture2D(bitmap, uv - vec2(0.001, 0.0)).b;
	color.rgb = vec3(r, g, b);

	// Vignette
	vec2 vig = uv * (1.0 - uv);
	float vigAmount = vig.x * vig.y * 15.0;
	color.rgb *= pow(vigAmount, 0.25);

	gl_FragColor = color;
}
