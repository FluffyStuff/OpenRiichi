#version 130
#define MAX_LIGHTS 2
//#define PI 3.1415926535897932384626433832795

uniform sampler2D tex;
uniform int light_count;
uniform float light_multiplier;
uniform vec4 diffuse_color;

in vec2 frag_texture_coord;
in vec3 frag_normal;
in vec3 frag_camera_normal;

in vec3 light_normals[MAX_LIGHTS];
in float light_intensity[MAX_LIGHTS];
in vec3 light_colors[MAX_LIGHTS];

out vec4 out_color;

void main()
{
	vec3 normal = normalize(frag_normal);
	
	out_color = texture(tex, frag_texture_coord);
	out_color.xyz += diffuse_color.xyz;
	
	vec3 diffuse = out_color.xyz * 0.02;
	vec3 specular = vec3(0);
	vec3 c = out_color.xyz;
	
	for (int i = 0; i < light_count; i++)
	{
		float intensity = light_intensity[i];
		
		float blend_factor = 0.005;
		float constant_factor = 0.01;
		float linear_factor = 0.8;
		float quadratic_factor = 0.5;
		
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
			float spec = 0;
			spec += pow(s, 50)    * 0.02;
			spec += pow(s, 100)   * 0.02;
			spec += pow(s, 1000)  * 0.1;
			spec += pow(s, 10000) * 0.1;
			
			vec3 col = vec3(0);
			
			float p = 0;
			p += spec * constant_factor;
			p += spec / lnlen * linear_factor;
			p += spec / pow(lnlen, 2) * quadratic_factor;
			
			p = max(p, 0) * intensity;
			
			specular += (light_colors[i] * (1-blend_factor) + out_color.xyz * blend_factor) * p;
		}
	}
	
	out_color.xyz  = diffuse  * light_multiplier *  1;
	out_color.xyz += specular * light_multiplier * 16;
	
	
	out_color.xyz /= max(pow(length(frag_camera_normal) / 5, 1.0) / 10, 1);
	out_color.a = diffuse_color.a;
}