vec3 FilmicTonemap(vec3 color)
{
	//https://github.com/crosire/reshade-shaders/blob/master/Shaders/FilmicPass.fx
	float Strength = 0.85; //625  	//[0.05:1.5] Strength of the color curve altering
	float Fade = 0.4;			//[0.0:0.6] Decreases contrast to imitate faded image
	float Contrast = 1.025;		//[0.5:2.0]
	float Linearization = 0.5;  //[0.5:2.0]
	float Bleach = 0.0;		//[-0.5:1.0] More bleach means more contrasted and less colorful image
	float Saturation = -0.23;	//[-1.0:1.0]
	float RedCurve = 1.0;		//[0.0:2.0]
	float GreenCurve = 1.0;		//[0.0:2.0]
	float BlueCurve = 1.0;		//[0.0:2.0]
	float BaseCurve = 1.0;		//[0.0:2.0]
	float BaseGamma = 1.0; 		//[0.7:2.0]
	float EffectGamma = 1.0;	//[0.0:2.0]
	float EffectGammaR = 1.0;	//[0.0:2.0]
	float EffectGammaG = 1.0;	//[0.0:2.0]
	float EffectGammaB = 1.0;	//[0.0:2.0]
	vec3 LumCoeff = vec3(0.212656, 0.715158, 0.072186);
	
	vec3 B = color;	
	vec3 G = B;
	vec3 H = vec3(0.01);
 
	B = clamp(B,0.0,1.0);
	B = pow(B, vec3(Linearization));
	B = mix(H, B, Contrast);
 
	float A = dot(B.rgb, LumCoeff);
	vec3 D = vec3(A);
 
	B = pow(B, vec3(1.0 / BaseGamma));
 
	float a = RedCurve;
	float b = GreenCurve;
	float c = BlueCurve;
	float d = BaseCurve;
 
	float y = 1.0 / (1.0 + exp(a / 2.0));
	float z = 1.0 / (1.0 + exp(b / 2.0));
	float w = 1.0 / (1.0 + exp(c / 2.0));
	float v = 1.0 / (1.0 + exp(d / 2.0));
 
	vec3 C = B;
 
	D.r = (1.0 / (1.0 + exp(-a * (D.r - 0.5))) - y) / (1.0 - 2.0 * y);
	D.g = (1.0 / (1.0 + exp(-b * (D.g - 0.5))) - z) / (1.0 - 2.0 * z);
	D.b = (1.0 / (1.0 + exp(-c * (D.b - 0.5))) - w) / (1.0 - 2.0 * w);
 
	D = pow(D, vec3(1.0 / EffectGamma));
 
	vec3 Di = 1.0 - D;
 
	D = mix(D, Di, Bleach);
 
	D.r = pow(abs(D.r), 1.0 / EffectGammaR);
	D.g = pow(abs(D.g), 1.0 / EffectGammaG);
	D.b = pow(abs(D.b), 1.0 / EffectGammaB);
 
	if (D.r < 0.5)
		C.r = (2.0 * D.r - 1.0) * (B.r - B.r * B.r) + B.r;
	else
		C.r = (2.0 * D.r - 1.0) * (sqrt(B.r) - B.r) + B.r;
 
	if (D.g < 0.5)
		C.g = (2.0 * D.g - 1.0) * (B.g - B.g * B.g) + B.g;
	else
		C.g = (2.0 * D.g - 1.0) * (sqrt(B.g) - B.g) + B.g;

	if (D.b < 0.5)
		C.b = (2.0 * D.b - 1.0) * (B.b - B.b * B.b) + B.b;
	else
		C.b = (2.0 * D.b - 1.0) * (sqrt(B.b) - B.b) + B.b;
 
	vec3 F = mix(B, C, Strength);
 
	F = (1.0 / (1.0 + exp(-d * (F - 0.5))) - v) / (1.0 - 2.0 * v);
 
	float r2R = 1.0 - Saturation;
	float g2R = 0.0 + Saturation;
	float b2R = 0.0 + Saturation;
 
	float r2G = 0.0 + Saturation;
	float g2G = (1.0 - Fade) - Saturation;
	float b2G = (0.0 + Fade) + Saturation;
 
	float r2B = 0.0 + Saturation;
	float g2B = (0.0 + Fade) + Saturation;
	float b2B = (1.0 - Fade) - Saturation;
 
	vec3 iF = F;
 
	F.r = (iF.r * r2R + iF.g * g2R + iF.b * b2R);
	F.g = (iF.r * r2G + iF.g * g2G + iF.b * b2G);
	F.b = (iF.r * r2B + iF.g * g2B + iF.b * b2B);
 
	float N = dot(F.rgb, LumCoeff);
	vec3 Cn = F;
 
	if (N < 0.5)
		Cn = (2.0 * N - 1.0) * (F - F * F) + F;
	else
		Cn = (2.0 * N - 1.0) * (sqrt(F) - F) + F;
 
	Cn = pow(max(Cn,0), vec3(1.0 / Linearization));
 
	vec3 Fn = mix(B, Cn, Strength);
	return Fn;
}

