shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 uv = UV;
	
	vec2 pix_uv = uv;
	pix_uv = floor(uv * 25.) / 25.;
	
	COLOR = texture(TEXTURE, pix_uv);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
