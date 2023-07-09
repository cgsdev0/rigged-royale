shader_type spatial;
render_mode unshaded;

uniform float radius = 0.3;
uniform vec2 position = vec2(0.5, 0.5);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec3 blue(vec3 color)
{
	vec3 lum = vec3(0.299, 0.587, 0.114);
	float r = dot(lum, color) / 2.2 + 0.1;
	return vec3(r, r + 0.1, r + 0.2);
}

void fragment() {
    ALBEDO = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	ALBEDO = mix(ALBEDO, blue(ALBEDO), sign(distance(UV, position) - radius) / 2.0 + 0.5);
}