vec3 Burgess(vec3 color)
{
	//color *= 1.115;
	color *= 2.200;
	vec3 maxColor = max(vec3(0.0), color - 0.004);
	//vec3 returnColor = (maxColor * (6.2 * maxColor + 0.05)) / (maxColor * (6.2 * maxColor + 1.7) + 0.06);
	vec3 returnColor = (maxColor * (6.2 * maxColor + 0.05)) / (maxColor * (6.2 * maxColor + 2) + 0.06);
	return returnColor;
}

//UNITY Filmic tonemap

#define HALF_MAX        65504.0
#define UNITY_PI        3.14159265359
#define EPSILON         1.0e-4

const mat3 AP0_2_AP1_MAT = mat3(
     1.4514393161, -0.2365107469, -0.2149285693,
    -0.0765537734,  1.1762296998, -0.0996759264,
     0.0083161484, -0.0060324498,  0.9977163014
);

const mat3 AP1_2_AP0_MAT = mat3(
     0.6954522414, 0.1406786965, 0.1638690622,
     0.0447945634, 0.8596711185, 0.0955343182,
    -0.0055258826, 0.0040252103, 1.0015006723
);

const mat3 XYZ_2_AP1_MAT = mat3(
     1.6410233797, -0.3248032942, -0.2364246952,
    -0.6636628587,  1.6153315917,  0.0167563477,
     0.0117218943, -0.0082844420,  0.9883948585
);

const mat3 AP1_2_XYZ_MAT = mat3(
     0.6624541811, 0.1340042065, 0.1561876870,
     0.2722287168, 0.6740817658, 0.0536895174,
    -0.0055746495, 0.0040607335, 1.0103391003
);

const mat3 D60_2_D65_CAT = mat3(
     0.98722400, -0.00611327, 0.0159533,
    -0.00759836,  1.00186000, 0.0053302,
     0.00307257, -0.00509595, 1.0816800
);

const mat3 XYZ_2_REC709_MAT = mat3(
     3.2409699419, -1.5373831776, -0.4986107603,
    -0.9692436363,  1.8759675015,  0.0415550574,
     0.0556300797, -0.2039769589,  1.0569715142
);

const vec3 AP1_RGB2Y = vec3(0.272229, 0.674082, 0.0536895);

const float RRT_GLOW_GAIN = 0.05;
const float RRT_GLOW_MID = 0.08;

const float RRT_RED_SCALE = 0.82;
const float RRT_RED_PIVOT = 0.03;
const float RRT_RED_HUE = 0.0;
const float RRT_RED_WIDTH = 135.0;

const float ODT_SAT_FACTOR = 0.93;

const float RRT_SAT_FACTOR = 0.96;

const float DIM_SURROUND_GAMMA = 0.9811;

vec3 Min3(vec3 x) { return vec3(min(x.x, min(x.y, x.z))); }
vec3 Max3(vec3 x) { return vec3(max(x.x, max(x.y, x.z))); }

float Pow2(float  x) { return x * x; }

