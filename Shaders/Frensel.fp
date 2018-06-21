#define saturate(x) clamp(x,0.0,1.0)
const vec3 RimColor = vec3(0.92,0.81,0.51);
//const float RimWidth = 2.0;
const float RimPower = 10.0;
const float Scale = 0.05;
const float SpeedX = 2.3;
const float SpeedY = 1.7;
const float TileX = 5.0;
const float TileY = 5.0;

const float ScrollU = -1.5;
const float ScrollV = 3.0;
uniform float timer;

vec4 Process(vec4 color)
{
	vec2 texCoord = gl_TexCoord[0].st;
	texCoord.x += sin(ScrollU * timer) * Scale;
	texCoord.y += cos(ScrollV * timer) * Scale;
	vec4 orgColor = getTexel(texCoord) * color;

	vec2 distordUV = gl_TexCoord[0].st;

	distordUV.x += sin((distordUV.x + distordUV.y) * TileX + timer * SpeedX) * Scale;
	distordUV.y += cos((distordUV.x + distordUV.y) * TileY + timer * SpeedY) * Scale;

	vec4 distordColor = getTexel(distordUV) * color;

    vec3 x = dFdx(pixelpos.xyz);
    vec3 y = dFdy(pixelpos.xyz);
    vec3 normal = normalize(cross(x,y));
	vec3 eyedir = normalize(uCameraPos.xyz-pixelpos.xyz);
	float dotProduct = 1.0 - dot(normal, eyedir);
	//float rim = smoothstep(1 - RimWidth, 1.0, dotProduct);
	orgColor.rgb *= RimColor * pow(RimPower,dotProduct);
	orgColor = mix(distordColor,orgColor,dotProduct);
	
	return orgColor;
}