#pragma header

uniform float u_amount;

void main()
{
	vec2 uv = openfl_TextureCoordv;
	float r = texture2D(bitmap, uv + vec2(u_amount, 0.0)).r;
	float g = texture2D(bitmap, uv).g;
	float b = texture2D(bitmap, uv - vec2(u_amount, 0.0)).b;
	float a = texture2D(bitmap, uv).a;
	gl_FragColor = vec4(r, g, b, a);
}
