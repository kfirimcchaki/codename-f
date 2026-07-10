#pragma header

uniform float u_time;
uniform float u_amplitude;
uniform float u_frequency;

void main()
{
	vec2 uv = openfl_TextureCoordv;
	uv.x += sin(uv.y * u_frequency + u_time) * u_amplitude;
	uv.y += cos(uv.x * u_frequency + u_time * 0.7) * u_amplitude;
	gl_FragColor = texture2D(bitmap, uv);
}
