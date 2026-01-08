shader_type canvas_item;

uniform float layers = 100.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 uv = UV;
	uv = 2. * uv - 1.;

	float circ_sdf = length(uv);
	float circ_mask = 1. - circ_sdf;

	COLOR.g += circ_mask * 0.1;

	COLOR.r = floor(COLOR.r * layers) / layers;
	COLOR.g = floor(COLOR.g * layers) / layers;
	COLOR.b = floor(COLOR.b * layers) / layers;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
