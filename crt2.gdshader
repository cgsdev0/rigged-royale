// Based on: https://www.shadertoy.com/view/Ms23DR
shader_type canvas_item;

global uniform float crt_on;

vec2 curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;
	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv * 0.92 + 0.04;
	return uv;
}
void fragment(  )
{
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 q = FRAGCOORD.xy / iResolution.xy;
    vec2 uv = q;
    uv = curve( uv );
	float scans = clamp( 0.35+0.35*sin(3.5*TIME+uv.y*iResolution.y*1.5), 0.0, 1.0);
	float vig = (0.0 + 1.0*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y));
	float s = pow(scans,1.7);
	vec4 col = vec4(0.0);
	col = mix(col, vec4( vec3(0.0), 0.5), s);
	col = mix(col, vec4( vec3(0.0), 0.5), clamp(1.0 - vig * 2.0, 0.0, 1.0));

	vec4 black = vec4(vec3(0.1),1.0);
	col = mix(col, black, clamp(abs(UV.y - 0.5) * 100.0 * (1.0 - crt_on), 0.0, 1.0));
	col = mix(col, black, pow(1.0 - crt_on, 2.0));
	float curv = pow(abs(UV.y - 0.5), 3.0) / 3.0;
	black = vec4(vec3(0.02), 1.0);
	col = mix(col, black, sign(UV.x - 0.99 + curv) / 2.0 + 0.5);
	col = mix(black, col, sign(UV.x - 0.01 - curv) / 2.0 + 0.5);
	curv = pow(abs(UV.x - 0.5), 3.0) / 3.0;
	col = mix(col, black, sign(UV.y - 0.99 + curv) / 2.0 + 0.5);
	col = mix(black, col, sign(UV.y - 0.01 - curv) / 2.0 + 0.5);
    COLOR = col;
}