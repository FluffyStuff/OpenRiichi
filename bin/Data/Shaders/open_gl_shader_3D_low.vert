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

uniform float light_multiplier;
uniform vec4 diffuse_color;

uniform int light_count;
uniform lightSourceParameters light_source[MAX_LIGHTS];

attribute vec4 position;
attribute vec3 texture_coord;
attribute vec3 normal;

varying vec2 frag_texture_coord;
varying vec3 light_color_original;
varying vec3 light_color_additive;

void main()
{
	vec3 mod_pos = (model_transform * position).xyz;
	vec3 frag_camera_normal = un_view_transform[3].xyz - mod_pos;
	vec3 frag_normal = normalize((vec4(normal, 1.0) * un_model_transform).xyz);
	
	vec3 original = vec3(0.02);
	vec3 additive = vec3(0);
	vec3 c = vec3(1) + diffuse_color.xyz;
	
	for (int i = 0; i < light_count; i++)
	{
		vec3 light_normal = light_source[i].position - mod_pos;
		float intensity = light_source[i].intensity;
		vec3 light_color = light_source[i].color;
		
		/////////////
		float blend_factor = 0.005;
		float constant_factor = 0.01;
		float linear_factor = 0.8;
		float quadratic_factor = 0.5;
		
		float lnlen = max(length(light_normal), 1);
		vec3 ln = normalize(light_normal);
		vec3 cm = normalize(frag_camera_normal);
		
		float d = max(dot(frag_normal, ln), 0);
		float plus = 0;
		plus += d * constant_factor;
		plus += d / lnlen * linear_factor;
		plus += d / pow(lnlen, 2) * quadratic_factor;
		
		original += c * (1-blend_factor) * plus * intensity;
		additive += light_color * blend_factor * plus * intensity;
		//////////////
		
		if (dot(ln, frag_normal) > 0) // Only reflect on the correct side
		{
			float s = max(dot(cm, reflect(-ln, frag_normal)), 0);
			float spec = 0;
			spec += pow(s, 10)    * 0.02;
			spec += pow(s, 100)   * 0.02;
			spec += pow(s, 1000)  * 0.1;
			spec += pow(s, 10000) * 0.1;
			
			float p = 0;
			p += spec * constant_factor;
			p += spec / lnlen * linear_factor;
			p += spec / pow(lnlen, 2) * quadratic_factor;
			
			p = max(p, 0) * intensity * 4;
			
			original += c * blend_factor * p;
			additive += light_color * (1-blend_factor) * p;
		}
	}
	
	float p = light_multiplier / max(pow(length(frag_camera_normal) / 5, 1.0) / 10, 1);
	light_color_original = original * p;
	light_color_additive = additive * p;
	
	frag_texture_coord = texture_coord.xy;
	gl_Position = projection_transform * view_transform * model_transform * position;
}
