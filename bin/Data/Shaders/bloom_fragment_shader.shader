#version 330 core
#define PI 3.1415926535897932384626433832795
#define E1 2.7182818284590452353602874713526
#define E2 0.3989422804014326779399460599343

in vec2 frag_texture_coord;
out vec4 out_color;

uniform sampler2D textures[2];
uniform float bloom;
uniform bool vertical;

float gauss(float x)
{
	return E2 * pow(E1, -x*x/2);
}

vec4 bloom_h(float size, sampler2D texture, vec2 coord)
{
	ivec2 tex_size = textureSize(texture, 0);
	float halfed = size / 2;
	vec4 sum = vec4(0);
	
	for (float i = -halfed; i < halfed; i++)
	{
		float strength = max(gauss(i / size * 5), 0);
		vec4 color = texture2D(texture, vec2(coord.x + i / tex_size.x, coord.y));
		sum += color * strength / size;
	}
	
	return sum;
}

vec4 bloom_v(float size, sampler2D texture, vec2 coord)
{
	ivec2 tex_size = textureSize(texture, 0);
	float halfed = size / 2;
	vec4 sum = vec4(0);
	
	for (float i = -halfed; i < halfed; i++)
	{
		float strength = max(gauss(i / size * 5), 0);
		vec4 color = texture2D(texture, vec2(coord.x, coord.y + i / tex_size.y));
		sum += color * strength / size;
	}
	
	return sum;
}

void main(void)
{
	float bloom_size = 200;
	float amplification = 15;
	
	vec4 color = texture2D(textures[0], frag_texture_coord);
	
	if (bloom > 0)
	{
		if (vertical)
			color = vec4(bloom_v(bloom_size, textures[0], frag_texture_coord).xyz, 1.0) * amplification * bloom;
		else
			color += vec4(bloom_h(bloom_size, textures[1], frag_texture_coord).xyz, 1.0) * amplification * bloom;
	}
	
	out_color = color;
}
