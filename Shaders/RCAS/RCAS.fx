#include "shared/lib.fxh"
#include "ReShadeUI.fxh"

uniform float Sharpness <
  ui_type = "slider";
  ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
  ui_label = "Sharpness";
> = 1.0;

//TODO: decide whether to remove this or not, as is isn't part of standard RCAS
#define RCAS_GREEN_AS_LUMA 0

#ifndef RCAS_DENOISE
  #define RCAS_DENOISE 1
#endif

#include "ReShade.fxh"

#define RCAS_LUMA_WEIGHTS float3(0.5, 1.0, 0.5) // TODO: consider using float3(0.598, 1.174, 0.228)
#define RCAS_LIMIT (0.25 - (1.0 / 16.0)) // TODO: lowering this prevents artifacts and noise at higher sharpnesses

texture ColorTex : COLOR;
sampler colorBufferLinear {
  Texture = ColorTex;
  SRGBTexture = true; // TODO: test this on or off
};

float getRCASLuma(float3 rgb)
{  
  #if RCAS_GREEN_AS_LUMA
    return rgb.g * 2.0;
  #else
    return dot(rgb, RCAS_LUMA_WEIGHTS);
  #endif
}

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
  float bL = getRCASLuma(b);
  float dL = getRCASLuma(d);
  float eL = getRCASLuma(e);
  float fL = getRCASLuma(f);
  float hL = getRCASLuma(h);

  #if RCAS_DENOISE == 1
    // Noise detection.
    float nz = (bL + dL + fL + hL) * 0.25 - eL;
    float range = max(max(max(bL, dL), max(hL, fL)), eL) - min(min(min(bL, dL), min(eL, fL)), hL);
    nz = saturate(abs(nz) * rcp(range));
    nz = -0.5 * nz + 1.0;
  #endif


  // Min and max of ring.
  float3 minRGB = Lib::min(b, d, f, h);
  float3 maxRGB = Lib::max(b, d, f, h);
  // Immediate constants for peak range.
  float2 peakC = float2(1.0, -4.0);

  // Limiters, these need to use high precision reciprocal operations.
  // Decided to use standard rcp for now in hopes of optimizing it
  float3 hitMin = minRGB * rcp(4.0 * maxRGB);
  float3 hitMax = (peakC.xxx - maxRGB) * rcp(4.0 * minRGB + peakC.yyy);
  float3 lobeRGB = max(-hitMin, hitMax);
  float lobe = max(-RCAS_LIMIT, min(Lib::max(lobeRGB), 0.0)) * Sharpness;

  #if RCAS_DENOISE == 1
    // Apply noise removal.
    lobe *= nz;
  #endif

  // Resolve, which needs medium precision rcp approximation to avoid visible tonality changes.
  float rcpL = rcp(4.0 * lobe + 1.0);
  float3 output = ((b + d + f + h) * lobe + e) * rcpL;

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
