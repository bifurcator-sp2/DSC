uniform float timer;
const float pi = 3.14159265358979323846;
const float Intensity = 0.1;

vec4 Process(vec4 color)
{
  vec2 t = gl_TexCoord[0].st;
  t.x += Intensity * (cos(timer/1.5) * max(0.0, 0.63 - t.y)) * sin( t.x * pi * .5 );
  t += noise2(t) * sin( pi * 0.5 *( timer* 0.5 ));
  return getTexel(t) * color;
}