//
// White balance
// Recommended workspace: ACEScg (linear)
//
const mat3 LIN_2_LMS_MAT = mat3(
    3.90405e-1, 5.49941e-1, 8.92632e-3,
    7.08416e-2, 9.63172e-1, 1.35775e-3,
    2.31082e-2, 1.28021e-1, 9.36245e-1
);

const mat3 LMS_2_LIN_MAT = mat3(
     2.85847e+0, -1.62879e+0, -2.48910e-2,
    -2.10182e-1,  1.15820e+0,  3.24281e-4,
    -4.18120e-2, -1.18169e-1,  1.06867e+0
);

vec3 WhiteBalance(vec3 c, vec3 balance)
{
    vec3 lms = LIN_2_LMS_MAT * c;
    lms *= balance;
    return LMS_2_LIN_MAT * lms;
}

vec3 XYZ_2_xyY(vec3 XYZ)
{
    float divisor = max(dot(XYZ, vec3(1.0)), 1e-4);
    return vec3(XYZ.xy / divisor, XYZ.y);
}

vec3 xyY_2_XYZ(vec3 xyY)
{
    float m = xyY.z / max(xyY.y, 1e-4);
    vec3 XYZ = vec3(xyY.xz, (1.0 - xyY.x - xyY.y));
    XYZ.xz *= m;
    return XYZ;
}

vec3 ACEScg_to_ACES(vec3 x)
{
    return AP1_2_AP0_MAT * x;
}

vec3 ChannelMixer(vec3 c, vec3 red, vec3 green, vec3 blue)
{
    return vec3(
        dot(c, red),
        dot(c, green),
        dot(c, blue)
    );
}

vec3 RgbToHsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = EPSILON;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 HsvToRgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx,0.0,1.0), c.y);
}

/*
vec3 YrgbCurve(vec3 c, sampler2D curveTex)
{
    const float kHalfPixel = (1.0 / 128.0) / 2.0;

    // Y
    c += vec3(kHalfPixel);
    float mr = texture(curveTex, vec2(c.r, 0.75)).a;
    float mg = texture(curveTex, vec2(c.g, 0.75)).a;
    float mb = texture(curveTex, vec2(c.b, 0.75)).a;
    c = clamp(vec3(mr, mg, mb),0.0,1.0);

    // RGB
    c += vec3(kHalfPixel);
    float r = texture(curveTex, vec2(c.r, 0.75)).r;
    float g = texture(curveTex, vec2(c.g, 0.75)).g;
    float b = texture(curveTex, vec2(c.b, 0.75)).b;
    return clamp(vec3(r, g, b),0.0,1.0);
}*/

//
// Offset, Power, Slope (ASC-CDL)
// Works in Log & Linear. Results will be different but still correct.
//
vec3 OffsetPowerSlope(vec3 c, vec3 offset, vec3 power, vec3 slope)
{
    vec3 so = c * slope + offset;
    so = so.r > 0.0 && so.g > 0 && so.b > 0.0 ? pow(so, power) : so;
    return so;
}

//
// Lift, Gamma (pre-inverted), Gain
// Recommended workspace: ACEScg (linear)
//
vec3 LiftGammaGain(vec3 c, vec3 lift, vec3 invgamma, vec3 gain)
{
    //return gain * (lift * (1.0 - c) + pow(max(c, kEpsilon), invgamma));
    //return pow(gain * (c + lift * (1.0 - c)), invgamma);

    vec3 power = invgamma;
    vec3 offset = lift * gain;
    vec3 slope = (vec3(1.0) - lift) * gain;
    return OffsetPowerSlope(c, offset, power, slope);
}

vec3 darkSurround_to_dimSurround(vec3 linearCV)
{
    vec3 XYZ = AP1_2_XYZ_MAT * linearCV;

    vec3 xyY = XYZ_2_xyY(XYZ);
    xyY.z = clamp(xyY.z, 0.0, HALF_MAX);
    xyY.z = pow(xyY.z, DIM_SURROUND_GAMMA);
    XYZ = xyY_2_XYZ(xyY);

    return XYZ_2_AP1_MAT * XYZ;
}
     
