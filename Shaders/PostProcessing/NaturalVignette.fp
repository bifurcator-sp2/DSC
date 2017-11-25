vec2 GetOffsetFromCenter(vec2 screenCoords, vec2 screenSize)
{
    vec2 halfScreenSize = screenSize / 2.0;
    
	return (screenCoords.xy - halfScreenSize) / min(halfScreenSize.x, halfScreenSize.y);
}

void main()
{
	float Falloff = 0.01;//02
	float intensity = 120;//120
	vec2 uv = TexCoord;
    vec2 coord = GetOffsetFromCenter(uv,vec2(1.0));
    float vig = pow(intensity, Falloff);
	
    float rf = sqrt(dot(coord, coord)) * vig;
    float rf2_1 = rf * rf + 1.0;
    float e = 1.0 / (rf2_1 * rf2_1);
    
    vec4 src = texture(InputTexture, TexCoord);
	FragColor = vec4(src.rgb * e, 1.0);
}