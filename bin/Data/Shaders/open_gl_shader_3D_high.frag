#version 120
#define MAX_LIGHTS 2

uniform bool use_texture;
uniform sampler2D tex;
uniform int light_count;

varying vec2 frag_texture_coord;
varying vec3 frag_normal;
varying vec3 frag_camera_normal;

varying vec3 light_normals[MAX_LIGHTS];
varying float light_intensity[MAX_LIGHTS];
varying vec3 light_colors[MAX_LIGHTS];

// Material
uniform vec4 ambient_color;
uniform float ambient_material_multiplier;

uniform vec4 diffuse_color;
uniform float diffuse_material_multiplier;

uniform vec4 specular_color;
uniform float specular_material_multiplier;

uniform float specular_exponent;
uniform float alpha;

/* BLEND_TYPE
	COLOR = 0,
	MATERIAL = 1,
	BLEND = 2,
	HYBRID = 3
*/

/*vec4 color_blend(vec4 color_src, vec4 color_dst, int blend_type)
{
	switch (blend_type)
	{
	default:
	case 0:
		return color_src;
	case 1:
		return color_dst;
	case 2:
		return vec4(color_src.xyz * color_dst.a + color_dst.xyz * color_dst.a, max(color_src.a, color_dst.a));
	case 3:
		//return vec4(0.0, 0.0, 0.0, 1.0);
		return vec4(color_src.xyz * min(color_src.a, color_dst.a) + color_dst.xyz * min(color_src.a, color_dst.a) * 1.0, max(color_src.a, color_dst.a));
	}
}*/

#define BLEND_COLOR 1
#define BLEND_TEXTURE 2
#define BLEND_WITH_MATERIAL_MULTIPLIER 3
#define BLEND_WITHOUT_MATERIAL_MULTIPLIER 4

void calculate_lighting_factor(out vec4 diffuse_out, out vec4 specular_out)
{
	vec4 diffuse_in = vec4(1.0);
	vec4 specular_in = vec4(1.0);
	
	float blend_factor = 0.0;//0.005;
	float constant_factor = 0.01;
	float linear_factor = 0.8;
	float quadratic_factor = 0.5;
		
	vec3 normal = normalize(frag_normal);
	
	vec3 diffuse = vec3(0);//diffuse_in;//out_color.xyz * 0.02;
	vec3 specular = vec3(0);
	vec3 c = diffuse_in.xyz;//out_color.xyz;
	
	for (int i = 0; i < light_count; i++)
	{
		float intensity = light_intensity[i];
		
		float lnlen = max(length(light_normals[i]), 1);
		vec3 ln = normalize(light_normals[i]);
		vec3 cm = normalize(frag_camera_normal);
		
		float d = max(dot(normal, ln) / 1, 0);
		float plus = 0;
		plus += d * constant_factor;
		plus += d / lnlen * linear_factor;
		plus += d / pow(lnlen, 2) * quadratic_factor;
		
		diffuse += (c * (1-blend_factor) + light_colors[i] * blend_factor) * plus * intensity;
		
		if (dot(ln, normal) > 0) // Only reflect on the correct side
		{
			float s = max(dot(cm, reflect(-ln, normal)), 0);
			float spec = pow(s, specular_exponent);
			
			float p = 0;
			p += spec * constant_factor;
			p += spec / lnlen * linear_factor;
			p += spec / pow(lnlen, 2) * quadratic_factor;
			
			p = max(p, 0) * intensity;
			
			specular += (light_colors[i] * (1-blend_factor) * 0 + specular_in.xyz/* * blend_factor*/) * p;
		}
	}
	
	float dist = max(pow(length(frag_camera_normal) / 5, 1.0) / 10, 1);
	diffuse /= dist;
	specular /= dist;
	
	diffuse_out = vec4(diffuse, 1.0);
	specular_out = vec4(specular, 1.0);
}

vec4 base_color_blend(vec4 color, vec4 texture_color, float material_multiplier, int type)
{
	if (type == BLEND_COLOR)
		return color;
	else if (type == BLEND_TEXTURE)
		return texture_color;
	else if (type == BLEND_WITH_MATERIAL_MULTIPLIER)
		return color * color.a * (1.0 - texture_color.a * material_multiplier) + texture_color * texture_color.a * material_multiplier;
	else if (type == BLEND_WITHOUT_MATERIAL_MULTIPLIER)
		return color * color.a * (1.0 - texture_color.a)                       + texture_color * texture_color.a * material_multiplier;
	else
		return vec4(0);
}

void main()
{
	if (alpha <= 0)
		discard;
	
	vec4 t = use_texture ? texture2D(tex, frag_texture_coord) : vec4(0);
	
	vec4  ambient = base_color_blend( ambient_color, t,  ambient_material_multiplier, BLEND_WITHOUT_MATERIAL_MULTIPLIER);
	vec4  diffuse = base_color_blend( diffuse_color, t,  diffuse_material_multiplier, BLEND_WITHOUT_MATERIAL_MULTIPLIER);
	vec4 specular = base_color_blend(specular_color, t, specular_material_multiplier, BLEND_WITH_MATERIAL_MULTIPLIER);
	
	if (ambient.a <= 0 && diffuse.a <= 0)
		discard;
	
	vec4 diffuse_strength, specular_strength;
	calculate_lighting_factor(diffuse_strength, specular_strength);
	diffuse  *= diffuse_strength;
	specular *= specular_strength;
	
	vec4 out_color = ambient + diffuse + specular;
	if (out_color.a <= 0)
		discard;
	
	out_color.a = alpha;
	
	gl_FragColor = out_color;
}