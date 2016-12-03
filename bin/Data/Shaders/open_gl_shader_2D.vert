#version 120

uniform mat3 model_transform;

attribute vec2 position;
varying vec2 frag_texture_coord;

void main(void)
{
	frag_texture_coord = (position + 1.0) / 2.0;
	frag_texture_coord.y = 1 - frag_texture_coord.y;
	
	gl_Position = vec4((model_transform * vec3(position, 1.0)).xy, 0.0, 1.0);
}