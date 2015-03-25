#version 330 core
uniform sampler2D texi; 

in vec2 oTexcoord;
out vec4 outColor;

uniform float bloom;
uniform bool blacking;

uniform float intensity; // Hue

vec4 blackwhite(vec4 color)
{
	float value = (color.r + color.g + color.b) / 3;
	color.r = value;
	color.g = value;
	color.b = value;
	return color;
}

vec4 get_bloom(float size)
{
	float bias = 3.5; // Stupid, but we need it because we have such a short range available
	float intensity_curve = 2; // Make the bloom intensity dependant on the combined color amplitude
	
	float half = size / 2;
	vec4 sum = vec4(0);
	
	ivec2 tex_size = textureSize(texi, 0);
	
	for (float i = -half; i < half; i++)
	{
		for (float j = -half; j < half; j++)
		{
			float strength = half - sqrt(i*i + j*j);
			strength /= half;
			strength = max(strength, 0);
			
			vec4 color = texture2D(texi, vec2(oTexcoord.x + i / tex_size.x * bias, oTexcoord.y + j / tex_size.y * bias));
			
			float s = (color.r + color.g + color.b) / 3;
			s = pow(s, intensity_curve);
			
			sum += color * strength / (size * size);
		}
	}
	
	return sum;
}

void main(void)
{
	float bloom_size = 9;
	float amplification = 10;
	
	vec4 color = texture2D(texi, oTexcoord) + get_bloom(bloom_size) * bloom * amplification;
	
	if (blacking)
		outColor = blackwhite(color);
	else
		outColor = color;
}
