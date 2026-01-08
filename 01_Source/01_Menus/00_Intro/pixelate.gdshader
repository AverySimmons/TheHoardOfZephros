shader_type canvas_item;

uniform float pix_count = 50.;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 uv = SCREEN_UV;
	uv = uv * 2. - 1.;
	uv.x *= 16. / 9.;
	uv = round(uv * pix_count) / pix_count;
	uv.x *= 9. / 16.;
	uv = uv * 0.5 + 0.5;


	COLOR = texture(screen_texture, uv);

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
