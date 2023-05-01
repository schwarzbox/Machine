shader_type canvas_item;

uniform bool is_element = false;

void fragment() {
	if (is_element)  {
		float gray = (COLOR.r + COLOR.g + COLOR.b + COLOR.a) / 4.0;
		COLOR = vec4(gray, gray, gray, gray);
	}
}
