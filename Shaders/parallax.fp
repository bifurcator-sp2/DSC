
vec2 parallaxMapping(in vec3 V, in vec2 T);

Material ProcessMaterial()
{
	vec2 texCoord = vTexCoord.st;
	//const float pi = 3.14159265358979323846;
	//vec2 offset = vec2(0.0,0.0);
	//offset.y = 0.5 + sin(pi * 2.0 * (texCoord.y + timer * 0.61 + 900.0/8192.0)) + sin(pi * 2.0 * (texCoord.x * 2.0 + timer * 0.36 + 300.0/8192.0));
	//offset.x = 0.5 + sin(pi * 2.0 * (texCoord.y + timer * 0.49 + 700.0/8192.0)) + sin(pi * 2.0 * (texCoord.x * 2.0 + timer * 0.49 + 1200.0/8192.0));
	//texCoord += offset * 0.025;

	vec3 V = normalize(vEyeNormal).xyz;
	V.x = -V.x;

	texCoord = parallaxMapping(V, fract(texCoord));

	Material material;
	material.Base = getTexel(texCoord);
	material.Normal = ApplyNormalMap(texCoord);
	material.Specular = texture(speculartexture, texCoord).rgb;
	material.Glossiness = uSpecularMaterial.x;
	material.SpecularLevel = uSpecularMaterial.y;
#if defined(BRIGHTMAP)
	material.Bright = texture(brighttexture, texCoord);
#endif
	return material;
}

vec2 parallaxMapping(in vec3 V, in vec2 T)
{
	const float	parallaxScale = 0.25;
	const float minLayers = 8.0;
	const float maxLayers = 24.0;

	float numLayers = mix(maxLayers, minLayers, abs(V.z));  

	// calculate the size of each layer
	float layerDepth = 1.0 / numLayers;

	// depth of current layer
	float currentLayerDepth = 0.0;

	// the amount to shift the texture coordinates per layer (from vector P)
	vec2 P = V.xy * parallaxScale; 
	vec2 deltaTexCoords = P / numLayers;
	vec2  currentTexCoords = T;
	float currentDepthMapValue = texture(tex_heightmap, currentTexCoords).r;

	while(currentLayerDepth < currentDepthMapValue)
	{
		// shift texture coordinates along direction of P
		currentTexCoords -= deltaTexCoords;

		// get depthmap value at current texture coordinates
		currentDepthMapValue = texture(tex_heightmap, currentTexCoords).r;  

		// get depth of next layer
		currentLayerDepth += layerDepth;  
	}

	// get texture coordinates before collision (reverse operations)
	vec2 prevTexCoords = currentTexCoords + deltaTexCoords;

	// get depth after and before collision for linear interpolation
	float afterDepth  = currentDepthMapValue - currentLayerDepth;
	float beforeDepth = texture(tex_heightmap, prevTexCoords).r - currentLayerDepth + layerDepth;
	 
	// interpolation of texture coordinates
	float weight = afterDepth / (afterDepth - beforeDepth);
	vec2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

	return finalTexCoords;  
}
