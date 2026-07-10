#pragma header

uniform float u_intensity;
uniform float u_roundness;

void main()
{
	vec4 color = textureCam(bitmap, getCamPos(openfl_TextureCoordv));
	vec2 uv = openfl_TextureCoordv * 2.0 - 1.0;
	float vignette = 1.0 - pow(length(uv), u_roundness) * u_intensity;
	gl_FragColor = color * vignette;
}
