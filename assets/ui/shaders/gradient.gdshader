shader_type canvas_item;

uniform vec4 color_start : source_color = vec4(0.1, 0.1, 0.2, 1.0);
uniform vec4 color_end : source_color = vec4(0.4, 0.1, 0.5, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 gradient = mix(color_start, color_end, UV.x);
	gradient.a *= alpha;
	COLOR = gradient;
}