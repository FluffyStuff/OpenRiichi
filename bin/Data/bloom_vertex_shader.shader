#version 330 core

in vec2 iTexcoord;
out vec2 oTexcoord;


void main(void)
{
	gl_Position = vec4(iTexcoord,0.0, 1.0);
	oTexcoord = iTexcoord;
	oTexcoord = (oTexcoord + 1.0f) / 2.0f;
}