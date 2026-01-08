shader_type canvas_item;

uniform float animation = 0.;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

const vec2 DIRS[] = {
	vec2(1,0),
	vec2(-1,0),
	vec2(0,1),
	vec2(0,-1)
};

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 uv = SCREEN_UV;
	
	vec3 col = vec3(0);
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			float leng = 0.002 * float(j+1);
			vec2 samp = uv + DIRS[i] * leng * animation;
			col += texture(screen_texture, samp).rgb * (1. / (4. * 4.));
		}
		
		
	}
	
	COLOR.rgb = col.rgb;
	COLOR.rgb *= 0.25;
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
