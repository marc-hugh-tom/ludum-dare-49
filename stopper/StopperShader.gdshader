shader_type canvas_item;

uniform float t : hint_range(0.0, 1.0);
uniform float starting_t : hint_range(0.0, 0.1);
uniform float blue_filter : hint_range(0.0, 1.0);
uniform vec4 fill_color : hint_color;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float mod_t = t * (0.5 - starting_t);

	if (col.b < blue_filter &&
		abs(0.5-UV.x) < mod_t) {
		
		vec2 new_uv;
		if (UV.x > 0.5) {
			new_uv = vec2(UV.x + (0.5-mod_t-starting_t), UV.y);
		} else {
			new_uv = vec2(UV.x - (0.5-mod_t-starting_t), UV.y);
		}
		vec4 new_col = texture(TEXTURE, new_uv);

		if (new_col.b < blue_filter) {
			col = fill_color
		}
	}

	COLOR = col;
}
