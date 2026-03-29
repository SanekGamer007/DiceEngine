shader_type canvas_item;
uniform float strenght: hint_range(1.0, 2.0, 0.05) = 0.0;

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	COLOR = vec4(strenght - color.rgb, color.a);
}

