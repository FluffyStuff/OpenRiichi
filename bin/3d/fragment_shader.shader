#version 450 core

struct lightSourceParameters 
{
   vec3 position;
   vec3 spotDirection;
};

struct lightNormalParameters
{
   vec3 normal;
};

in vec2 Texcoord;
in vec3 Normal;
//in vec3 Position;
in lightNormalParameters ls[20];
in vec3 Camera_normal;
out vec4 outColor;
uniform sampler2D tex;
uniform int light_count;

//////////////////////////////////

//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
// 

/*vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}*/
//////////////////////////////////

void main()
{
	//outColor = texture(tex, Texcoord);
	//float diffuse = 0.01 * 1; //Table
	/*float diffuse = 0.02 * 1;
	
	vec3 light = normalize(vec3(0, 1, -1));
	vec3 light2 = normalize(vec3(0, 1, -1));
	
	float noise = snoise(Texcoord.xy * 8) * 0.5 * 0 + snoise(Texcoord.xy * 400) * 0.5;
	float n1 = cos(noise);
	float n2 = sin(noise);
	float n3 = snoise(vec2(n1, n2));
	
	vec3 orig = normalize(Normal);
	vec3 n = normalize(vec3(Normal.x + Normal.x * n1 * diffuse, Normal.y + Normal.y * n2 * diffuse, Normal.z + Normal.z * n3 * diffuse));
	
	vec3 Color = vec3(1.0, 1.0, 1.0) * (0.016 *1 + max(0, (dot(light2, n.xyz))) * 1.0);
	
	float specOffset = max(dot(light, n.xyz), 0);
	float speccy2 = pow(specOffset, 10);
	float speccy = pow(speccy2, 30);
	
	vec4 sColor = normalize(vec4(outColor.xyz + vec3(6.0, 6.0, 6.0), 1.0)) * 4;
	
	vec4 specColor = sColor * speccy * 1.0 * 1 + sColor * speccy2 * 0.03 * 1;*/
	
	//outColor.xyz = outColor.xyz * 0.0 + outColor.xyz * Color * 0.9 * 1;
	//outColor += max(specColor, 0);
	
	outColor = texture(tex, Texcoord);
	//outColor = vec4(0.7, 0.3, 0.5, 1.0);
	
	float diff = 0;
	float specular = 0;
	
	for (int i = 0; i < light_count; i++)
	{
		diff += max(dot(normalize(Normal), normalize(ls[i].normal)) * 0.04, 0);
		float s = dot(Camera_normal, reflect(-normalize(ls[i].normal), normalize(Normal)));
		specular += max(pow(s, 1000) * 2, 0);
	}
	
	outColor.xyz *= diff;
	outColor.xyz += vec3(specular);
}