#pragma header

uniform float u_spacing;
uniform float u_intensity;
uniform float u_time;

void main()
{
	vec4 color = textureCam(bitmap, getCamPos(openfl_TextureCoordv));
	float scanline = sin(openfl_TextureCoordv.y * openfl_TextureSize.y / u_spacing * 3.14159) * u_intensity;
	color.rgb -= scanline;

	// Subtle flicker
	float flicker = 0.98 + 0.02 * sin(u_time * 15.0);
	color.rgb *= flicker;

	gl_FragColor = color;
}
