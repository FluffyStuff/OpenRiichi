#version 330 core
uniform sampler2D texi; 

in vec2 oTexcoord;
out vec4 outColor;
uniform float bloomy;
uniform float blacking;
uniform float intensity;
const float blurSize = 1.0/1024.0;
vec4 bloom_vertical( vec4 sum)
{
	vec2 coord = oTexcoord;
	sum += texture2D(texi, vec2(coord.x, coord.y - 4.0*blurSize)) * 0.05;
	sum += texture2D(texi, vec2(coord.x, coord.y - 3.0*blurSize)) * 0.09;
	sum += texture2D(texi, vec2(coord.x, coord.y - 2.0*blurSize)) * 0.12;
	sum += texture2D(texi, vec2(coord.x, coord.y - blurSize)) * 0.15;
	sum += texture2D(texi, vec2(coord.x, coord.y)) * 0.16;
	sum += texture2D(texi, vec2(coord.x, coord.y + blurSize)) * 0.15;
	sum += texture2D(texi, vec2(coord.x, coord.y + 2.0*blurSize)) * 0.12;
	sum += texture2D(texi, vec2(coord.x, coord.y + 3.0*blurSize)) * 0.09;
	sum += texture2D(texi, vec2(coord.x, coord.y + 4.0*blurSize)) * 0.05;
	vec4 color = sum*intensity + texture2D(texi, coord);
	return color;
}
vec4 bloom_horizontal()
{
	vec2 coord = oTexcoord;
	vec4 sum = vec4(0.0,0.0,0.0,0.0);
	sum += texture2D(texi, vec2(coord.x - 4.0*blurSize, coord.y)) * 0.05;
	sum += texture2D(texi, vec2(coord.x - 3.0*blurSize, coord.y)) * 0.09;
	sum += texture2D(texi, vec2(coord.x - 2.0*blurSize, coord.y)) * 0.12;
	sum += texture2D(texi, vec2(coord.x - blurSize, coord.y)) * 0.15;
	sum += texture2D(texi, vec2(coord.x, coord.y)) * 0.22;
	sum += texture2D(texi, vec2(coord.x + blurSize, coord.y)) * 0.15;
	sum += texture2D(texi, vec2(coord.x + 2.0*blurSize, coord.y)) * 0.12;
	sum += texture2D(texi, vec2(coord.x + 3.0*blurSize, coord.y)) * 0.09;
	sum += texture2D(texi, vec2(coord.x + 4.0*blurSize, coord.y)) * 0.05;
	//vec4 color = sum*intensity + texture2D(texi, coord); 
	return bloom_vertical(sum);
}

vec4 blackwhite(vec4 color)
{
	float value =(color.r + color.g + color.b) /3; 
	color.r = value;
	color.g = value;
	color.b = value;
	return color;
}

void main(void)
{	
	vec4 color;
	if(bloomy > 0.5)
		color = bloom_horizontal();
	else
		color = texture2D(texi, oTexcoord);
	if(blacking > 0.5)
		outColor = blackwhite(color);
	else
		outColor = color;
}
