shader_type canvas_item;

// outline
uniform float outline_width = 1.0;
uniform vec4 outline_color: hint_color;
uniform bool is_outlined = false;

// dissolve
uniform sampler2D dissolveNoise;
uniform bool is_dissolve = false;

// stripe
uniform vec2 texture_size = vec2(137, 137);
uniform vec4 stripe_color : hint_color;
uniform float stripe_width = 4.0;
uniform float stripe_bias = 2.0;
uniform bool is_striped = false;
// set alpha
uniform bool is_created = false;

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
		COLOR = col;
	} else if (is_outlined) {
		COLOR = mix(col, outline_color, maxa - mina);
	} else if (is_striped) {
		float divisions = texture_size.x / stripe_width;
		//	vec2 base_uv = fract(UV * 2.0);
		if (floor(mod(UV.x * divisions, stripe_bias)) < 0.0001) {
			COLOR = col;
		} else {
			COLOR = mix(col, stripe_color, col.a * 0.7); 
		} 
	} else if (is_created)  {
		col.a = col.a * MODULATE.a;
		COLOR = col;
	} else {
		col.a = col.a * MODULATE.a;
		COLOR = col;
	}
}