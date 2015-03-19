#version 330 core
uniform sampler2D texi; 
in vec2 oTexcoord;
out vec4 outColor;
 
const float blurSize = 1.0/512.0; 
const float intensity = 0.35;
void main(void)
{
	vec4 sum = vec4(0.0);
	//Semi Gaussian Blur
	/*sum += texture2D(texi, vec2(oTexcoord.x - 4.0*blurSize, oTexcoord.y)) * 0.05;
	sum += texture2D(texi, vec2(oTexcoord.x - 3.0*blurSize, oTexcoord.y)) * 0.09;
	sum += texture2D(texi, vec2(oTexcoord.x - 2.0*blurSize, oTexcoord.y)) * 0.12;
	sum += texture2D(texi, vec2(oTexcoord.x - blurSize, oTexcoord.y)) * 0.15;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y)) * 0.16;
	sum += texture2D(texi, vec2(oTexcoord.x + blurSize, oTexcoord.y)) * 0.15;
	sum += texture2D(texi, vec2(oTexcoord.x + 2.0*blurSize, oTexcoord.y)) * 0.12;
	sum += texture2D(texi, vec2(oTexcoord.x + 3.0*blurSize, oTexcoord.y)) * 0.09;
	sum += texture2D(texi, vec2(oTexcoord.x + 4.0*blurSize, oTexcoord.y)) * 0.05;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y - 4.0*blurSize)) * 0.05;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y - 3.0*blurSize)) * 0.09;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y - 2.0*blurSize)) * 0.12;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y - blurSize)) * 0.15;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y)) * 0.16;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y + blurSize)) * 0.15;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y + 2.0*blurSize)) * 0.12;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y + 3.0*blurSize)) * 0.09;
	sum += texture2D(texi, vec2(oTexcoord.x, oTexcoord.y + 4.0*blurSize)) * 0.05;*/
	outColor.r = 1;
	outColor.g = 0;
	outColor.b = 0;
	outColor.a = 1;
}