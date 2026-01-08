shader_type canvas_item;

uniform float animation = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 norm_uv = UV * 2. - 1.;

	vec2 pix_uv = round(norm_uv * 6.) / 6.;

	float mask = abs(pix_uv.y);

	if (mask <= animation) {
		COLOR.a = 0.;
	}

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
