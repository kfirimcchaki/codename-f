#pragma header

uniform float u_blurAmount;

void main()
{
	vec4 color = vec4(0.0);
	float total = 0.0;
	float offset = u_blurAmount / openfl_TextureSize.x;

	for (float x = -4.0; x <= 4.0; x += 1.0) {
		for (float y = -4.0; y <= 4.0; y += 1.0) {
			vec2 coord = openfl_TextureCoordv + vec2(x, y) * offset;
			float weight = 1.0 - length(vec2(x, y)) / 5.66;
			if (weight > 0.0) {
				color += texture2D(bitmap, coord) * weight;
				total += weight;
			}
		}
	}
	gl_FragColor = color / total;
}
