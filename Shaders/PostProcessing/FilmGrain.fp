/**
 * Film Grain post-process shader v1.1
 * Martins Upitis (martinsh) devlog-martinsh.blogspot.com 2013
 *
 * This work is licensed under a Creative Commons Attribution 3.0 Unported License.
 * So you are free to share, modify and adapt it for your needs, and even use it for commercial use.
 *
 * Uses perlin noise shader by toneburst from http://machinesdontcare.wordpress.com/2009/06/25/3d-perlin-noise-sphere-vertex-shader-sourcecode/
 */

float AspectRatio;

vec4 rnm(in vec2 tc)
{
	// A random texture generator, but you can also use a pre-computed perturbation texture
	//float noise = sin(dot(tc + timer.xx * 0.5, vec2(12.9898, 78.233))) * 43758.5453;
	float noise = sin(dot(vec3(tc.x, tc.y, timer), vec3(12.9898, 78.233,1.0))) * 43758.5453;
	
	float noiseR = fract(noise) * 2.0 - 1.0;
	float noiseG = fract(noise * 1.2154) * 2.0 - 1.0;
	float noiseB = fract(noise * 1.3453) * 2.0 - 1.0;
	float noiseA = fract(noise * 1.3647) * 2.0 - 1.0;

	return vec4(noiseR, noiseG, noiseB, noiseA);
}

float pnoise3D(in vec3 p)
{
	// Perm texture texel-size
	const float permTexUnit = 1.0 / 256.0;
	// Half perm texture texel-size
	const float permTexUnitHalf = 0.5 / 256.0;

	// Integer part
	// Scaled so +1 moves permTexUnit texel and offset 1/2 texel to sample texel centers
	vec3 pi = permTexUnit * floor(p) + permTexUnitHalf;
	// Fractional part for interpolation
	vec3 pf = fract(p);

	// Noise contributions from (x=0, y=0), z=0 and z=1
	float perm00 = rnm(pi.xy).a;
	vec3 grad000 = rnm(vec2(perm00, pi.z)).rgb * 4.0 - 1.0;
	float n000 = dot(grad000, pf);
	vec3 grad001 = rnm(vec2(perm00, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
	float n001 = dot(grad001, pf - vec3(0.0, 0.0, 1.0));

	// Noise contributions from (x=0, y=1), z=0 and z=1
	float perm01 = rnm(pi.xy + vec2(0.0, permTexUnit)).a;
	vec3 grad010 = rnm(vec2(perm01, pi.z)).rgb * 4.0 - 1.0;
	float n010 = dot(grad010, pf - vec3(0.0, 1.0, 0.0));
	vec3 grad011 = rnm(vec2(perm01, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
	float n011 = dot(grad011, pf - vec3(0.0, 1.0, 1.0));

	// Noise contributions from (x=1, y=0), z=0 and z=1
	float perm10 = rnm(pi.xy + vec2(permTexUnit, 0.0)).a;
	vec3 grad100 = rnm(vec2(perm10, pi.z)).rgb * 4.0 - 1.0;
	float n100 = dot(grad100, pf - vec3(1.0, 0.0, 0.0));
	vec3 grad101 = rnm(vec2(perm10, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
	float n101 = dot(grad101, pf - vec3(1.0, 0.0, 1.0));

	// Noise contributions from (x=1, y=1), z=0 and z=1
	float perm11 = rnm(pi.xy + vec2(permTexUnit, permTexUnit)).a;
	vec3 grad110 = rnm(vec2(perm11, pi.z)).rgb * 4.0 - 1.0;
	float n110 = dot(grad110, pf - vec3(1.0, 1.0, 0.0));
	vec3 grad111 = rnm(vec2(perm11, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
	float n111 = dot(grad111, pf - vec3(1.0, 1.0, 1.0));

	// Blend contributions along x
	float fade_x = pf.x * pf.x * pf.x * (pf.x * (pf.x * 6.0 - 15.0) + 10.0);
	vec4 n_x = mix(vec4(n000, n001, n010, n011), vec4(n100, n101, n110, n111), fade_x);

	// Blend contributions along y
	float fade_y = pf.y * pf.y * pf.y * (pf.y * (pf.y * 6.0 - 15.0) + 10.0);
	vec2 n_xy = mix(n_x.xy, n_x.zw, fade_y);

	// Blend contributions along z
	float fade_z = pf.z * pf.z * pf.z * (pf.z * (pf.z * 6.0 - 15.0) + 10.0);
	float n_xyz = mix(n_xy.x, n_xy.y, fade_z);

	// We're done, return the final noise value.
	return n_xyz;
}

vec2 coordRot(in vec2 tc, in float angle)
{
	float rotX = ((tc.x * 2.0 - 1.0) * AspectRatio * cos(angle)) - ((tc.y * 2.0 - 1.0) * sin(angle));
	float rotY = ((tc.y * 2.0 - 1.0) * cos(angle)) + ((tc.x * 2.0 - 1.0) * AspectRatio * sin(angle));
	rotX = ((rotX / AspectRatio) * 0.5 + 0.5);
	rotY = rotY * 0.5 + 0.5;

	return vec2(rotX, rotY);
}

void main()
{
    float grainamount = 0.03;
    float coloramount = 0.3;
    float lumamount = 1.0;
    float grainsize = 2.0;
	vec3 rotOffset = vec3(1.425, 3.892, 5.835); // Rotation offset values
    ivec2 screensize = textureSize(InputTexture, 0);
    AspectRatio = screensize.x / screensize.y;
	vec2 rotCoordsR = coordRot(TexCoord, timer + rotOffset.x);
	vec3 noise = vec3( pnoise3D(vec3(rotCoordsR * screensize / grainsize, 0.0)) );

	if (coloramount > 0)
	{
		vec2 rotCoordsG = coordRot(TexCoord, timer + rotOffset.y);
		vec2 rotCoordsB = coordRot(TexCoord, timer + rotOffset.z);
		noise.g = mix(noise.r, pnoise3D(vec3(rotCoordsG * screensize / grainsize, 1.0)), coloramount);
		noise.b = mix(noise.r, pnoise3D(vec3(rotCoordsB * screensize / grainsize, 2.0)), coloramount);
	}

	vec3 col = texture(InputTexture, TexCoord).rgb;

	const vec3 lumcoeff = vec3(0.299, 0.587, 0.114);
	float luminance = mix(0.0, dot(col, lumcoeff), lumamount);
	float lum = smoothstep(0.2, 0.0, luminance);
	lum += luminance;


	noise = mix(noise, vec3(0.0), pow(lum, 4.0));
	col = col + noise * grainamount;

    FragColor = vec4(col,1.0);
}