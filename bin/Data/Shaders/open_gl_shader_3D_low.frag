#version 120
#define MAX_LIGHTS 2

uniform bool use_texture;
uniform sampler2D tex;

varying vec2 frag_texture_coord;
varying vec4 diffuse_strength;
varying vec4 specular_strength;

// Material
uniform vec4 ambient_color;
uniform float ambient_material_multiplier;

uniform vec4 diffuse_color;
uniform float diffuse_material_multiplier;

uniform vec4 specular_color;
uniform float specular_material_multiplier;

uniform float specular_exponent;
uniform float alpha;

#define BLEND_COLOR 1
#define BLEND_TEXTURE 2
#define BLEND_WITH_MATERIAL_MULTIPLIER 3
#define BLEND_WITHOUT_MATERIAL_MULTIPLIER 4

vec4 base_color_blend(vec4 color, vec4 texture_color, float material_multiplier, int type)
{
	if (type == BLEND_COLOR)
		return color;
	else if (type == BLEND_TEXTURE)
		return texture_color;
	else if (type == BLEND_WITH_MATERIAL_MULTIPLIER)
		return color * color.a * (1.0 - texture_color.a * material_multiplier) + texture_color * texture_color.a * material_multiplier;
	else if (type == BLEND_WITHOUT_MATERIAL_MULTIPLIER)
		return color * color.a * (1.0 - texture_color.a)                       + texture_color * texture_color.a * material_multiplier;
	else
		return vec4(0);
}

void main()
{
	if (alpha <= 0)
		discard;
	
	vec4 t = use_texture ? texture2D(tex, frag_texture_coord) : vec4(0);
	
	vec4  ambient = base_color_blend( ambient_color, t,  ambient_material_multiplier, BLEND_WITHOUT_MATERIAL_MULTIPLIER);
	vec4  diffuse = base_color_blend( diffuse_color, t,  diffuse_material_multiplier, BLEND_WITHOUT_MATERIAL_MULTIPLIER);
	vec4 specular = base_color_blend(specular_color, t, specular_material_multiplier, BLEND_WITH_MATERIAL_MULTIPLIER);
	
	if (ambient.a <= 0 && diffuse.a <= 0)
		discard;
	
	diffuse  *= diffuse_strength;
	specular *= specular_strength;
	
	vec4 out_color = ambient + diffuse + specular;
	if (out_color.a <= 0)
		discard;
	
	out_color.a = alpha;
	
	gl_FragColor = out_color;
}