//based on https://thebookofshaders.com/13/ and http://www.iquilezles.org/www/articles/warp/warp.htm
uniform float timer;

float rand(vec2 n) {
    return fract(sin(cos(dot(n, vec2(12.9898,12.1414)))) * 83758.5453);
}

float noise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

float fbm(vec2 n) {
    float total = 0.0, amplitude = 1.0;
    for (int i = 0; i <5; i++) {
        total += noise(n) * amplitude;
        n += n*1.7;
        amplitude *= 0.47;
    }
    return total;
}

const float distortFocus = 1.3;

vec2 HeatHaze ( in vec2 uv)
{
	float horizontDistance = abs(uv.y - distortFocus);
	float smallWaves = sin((uv.y+timer*.01)*45.)*.06;
	float horizontalRipples = smallWaves / (horizontDistance*horizontDistance*1000. + 1.);
	
	float squiglyVerticalPoints = uv.x + smallWaves*.08;
	float verticalRipples = sin((squiglyVerticalPoints+timer*.01)*60.) * .005;

	return vec2(uv.x + verticalRipples, uv.y + horizontalRipples);
}

  vec2 pattern( in vec2 uv )
  {
    const vec3 c1 = vec3(0.5, 0.0, 0.1);
    const vec3 c2 = vec3(0.9, 0.1, 0.0);
    const vec3 c3 = vec3(0.2, 0.1, 0.7);
    const vec3 c4 = vec3(1.0, 0.9, 0.1);
    const vec3 c5 = vec3(0.1);
    const vec3 c6 = vec3(0.9);
	
   //vec2 speed = vec2(0.1, 0.9);
   vec2 speed = vec2(0.0, 0.1);
    float shift = 1.327+sin(timer*2.0)/2.4;
	//float shift = 0;
    float alpha = 1.0;
    //change the constant term for all kinds of cool distance versions,
    //make plus/minus to switch between 
    //ground fire and fire rain!
	float dist = 3.5-sin(timer*0.4)/1.89;
 
	
    vec2 p = uv * dist;
    p += sin(p.yx*4.0+vec2(.2,-.3)*timer)*0.04;
    p += sin(p.yx*8.0+vec2(.6,+.1)*timer)*0.01;	
    p.y -= timer/1.1;
    float q = fbm(p - timer * 0.3+1.0*sin(timer+0.5)/10.0);
    float qb = fbm(p - timer * 0.4+0.1*cos(timer)/5.0);
    float q2 = fbm(p - timer * 0.44 - 5.0*cos(timer)/7.0) - 6.0;
    float q3 = fbm(p - timer * 0.9 - 10.0*cos(timer)/30.0)-4.0;
    float q4 = fbm(p - timer * 2.0 - 20.0*sin(timer)/20.0)+2.0;
    q = (q + qb - .4 * q2 -2.0*q3  + .6*q4)/3.8;
    vec2 r = vec2(fbm(p + q /2.0 + timer * speed.x - p.x - p.y), fbm(p + q - timer * speed.y));

 //   vec3 c = mix(c1, c2, fbm(p + r)) + mix(c3, c4, r.x) - mix(c5, c6, r.y);

    return r;//fbm( p + 4.0*r );
  }


vec4 Process(vec4 color)
{
	vec2 uv = gl_TexCoord[0].st;
	vec2 result = pattern(-uv);
	result *= HeatHaze(uv);
	return getTexel(result) * color;
}