// An analytical model of chromaticity of the standard illuminant, by Judd et al.
// http://en.wikipedia.org/wiki/Standard_illuminant#Illuminant_series_D
// Slightly modifed to adjust it with the D65 white point (x=0.31271, y=0.32902).
    
float StandardIlluminantY(float x)
{
	return 2.87 * x - 3.0 * x * x - 0.27509507;
}
	
// CIE xy chromaticity to CAT02 LMS.
// http://en.wikipedia.org/wiki/LMS_color_space#CAT02
vec3 CIExyToLMS(float x, float y)
{
	float Y = 1.0;
	float X = Y * x / y;
	float Z = Y * (1.0 - x - y) / y;
	
	float L =  0.7328 * X + 0.4296 * Y - 0.1624 * Z;
	float M = -0.7036 * X + 1.6975 * Y + 0.0061 * Z;
	float S =  0.0030 * X + 0.0136 * Y + 0.9834 * Z;
	
	return vec3(L, M, S);
}

vec3 CalculateColorBalance(float temperature, float tint)
{
	// Range ~[-1.8;1.8] ; using higher ranges is unsafe
	float t1 = temperature / 55.0;
	float t2 = tint / 55.0;
	
	// Get the CIE xy chromaticity of the reference white point.
	// Note: 0.31271 = x value on the D65 white point
	float x = 0.31271 - t1 * (t1 < 0.0 ? 0.1 : 0.05);
	float y = StandardIlluminantY(x) + t2 * 0.05;
	
	// Calculate the coefficients in the LMS space.
	vec3 w1 = vec3(0.949237, 1.03542, 1.08728); // D65 white point
	vec3 w2 = CIExyToLMS(x, y);
	return vec3(w1.x / w2.x, w1.y / w2.y, w1.z / w2.z);
}

float rgb_2_hue(vec3 rgb)
{
    // Returns a geometric hue angle in degrees (0-360) based on RGB values.
    // For neutral colors, hue is undefined and the function will return a quiet NaN value.
    float hue;
    if (rgb.x == rgb.y && rgb.y == rgb.z)
        hue = 0.0; // RGB triplets where RGB are equal have an undefined hue
    else
        hue = (180.0 / UNITY_PI) * atan(2.0 * rgb.x - rgb.y - rgb.z,sqrt(3.0) * (rgb.y - rgb.z));

    if (hue < 0.0) hue = hue + 360.0;

    return hue;
}

float center_hue(float hue, float centerH)
{
    float hueCentered = hue - centerH;
    if (hueCentered < -180.0) hueCentered = hueCentered + 360.0;
    else if (hueCentered > 180.0) hueCentered = hueCentered - 360.0;
    return hueCentered;
}

float rgb_2_saturation(vec3 rgb)
{
    const float TINY = 1e-10;
    float mi = Min3(rgb).x;
    float ma = Max3(rgb).x;
    return (max(ma, TINY) - max(mi, TINY)) / max(ma, 1e-2);
}

vec3 ACES_to_ACEScg(vec3 x)
{
    return AP0_2_AP1_MAT * x;
}

float rgb_2_yc(vec3 rgb)
{
    const float ycRadiusWeight = 1.75;

    // Converts RGB to a luminance proxy, here called YC
    // YC is ~ Y + K * Chroma
    // Constant YC is a cone-shaped surface in RGB space, with the tip on the
    // neutral axis, towards white.
    // YC is normalized: RGB 1 1 1 maps to YC = 1
    //
    // ycRadiusWeight defaults to 1.75, although can be overridden in function
    // call to rgb_2_yc
    // ycRadiusWeight = 1 -> YC for pure cyan, magenta, yellow == YC for neutral
    // of same value
    // ycRadiusWeight = 2 -> YC for pure red, green, blue  == YC for  neutral of
    // same value.

    float r = rgb.x;
    float g = rgb.y;
    float b = rgb.z;
    float chroma = sqrt(b * (b - g) + g * (g - r) + r * (r - b));
    return (b + g + r + ycRadiusWeight * chroma) / 3.0;
}

