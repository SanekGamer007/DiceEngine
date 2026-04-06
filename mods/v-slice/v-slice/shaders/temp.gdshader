shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec2 curve(vec2 uv) {
	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;	
	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv *0.92 + 0.04;
	return uv;
}

void fragment() {
	vec2 q = UV;
    vec2 uv = q;
	// vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    uv = curve( uv );
	vec4 oricol = texture(screen_texture, uv);
    vec4 col = texture(screen_texture, uv);
	col.a = 1.0;
	float x =  0.0; //sin(0.3*time+uv.y*21.0)*sin(0.7*time+uv.y*29.0)*sin(0.3+0.33*time+uv.y*31.0)*0.0017;

    col.r = texture(screen_texture,vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
    col.g = texture(screen_texture,vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
    col.b = texture(screen_texture,vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
    col.r += 0.08*texture(screen_texture,0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
    col.g += 0.05*texture(screen_texture,0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
    col.b += 0.08*texture(screen_texture,0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

    col = clamp(col*0.6+0.4*col*col*1.0,0.0,1.0);

    float vig = (0.0 + 1.0*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y));
	col *= vec4(pow(vig,0.3), pow(vig,0.3), pow(vig,0.3), 1.0);

	col *= vec4(0.95,1.05,0.95, 1.0);
	col *= 2.8;

	float scans = clamp( 0.35+0.35*sin(3.5*1.0+uv.y*TEXTURE_PIXEL_SIZE.y*1.5), 0.0, 1.0);
	
	float s = pow(scans,1.7);
	col = col*vec4( 0.4+0.7*s, 0.4+0.7*s, 0.4+0.7*s, 1.0) ;

	col *= 1.0+0.01*sin(110.0*TIME);
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0){
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		float comp = smoothstep( 0.1, 0.9, sin(TIME) );
		col.a = oricol.a;
		COLOR = col;
	}
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
