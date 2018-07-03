/*
//Noise animation - Lava
//by nimitz (twitter: @stormoid)
// Try by x-->0

//Somewhat inspired by the concepts behind "flow noise"
//every octave of noise is modulated separately
//with displacement using a rotated vector field

//This is a more standard use of the flow noise
//unlike my normalized vector field version (https://www.shadertoy.com/view/MdlXRS)
//the noise octaves are actually displaced to create a directional flow

//Sinus ridged fbm is used for better effect.

uniform float timer;

// Big thanks ZZYZX for fix
vec4 textureBilinear(sampler2D t, vec2 uv)
{
	ivec2 textureSize = textureSize(t, 0);
	vec2 texelSize = 1.0/textureSize;
    vec2 f = fract(uv * textureSize);
    uv = (floor(uv*textureSize)+vec2(0.5, 0.5))/textureSize; // <- Fix here
    vec4 tl = texture(t, uv);
    vec4 tr = texture(t, uv + vec2(texelSize.x, 0.0));
    vec4 bl = texture(t, uv + vec2(0.0, texelSize.y));
    vec4 br = texture(t, uv + vec2(texelSize.x, texelSize.y));
    vec4 tA = mix( tl, tr, f.x );
    vec4 tB = mix( bl, br, f.x );
    return mix( tA, tB, f.y );
}

float hash21(in vec2 n){ return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453); }
mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(c,-s,s,c);}
float noise( in vec2 x ){return textureBilinear(tex, x*.01).x;}
vec2 gradn(vec2 p)
{
	float ep = .09;
	float gradx = noise(vec2(p.x+ep,p.y))-noise(vec2(p.x-ep,p.y));
	float grady = noise(vec2(p.x,p.y+ep))-noise(vec2(p.x,p.y-ep));
	return vec2(gradx,grady);
}

float flow(in vec2 p)
{
	float z=2.;
	float rz = 0.;
	vec2 bp = p;
	for (float i= 1.;i < 7.;i++ )
	{
		//primary flow speed
		p += timer*.6;
		
		//secondary flow speed (speed of the perceived flow)
		bp += timer*1.9;
		
		//displacement field (try changing time multiplier)
		vec2 gr = gradn(i*p*.34+timer*1.);
		
		//rotation of the displacement field
		gr*=makem2(timer*6.-(0.05*p.x+0.03*p.y)*40.);
		
		//displace the system
		p += gr*.5;
		
		//add noise octave
		rz+= (sin(noise(p)*7.)*0.5+0.5)/z;
		
		//blend factor (blending displaced system with base system)
		//you could call this advection factor (.5 being low, .95 being high)
		p = mix(bp,p,.77);
		
		//intensity scaling
		z *= 1.4;
		//octave scaling
		p *= 2.;
		bp *= 1.9;
	}
	return rz;	
}

vec4 Process(vec4 color)
{
	vec2 iResolution = vec2(0.5, 0.5);
	vec2 p = gl_TexCoord[0].st / iResolution.xy-0.5;
	p.x *= iResolution.x/iResolution.y;
	p *= 3.0;
	
	float rz = flow(p);
	
	vec3 col = vec3(.2,0.07,0.01)/rz;
	col=pow(col,vec3(1.4));
	return vec4(col,1.0);
	// vec4 tex = textureBilinear(tex, gl_TexCoord[0].st);
	// return tex;
}*/

//Noise animation - Lava
//by nimitz (twitter: @stormoid)
// Try by x-->0

//Somewhat inspired by the concepts behind "flow noise"
//every octave of noise is modulated separately
//with displacement using a rotated vector field

//This is a more standard use of the flow noise
//unlike my normalized vector field version (https://www.shadertoy.com/view/MdlXRS)
//the noise octaves are actually displaced to create a directional flow

//Sinus ridged fbm is used for better effect.

uniform float timer;

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}


float CatMullRom( float x )
{
    const float B = 0.0;
    const float C = 0.5;
    float f = x;
    if( f < 0.0 )
    {
        f = -f;
    }
    if( f < 1.0 )
    {
        return ( ( 12 - 9 * B - 6 * C ) * ( f * f * f ) +
            ( -18 + 12 * B + 6 *C ) * ( f * f ) +
            ( 6 - 2 * B ) ) / 6.0;
    }
    else if( f >= 1.0 && f < 2.0 )
    {
        return ( ( -B - 6 * C ) * ( f * f * f )
            + ( 6 * B + 30 * C ) * ( f *f ) +
            ( - ( 12 * B ) - 48 * C  ) * f +
            8 * B + 24 * C)/ 6.0;
    }
    else
    {
        return 0.0;
    }
} 

 vec4 textureBilinear(sampler2D t, vec2 uv)
 {
	 ivec2 textureSize = textureSize(t, 0);
	 vec2 texelSize = 1.0/textureSize;
     vec2 f = fract(uv * textureSize);
	 vec2 uv_base = (floor(uv*textureSize)+vec2(0.5, 0.5))/textureSize;
	 uv = uv_base;
     vec4 tl = texture(t, uv);
     vec4 tr = texture(t, uv + vec2(texelSize.x, 0.0));
     vec4 bl = texture(t, uv + vec2(0.0, texelSize.y));
     vec4 br = texture(t, uv + vec2(texelSize.x, texelSize.y));
     vec4 tA = mix( tl, tr, f.x );
     vec4 tB = mix( bl, br, f.x );
     return mix( tA, tB, f.y );
 }

