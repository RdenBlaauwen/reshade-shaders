#include "ReShadeUI.fxh"


uniform float VignetteDistance <
  ui_type = "slider";
  ui_label = "Distance";
  ui_min = 0.0; ui_max = 0.707; ui_step = 0.01;
> = 0.4;

uniform float TransitionDistance <
  ui_type = "slider";
  ui_label = "Transition distance";
  ui_min = 0.0; ui_max = 0.707; ui_step = 0.01;
> = 0.25;

#include "ReShade.fxh"


float3 VignettePS(float4 vpos: POSITION, float2 texcoord: TEXCOORD) : SV_TARGET
{
  // Debug colors
  const float3 innerColor = float3(1.0, 1.0, 1.0);
  const float3 outerColor = float3(0.0, 0.0, 0.0);

  // Distance from center
  float dist = distance(texcoord, 0.5);

  // Area between VignetteDistance and VignetteDistance + TransitionDistance is lerped from 1.0 to 0.0.
  // Anything below is 0.0, anything above is 1.0
  float strength = smoothstep(VignetteDistance, VignetteDistance + TransitionDistance, dist);

  return lerp(innerColor, outerColor, strength);
}

technique VignetteTest
{
  pass
  {
    VertexShader = PostProcessVS;
    PixelShader = VignettePS;
  }
}