//vignette from https://www.assetstore.unity3d.com/en/#!/content/83912

#define saturate(value) clamp(value,0.0,1.0) 

void main()
{
    vec4 color = texture(InputTexture, TexCoord);
    ivec2 screenSize = textureSize(InputTexture, 0);
    vec3 vignetteColor = vec3(0.0,0.0,0.0);
    vec2 vignetteCenter = vec2(0.5,0.5);
    float vignetteRoundness = 1.0;
    float roundness = (1.0 - 1.0) * 6.0 + 1.0;
    vec4 vignetteSettings = vec4( 0.45 * 3.0, 0.2 * 5.0,roundness, 0.0);
 
    vec2 d = abs(TexCoord - vignetteCenter) * vignetteSettings.x;
    d.x *= mix(1.0, float(screenSize.x / screenSize.y), vignetteSettings.w);
    d = pow(saturate(d), vec2(vignetteSettings.z)); // Roundness
    float vfactor = pow(saturate(1.0 - dot(d, d)), vignetteSettings.y);
    color.rgb *= mix(vignetteColor, (1.0).xxx, vfactor);
	color.a = mix(1.0, color.a, vfactor);
	FragColor = color;
}