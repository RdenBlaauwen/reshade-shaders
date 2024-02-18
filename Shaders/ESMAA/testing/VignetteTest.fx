#include "ReShadeUI.fxh"


uniform float MaxDebugDistance <
  ui_type = "slider";
  ui_label = "Max Distance";
  ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.5;

#include "ReShade.fxh"


float3 vignette(float4 vpos: POSITION, float2 texcoord: TEXCOORD) : SV_TARGET
{
  float dist = distance(texcoord, 0.5);

  if(dist <= MaxDebugDistance) {
    return float3(1.0, 1.0, 1.0);
  }
  return float3(0.0, 0.0, 0.0);
}

technique VignetteTest
{
  pass
  {
    VertexShader = PostProcessVS;
    PixelShader = vignette;
  }
}