uniform float timer;
const float _gravity = 0.1;
const float _Curves = 0.5;
const float _windSpeed = 1.0;

vec2 ProcessForAnimationX(vec2 i)
{
	float yoffset = i.x - timer * _windSpeed; // Animates Root of Flag as Well,wind speed
//	yoffset = (yoffset * 2) - 1;
	yoffset = yoffset*1.57079633 * _Curves;	//one cycle of trinometric function, curves controll
	yoffset = cos(yoffset * 2)*i.x*0.05 + _gravity*i.x*i.x;
	vec2 uv = vec2(i.x, (i.y + yoffset));
	//uv = (uv + 1) / 2;
	return uv;
} 

vec2 ProcessForAnimationY(vec2 i)
{
	float xoffset = i.y - timer * _windSpeed; // Animates Root of Flag as Well,wind speed
//	xoffset = (xoffset * 2) - 1;
	xoffset = xoffset*1.57079633 * _Curves;	//one cycle of trinometric function, curves controll
	xoffset = sin(xoffset * 2)*i.y*0.05 + _gravity*i.y*i.y;
	vec2 uv = vec2((i.x + xoffset), i.y );
	//uv = (uv + 1) / 2;
	return uv;
}

vec4 Process(vec4 color)
{
    vec2 st = gl_TexCoord[0].st;
    vec2 finalTex = ProcessForAnimationY(st);

	return getTexel(finalTex) * color;
}