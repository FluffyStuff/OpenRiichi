#version 330 core

uniform sampler2D tex;
uniform vec4 diffuse_color;

in vec2 frag_texture_coord;
in vec3 light_color_original;
in vec3 light_color_additive;

out vec4 out_color;

void main()
{
	out_color = vec4(texture(tex, frag_texture_coord).xyz * light_color_original + light_color_additive, diffuse_color.a);
}
