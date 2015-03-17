uniform sampler2D tex; 
in vec2 Texcoord;

 
const float blurSize = 1.0/512.0; 
 
void main(void)
{
	vec4 sum = vec4(0.0);
	//Semi Gaussian Blur
	sum += texture2D(tex, vec2(Texcoord.x - 4.0*blurSize, Texcoord.y)) * 0.05;
	sum += texture2D(tex, vec2(Texcoord.x - 3.0*blurSize, Texcoord.y)) * 0.09;
	sum += texture2D(tex, vec2(Texcoord.x - 2.0*blurSize, Texcoord.y)) * 0.12;
	sum += texture2D(tex, vec2(Texcoord.x - blurSize, Texcoord.y)) * 0.15;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y)) * 0.16;
	sum += texture2D(tex, vec2(Texcoord.x + blurSize, Texcoord.y)) * 0.15;
	sum += texture2D(tex, vec2(Texcoord.x + 2.0*blurSize, Texcoord.y)) * 0.12;
	sum += texture2D(tex, vec2(Texcoord.x + 3.0*blurSize, Texcoord.y)) * 0.09;
	sum += texture2D(tex, vec2(Texcoord.x + 4.0*blurSize, Texcoord.y)) * 0.05;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y - 4.0*blurSize)) * 0.05;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y - 3.0*blurSize)) * 0.09;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y - 2.0*blurSize)) * 0.12;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y - blurSize)) * 0.15;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y)) * 0.16;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y + blurSize)) * 0.15;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y + 2.0*blurSize)) * 0.12;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y + 3.0*blurSize)) * 0.09;
	sum += texture2D(tex, vec2(Texcoord.x, Texcoord.y + 4.0*blurSize)) * 0.05;
	gl_FragColor = sum*intensity + texture2D(tex, Texcoord);
}