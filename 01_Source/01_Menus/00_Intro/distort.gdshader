shader_type canvas_item;

uniform float pix_count = 150.;
uniform float distort_amount = 1.;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

//
// 2D simplex noise
// Author: Ian McEwan, Ashima Arts
//
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289((x * 34.0 + 1.0) * x); }

float snoise(vec2 v)
{
    const float C = 0.211324865405187;  // (3 - sqrt(3)) / 6
    const float D = 0.366025403784439;  // (sqrt(3) - 1) / 2

    // First corner
    vec2 i  = floor(v + dot(v, vec2(D)));
    vec2 x0 = v - i + dot(i, vec2(C));

    // Other corners
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

    vec2 x1 = x0 - i1 + vec2(C);
    vec2 x2 = x0 - 1.0 + 2.0 * vec2(C);

    // Permutation
    i = mod289(i);
    vec3 p = permute(
                permute(i.y + vec3(0.0, i1.y, 1.0))
              + i.x + vec3(0.0, i1.x, 1.0)
            );

    // Gradients
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.0);
    m = m * m;
    m = m * m;

    vec3 x = 2.0 * fract(p * (1.0 / 41.0)) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalize gradients implicitly
    return 70.0 * dot(
        m,
        a0 * vec3(x0.x, x1.x, x2.x) +
        h  * vec3(x0.y, x1.y, x2.y)
    );
}



mat2 rot2D(float a) {
    float c = cos(a), s = sin(a);
    return mat2(vec2(c, -s), vec2(s, c));
}



void fragment() {
	// Called for every pixel the material is visible on.

	vec2 uv = UV;
	vec2 norm_uv = uv;
	norm_uv = 2. * uv - 1.;

	vec2 pix_uv = norm_uv;
	pix_uv.x *= 16. / 9.;
	pix_uv = round(pix_uv * pix_count) / pix_count;
	pix_uv.x *= 9. / 16.;


	vec2 warp_uv = pix_uv;

	float n1 = snoise(warp_uv * 6.0 + TIME * 0.5);
	float n2 = snoise(warp_uv * 10.0 - TIME * 0.3);
	vec2 warp = vec2(n1, n2) * 1.3;

	warp_uv += warp * distort_amount;



	vec2 un_norm_uv = warp_uv;
	un_norm_uv = un_norm_uv * 0.5 + 0.5;

	COLOR = texture(screen_texture, un_norm_uv);




}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
