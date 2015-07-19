#version 330 core

uniform sampler2D texture;

uniform float alpha;
uniform vec3 diffuse_color;

in vec2 frag_texture_coord;
out vec4 out_color;

void main(void)
{
	vec4 color = texture2D(texture, frag_texture_coord);
	color.xyz += diffuse_color;
	color.a = alpha;
	
	out_color = color;
}
