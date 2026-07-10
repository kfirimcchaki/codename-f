#pragma header

uniform float u_pixelSize;

void main()
{
	vec2 uv = openfl_TextureCoordv;
	vec2 pixelated = floor(uv * openfl_TextureSize / u_pixelSize) * u_pixelSize / openfl_TextureSize;
	gl_FragColor = texture2D(bitmap, pixelated);
}
