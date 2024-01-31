#include "shared/lib.fxh"
#include "ReShadeUI.fxh"

uniform float Sharpness <
  ui_type = "slider";
  ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
  ui_label = "Sharpness";
> = 1.0;

#include "ReShade.fxh"

#define PIXEL_DATA float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define RCAS_LUMA_WEIGHTS float3(0.5, 1.0, 0.5)
#define RCAS_LIMIT (0.25-(1.0/16.0))

texture ColorTex : COLOR;
sampler colorBufferLinear {
  Texture = ColorTex;
  SRGBTexture = true; // TODO: test this on or off
};

// Based on https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK/blob/main/sdk/include/FidelityFX/gpu/fsr1/ffx_fsr1.h#L684
float3 rcasPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
  // Algorithm uses minimal 3x3 pixel neighborhood.
  //    b
  //  d e f
  //    h
  float3 b = tex2Doffset(colorBufferLinear, texcoord, int2(0,-1)).rgb;
  float3 d = tex2Doffset(colorBufferLinear, texcoord, int2(-1,0)).rgb;
  float3 e = tex2Doffset(colorBufferLinear, texcoord, int2(0,0)).rgb;
  float3 f = tex2Doffset(colorBufferLinear, texcoord, int2(1,0)).rgb;
  float3 h = tex2Doffset(colorBufferLinear, texcoord, int2(0,1)).rgb;

  // Get lumas times 2. Should use luma weights that are twice as large as normal.
  float bL = dot(b, RCAS_LUMA_WEIGHTS);
  float dL = dot(d, RCAS_LUMA_WEIGHTS);
  float eL = dot(e, RCAS_LUMA_WEIGHTS);
  float fL = dot(f, RCAS_LUMA_WEIGHTS);
  float hL = dot(h, RCAS_LUMA_WEIGHTS);

  // Noise detection.
  float nz = bL * 0.25 + dL * 0.25 + fL * 0.25 + hL * 0.25 - eL;
  float range = Lib::max(bL,dL,eL,fL,hL) - Lib::min(bL,dL,eL,fL,hL);
  nz = saturate(abs(nz) * rcp(range));
  nz = -0.5 * nz + 1.0;

  // Min and max of ring.
  float3 minRGB = lib::min(b, d, f, h);
  float3 maxRGB = lib::max(b, d, f, h);
  // Immediate constants for peak range.
  float2 peakC = float2(1.0, -1.0 * 4.0);

  // Limiters, these need to use high precision reciprocal operations.
  float3 hitMin = minRGB * (1 / (4.0 * maxRGB));
  float3 hitMax = (peakC.xxx - maxRGb) * (1 / (4.0 * minRGB + peakC.yyy));
  float3 lobeRGB = max(-hitMin, hitMax);
  float lobe = max(-RCAS_LIMIT, Lib::min(Lib::max(lobeRGB), 0.0)) * Sharpness;

  // Apply noise removal.
  lobe *= nz;

  // Resolve, which needs medium precision rcp approximation to avoid visible tonality changes.
  float rcpL = rcp(4.0 * lobe + 1.0);
  float3 output = (lobe * b + lobe * d + lobe * f + lobe * h + e) * rcpL;

  return output;
}

technique RobustContrastAdaptiveSharpening 
  <
    ui_label = "AMD FidelityFX Robust Contrast Adaptive Sharpening";
  >
{
  pass
  {
    VertexShader = PostProcessVS;
    PixelShader = rcasPS;
    SRGBWriteEnable = true; // TODO: test this on or off
  } 
}
