shader_type canvas_item;

const float MAX_RADIUS = 0.75;
const float MIN_RADIUS = 0.3; 

uniform float brightness = 0.8;
uniform float energy = 0.5;

void fragment() {
	vec3 col = textureLod(TEXTURE, UV, 0.0).rgb;
	float radius = MIN_RADIUS + (MAX_RADIUS-MIN_RADIUS) * energy;
	if (distance(UV, vec2(0.5, 0.5)) > radius) {
		col.rgb = mix(vec3(0.0), col.rgb, brightness);
	}
	COLOR.rgb = col;
}
