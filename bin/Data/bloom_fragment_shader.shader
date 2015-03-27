#version 330 core
uniform sampler2D texi;
uniform sampler2D texi_2nd_pass;

in vec2 oTexcoord;
out vec4 outColor;

uniform float bloom;
uniform bool blacking;
uniform bool vertical;
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
	
	float halfed = size / 2;
	vec4 sum = vec4(0);
	
	ivec2 tex_size = textureSize(texi, 0);
	
	for (float i = -halfed; i < halfed; i++)
	{
		for (float j = -halfed; j < halfed; j++)
		{
			float strength = halfed - sqrt(i*i + j*j);
			strength /= halfed;
			strength = max(strength, 0);
			
			vec4 color = texture2D(texi, vec2(oTexcoord.x + i / tex_size.x * bias, oTexcoord.y + j / tex_size.y * bias));
			
			float s = (color.r + color.g + color.b) / 3;
			s = pow(s, intensity_curve);
			
			sum += color * strength / (size * size);
		}
	}
	
	return sum;
}

vec4 bloom_v(float size){
	ivec2 tex_size = textureSize(texi, 0);
	float halfed = size /2;
	float bias = 3.5;
	vec4 sum = texture2D(texi, oTexcoord);
	for(float i = -halfed; i < halfed; i++)
	{
		float strength = halfed - i;
		strength /= halfed;
		strength = max(strength, 0);
		vec4 color = texture2D(texi, vec2(oTexcoord.x + i / tex_size.x * bias, oTexcoord.y));
		sum+= color * strength / (size * size);
	}
	
	
	/*sum += texture2D(texi, vec2(oTexcoord.x - 4.0*blurSize, oTexcoord.y)) * 0.05;
	sum += texture2D(texi, vec2(oTexcoord.x - 3.0*blurSize, oTexcoord.y)) * 0.09;
	sum += texture2D(texi, vec2(oTexcoord.x - 2.0*blurSize, oTexcoord.y)) * 0.12;
	sum += texture2D(texi, vec2(oTexcoord.x - blurSize, oTexcoord.y)) * 0.15;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y)) * 0.16;
	sum += texture2D(texi, vec2(oTexcoord.x + blurSize, oTexcoord.y)) * 0.15;
	sum += texture2D(texi, vec2(oTexcoord.x + 2.0*blurSize, oTexcoord.y)) * 0.12;
	sum += texture2D(texi, vec2(oTexcoord.x + 3.0*blurSize, oTexcoord.y)) * 0.09;
	sum += texture2D(texi, vec2(oTexcoord.x + 4.0*blurSize, oTexcoord.y)) * 0.05;*/
	return sum;
}

vec4 bloom_h(float size){
	ivec2 tex_size = textureSize(texi_2nd_pass, 0);
	float halfed = size /2;
	float bias = 3.5;
	vec4 sum = texture2D(texi_2nd_pass, oTexcoord);
	for(float i = -halfed; i < halfed; i++)
	{
		float strength = halfed - i;
		strength /= halfed;
		strength = max(strength, 0);
		vec4 color = texture2D(texi_2nd_pass, vec2(oTexcoord.x, oTexcoord.y + i / tex_size.y * bias));
		sum+= color * strength / (size * size);
	}
	/*sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y - 4.0*blurSize)) * 0.05;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y - 3.0*blurSize)) * 0.09;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y - 2.0*blurSize)) * 0.12;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y - blurSize)) * 0.15;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y)) * 0.16;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y + blurSize)) * 0.15;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y + 2.0*blurSize)) * 0.12;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y + 3.0*blurSize)) * 0.09;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y + 4.0*blurSize)) * 0.05;*/
	return sum;
}

void main(void)
{
	float bloom_size = 50;
	float amplification = 10;
	
	vec4 color = texture2D(texi, oTexcoord);
	
	if (bloom > 0)
	{
		//color += get_bloom(bloom_size) * bloom * amplification;
		if(vertical){
			color = bloom_v(bloom_size);
		}
		else
			color += bloom_h(bloom_size)*intensity*amplification;
	}
	if (blacking)
		outColor = blackwhite(color);
	else
		outColor = color;
}
