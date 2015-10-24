#version 330 core

uniform sampler2D texture;

uniform bool use_texture;
uniform vec4 diffuse_color;

in vec2 frag_texture_coord;
out vec4 out_color;

void main(void)
{
	vec4 color;
	if (use_texture)
		color = texture2D(texture, frag_texture_coord);
	else
		color = vec4(0.0, 0.0, 0.0, 1.0);
	color.xyz += diffuse_color.xyz;
	color.a *= diffuse_color.a;
	
	out_color = color;
}
