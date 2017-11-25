//based on https://thebookofshaders.com/13/ and http://www.iquilezles.org/www/articles/warp/warp.htm

uniform float timer;
const int numOctaves = 12;
const float speedx = 0.15;
const float speedy = 0.126;
const float freq = 1.0;
const float freqMult = 1.25;
const float value = 3.0;
const float texMult = 2.5;
const float amplitude = 0.5;
const float amplitudeMult = 0.5;
const float shiftPosX = 100.0;
const float shiftPosY = 100.0;
const float brightness = 2.2; // ?????
const float axialBias1 = 0.5; //cos(axialBias1)
const float axialBias2 = 0.5; //sin(axialBias2)
const float axialBias3 = 0.5; //-sin(axialBias3)
const float axialBias4 = 0.5; //cos(axialBias4)
const float pattern1X = 1.7;
const float pattern1Y = 9.2;
const float pattern2X = 8.3;
const float pattern2Y = 2.8;

float random (in vec2 _st) { 
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))* 
        43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + 
            (c - a)* u.y * (1.0 - u.x) + 
            (d - b) * u.x * u.y;
}

float fbm ( in vec2 _st) {
    float v = value;
    float a = amplitude;
	float locFreq = freq;
    vec2 shift = vec2(shiftPosX,shiftPosY);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(axialBias1), sin(axialBias2), 
                    -sin(axialBias3), cos(axialBias4));
    for (int i = 0; i < numOctaves; ++i) {
        v += a * noise(locFreq * _st);
        _st = rot * _st * texMult + shift;
        a *= amplitudeMult;
		locFreq *= freqMult;
    }
    return v;
}

  vec2 pattern( in vec2 p, float timer, out vec2 q, out vec2 r )
  {
    q.x = fbm( p + 0.00*timer);
    q.y = fbm( p + vec2(1.0));

    r.x = fbm( p + 1.0*q + vec2(pattern1X,pattern1Y)+ speedx*timer ); //0.220,0.230
    r.y = fbm( p + 1.0*q + vec2(pattern2X,pattern2Y)+ speedy*timer);

    return ((q + r) / brightness);//fbm( p + 4.0*r );
  }

vec4 Process(vec4 color)
{
    vec2 st = gl_TexCoord[0].st;
    vec2 q,r = vec2(0.);

	vec2 result = pattern(st, timer, q, r);

	return getTexel(result) * color;
}