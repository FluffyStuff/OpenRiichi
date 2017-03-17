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

varying vec3 light_normals0;
varying float light_intensity0;
varying vec3 light_colors0;

varying vec3 light_normals1;
varying float light_intensity1;
varying vec3 light_colors1;

void main()
{
	vec3 mod_pos = (model_transform * position).xyz;

	light_normals0 = light_source[0].position - mod_pos;
	light_intensity0 = light_source[0].intensity;
	light_colors0 = light_source[0].color;
	
	light_normals1 = light_source[1].position - mod_pos;
	light_intensity1 = light_source[1].intensity;
	light_colors1 = light_source[1].color;
	
	frag_texture_coord = texture_coord.xy;
	frag_normal = (vec4(normalize(normal), 1.0) * un_model_transform).xyz;
	frag_camera_normal = un_view_transform[3].xyz - mod_pos;
	gl_Position = projection_transform * view_transform * model_transform * position;
}