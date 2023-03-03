shader_type canvas_item;

uniform vec4 stripe_color : source_color;
uniform float divisions = 16;
uniform float stripe_bias = 2;
uniform float speed = 0.1;
uniform bool is_energy = false;

void fragment() {
	vec4 col = texture(TEXTURE, vec2(0.0, 1.0));
	
	if (is_energy) {
		if (floor(mod(UV.x - (speed * TIME) * divisions, stripe_bias)) < 0.0001) {
			COLOR = col;
		} else {
			COLOR = mix(col, stripe_color, col.a); 
		}
	} else {
		COLOR = col;
	}
	
}