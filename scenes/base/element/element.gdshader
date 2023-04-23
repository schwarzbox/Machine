shader_type canvas_item;

// outline
uniform float outline_width = 2.0;
uniform vec4 outline_color: source_color;
uniform bool is_outlined = false;

// stripe
uniform vec2 texture_size = vec2(256, 256);
uniform vec4 stripe_color : source_color;
uniform float stripe_width = 24.0;
uniform float stripe_bias = 2.0;
uniform bool is_striped = false;

// set alpha
uniform float texture_alpha = 1.0;

// dissolve
uniform sampler2D dissolveNoise;
uniform bool is_dissolve = false;

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
		col.a *= step(texture_alpha, noise);
		COLOR = col;
	} else if (is_outlined) {
		COLOR = mix(col, outline_color, maxa - mina);
	} else if (is_striped) {
		
		float divisions = texture_size.x / stripe_width;
//		reduce size
//		vec2 base_uv = fract(UV * 2.0);
		if (floor(mod((UV.y - UV.x) * divisions, stripe_bias)) < 0.01) {
			COLOR = col;
		} else {
			COLOR = mix(col, stripe_color, col.a * 0.7); 
		} 
	} else {
		col.a = col.a * texture_alpha;
		COLOR = col;
	}
}