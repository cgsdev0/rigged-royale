shader_type spatial;
render_mode unshaded;

uniform float radius = 0.3;
uniform vec2 position = vec2(0.5, 0.5);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
   if (abs(distance(UV, position) - radius) > 0.002) {
	discard;
	}
	ALBEDO = vec3(sin(TIME * 5.0) / 3.0 + 0.65);
}