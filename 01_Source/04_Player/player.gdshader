shader_type canvas_item;

uniform vec4 outline_color: source_color;
uniform vec4 center_color: source_color;
uniform vec4 outer_color: source_color;

uniform float size = 1.;
uniform float pixel_count = 50.;

uniform vec2 velocity = vec2(0,0);


float sdEllipse(vec2 p, vec2 r) {
	// p: point, r: radii
	float k0 = length(p / r);
	float k1 = length(p / (r * r)) ;
	return k0*(k0 - 1.0)/k1;
}


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	float real_size = size * 1.2;
	
	
	vec2 uv = UV;
	
	vec2 norm_uv = uv;
	norm_uv = 2. * norm_uv - 1.;
	norm_uv *= 2.;
	
	vec2 pix_uv = norm_uv;
	pix_uv = round(pix_uv * pixel_count) / pixel_count;
	
	vec2 warp_uv = pix_uv;
	
	warp_uv.y += velocity.y * (warp_uv.x * warp_uv.x);
	warp_uv.x -= sin(warp_uv.y * 3.0) * velocity.x * 0.1;
	
	if (abs(warp_uv.x) > 0.01 && velocity.y > 0.) {
		
		if (warp_uv.y > -0.5) {warp_uv.y -= 0.005;}
		else {warp_uv.y += 0.005;}
		
	}
	
	
	vec2 oval_uv = warp_uv;
	
	float bounce = pow(abs(sin(TIME * 6.0)), 0.6);
	
	oval_uv.y += (bounce * 0.1 + 0.1) * real_size;
	float oval_x_size = 0.6 - 0.1 * bounce;
	float oval_y_size = 0.4 + 0.1 * bounce;
	vec2 oval_size = vec2(oval_x_size, oval_y_size) * real_size;
	float oval_sdf = sdEllipse(oval_uv, oval_size);
	float oval_outline_mask = abs(oval_sdf);
	float oval_mask = step(oval_sdf, 0.001);
	oval_outline_mask = step(oval_outline_mask, 0.01);
	
	if (warp_uv.y > 0.) {
		COLOR.a = 0.;
	}
	
	else if (oval_outline_mask > 0.) {
		COLOR = outline_color;
	}
	
	else if (oval_mask > 0. && abs(warp_uv.y) < 0.02) {
		COLOR = outline_color;
	}
	
	else if (oval_mask > 0.) {
		COLOR = mix(outer_color, center_color, -oval_sdf / size);
	}
	
	else {
		COLOR.a = 0.;
	}
	
	
	COLOR.r = floor(COLOR.r * 16.) / 16.;
	COLOR.g = floor(COLOR.g * 16.) / 16.;
	COLOR.b = floor(COLOR.b * 16.) / 16.;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
