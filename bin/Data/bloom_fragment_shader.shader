#version 330 core
uniform sampler2D texi; 

in vec2 oTexcoord;
out vec4 outColor;
uniform float bloomy;
uniform float blacking;
uniform float intensity;
const float blurSize = 1.0/512.0;
vec4 bloom()
{
	vec4 sum = vec4(0.0,0.0,0.0,0.0);
	vec2 coord = oTexcoord;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + -4.0* blurSize)) * 0.002500;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + -3.0* blurSize)) * 0.004500;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + -2.0* blurSize)) * 0.006000;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + -1.0* blurSize)) * 0.007500;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + 0.0* blurSize)) * 0.008000;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + 1.0* blurSize)) * 0.007500;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + 2.0* blurSize)) * 0.006000;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + 3.0* blurSize)) * 0.004500;
	sum += texture2D(texi, vec2(coord.x + -4.0  * blurSize, coord.y + 4.0* blurSize)) * 0.002500;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + -4.0* blurSize)) * 0.004500;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + -3.0* blurSize)) * 0.008100;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + -2.0* blurSize)) * 0.010800;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + -1.0* blurSize)) * 0.013500;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + 0.0* blurSize)) * 0.014400;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + 1.0* blurSize)) * 0.013500;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + 2.0* blurSize)) * 0.010800;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + 3.0* blurSize)) * 0.008100;
	sum += texture2D(texi, vec2(coord.x + -3.0  * blurSize, coord.y + 4.0* blurSize)) * 0.004500;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + -4.0* blurSize)) * 0.006000;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + -3.0* blurSize)) * 0.010800;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + -2.0* blurSize)) * 0.014400;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + -1.0* blurSize)) * 0.018000;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + 0.0* blurSize)) * 0.019200;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + 1.0* blurSize)) * 0.018000;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + 2.0* blurSize)) * 0.014400;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + 3.0* blurSize)) * 0.010800;
	sum += texture2D(texi, vec2(coord.x + -2.0  * blurSize, coord.y + 4.0* blurSize)) * 0.006000;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + -4.0* blurSize)) * 0.007500;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + -3.0* blurSize)) * 0.013500;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + -2.0* blurSize)) * 0.018000;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + -1.0* blurSize)) * 0.022500;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + 0.0* blurSize)) * 0.024000;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + 1.0* blurSize)) * 0.022500;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + 2.0* blurSize)) * 0.018000;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + 3.0* blurSize)) * 0.013500;
	sum += texture2D(texi, vec2(coord.x + -1.0  * blurSize, coord.y + 4.0* blurSize)) * 0.007500;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + -4.0* blurSize)) * 0.008000;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + -3.0* blurSize)) * 0.014400;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + -2.0* blurSize)) * 0.019200;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + -1.0* blurSize)) * 0.024000;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + 0.0* blurSize)) * 0.025600;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + 1.0* blurSize)) * 0.024000;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + 2.0* blurSize)) * 0.019200;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + 3.0* blurSize)) * 0.014400;
	sum += texture2D(texi, vec2(coord.x + 0.0  * blurSize, coord.y + 4.0* blurSize)) * 0.008000;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + -4.0* blurSize)) * 0.007500;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + -3.0* blurSize)) * 0.013500;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + -2.0* blurSize)) * 0.018000;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + -1.0* blurSize)) * 0.022500;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + 0.0* blurSize)) * 0.024000;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + 1.0* blurSize)) * 0.022500;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + 2.0* blurSize)) * 0.018000;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + 3.0* blurSize)) * 0.013500;
	sum += texture2D(texi, vec2(coord.x + 1.0  * blurSize, coord.y + 4.0* blurSize)) * 0.007500;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + -4.0* blurSize)) * 0.006000;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + -3.0* blurSize)) * 0.010800;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + -2.0* blurSize)) * 0.014400;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + -1.0* blurSize)) * 0.018000;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + 0.0* blurSize)) * 0.019200;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + 1.0* blurSize)) * 0.018000;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + 2.0* blurSize)) * 0.014400;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + 3.0* blurSize)) * 0.010800;
	sum += texture2D(texi, vec2(coord.x + 2.0  * blurSize, coord.y + 4.0* blurSize)) * 0.006000;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + -4.0* blurSize)) * 0.004500;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + -3.0* blurSize)) * 0.008100;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + -2.0* blurSize)) * 0.010800;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + -1.0* blurSize)) * 0.013500;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + 0.0* blurSize)) * 0.014400;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + 1.0* blurSize)) * 0.013500;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + 2.0* blurSize)) * 0.010800;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + 3.0* blurSize)) * 0.008100;
	sum += texture2D(texi, vec2(coord.x + 3.0  * blurSize, coord.y + 4.0* blurSize)) * 0.004500;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + -4.0* blurSize)) * 0.002500;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + -3.0* blurSize)) * 0.004500;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + -2.0* blurSize)) * 0.006000;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + -1.0* blurSize)) * 0.007500;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + 0.0* blurSize)) * 0.008000;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + 1.0* blurSize)) * 0.007500;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + 2.0* blurSize)) * 0.006000;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + 3.0* blurSize)) * 0.004500;
	sum += texture2D(texi, vec2(coord.x + 4.0  * blurSize, coord.y + 4.0* blurSize)) * 0.002500;


	vec4 color = sum*intensity + texture2D(texi, coord);
	return color;
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
		color = bloom();
	else
		color = texture2D(texi, oTexcoord);
	if(blacking > 0.5)
		outColor = blackwhite(color);
	else
		outColor = color;
}