float sigmoid_shaper(float x)
{
    // Sigmoid function in the range 0 to 1 spanning -2 to +2.

    float t = max(1.0 - abs(x / 2.0), 0.0);
    float y = 1.0 + sign(x) * (1.0 - t * t);

    return y / 2.0;
}

float glow_fwd(float ycIn, float glowGainIn, float glowMid)
{
    float glowGainOut;

    if (ycIn <= 2.0 / 3.0 * glowMid)
        glowGainOut = glowGainIn;
    else if (ycIn >= 2.0 * glowMid)
        glowGainOut = 0.0;
    else
        glowGainOut = glowGainIn * (glowMid / ycIn - 1.0 / 2.0);

    return glowGainOut;
}

vec3 ACESTonemap(vec3 aces)
{
    // --- Glow module --- //
    float saturation = rgb_2_saturation(aces);
    float ycIn = rgb_2_yc(aces);
    float s = sigmoid_shaper((saturation - 0.4) / 0.2);
    float addedGlow = 1.0 + glow_fwd(ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);
    aces *= addedGlow;	

    // --- Red modifier --- //
    float hue = rgb_2_hue(aces);
    float centeredHue = center_hue(hue, RRT_RED_HUE);
    float hueWeight = Pow2(smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / RRT_RED_WIDTH)));

    aces.r += hueWeight * saturation * (RRT_RED_PIVOT - aces.r) * (1.0 - RRT_RED_SCALE);

    // --- ACES to RGB rendering space --- //
    vec3 acescg = max(vec3(0.0), ACES_to_ACEScg(aces));

    // --- Global desaturation --- //
    //acescg = mul(RRT_SAT_MAT, acescg);
    acescg = mix(vec3(dot(acescg, AP1_RGB2Y)), acescg, vec3(RRT_SAT_FACTOR));

    // Luminance fitting of *RRT.a1.0.3 + ODT.Academy.RGBmonitor_100nits_dim.a1.0.3*.
    // https://github.com/colour-science/colour-unity/blob/master/Assets/Colour/Notebooks/CIECAM02_Unity.ipynb
    // RMSE: 0.0012846272106
    const float a = 278.5085;
    const float b = 10.7772;
    const float c = 293.6045;
    const float d = 88.7122;
    const float e = 80.6889;
    vec3 x = acescg;
    vec3 rgbPost = (x * (vec3(a) * x + vec3(b))) / (x * (vec3(c) * x + vec3(d)) + vec3(e));

    // Scale luminance to linear code value
    // vec3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

    // Apply gamma adjustment to compensate for dim surround
    vec3 linearCV = darkSurround_to_dimSurround(rgbPost);

    // Apply desaturation to compensate for luminance difference
    //linearCV = mul(ODT_SAT_MAT, color);
    linearCV = mix(vec3(dot(linearCV, AP1_RGB2Y)), linearCV, vec3(ODT_SAT_FACTOR));
/*
    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    vec3 XYZ = AP1_2_XYZ_MAT * linearCV;

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = D60_2_D65_CAT * XYZ;

    // CIE XYZ to display primaries
    linearCV = XYZ_2_REC709_MAT * XYZ; 
*/
    return D60_2_D65_CAT * linearCV;

}

void main() 
{
	vec3 color = texture(InputTexture, TexCoord).rgb;
	// ACEScg (linear) space
	vec3 acescg = color;
	
	acescg = WhiteBalance(acescg, CalculateColorBalance(0.0,0.0));
//	acescg = LiftGammaGain(acescg, vec3(1.0), vec3(1.0), vec3(1.0));
	
	acescg = ChannelMixer(acescg, vec3(1.0,0.0,0.0), vec3(0.0,1.0,0.0), vec3(0.0,0.0,1.0));
	
	vec3 aces = ACEScg_to_ACES(acescg);
	vec3 uTonemap = ACESTonemap(aces);

	vec3 filmicTonemap = FilmicTonemap(color);
	color = mix(uTonemap,filmicTonemap,0.325);
	
	//FragColor = vec4(color, 1.0);
	FragColor = vec4(mix(color,Burgess(color),0.2), 1.0);
}