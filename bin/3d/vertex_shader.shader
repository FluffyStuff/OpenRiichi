#version 330 core
#define MAX_LIGHTS 20
#define PI 3.1415926535897932384626433832795

struct lightSourceParameters 
{
   vec3 position;
   vec3 spotDirection;
};

struct lightNormalParameters
{
   vec3 normal;
};

uniform vec3 camera_rotation;
uniform vec3 camera_position;
uniform vec3 rotation_vec;
uniform vec3 position_vec;
uniform vec3 scale_vec;
uniform float aspect_ratio;
uniform lightSourceParameters light_source[MAX_LIGHTS];
uniform int light_count;

in vec4 position;
in vec3 texcoord;
in vec3 normals;

out vec3 Color;
out vec2 Texcoord;
out vec3 Normal;
out lightNormalParameters ls[MAX_LIGHTS];
out vec3 Camera_normal;
out vec3 noise_coord;

mat4 rotationMatrix(vec3 axis, float angle)
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

mat4 view_frustum(
    float angle_of_view,
    float aspect_ratio,
    float z_near,
    float z_far
) {
    return mat4(
        vec4(1.0/tan(angle_of_view/2),           0.0, 0.0, 0.0),
        vec4(0.0, aspect_ratio/tan(angle_of_view/2),  0.0, 0.0),
        vec4(0.0, 0.0,    (z_far+z_near)/(z_far-z_near), -1.0),
        vec4(0.0, 0.0, 2.0*z_far*z_near/(z_far-z_near), 0.0)
    );
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
	
	vec4 pos = scale(scale_vec) * position
    * rotationMatrix(vec3(0, 1, 0), PI * rotation_vec.y)
    * rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z);
	
	pos = translate(position_vec) * pos;
	
	pos = (translate(-camera_position) * pos)
    * rotationMatrix(vec3(0, 1, 0), PI * (camera_rotation.y + 1))
    * rotationMatrix(vec3(1, 0, 0), PI * camera_rotation.x)
	* rotationMatrix(vec3(0, 0, 1), PI * camera_rotation.z);
	
	gl_Position = pos * view_frustum(PI / 3, aspect_ratio, 0.5 * max(aspect_ratio, 1), 30 * max(aspect_ratio, 1));
	
	for (int i = 0; i < light_count; i++)
	{
		vec4 v = scale(scale_vec) * position
		* rotationMatrix(vec3(0, 1, 0), PI * rotation_vec.y)
		* rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
		* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z);
    
		ls[i].normal = light_source[i].position - (translate(position_vec) * v).xyz;
	}
	
	vec4 pn = scale(scale_vec) * position
    * rotationMatrix(vec3(0, 1, 0), PI * rotation_vec.y)
    * rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z);
	Camera_normal = camera_position - (translate(position_vec) * pn).xyz;
	
	vec3 sn = normalize(vec3(normals.x / scale_vec.x, normals.y / scale_vec.y, normals.z / scale_vec.z));
	Normal = (vec4(sn, 1.0)
	* rotationMatrix(vec3(0, 1, 0), PI * rotation_vec.y)
    * rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z)).xyz;
}