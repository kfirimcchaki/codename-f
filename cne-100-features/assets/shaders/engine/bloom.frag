#pragma header

uniform float u_threshold;
uniform float u_intensity;
uniform float u_blurSize;

void main()
{
	vec4 color = texture2D(bitmap, openfl_TextureCoordv);
	float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));

	// Extract bright areas
	vec3 bloom = max(vec3(0.0), color.rgb - u_threshold) * u_intensity;

	// Simple blur for bloom
	vec3 blurred = vec3(0.0);
	float total = 0.0;
	for (float x = -2.0; x <= 2.0; x += 1.0) {
		for (float y = -2.0; y <= 2.0; y += 1.0) {
			vec2 offset = vec2(x, y) * u_blurSize / openfl_TextureSize;
			vec4 s = texture2D(bitmap, openfl_TextureCoordv + offset);
			float b = dot(s.rgb, vec3(0.299, 0.587, 0.114));
			float w = max(0.0, b - u_threshold);
			blurred += s.rgb * w;
			total += w;
		}
	}
	if (total > 0.0) blurred /= total;

	gl_FragColor = vec4(color.rgb + blurred * u_intensity, color.a);
}
