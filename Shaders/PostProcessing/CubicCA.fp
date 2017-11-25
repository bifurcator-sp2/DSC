void main()
{ 
	float fFisheyeZoom = 0.51;
	float fFisheyeDistortion = 0.02;
	float fFisheyeDistortionCubic = 0.02;
	float fFisheyeColorshift = 0.01;
	
	vec3 color = texture( InputTexture, TexCoord ).rgb;

	vec4 coord=vec4(0.0);
	coord.xy=TexCoord.xy;
	coord.w=0.0;

	color.rgb = vec3(0.0);
	  
	vec3 eta = vec3(1.0+fFisheyeColorshift*0.9,1.0+fFisheyeColorshift*0.6,1.0+fFisheyeColorshift*0.3);
	vec2 center;
	center.x = coord.x-0.5;
	center.y = coord.y-0.5;
	float LensZoom = 1.0/fFisheyeZoom;

    float r2 = (TexCoord.y-0.5) * (TexCoord.y-0.5) + (TexCoord.y-0.5) * (TexCoord.y-0.5);

	float f = 0;

	if( fFisheyeDistortionCubic == 0.0){
		f = 1 + r2 * fFisheyeDistortion;
	}else{
        f = 1 + r2 * (fFisheyeDistortion + fFisheyeDistortionCubic * sqrt(r2));
	};

	float x = f*LensZoom*(coord.x-0.5)+0.5;
	float y = f*LensZoom*(coord.y-0.5)+0.5;
	vec2 rCoords = (f*eta.r)*LensZoom*(center.xy*0.5)+0.5;
	vec2 gCoords = (f*eta.g)*LensZoom*(center.xy*0.5)+0.5;
	vec2 bCoords = (f*eta.b)*LensZoom*(center.xy*0.5)+0.5;
	
	color.x = texture(InputTexture,rCoords).r;
	color.y = texture(InputTexture,gCoords).g;
	color.z = texture(InputTexture,bCoords).b;
	
	FragColor = vec4(color,1.0);
}