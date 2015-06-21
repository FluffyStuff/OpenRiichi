#version 330 core
#define MAX_LIGHTS 9
#define PI 3.1415926535897932384626433832795

struct lightSourceParameters 
{
	vec3 position;
	vec3 color;
	float intensity;
	/*vec3 spotDirection;*/
};

//uniform mat4 model_transform;
uniform mat4 view_transform;
//uniform mat4 projection_transform;

uniform vec3 rotation_vec;
uniform vec3 position_vec;
uniform vec3 scale_vec;

uniform float aspect_ratio;
uniform float focal_length;

uniform int light_count;
uniform lightSourceParameters light_source[MAX_LIGHTS];

in vec4 position;
in vec3 texcoord;
in vec3 normals;

out vec2 Texcoord;
out vec3 Normal;
out vec3 Camera_normal;
out vec3 noise_coord;

out vec3 light_normals[MAX_LIGHTS];
out float light_intensity[MAX_LIGHTS];
out vec3 light_colors[MAX_LIGHTS];

mat4 view_frustum
(
	float angle_of_view,
	float aspect_ratio,
	float z_near,
	float z_far
)
{
	return mat4(
		vec4(1.0/tan(angle_of_view/2),           0.0, 0.0, 0.0),
		vec4(0.0, aspect_ratio/tan(angle_of_view/2),  0.0, 0.0),
		vec4(0.0, 0.0,    (z_far+z_near)/(z_far-z_near),   1.0),
		vec4(0.0, 0.0, -2.0*z_far*z_near /(z_far-z_near),   0.0)
	);
}

mat4 rotate(vec3 axis, float angle)
{
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
				oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
				oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
				0.0,                                0.0,                                0.0,                                1.0);
}

mat4 scale(vec3 vec)
{
	return mat4(
		vec4(vec.x, 0.0, 0.0, 0.0),
		vec4(0.0, vec.y, 0.0, 0.0),
		vec4(0.0, 0.0, vec.z, 0.0),
		vec4(0.0, 0.0, 0.0,   1.0)
	);
}

mat4 translate(vec3 vec)
{
	return mat4(
		vec4(1.0,   0.0,   0.0,   0.0),
		vec4(0.0,   1.0,   0.0,   0.0),
		vec4(0.0,   0.0,   1.0,   0.0),
		vec4(vec.x, vec.y, vec.z, 1.0)
	);
}

void main()
{
	Texcoord = texcoord.xy;
	noise_coord = position.xyz;
	
	mat4 rotation_matrix = 
	  rotate(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotate(vec3(0, 1, 0), PI * rotation_vec.y)
	* rotate(vec3(0, 0, 1), PI * rotation_vec.z);
	
	mat4 t = translate(position_vec);
	mat4 r = rotation_matrix;
	mat4 s = scale(scale_vec);
	
	mat4 model_transform = t * r * s;
	mat4 projection_transform = view_frustum(1.5 * focal_length, aspect_ratio, 0.5 * max(aspect_ratio, 1), 30 * max(aspect_ratio, 1));
	
	gl_Position = projection_transform * view_transform * model_transform * position;
	
	for (int i = 0; i < light_count; i++)
	{
		light_normals[i] = light_source[i].position - (model_transform * position).xyz;
		light_intensity[i] = light_source[i].intensity;
		light_colors[i] = light_source[i].color;
	}
	
	Camera_normal = (inverse(view_transform)[3] - (model_transform * position)).xyz;
	Normal = (vec4(normalize(normals), 1.0) * inverse(model_transform)).xyz;
}