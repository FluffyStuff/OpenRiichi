#version 330 core

in vec2 texture_coord;
out vec2 frag_texture_coord;

void main(void)
{
	frag_texture_coord = texture_coord;
	frag_texture_coord = (frag_texture_coord + 1.0) / 2.0;
	gl_Position = vec4(texture_coord, 0.0, 1.0);
}