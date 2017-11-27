//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Credits to kingeric1992 http://enbseries.enbdev.com/forum/viewtopic.php?f=7&t=4394
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define saturate(value) clamp(value,0.0,1.0)
#define fLookupTableMix	 1.0

const vec2 CLut_Size = vec2(256.0, 16.0);

vec3 CLutFunc( vec3 colorIN) {
    vec2 CLut_pSize = vec2(1.0 / CLut_Size);
    vec4 CLut_UV;
    colorIN    = saturate(colorIN) * ( CLut_Size.y - 1.0);
    CLut_UV.w  = floor(colorIN.z);
    CLut_UV.xy = (colorIN.xy + 0.5) * CLut_pSize;
    CLut_UV.x += CLut_UV.w * CLut_pSize.y;
    CLut_UV.z  = CLut_UV.x + CLut_pSize.y;
    return       mix(texture(ColourmapLUT, CLut_UV.xy, 0).xyz, 
                     texture(ColourmapLUT, CLut_UV.zy, 0).xyz, colorIN.z - CLut_UV.w);
}

void main() 
{
	vec3 color = texture(InputTexture, TexCoord.xy).xyz;
	vec3 Lutcolor = CLutFunc(color);
	color.xyz = mix(color.xyz,Lutcolor.xyz,fLookupTableMix);
	FragColor = vec4(color, 1.0);
}