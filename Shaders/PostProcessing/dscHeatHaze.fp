/**
 * Heat Haze
 * by Marty McFly
 */

void main()
{
	float fHeatHazeSpeed = 1.8;
	float fHeatHazeOffset = 4.40;
	float fHeatHazeTextureScale = 1.0;
//	float fHeatHazeChromaAmount = 0.3;
	vec4 color = texture(InputTexture, TexCoord);
	vec3 heatnormal = texture(HazeBump, vec2(TexCoord.xy*fHeatHazeTextureScale+vec2(0.0,timer*0.01*fHeatHazeSpeed))).rgb - 0.5;
	vec2 heatoffset = normalize(heatnormal.xy) * pow(length(heatnormal.xy), 0.5);
	
	vec3 heathazecolor = vec3(0.0);

	heathazecolor.y = texture(InputTexture, (TexCoord.xy - vec2(0.001)) + heatoffset.xy * 0.001 * fHeatHazeOffset).y;
	heathazecolor.x = texture(InputTexture, (TexCoord.xy - vec2(0.001)) + heatoffset.xy * 0.001 * fHeatHazeOffset * (1.0+fHeatHazeChromaAmount)).x;
	heathazecolor.z = texture(InputTexture, (TexCoord.xy - vec2(0.001)) + heatoffset.xy * 0.001 * fHeatHazeOffset * (1.0-fHeatHazeChromaAmount)).z;

	color.xyz = heathazecolor;
	FragColor = color;
}