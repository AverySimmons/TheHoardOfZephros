shader_type canvas_item;

uniform float pixel_count = 50.;
uniform vec3 inner_color: source_color = vec3(1);
uniform vec3 outer_color: source_color = vec3(1);
uniform float pulse_speed = 1.;
uniform float alpha = 1.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 uv = UV;

	vec2 norm_uv = uv;
	norm_uv = norm_uv * 2. - 1.;

	vec2 pix_uv = norm_uv;
	pix_uv = round(pix_uv * pixel_count) / pixel_count;

	vec2 circ_uv = pix_uv;

	float pulse = sin(TIME * pulse_speed * 6.) * 0.01;
	float circ_sdf = length(circ_uv) - pulse;
	float circ_mask = 1. - circ_sdf;
	circ_mask = floor(circ_mask * 6.) / 6.;

	COLOR.a = circ_mask * alpha;
	COLOR.rgb = mix(outer_color, inner_color, circ_mask);

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
