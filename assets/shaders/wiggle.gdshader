shader_type canvas_item;

const int EFFECT_TYPE_DREAMY = 0;
const int EFFECT_TYPE_WAVY = 1;
const int EFFECT_TYPE_HEAT_WAVE_HORIZONTAL = 2;
const int EFFECT_TYPE_HEAT_WAVE_VERTICAL = 3;
const int EFFECT_TYPE_FLAG = 4;

uniform int effectType : hint_enum("Dreamy", "Wavy", "Heat Horizontal", "Heat Vertical", "Flag") = 0;

uniform float speed;

uniform float frequency;

uniform float wave_amplitude;

vec2 sineWave(vec2 pt, sampler2D text) {
	float x = 0.0;
	float y = 0.0;
			
	if (effectType == EFFECT_TYPE_DREAMY) {
		float w = 1.0 / float(textureSize(text, 0).x);
		float h = 1.0 / float(textureSize(text, 0).y);

		// look mom, I know how to write shaders now

		pt.x = floor(pt.x / h) * h;

		float offsetX = sin(pt.x * frequency + TIME * speed) * wave_amplitude;
    
		pt.y += floor(offsetX / w) * w; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
		pt.y = floor(pt.y / w) * w;

		float offsetY = sin(pt.y * (frequency / 2.0) + TIME * (speed / 2.0)) * (wave_amplitude / 2.0);
    pt.x += floor(offsetY / h) * h; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
	} else if (effectType == EFFECT_TYPE_WAVY)  {
		float offsetY = sin(pt.x * frequency + TIME * speed) * wave_amplitude;
		pt.y += offsetY; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
	} else if (effectType == EFFECT_TYPE_HEAT_WAVE_HORIZONTAL) {
		x = sin(pt.x * frequency + TIME * speed) * wave_amplitude;
	} else if (effectType == EFFECT_TYPE_HEAT_WAVE_VERTICAL) {
		y = sin(pt.y * frequency + TIME * speed) * wave_amplitude;
	} else if (effectType == EFFECT_TYPE_FLAG) {
		y = sin(pt.y * frequency + 10.0 * pt.x + TIME * speed) * wave_amplitude;
		x = sin(pt.x * frequency + 5.0 * pt.y + TIME * speed) * wave_amplitude;
	}
			
	return vec2(pt.x + x, pt.y + y);
}

void fragment() {
	vec2 new_uv = sineWave(UV, TEXTURE);
	COLOR = texture(TEXTURE, new_uv);
}