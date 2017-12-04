// Based on kingeric1992's TiltShift effect

#define saturate(value) clamp(value,0.0,1.0)
 
void main()
{
	bool Line = false;
	float Axis = 0.0;
	float Offset = -0.5;
	float BlurCurve = 1.57;
	vec4 res = texture(InputTexture, TexCoord);
    ivec2 screenSize = textureSize(InputTexture, 0);
	float aspectRatio = screenSize.x / screenSize.y;
	vec2 othogonal = vec2(tan(Axis * 0.0174533), -1.0 / aspectRatio);
	vec2 pos = othogonal * Offset;
	float dist = abs(dot(TexCoord - pos, othogonal) / length(othogonal));

	res.a = pow(saturate(dist), BlurCurve);
	res.rgb = (Line && dist < 0.01) ? vec3(1.0, 0, 0) : res.rgb;

	FragColor = res;
}