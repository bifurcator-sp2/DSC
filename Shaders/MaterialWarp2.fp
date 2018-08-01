Material ProcessMaterial()
{
	vec2 texCoord = vTexCoord.st;
	const float pi = 3.14159265358979323846;
	vec2 offset = vec2(0.0,0.0);
	offset.y = 0.5 + sin(pi * 2.0 * (texCoord.y + timer * 0.61 + 900.0/8192.0)) + sin(pi * 2.0 * (texCoord.x * 2.0 + timer * 0.36 + 300.0/8192.0));
	offset.x = 0.5 + sin(pi * 2.0 * (texCoord.y + timer * 0.49 + 700.0/8192.0)) + sin(pi * 2.0 * (texCoord.x * 2.0 + timer * 0.49 + 1200.0/8192.0));
	texCoord += offset * 0.025;

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
