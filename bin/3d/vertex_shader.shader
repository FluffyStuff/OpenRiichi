#version 450 core
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
uniform lightSourceParameters light_source[20];
uniform int light_count;

in vec4 position;
in vec3 texcoord;
in vec3 normals;

out vec3 Color;
out vec2 Texcoord;
out vec3 Normal;
//out vec3 Position;
out lightNormalParameters ls[20];
out vec3 Camera_normal;

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
	
	vec4 pos = scale(scale_vec) * position
    * rotationMatrix(vec3(0, 1, 0), PI * (rotation_vec.y))
    * rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z);
	
	pos = translate(position_vec) * pos;
	
	for (int i = 0; i < light_count; i++)
	{
		vec3 p = light_source[i].position;
		vec4 whut = scale(scale_vec) * position
		* rotationMatrix(vec3(0, 1, 0), PI * (rotation_vec.y))
		* rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
		* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z);
		vec4 whut2 = vec4(normalize(vec3(p.x, p.y, p.z) - (translate(position_vec) * whut).xyz), 1);
    
		ls[i].normal = normalize((whut2
		/** rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
		* rotationMatrix(vec3(0, 1, 0), PI * (rotation_vec.y))
		* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z)*/).xyz);
		
		//ls[i].normal = normalize(vec3(-p.x, p.y, -p.z) - pos.xyz);
	}
	
	pos = translate(vec3(-camera_position.x, -camera_position.y, -camera_position.z)) * pos;
	
	pos = pos
    * rotationMatrix(vec3(0, 1, 0), PI * (camera_rotation.y + 1))
    * rotationMatrix(vec3(1, 0, 0), PI * camera_rotation.x)
	* rotationMatrix(vec3(0, 0, 1), PI * camera_rotation.z);
	
	gl_Position = pos * view_frustum(PI / 3, aspect_ratio, 0.5 * max(aspect_ratio, 1), 30 * max(aspect_ratio, 1));

	/*vec4 n = vec4(normals, 1.0)
    * rotationMatrix(vec3(0, 1, 0), PI * (rotation_vec.y + 1))
	* rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z);
	
	n = n
    * rotationMatrix(vec3(0, 1, 0), PI * (-camera_rotation.y * 2 + 1))
    * rotationMatrix(vec3(1, 0, 0), PI * camera_rotation.x * 2)
	* rotationMatrix(vec3(0, 0, 1), PI * -camera_rotation.z * 2);
	
	n *= view_frustum(PI / 3, 1, 0.5, 30);
	
	vec4 n = vec4(0, 0, 1, 0)
    * rotationMatrix(vec3(1, 0, 0), PI * camera_rotation.x)
    * rotationMatrix(vec3(0, 1, 0), PI * (-camera_rotation.y + 1))
	* rotationMatrix(vec3(0, 0, 1), PI * camera_rotation.z);
	Camera_normal = n.xyz;*/
	
	vec4 pn = position
    * rotationMatrix(vec3(0, 1, 0), PI * (rotation_vec.y))
    * rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z);
	
	Camera_normal = (vec4(normalize(vec3(camera_position.x, camera_position.y, camera_position.z) - pn.xyz), 1.0)
	/** rotationMatrix(vec3(1, 0, 0), PI * (-rotation_vec.y))
    * rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z)*/).xyz;
	Normal = (vec4(normalize(normals), 1.0)
	* rotationMatrix(vec3(0, 1, 0), PI * (rotation_vec.y))
    * rotationMatrix(vec3(1, 0, 0), PI * rotation_vec.x)
	* rotationMatrix(vec3(0, 0, 1), PI * rotation_vec.z)).xyz;
	//Position = gl_Position.xyz;
}