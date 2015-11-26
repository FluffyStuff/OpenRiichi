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

attribute vec4 position;
attribute vec3 texture_coord;
attribute vec3 normal;

varying vec2 frag_texture_coord;
varying vec3 frag_normal;
varying vec3 frag_camera_normal;

varying vec3 light_normals[MAX_LIGHTS];
varying float light_intensity[MAX_LIGHTS];
varying vec3 light_colors[MAX_LIGHTS];

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
}