vec4 textureBicubic( sampler2D textureSampler, vec2 TexCoord )//(sampler2D sampler, vec2 texCoords)
{
   vec2 texSize = textureSize(tex, 0);
   // vec2 invTexSize = 1.0 / texSize;
   
   // texCoords = texCoords * texSize - 0.5;

   
    // vec2 fxy = fract(texCoords);
    // texCoords -= fxy;

    // vec4 xcubic = cubic(fxy.x);
    // vec4 ycubic = cubic(fxy.y);

    // vec4 c = texCoords.xxyy + vec2(-0.5, +1.5).xyxy;
    
    // vec4 s = vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
    // vec4 offset = c + vec4(xcubic.yw, ycubic.yw) / s;
    
    // offset *= invTexSize.xxyy;
    
    // vec4 sample0 = texture(sampler, offset.xz);
    // vec4 sample1 = texture(sampler, offset.yz);
    // vec4 sample2 = texture(sampler, offset.xw);
    // vec4 sample3 = texture(sampler, offset.yw);

    // float sx = s.x / (s.x + s.y);
    // float sy = s.z / (s.z + s.w);

    // return mix(
       // mix(sample3, sample2, sx), mix(sample1, sample0, sx)
    // , sy);
	

    float texelSizeX = 1.0 / texSize.x; //size of one texel 
    float texelSizeY = 1.0 / texSize.y; //size of one texel 
    vec4 nSum = vec4( 0.0, 0.0, 0.0, 0.0 );
    vec4 nDenom = vec4( 0.0, 0.0, 0.0, 0.0 );
    float a = fract( TexCoord.x * texSize.x ); // get the decimal part
    float b = fract( TexCoord.y * texSize.y ); // get the decimal part
    for( int m = -1; m <=2; m++ )
    {
        for( int n =-1; n<= 2; n++)
        {
			vec4 vecData = texture(textureSampler, 
                               TexCoord + vec2(texelSizeX * float( m ), 
					texelSizeY * float( n )));
			float f  = CatMullRom( float( m ) - a );
			vec4 vecCooef1 = vec4( f,f,f,f );
			float f1 = CatMullRom ( -( float( n ) - b ) );
			vec4 vecCoeef2 = vec4( f1, f1, f1, f1 );
            nSum = nSum + ( vecData * vecCoeef2 * vecCooef1  );
            nDenom = nDenom + (( vecCoeef2 * vecCooef1 ));
        }
    }
    return nSum / nDenom;

}

vec4 getTexelSmooth(in vec2 x)
{
	float noise = snoise(x/.03);
	//return vec4(noise,noise,noise,1);
	return textureBilinear(tex, x);
}

float hash21(in vec2 n){ return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453); }
mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(c,-s,s,c);}
float noise( in vec2 x ){return getTexelSmooth(x*.01).x;}
vec2 gradn(vec2 p)
{
	float ep = .09;
	float gradx = noise(vec2(p.x+ep,p.y))-noise(vec2(p.x-ep,p.y));
	float grady = noise(vec2(p.x,p.y+ep))-noise(vec2(p.x,p.y-ep));
	return vec2(gradx,grady);
}

float flow(in vec2 p)
{
	float z=2.;
	float rz = 0.;
	vec2 bp = p;
	for (float i= 1.;i < 7.;i++ )
	{
		//primary flow speed
		p += timer*.6;
		
		//secondary flow speed (speed of the perceived flow)
		bp += timer*1.9;
		
		//displacement field (try changing time multiplier)
		vec2 gr = gradn(i*p*.34+timer*1.);
		
		//rotation of the displacement field
		gr*=makem2(timer*6.-(0.05*p.x+0.03*p.y)*40.);
		
		//displace the system
		p += gr*.5;
		
		//add noise octave
		rz+= (sin(noise(p)*7.)*0.5+0.5)/z;
		
		//blend factor (blending displaced system with base system)
		//you could call this advection factor (.5 being low, .95 being high)
		p = mix(bp,p,.77);
		
		//intensity scaling
		z *= 1.4;
		//octave scaling
		p *= 2.;
		bp *= 1.9;
	}
	return rz;	
}

vec4 Process(vec4 color)
{
	vec2 iResolution = vec2(0.5, 0.5);
	vec2 p = gl_TexCoord[0].st / iResolution.xy-0.5;
	p.x *= iResolution.x/iResolution.y;
	p *= 3.0;
	
	float rz = flow(p);
	
	vec3 col = vec3(.2,0.07,0.01)/rz;
	//col=pow(col,vec3(1.4));
	col=pow(col * 2,vec3(1.4));
	return vec4(col,1.0);

}