#version 120
#define MAX_LIGHTS 2

struct lightSourceParameters 
{
	vec3 position;
	vec3 color;
	float intensity;
};

uniform mat4 projection_transform;
uniform mat4 view_transform;
uniform mat4 model_transform;
uniform mat4 un_projection_transform;
uniform mat4 un_view_transform;
uniform mat4 un_model_transform;

uniform int light_count;
uniform lightSourceParameters light_source[MAX_LIGHTS];
uniform float specular_exponent;

attribute vec4 position;
attribute vec3 texture_coord;
attribute vec3 normal;

varying vec4 diffuse_strength;
varying vec4 specular_strength;

varying vec2 frag_texture_coord;
varying vec3 frag_normal;
varying vec3 frag_camera_normal;

varying vec3 light_normals[MAX_LIGHTS];
varying float light_intensity[MAX_LIGHTS];
varying vec3 light_colors[MAX_LIGHTS];

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

void main()
{
	vec3 mod_pos = (model_transform * position).xyz;
	for (int i = 0; i < light_count; i++)
	{
		light_normals[i] = light_source[i].position - mod_pos;
		light_intensity[i] = light_source[i].intensity;
		light_colors[i] = light_source[i].color;
	}
	
	frag_texture_coord = texture_coord.xy;
	frag_normal = (vec4(normalize(normal), 1.0) * un_model_transform).xyz;
	frag_camera_normal = un_view_transform[3].xyz - mod_pos;
	gl_Position = projection_transform * view_transform * model_transform * position;
	
	vec4 diffuse_str, specular_str;
	calculate_lighting_factor(diffuse_str, specular_str);
	
	diffuse_strength = diffuse_str;
	specular_strength = specular_str;
}