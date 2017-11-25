//based on https://thebookofshaders.com/13/ and http://www.iquilezles.org/www/articles/warp/warp.htm
uniform float timer;

float rand(in vec2 _st) { 
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))* 
        43758.5453123);
}

float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + 
            (c - a)* u.y * (1.0 - u.x) + 
            (d - b) * u.x * u.y;
}

float fbm(vec2 n) {
    float total = 0.0, amplitude = 0.7;
	 vec2 shift = vec2(100.0);
    mat2 rot = mat2(cos(0.5), sin(0.5), 
                    -sin(0.5), cos(0.50));	
    for (int i = 0; i <5; i++) {
        total += noise(n) * amplitude;
        n += rot*n*1.7+shift;
        amplitude *= 0.5;
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
    vec2 speed = vec2(0.1, 0.9);
    float shift = 1.327+sin(timer*0.1)/2.4;

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
    vec2 r = vec2(fbm(p + q /4.0 + timer * speed.x - p.x - p.y), fbm(p + q - timer * speed.y));
	r.x += shift;
    return r;
  }


vec4 Process(vec4 color)
{
	vec2 uv = gl_TexCoord[0].st;
	vec2 result = pattern(-uv);
	result *= HeatHaze(uv);
	return getTexel(result) * color;
}
