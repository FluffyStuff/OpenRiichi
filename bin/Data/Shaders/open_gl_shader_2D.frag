#version 330 core

uniform sampler2D texture;

in vec2 frag_texture_coord;
out vec4 out_color;

void main(void)
{
	vec4 color = texture2D(texture, frag_texture_coord);
	color.a = 0.5;
	
	out_color = color;
}
