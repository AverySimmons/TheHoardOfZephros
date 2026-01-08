shader_type canvas_item;

uniform float percent = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 uv = UV;
	uv.y = 1. - uv.y;

	if (uv.y * 1.05 < percent) {COLOR.a = 0.;}


}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
