shader_type canvas_item;


uniform vec4 stripe_color : hint_color;
uniform float divisions = 64;
uniform float stripe_bias = 2;
uniform float speed = 0.001;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	if (floor(mod(UV.x - (speed * TIME) * divisions, stripe_bias)) < 0.0001) {
		COLOR = col;
	} else {
		COLOR = mix(col, stripe_color, col.a); 
	}
}