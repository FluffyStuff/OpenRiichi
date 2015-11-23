#version 120

uniform sampler2D tex;
uniform vec4 diffuse_color;

varying vec2 frag_texture_coord;
varying vec3 light_color_original;
varying vec3 light_color_additive;

//varying out vec4 out_color;

void main()
{
	gl_FragColor = vec4(texture2D(tex, frag_texture_coord).xyz * light_color_original + light_color_additive, diffuse_color.a);
}
