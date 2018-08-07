void main()
{
	float BlurMultiplier = 10.0;
	const float weight[11] = float[11](
		0.082607,
		0.080977,
		0.076276,
		0.069041,
		0.060049,
		0.050187,
		0.040306,
		0.031105,
		0.023066,
		0.016436,
		0.011254
	);
	vec4 res = texture(InputTexture, TexCoord);
    ivec2 screenSize = textureSize(InputTexture, 0);
	float aspectRatio = screenSize.x / screenSize.y;
    vec2 PixelSize = vec2( 1.0 / screenSize.x, (1.0 / screenSize.x) * aspectRatio);
        
	float blurAmount = res.a * BlurMultiplier;
	res *= weight[0];

	for (int i = 1; i < 11; i++)
	{
		res += texture(InputTexture, TexCoord.xy + vec2(float(i) * PixelSize.x * blurAmount, 0)) * weight[i];
		res += texture(InputTexture, TexCoord.xy - vec2(float(i) * PixelSize.x * blurAmount, 0)) * weight[i];
	}
	
	FragColor = res;
}