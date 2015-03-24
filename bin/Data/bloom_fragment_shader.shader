#version 330 core
uniform sampler2D texi; 
in vec2 oTexcoord;
out vec4 outColor;
uniform float bloomy;
uniform float blacking;
uniform float intensity;

vec4 bloom()
{
	vec2 coord = oTexcoord;
	vec4 sum = vec4(0.0);
	float radius1 = 0.43;
	sum += texture2D(texi, coord + vec2(-1.5, -1.5)* radius1);
	sum += texture2D(texi, coord + vec2(-2.5, 0)  * radius1);
	sum += texture2D(texi, coord + vec2(-1.5, 1.5) * radius1);
	sum += texture2D(texi, coord + vec2(0, 2.5) * radius1);
	sum += texture2D(texi, coord + vec2(1.5, 1.5) * radius1);
	sum += texture2D(texi, coord + vec2(2.5, 0) * radius1);
	sum += texture2D(texi, coord + vec2(1.5, -1.5) * radius1);
	sum += texture2D(texi, coord + vec2(0, -2.5) * radius1);
	
	float radius2 = 1.8;
	sum += texture2D(texi, coord + vec2(-1.5, -1.5)* radius2);
	sum += texture2D(texi, coord + vec2(-2.5, 0)  * radius2);
	sum += texture2D(texi, coord + vec2(-1.5, 1.5) * radius2);
	sum += texture2D(texi, coord + vec2(0, 2.5) * radius2);
	sum += texture2D(texi, coord + vec2(1.5, 1.5) * radius2);
	sum += texture2D(texi, coord + vec2(2.5, 0) * radius2);
	sum += texture2D(texi, coord + vec2(1.5, -1.5) * radius2);
	sum += texture2D(texi, coord + vec2(0, -2.5) * radius2);
	
	sum *= 0.04;
	sum -= vec4(0.3,0.3,0.3,0.3);
	sum = max(sum, vec4(0,0,0,0));
	vec2 pos = (oTexcoord - vec2(0.5,0.5))*2;
	float dist = dot(pos,pos);
	dist = 1 -0.42*dist;
	vec4 color= (texture2D(texi, oTexcoord) * intensity + sum )* dist;
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
	if(bloomy < 0.5)
		color = bloom();
	else
		color = texture2D(texi, oTexcoord);
	if(blacking < 0.5)
		outColor = blackwhite(color);
	else
		outColor = color;
}
