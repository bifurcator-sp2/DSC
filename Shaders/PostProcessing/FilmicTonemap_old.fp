/*vec3 FilmicTonemap(vec3 color)
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
 
void main()
{
	vec3 color = texture(InputTexture, TexCoord).rgb;
	vec3 burgessTonemap = Burgess(color);
	vec3 filmicTonemap = FilmicTonemap(color);
	color = mix(burgessTonemap,filmicTonemap,0.625);
	FragColor = vec4(color, 1.0);
}
*/