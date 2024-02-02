#include "shared/lib.fxh"
#include "ReShadeUI.fxh"

#ifndef ENABLE_NON_STANDARD_FEATURES
  #define ENABLE_NON_STANDARD_FEATURES 0
#endif

uniform int RCASIntroduction <
  ui_category = "about";
	ui_type = "radio";
  ui_text = 
    "RCAS_DENOISE - Noise reduction. Recommended value: 1\n"
    "RCAS_PASSTHROUGH_ALPHA - Lets RCAS output the alpha channel, unchanged.\n"
    "Recommended value: 0\n. If you're having trouble, try turning this on."
    "ENABLE_NON_STANDARD_FEATURES - enables custom features not part\n"
    "of ADM FidelityFX RCAS. Turned off by default, as the default is\n"
    "supposed to approximate real RCAS as much as possible.\n"
    "I recommend you try it out though.";
>;

uniform float Sharpness <
  ui_type = "slider";
  ui_min = 0.0; ui_step = 0.01;
  #if ENABLE_NON_STANDARD_FEATURES
    ui_max = 1.30; 
  #else
    ui_max = 1.0;
  #endif
  ui_label = "Sharpness";
  ui_tooltip = "Sharpening strength.";
> = 1.0;

#if ENABLE_NON_STANDARD_FEATURES == 1
  uniform float RCASLimit <
    ui_type = "slider";
    ui_min = 0.07; ui_max = 0.1875; ui_step = 0.001;
    ui_label = "Limit";
    ui_tooltip = 
      "Limits how much pixels can be sharpened.\n"
      "Lower values reduce artifacts, but may reduce sharpening.";
  > = 0.1875;

  uniform bool GreenAsLuma <
    ui_type = "slider";
    ui_label = "Use green as luma.";
    uit_tooltip =
      "Better performance, but less precision";
  > = false;
#endif

#ifndef RCAS_DENOISE
  #define RCAS_DENOISE 1
#endif

#ifndef RCAS_PASSTHROUGH_ALPHA
  #define RCAS_PASSTHROUGH_ALPHA 0
#endif

#include "ReShade.fxh"

#define RCAS_LUMA_WEIGHTS float3(0.5, 1.0, 0.5) // TODO: consider using float3(0.598, 1.174, 0.228)

#if ENABLE_NON_STANDARD_FEATURES == 1
  #ifdef RCAS_LIMIT
    #undef RCAS_LIMIT
  #endif
  #define RCAS_LIMIT (RCASLimit) // TODO: lowering this prevents artifacts and noise at higher sharpnesses
#else
  #ifdef RCAS_LIMIT
    #undef RCAS_LIMIT
  #endif
  #define RCAS_LIMIT (0.25 - (1.0 / 16.0)) // TODO: lowering this prevents artifacts and noise at higher sharpnesses
#endif

texture ColorTex : COLOR;
sampler colorBufferLinear {
  Texture = ColorTex;
  SRGBTexture = true;
};

float getRCASLuma(float3 rgb)
{  
  #if ENABLE_NON_STANDARD_FEATURES
    if(GreenAsLuma){
      return rgb.g * 2.0;
    }

    return dot(rgb, RCAS_LUMA_WEIGHTS);
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
  #if RCAS_PASSTHROUGH_ALPHA
    float4 curr = tex2D(colorBufferLinear, texcoord).rgba;
    float3 e = curr.rgb;
    float alpha = curr.a;
  #else
    float3 e =  tex2D(colorBufferLinear, texcoord).rgb;
  #endif

  float3 b = tex2Doffset(colorBufferLinear, texcoord, int2(0,-1)).rgb;
  float3 d = tex2Doffset(colorBufferLinear, texcoord, int2(-1,0)).rgb;
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

  #if RCAS_PASSTHROUGH_ALPHA
    return float4(output.r, output.g, output.b, alpha);
  #else
    return output;
  #endif
}

technique RobustContrastAdaptiveSharpening 
  <
    ui_label = "AMD FidelityFX Robust Contrast Adaptive Sharpening";
    ui_tooltip = 
      "RCAS is a low overhead adaptive sharpening shader included in AMD FidelityFX FSR 1.\n"
      "It is a derivative of AMD FidelityFX CAS, but it \"uses a more exact mechanism, \n"
      "solving for the maximum local sharpness possible before clipping.\"\n"
      "It also lacks the support for scaling that AMD CAS has.\n";
      "\n"
      "The algorithm applies less sharpening to areas that are already sharp, while more\n"
      "featureless areas are sharpened more. This prevents artifacts, like ugly contours.\n"
      "\n"
      "RCAS was never meant to be used as a stand-alone shader. I decided to do it anyways\n"
      "because (imho) it has excellent results and performance. However, since this shader\n"
      "uses RCAS in a way it was never intended to, I should make clear that any shortcomings\n"
      "this shader may have are not representative of the quality of AMD FidelityFX FSR, or\n"
      "any other of AMD FidelityFX' shaders, or of the skills of the AMD FidelityFX team.\n";
  >
{
  pass
  {
    VertexShader = PostProcessVS;
    PixelShader = rcasPS;
    SRGBWriteEnable = true; // TODO: test this on or off
  } 
}
