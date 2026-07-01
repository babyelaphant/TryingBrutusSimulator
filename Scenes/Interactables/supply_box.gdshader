shader_type spatial;
render_mode specular_disabled, vertex_lighting;

// --- MATERIAL SETTINGS ---
uniform sampler2D wood_texture : source_color, filter_nearest;
uniform vec4 color_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0); 

// --- RETRO EFFECT SETTINGS ---
uniform float jitter_resolution = 256.0; 
uniform bool use_affine = true;  
uniform float color_depth = 32.0;       

// --- PS1 FOG SETTINGS ---
// Dark, oppressive fog colors work best for horror
uniform vec4 fog_color : source_color = vec4(0.05, 0.05, 0.05, 1.0);
uniform float fog_near = 2.0;
uniform float fog_far = 8.0;

varying vec2 affine_uv;
varying float vertex_z;
varying float fog_factor;

void vertex() {
	// 1. VERTEX JITTER
	vec4 clip_pos = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec4 snapped_pos = clip_pos;
	
	snapped_pos.xyz /= snapped_pos.w;
	snapped_pos.xy = floor(snapped_pos.xy * jitter_resolution) / jitter_resolution;
	snapped_pos.xyz *= snapped_pos.w;
	
	POSITION = snapped_pos;

	// 2. AFFINE MAPPING PREP
	vertex_z = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).z;
	affine_uv = UV * vertex_z;
	
	// 3. VERTEX FOG CALCULATION
	// Calculate distance from the camera to the vertex
	float depth = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz);
	
	// Determine how much fog to apply based on distance (0.0 to 1.0)
	fog_factor = clamp((depth - fog_near) / (fog_far - fog_near), 0.0, 1.0);
}

void fragment() {
	vec2 final_uv = UV;
	
	if (use_affine) {
		final_uv = affine_uv / vertex_z;
	}

	vec4 tex_color = texture(wood_texture, final_uv);
	tex_color *= color_tint;

	// Color banding (Posterization)
	tex_color.rgb = floor(tex_color.rgb * color_depth) / color_depth;

	// Apply the fog interpolation
	ALBEDO = mix(tex_color.rgb, fog_color.rgb, fog_factor);
}
