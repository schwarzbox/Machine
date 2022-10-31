shader_type canvas_item;

uniform sampler2D dissolveNoise;
uniform bool is_dissolve = false;

uniform float outline_width = 1.0;
uniform vec4 outline_color: hint_color;
uniform bool is_outlined = false;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float a;
	float maxa = col.a;
	float mina = col.a;

	a = texture(TEXTURE, UV + vec2(0.0, -outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(0.0, outline_width) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(-outline_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	a = texture(TEXTURE, UV + vec2(outline_width, 0.0) * ps).a;
	maxa = max(a, maxa);
	mina = min(a, mina);

	if (is_dissolve) {
		float noise = texture(dissolveNoise, UV).r;
		col.a *= step(MODULATE.a, noise);
	} 
	if (is_outlined && !is_dissolve) {
		COLOR = mix(col, outline_color, maxa - mina);
	} else {
		COLOR = col;
	}
}