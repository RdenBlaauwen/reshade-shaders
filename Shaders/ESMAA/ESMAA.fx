
/////////////////////////////////// CREDITS ///////////////////////////////////
//TODO: consider adding explicit credits to EACH piece of code not made by me
// This shader includes code adapted from existing shaders, 
// which aren't made by RdenBlaauwen.
// Do not distribute without giving credit to the original author(s).
// All original code not attributed to the below authors is made by
// Robert den Blaauwen aka "RdenBlaauwen" (rdenblaauwen@gmail.com)

/**
 *                  _______  ___  ___       ___           ___
 *                 /       ||   \/   |     /   \         /   \
 *                |   (---- |  \  /  |    /  ^  \       /  ^  \
 *                 \   \    |  |\/|  |   /  /_\  \     /  /_\  \
 *              ----)   |   |  |  |  |  /  _____  \   /  _____  \
 *             |_______/    |__|  |__| /__/     \__\ /__/     \__\
 * 
 *                               E N H A N C E D
 *       S U B P I X E L   M O R P H O L O G I C A L   A N T I A L I A S I N G
 *
 *                         http://www.iryoku.com/smaa/
 */
/**
 * Copyright (C) 2013 Jorge Jimenez (jorge@iryoku.com)
 * Copyright (C) 2013 Jose I. Echevarria (joseignacioechevarria@gmail.com)
 * Copyright (C) 2013 Belen Masia (bmasia@unizar.es)
 * Copyright (C) 2013 Fernando Navarro (fernandn@microsoft.com)
 * Copyright (C) 2013 Diego Gutierrez (diegog@unizar.es)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to
 * do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software. As clarification, there
 * is no requirement that the copyright notice and permission be included in
 * binary distributions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
/**
 * This shader contains components and/or adapted from Lordbean's ASSMAA.
 * https://github.com/lordbean-git/ASSMAA
 * 
 * All code attributed to "Lordbean" is copyright (c) Derek Brush (derekbrush@gmail.com)
 */
/*               TSMAA for ReShade 3.1.1+
 *
 *    (Temporal Subpixel Morphological Anti-Aliasing)
 *
 *
 *     Experimental multi-frame SMAA implementation
 *
 *                     by lordbean
 *
 */
/** 
 * This shader contains components taken and/or adapted from Lordbean's TSMAA.
 * https://github.com/lordbean-git/reshade-shaders/blob/main/Shaders/TSMAA.fx
 * 
 * All code attributed to "Lordbean" is copyright (c) Derek Brush (derekbrush@gmail.com)
 */
 /*------------------------------------------------------------------------------
 * THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *-------------------------------------------------------------------------------*/

/**
 * This shader contains a pass based on  AMD's RCAS.
 * https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK/blob/main/sdk/include/FidelityFX/gpu/fsr1/ffx_fsr1.h#L684
 */
// RCAS LICENCE
// ============
// Copyright (C)2023 Advanced Micro Devices, Inc.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files(the “Software”), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and /or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions :
// 
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.

//Implementation and additions by RdenBlaauwen:
//  The defaults are supposed to approximate AMD FidelityFX RCAS to the best of my abilities.
//  I added some additional features, but these are only available when
//  ENABLE_NON_STANDARD_FEATURES is set to 1.
//   - The ability to use a Sharpness value of > 1.0, for stronger sharpening than normal.
//   - Ability to lower the RCAS_LIMIT. This decreases artifacts and extreme sharpening, 
//     but may decrease sharpening strength. Lowering this value is recommended when using very high Sharpness settings.
//   - Option to use green as luma instead of the dot product of luma weights. 
//     This improves performance, but may decrease quality.


/**
 * This shader contains a port of AMD FidelityFX CAS, found on CeeJay.DK's github:
 * https://github.com/CeeJayDK/SweetFX/blob/master/Shaders/CAS.fx
 */
// LICENSE
// =======
// Copyright (c) 2017-2019 Advanced Micro Devices, Inc. All rights reserved.
// -------
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// -------
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
// -------
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

//Initial port to ReShade: SLSNe	https://gist.github.com/SLSNe/bbaf2d77db0b2a2a0755df581b3cf00c

//Optimizations by Marty McFly:
//	vectorized math, even with scalar gcn hardware this should work
//	out the same, order of operations has not changed
//	For some reason, it went from 64 to 48 instructions, a lot of MOV gone
//	Also modified the way the final window is calculated
//	  
//	reordered min() and max() operations, from 11 down to 9 registers	
//
//	restructured final weighting, 49 -> 48 instructions
//
//	delayed RCP to replace SQRT with RSQRT
//
//	removed the saturate() from the control var as it is clamped
//	by UI manager already, 48 -> 47 instructions
//
//	replaced tex2D with tex2Doffset intrinsic (address offset by immediate integer)
//	47 -> 43 instructions
//	9 -> 8 registers

//Further modified by OopyDoopy and Lord of Lunacy:
//	Changed wording in the UI for the existing variable and added a new variable and relevant code to adjust sharpening strength.

//Fix by Lord of Lunacy:
//	Made the shader use a linear colorspace rather than sRGB, as recommended by the original AMD documentation from FidelityFX.

//Modified by CeeJay.dk:
//	Included a label and tooltip description. I followed AMDs official naming guidelines for FidelityFX.
//
//	Used gather trick to reduce the number of texture operations by one (9 -> 8). It's now 42 -> 51 instructions but still faster
//	because of the texture operation that was optimized away.

//Fix by CeeJay.dk
//	Fixed precision issues with the gather at super high resolutions
//	Also tried to refactor the samples so more work can be done while they are being sampled, but it's not so easy and the gains
//	I'm seeing are so small they might be statistical noise. So it MIGHT be faster - no promises.

// #include "../shared/lib.fxh" // Not necesssary as long as "ESMAACore.fxh" is included
#include "ReShade.fxh"

//------------------- Preprocessor Settings -------------------

#if !defined(SMAA_PRESET_LOW) && !defined(SMAA_PRESET_MEDIUM) && !defined(SMAA_PRESET_HIGH) && !defined(SMAA_PRESET_ULTRA)
#define SMAA_PRESET_CUSTOM // Do not use a quality preset by default
#endif

//----------------------- UI Variables ------------------------ 

#include "ReShadeUI.fxh"

uniform int MaxSearchSteps < __UNIFORM_SLIDER_INT1
	ui_min = 1; ui_max = 112;
	ui_label = "Max Search Steps";
	ui_tooltip = "Determines the radius SMAA will search for aliased edges";
> = 32;

uniform int MaxSearchStepsDiagonal < __UNIFORM_SLIDER_INT1
	ui_min = 1; ui_max = 32;
	ui_label = "Max Search Steps Diagonal";
	ui_tooltip = "Determines the radius SMAA will search for diagonal aliased edges";
> = 20;

uniform int CornerRounding < __UNIFORM_SLIDER_INT1
	ui_min = 0; ui_max = 100;
	ui_label = "Corner Rounding";
	ui_tooltip = "Determines the percent of anti-aliasing to apply to corners";
> = 10;

uniform int DebugOutput < __UNIFORM_COMBO_INT1
	ui_items = "None\0View edges\0View weights\0Depth predication\0Edge prediction\0";
	ui_label = "Debug Output";
> = false;

uniform bool EnableSMAABlendingWeightCalc <
	ui_label = "Enable blend weight calc";
> = true;

uniform bool ESMAAEnableSMAABlending <
	ui_label = "Enable SMAA blending";
	ui_tooltip = "Calculates the final result for SMAA. Turning this off stops SMAA from doing\n"
				 "actual anti-aliasing, but won't stop it from detecting edges and calculating weights.\n"
				 "Turning this off won't affect other effects.";
> = true;

uniform int EdgeDetectionMethod < __UNIFORM_COMBO_INT1
	ui_category = "Edge Detection";
	ui_items = "Luma\0Color\0Euclidian Luma\0Hyrid\0";
	ui_label = "Edge detection method";
> = 3;

// Threshold for detecting edges on surfaces. 
// Typically higher to prevent false positives
uniform float EdgeDetectionThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Edge Threshold";
	ui_min = 0.050; ui_max = 0.15; ui_step = 0.001;
> = 0.09;

uniform float ContrastAdaptationFactor < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Local Contrast Adaptation Factor";
	ui_min = 1.5; ui_max = 4.0; ui_step = 0.1;
	ui_tooltip = "High values increase anti-aliasing effect, but may increase artifacts.";
> = 2.0;

uniform int ESMAADivider1 <
	ui_category = "Edge Detection";
	ui_type = "radio";
	ui_label = " ";
>;

uniform int DepthPredicationMethod < __UNIFORM_COMBO_INT1
	ui_category = "Edge Detection";
	ui_items = "None\0Simple\0Edge prediction\0";
	ui_label = "DepthPredicationMethod";
> = 0;

uniform float PredicationThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Predication threshold";
	ui_min = 0.01; ui_max = 0.05; ui_step = 0.001;
	ui_tooltip = "Depth Edge detection threshold. If SMAA misses some edges try lowering this slightly.";
> = 0.015;

uniform float EdgeEstimationThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Edge prediction threshold";
	ui_min = 0.5; ui_max = 2.0; ui_step = 0.1;
> = 1.2;

uniform float PredicationAmount < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Threshold for local avg";
	ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
	ui_tooltip = "Amount by which threshold is lowered upon finding a depth edge.";
> = 0.95;

uniform int ESMAADivider2 <
	ui_category = "Edge Detection";
	ui_type = "radio";
	ui_label = " ";
>;

uniform float EdgeThresholdVignetteDistance <
  ui_category = "Edge Detection";
  ui_type = "slider";
  ui_label = "Thresh vignette distance";
  ui_min = 0.3; ui_max = 0.707; ui_step = 0.01;
> = 0.5;

uniform float EdgeThresholdTransitionDistance <
ui_category = "Edge Detection";
  ui_type = "slider";
  ui_label = "Thresh vignette transition";
  ui_min = 0.0; ui_max = 0.407; ui_step = 0.01;
> = 0.25;

uniform int ESMAADivider4 <
	ui_category = "Edge Detection";
	ui_type = "radio";
	ui_label = " ";
>;

uniform bool ESMAAEnableAdaptiveThreshold <
	ui_category = "Edge Detection";
	ui_label = "Enable adaptive threshold";
	ui_tooltip = "Adapts edge detection threshold for darker areas, where more sensitivity is needed.\n"
				 "Lets the shader anti-aliase many jaggies it would normally miss, but may blur texures a bit.\n";
> = true;

uniform float ESMAALumaAdaptationRange <
	ui_category = "Edge Detection";
	ui_type = "slider";
	ui_label = "ESMAALumaAdaptationRange";
	ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
	ui_tooltip = "Lower values detect more in darker areas, but may cause artifacts and blur.";
> = 0.95;

uniform bool ESMAAEnableSoftening <
	ui_category = "Image Softening";
	ui_label = "Enable softening";
> = true;

uniform bool ESMAADisableBackgroundSoftening <
	ui_category = "Image Softening";
	ui_label = "Skip background";
	ui_tooltip = "This lets the shader skip the sky/background/skybox.\n"
				 "Only works if ReShade has access to this game's depth buffer.";
> = true;

// uniform int ESMAAAnomalousPixelBlendingStrengthMethod < __UNIFORM_COMBO_INT1
// 	ui_category = "Image Softening";
// 	ui_items = "Strongly favor precision\0Favor precision\0Balanced\0Favor softening\0Strongly favor softening\0";
// 	ui_label = "Softening method";
// 	ui_tooltip = "This determines how the degree by which a pixel differs from it's surroundings is calculated.\n"
// 				 "\n"
// 				 "Methods that favor precision are conservative and only target the bigger outliers.\n"
// 				 "Recommended for people who like crisp images and just want to filter out extremes.\n"
// 				 "\n"
// 				 "Methods that favor softening are aggressive and even target pixels that differ slightly.\n"
// 				 "Recommended for people who like smooth images and don't mind risking blurriness.";
// > = 1;

uniform int ESMAAAnomalousPixelScaling < __UNIFORM_COMBO_INT1
	ui_items = "Subtle\0Balanced\0Agressive\0";
	ui_label = "Strength scaling";
	ui_tooltip = "This determines how softening strength scales with the degree\n"
				"by which a pixel differs from it's surroundings. More aggressive\n"
				"settings mean less anomalous pixels are softened more than normal.";
	ui_category = "Image Softening";
> = 1;

uniform int ESMAADivider3 <
	ui_category = "Image Softening";
	ui_type = "radio";
	ui_label = " ";
>;

uniform float ESMAASofteningStrength <
	ui_type = "slider";
	ui_min = 0.05; ui_max = 1.0; ui_step = 0.01;
	ui_label = "Blending strength";
	ui_tooltip = "The degree in which the final result is blended with the image.\n"
				 "Lower values = weaker effect.";
	ui_category = "Image Softening";
> = 0.85;

uniform float ESMAASofteningExtraPixelSoftening<
	ui_type = "slider";
	ui_min = 0.0; ui_max = 0.5; ui_step = 0.01;
	ui_label = "Extra pixel smoothing";
	ui_category = "Image Softening";
> = 0.15;

uniform bool ESMAAEnableSmoothing <
	ui_category = "Smoothing";
	ui_label = "Enable 'smoothing' AA";
> = true;

uniform float SmoothingThreshold <
	ui_category = "Smoothing";
	ui_type = "slider";
	ui_min = 0.01; ui_max = 0.15; ui_step = 0.001;
	ui_label = "Threshold";
> = 0.05;

uniform float EdgeThresholdModifier <
	ui_category = "Smoothing";
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
	ui_label = "Edge thresh mod";
> = 0.35;

// creates max value for the `maxblending` var
uniform float ESMAASmoothingStrengthMod <
	ui_category = "Smoothing";
	ui_type = "slider";
	ui_label = "Strength modifier";
	ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

uniform uint ESMAASmoothingMaxIterations <
	ui_category = "Smoothing";
	ui_type = "slider";
	ui_label = "SmoothingMaxIterations";
	ui_min = 5; ui_max = 20; ui_step = 1;
> = 15;

uniform float SmoothingVignetteDistance <
  ui_category = "Smoothing";
  ui_type = "slider";
  ui_label = "Thresh vignette distance";
  ui_min = 0.0; ui_max = 0.707; ui_step = 0.01;
> = 0.35;

uniform float SmoothingTransitionDistance <
ui_category = "Smoothing";
  ui_type = "slider";
  ui_label = "Thresh vignette transition";
  ui_min = 0.0; ui_max = 0.707; ui_step = 0.01;
> = 0.25;

uniform bool SmoothingDebug <
	ui_category = "Smoothing";
	ui_label = "SmoothingDebug";
> = false;

uniform int SharpeningMethod < __UNIFORM_COMBO_INT1
	ui_category = "Sharpening";
	ui_label = "Sharpening method";
	ui_items = "None\0Fast\0Precise\0";
> = 1;

// // TODO: consider using uint instead
// uniform float MaxCorners <
// 	ui_type = "slider";
// 	ui_category = "Sharpening";
// 	ui_label = "Max # of corners";
// 	ui_min = 0.0; ui_max = 4.0; ui_step = 1.0;
// > = 0.0;

uniform float EdgeBias <
	ui_type = "slider";
	ui_category = "Sharpening";
	ui_label = "Edge Bias";
	ui_min = -4.0; ui_max = 0.0; ui_step = 0.01;
> = -2.0;

uniform float SharpeningStrength <
	ui_category = "Sharpening";
	ui_type = "slider";
	ui_label = "Sharpening strength";
	ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;


// depths greater than this are considered part of the background/skybox
#define ESMAA_BACKGROUND_DEPTH_THRESHOLD 0.999
#define ESMAA_EDGE_PREDICTION_THRESHOLD (0.000001 * pow(10,EdgeEstimationThreshold))
// weights for luma calculations
#define TSMAA_LUMA_REF float3(0.299, 0.587, 0.114)
#define ESMAA_THRESHOLD_FLOOR 0.018

#ifndef ESMAA_EDGE_PREDICTION_WEIGHT
	#define ESMAA_EDGE_PREDICTION_WEIGHT 0.8 //TODO: test this value.
#endif

/**
 * SMAA preprocessor variables, from Lordbean's ASSMAA
 */
#ifdef SMAA_PRESET_CUSTOM
	#define SMAA_THRESHOLD EdgeDetectionThreshold
	#define SMAA_DEPTH_THRESHOLD 0.004
	#define SMAA_MAX_SEARCH_STEPS MaxSearchSteps
	#define SMAA_CORNER_ROUNDING CornerRounding
	#define SMAA_MAX_SEARCH_STEPS_DIAG MaxSearchStepsDiagonal
	#define SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR ContrastAdaptationFactor
#endif

#define SMAA_RT_METRICS float4(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT, BUFFER_WIDTH, BUFFER_HEIGHT)
#define SMAA_CUSTOM_SL 1

#define SMAATexture2D(tex) sampler tex
#define SMAATexturePass2D(tex) tex
#define SMAASampleLevelZero(tex, coord) tex2Dlod(tex, float4(coord, coord))
#define SMAASampleLevelZeroPoint(tex, coord) SMAASampleLevelZero(tex, coord)
#define SMAASampleLevelZeroOffset(tex, coord, offset) tex2Dlodoffset(tex, float4(coord, coord), offset)
#define SMAASample(tex, coord) tex2D(tex, coord)
#define SMAASamplePoint(tex, coord) SMAASample(tex, coord)
#define SMAASampleOffset(tex, coord, offset) tex2Doffset(tex, coord, offset)
#define SMAA_BRANCH [branch]
#define SMAA_FLATTEN [flatten]

#if (__RENDERER__ == 0xb000 || __RENDERER__ == 0xb100)
	#define SMAAGather(tex, coord) tex2Dgather(tex, coord, 0)
#endif

/**
 * Edge threshold pre-processor variable, from Lordbean's TSMAA
 */
// #define __TSMAA_EDGE_THRESHOLD (PredicationEdgeThreshold) //TODO: test if this must be reactivated

#include "SMAA.fxh"
#include "ESMAACore.fxh"

// Textures

texture edgesTex < pooled = true; >
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = RG8;
};
texture blendTex < pooled = true; >
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = RGBA8;
};

texture areaTex < source = "AreaTex.png"; >
{
	Width = 160;
	Height = 560;
	Format = RG8;
};
texture searchTex < source = "SearchTex.png"; >
{
	Width = 64;
	Height = 16;
	Format = R8;
};

// Samplers
sampler colorGammaSampler
{
	Texture = ReShade::BackBufferTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler colorLinearSampler
{
	Texture = ReShade::BackBufferTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = true;
};
sampler edgesSampler
{
	Texture = edgesTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler blendSampler
{
	Texture = blendTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler areaSampler
{
	Texture = areaTex;
	AddressU = Clamp; AddressV = Clamp; AddressW = Clamp;
	MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler searchSampler
{
	Texture = searchTex;
	AddressU = Clamp; AddressV = Clamp; AddressW = Clamp;
	MipFilter = Point; MinFilter = Point; MagFilter = Point;
	SRGBTexture = false;
};

//////////////////////////////// VERTEX SHADERS ////////////////////////////////

/**
 * From Lordbean's ASSMAA shader. 
 */
void SMAAEdgeDetectionWrapVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position,
	out float2 texcoord : TEXCOORD0,
	out float4 offset[3] : TEXCOORD1)
{
	PostProcessVS(id, position, texcoord);
	SMAAEdgeDetectionVS(texcoord, offset);
}
/**
 * From Lordbean's ASSMAA shader. 
 */
void SMAABlendingWeightCalculationWrapVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position,
	out float2 texcoord : TEXCOORD0,
	out float2 pixcoord : TEXCOORD1,
	out float4 offset[3] : TEXCOORD2)
{
	PostProcessVS(id, position, texcoord);
	SMAABlendingWeightCalculationVS(texcoord, pixcoord, offset);
}
/**
 * From Lordbean's ASSMAA shader. 
 */
void SMAANeighborhoodBlendingWrapVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position,
	out float2 texcoord : TEXCOORD0,
	out float4 offset : TEXCOORD1)
{
	PostProcessVS(id, position, texcoord);
	SMAANeighborhoodBlendingVS(texcoord, offset);
}

/**
 * From Lordbean's TSMAA shader. 
 */
void TSMAANeighborhoodBlendingVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float4 offset : TEXCOORD1)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
    offset = mad(SMAA_RT_METRICS.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
	// offset.xy -> pixel to the left
	// offset.zw -> pixel to the bottom
}

//////////////////////////////// PIXEL SHADERS (WRAPPERS) ////////////////////////////////

/**
 * Custom edge detection pass that uses one or more edge detection methods in succession
 */
float2 EdgeDetectionWrapperPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float4 offset[3] : TEXCOORD1) : SV_Target
{
	const float THRESHOLD_AT_TRANSITION_EXTREME = 0.8;
	const float SCREEN_CENTER = 0.5;

	// Calc distance from center for threshold vignetting
	float vignetteDist = distance(texcoord, SCREEN_CENTER);
	// Area between VignetteDistance and VignetteDistance + TransitionDistance is lerped from 1.0 to 0.0.
  // Anything below is 0.0, anything above is 1.0
  float vignetteStrength = smoothstep(
		EdgeThresholdVignetteDistance, 
		EdgeThresholdVignetteDistance + EdgeThresholdTransitionDistance, 
		vignetteDist
	);
	// If strength equals 1.0, the distance from the center is too great to do smoothing.
	if(vignetteStrength == 1.0) discard;

	float2 threshold = float2(SMAA_THRESHOLD,SMAA_THRESHOLD);

	if (DepthPredicationMethod > 0){
		// Higher values = more confidence that an edge is there
		float2 predicationAmount = ESMAACore::Predication::GetPredicationFactor(
				texcoord, 
				offset, 
				ReShade::DepthBuffer, 
				PredicationThreshold
			);

		if(DepthPredicationMethod == 2 && Lib::max(predicationAmount) == 0f) {
			// Higher values = more confidence that an edge is there
			float2 predicationFactor = ESMAACore::Predication::GetEdgePredictionFactor(
				texcoord, 
				offset, 
				ReShade::DepthBuffer, 
				ESMAA_EDGE_PREDICTION_THRESHOLD
			) * ESMAA_EDGE_PREDICTION_WEIGHT;

			predicationAmount = max(predicationAmount, predicationFactor);
		}

		// The higher the predication values (certainty), the closer to predicationThreshold 
		threshold *= 1.0 - (predicationAmount * PredicationAmount);
	}

	// Apply thresh vignette to result
	threshold = lerp(
		threshold, 
		THRESHOLD_AT_TRANSITION_EXTREME, 
		vignetteStrength
	);


	if(EdgeDetectionMethod == 0){
		return ESMAACore::EdgeDetection::LumaDetection(
			texcoord, 
			offset, 
			colorGammaSampler, 
			threshold, 
			SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR, 
			ESMAAEnableAdaptiveThreshold, 
			ESMAA_THRESHOLD_FLOOR, 
			ESMAALumaAdaptationRange
		);
	} else if(EdgeDetectionMethod == 1){
		return ESMAACore::EdgeDetection::ChromaDetection(
			texcoord, 
			offset, 
			colorGammaSampler, 
			threshold, 
			SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR, 
			ESMAAEnableAdaptiveThreshold, 
			ESMAA_THRESHOLD_FLOOR, 
			ESMAALumaAdaptationRange
		);
	} else if(EdgeDetectionMethod == 2){
		return ESMAACore::EdgeDetection::EuclideanLumaDetection(
			texcoord, 
			offset, 
			colorGammaSampler, 
			threshold, 
			SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR, 
			ESMAAEnableAdaptiveThreshold, 
			ESMAA_THRESHOLD_FLOOR, 
			ESMAALumaAdaptationRange
		);
	}
	// if EdgeDetectionMethod == 4
 	return ESMAACore::EdgeDetection::HybridDetection(
		texcoord, 
		offset, 
		colorGammaSampler, 
		threshold, 
		SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR, 
		ESMAAEnableAdaptiveThreshold, 
		ESMAA_THRESHOLD_FLOOR, 
		ESMAALumaAdaptationRange
	);
}

/**
 * Adapted from Lordbean's ASSMAA shader. 
 */
float4 SMAABlendingWeightCalculationWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float2 pixcoord : TEXCOORD1,
	float4 offset[3] : TEXCOORD2) : SV_Target
{
	if(!EnableSMAABlendingWeightCalc){
		discard;
	}
	return SMAABlendingWeightCalculationPS(texcoord, pixcoord, offset, edgesSampler, areaSampler, searchSampler, 0.0);
}

/**
 * Adapted from Lordbean's ASSMAA shader. 
 */
float3 SMAANeighborhoodBlendingWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float4 offset : TEXCOORD1) : SV_Target
{
	if (DebugOutput == 1)
		return tex2D(edgesSampler, texcoord).rgb;
	if (DebugOutput == 2)
		return tex2D(blendSampler, texcoord).rgb;
	if (DebugOutput >= 3) {
		// construct a custom set of offsets suitable for LocalAverageDepthPredication(),
		// because it usually needs the offsets generated by SMAAEdgeDetectionWrapVS
		float4 edgeOffset[3];
		edgeOffset[0] = float4(-offset.x,offset.y,offset.z,-offset.w);
		edgeOffset[1] = float4(offset.x,offset.y,offset.z,offset.w);
		edgeOffset[2] = float4(-offset.x*2.0,offset.y,offset.z,-offset.w*2.0);

		float2 depthEdges = ESMAACore::Predication::GetPredicationFactor(
			texcoord, 
			edgeOffset, 
			ReShade::DepthBuffer, 
			PredicationThreshold
		);
		if (DebugOutput == 4 && Lib::max(depthEdges) == 0f) {
			float2 predictionEdges = ESMAACore::Predication::GetEdgePredictionFactor(
				texcoord, 
				edgeOffset, 
				ReShade::DepthBuffer, 
				ESMAA_EDGE_PREDICTION_THRESHOLD
			) * ESMAA_EDGE_PREDICTION_WEIGHT;
			depthEdges = max(depthEdges, predictionEdges);
			// depthEdges = predictionEdges;
		}
		return float3(depthEdges, 0.0);
	}
	if(ESMAAEnableSMAABlending)
		return SMAANeighborhoodBlendingPS(texcoord, offset, colorLinearSampler, blendSampler).rgb;

	// Return the original color if nothing is turned on
	return SMAASampleLevelZero(colorLinearSampler, texcoord).rgb;
}

//////////////////////////////////////////////////////// SMOOTHING ////////////////////////////////////////////////////////////////////////

/**
 * Algorithm called 'smoothing', found in Lordbean's TSMAA. 
 * Appears to fix inconsistencies at edges by nudging pixel values towards values of nearby pixels.
 * A little gem that combines well with SMAA, but causes a significant performance hit.
 *
 * Adapted from Lordbean's TSMAA shader. 
 */
float3 TSMAASmoothing(float4 vpos, float2 texcoord, float4 offset, float threshold) : SV_Target
 {
	const float3 debugColorNoHits = float3(0.0,0.0,0.0);
	const float3 debugColorSmallHit = float3(0.0,0.0,1.0);
	const float3 debugColorBigHit = float3(1.0,0.0,0.0);

	float3 mid = SMAASampleLevelZero(ReShade::BackBuffer, texcoord).rgb;
  float3 original = mid;
	
	float lumaM = dot(mid, TSMAA_LUMA_REF);
	float chromaM = Lib::dotsat(mid, lumaM);
	bool useluma = lumaM > chromaM;
	if (!useluma) lumaM = 0.0;

	float lumaS = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 0, 1)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaE = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 1, 0)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaN = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 0,-1)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaW = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 0)).rgb, useluma, TSMAA_LUMA_REF);
    
    float rangeMax = Lib::max(lumaS, lumaE, lumaN, lumaW, lumaM);
    float rangeMin = Lib::min(lumaS, lumaE, lumaN, lumaW, lumaM);
	
    float range = rangeMax - rangeMin;
    
	// early exit check
    bool earlyExit = (range < threshold);
	if (earlyExit) {

		// If debug, return no hits color to signify no smoothing took place.
		if(SmoothingDebug){
			return debugColorNoHits;
		}
		return original;
	}
	// If debug, early return. Return hit colors to signify that smoothing takes place here
	if(SmoothingDebug) {
		// The further the range is above the threshold, the bigger the "hit"
		float strength = smoothstep(threshold, 1.0, range);
		return lerp(debugColorSmallHit, debugColorBigHit, strength);
	}

	float lumaNW = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1,-1)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaSE = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 1, 1)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaNE = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 1,-1)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaSW = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 1)).rgb, useluma, TSMAA_LUMA_REF);

	// These vals serve as caches, so they can be used later without having to redo them
	// It's just an optimisation thing, though the difference it makes is so small it could just be statistical noise.
	float lumaNWSW = lumaNW + lumaSW;
	float lumaNS = lumaN + lumaS;
	float lumaNESE = lumaNE + lumaSE;
	float lumaSWSE = lumaSW + lumaSE;
	float lumaWE = lumaW + lumaE;
	float lumaNWNE = lumaNW + lumaNE;
	
    bool horzSpan = (abs(mad(-2.0, lumaW, lumaNWSW)) + mad(2.0, abs(mad(-2.0, lumaM, lumaNS)), abs(mad(-2.0, lumaE, lumaNESE)))) >= (abs(mad(-2.0, lumaS, lumaSWSE)) + mad(2.0, abs(mad(-2.0, lumaM, lumaWE)), abs(mad(-2.0, lumaN, lumaNWNE))));	
    float lengthSign = horzSpan ? BUFFER_RCP_HEIGHT : BUFFER_RCP_WIDTH;

	float4 midWeights = float4(
		SMAASampleLevelZero(blendSampler, offset.xy).a, 
		SMAASampleLevelZero(blendSampler, offset.zw).g, 
		SMAASampleLevelZero(blendSampler, texcoord).zx
	);
	
	bool smaahoriz = max(midWeights.x, midWeights.z) > max(midWeights.y, midWeights.w);
    bool smaadata = Lib::any(midWeights);
	float maxWeight = Lib::max(midWeights.r, midWeights.g, midWeights.b, midWeights.a);
	float maxblending = 0.5 + (0.5 * maxWeight);

	if ((horzSpan && smaahoriz && smaadata) || (!horzSpan && !smaahoriz && smaadata)) {
		maxblending *= 1.0 - maxWeight / 2.0;
	} else {
		maxblending = min(maxblending * 1.5, 1.0);
	};

	float2 lumaNP = float2(lumaN, lumaS);
	SMAAMovc(bool(!horzSpan).xx, lumaNP, float2(lumaW, lumaE));
	
    float gradientN = lumaNP.x - lumaM;
    float gradientS = lumaNP.y - lumaM;
    float lumaNN = lumaNP.x + lumaM;
	
    if (abs(gradientN) >= abs(gradientS)) lengthSign = -lengthSign;
    else lumaNN = lumaNP.y + lumaM;
	
    float2 posB = texcoord;
	
	float texelsize = 0.5;

    float2 offNP = float2(0.0, BUFFER_RCP_HEIGHT * texelsize);
	SMAAMovc(bool(horzSpan).xx, offNP, float2(BUFFER_RCP_WIDTH * texelsize, 0.0));
	SMAAMovc(bool2(!horzSpan, horzSpan), posB, float2(posB.x + lengthSign / 2.0, posB.y + lengthSign / 2.0));
	
    float2 posN = posB - offNP;
    float2 posP = posB + offNP;

	float lumaEndN = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posN).rgb, useluma, TSMAA_LUMA_REF);
    float lumaEndP = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posP).rgb, useluma, TSMAA_LUMA_REF);
	
    float gradientScaled = max(abs(gradientN), abs(gradientS)) * 0.25;
    bool lumaMLTZero = mad(0.5, -lumaNN, lumaM) < 0.0;
	
	lumaNN *= 0.5;
	
    lumaEndN -= lumaNN;
    lumaEndP -= lumaNN;
	
    bool doneN = abs(lumaEndN) >= gradientScaled;
    bool doneP = abs(lumaEndP) >= gradientScaled;
    bool doneNP = doneN && doneP;
	
	if(!doneNP){
		uint iterations = 0;
		// scan distance
		uint maxiterations = ESMAASmoothingMaxIterations;
		
		[loop] while (iterations < maxiterations)
		{
			doneNP = doneN && doneP;
			if (doneNP) break;
			if (!doneN)
			{
				posN -= offNP;
				lumaEndN = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posN).rgb, useluma, TSMAA_LUMA_REF);
				lumaEndN -= lumaNN;
				doneN = abs(lumaEndN) >= gradientScaled;
			}
			if (!doneP)
			{
				posP += offNP;
				lumaEndP = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posP).rgb, useluma, TSMAA_LUMA_REF);
				lumaEndP -= lumaNN;
				doneP = abs(lumaEndP) >= gradientScaled;
			}
			iterations++;
		}
	}
	
	float2 dstNP = float2(texcoord.y - posN.y, posP.y - texcoord.y);
	SMAAMovc(bool(horzSpan).xx, dstNP, float2(texcoord.x - posN.x, posP.x - texcoord.x));

	//TODO: consider turning this into a preprocessor value
	maxblending = maxblending * ESMAASmoothingStrengthMod;
	
    bool goodSpan = (dstNP.x < dstNP.y) ? ((lumaEndN < 0.0) != lumaMLTZero) : ((lumaEndP < 0.0) != lumaMLTZero);
    float pixelOffset = mad(-rcp(dstNP.y + dstNP.x), min(dstNP.x, dstNP.y), 0.5);
    float subpixOut = pixelOffset * maxblending;
	
	[branch] if (!goodSpan)
	{
		subpixOut = mad(mad(2.0, lumaNS + lumaWE, lumaNWSW + lumaNESE), 0.083333, -lumaM) * rcp(range); //ABC
		subpixOut = pow(saturate(mad(-2.0, subpixOut, 3.0) * (subpixOut * subpixOut)), 2.0) * maxblending * pixelOffset; // DEFGH
	}

    float2 posM = texcoord;
	SMAAMovc(bool2(!horzSpan, horzSpan), posM, mad(lengthSign, subpixOut, posM));

	return SMAASampleLevelZero(ReShade::BackBuffer, posM).rgb;
}

/**
 * Wrapper around TSMAASmoothing that fixe
 */
float3 SmoothingPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float4 offset : TEXCOORD1) : SV_Target
{
	const float THRESHOLD_AT_TRANSITION_EXTREME = 0.8;
	const float SCREEN_CENTER = 0.5;
	if(!ESMAAEnableSmoothing) discard;

	// Calc distance from center for threshold vignetting
	float vignetteDist = distance(texcoord, SCREEN_CENTER);
	// Area between VignetteDistance and VignetteDistance + TransitionDistance is lerped from 1.0 to 0.0.
  // Anything below is 0.0, anything above is 1.0
  float vignetteStrength = smoothstep(SmoothingVignetteDistance, SmoothingVignetteDistance + SmoothingTransitionDistance, vignetteDist);
	// If strength equals 1.0, the distance from the center is too great to do smoothing.
	if(vignetteStrength == 1.0) discard;

	float threshold = lerp(SmoothingThreshold, THRESHOLD_AT_TRANSITION_EXTREME, vignetteStrength);

		// Predicate threshold based on edge data. AKA If an edge is present, lower the threshold.
	float4 edgeData;
	#if __RENDERER__ >= 0xa000 // if DX10 or above
		// get edge data from the bottom (x), bottom-right (y), right (z),
		// and current pixels (w), in that order.
		float4 leftEdges = tex2Dgather(edgesSampler, texcoord, 0);
		float4 topEdges = tex2Dgather(edgesSampler, texcoord, 1);
		edgeData = float4(
			leftEdges.w,
			topEdges.w,
			leftEdges.z,
			topEdges.x
		);
	#else // if DX9
		edgeData = float4(
			SMAASampleLevelZero(edgesSampler, texcoord).rg,
			SMAASampleLevelZero(edgesSampler, offset.xy).r, 
			SMAASampleLevelZero(edgesSampler, offset.zw).g
		); 
	#endif

	// If there is an edge, lower threshold by multiplying with EdgeThresholdModifier
	// Else leave uchanged by multiplying by 1.0
	bool edgePresent = Lib::any(edgeData);
	threshold *= edgePresent ? EdgeThresholdModifier : 1.0;

	return TSMAASmoothing(vpos, texcoord, offset, threshold);
}

////////////////////////////////////////////////////////////// SOFTENING ////////////////////////////////////////////////////////////////

/** 
 * Optionally scales the blending strength (ssee @SCALE_LINEAR).
 * Scaling depends on the value of `ESMAAAnomalousPixelScaling`.
 * 
 * @param `strength` The linear input strength 
 * @return The output strength. Same as input strength when `ESMAAAnomalousPixelScaling` is below 1.
 * 		   Amplified in a non-linear fashion when `ESMAAAnomalousPixelScaling` >= 1
 */
float scaleSofteningStrength(float strength){
	if(ESMAAAnomalousPixelScaling >= 1){ // Balanced
		// strength = strength * (2.0 - strength); // Tests turned out this was slower
		strength = Lib::sineScale(strength);
	}
	// no else-if, because it is a cumulative effect
	if(ESMAAAnomalousPixelScaling >= 2){ // Aggressive
		strength = Lib::sineScale(strength);
	}
	return strength;
}

/**
 * A modified version of Lordbean's Softening pass, taken from his TSMAA shader.
 * It works by averaging divergent pixels with their surroundings.
 * 
 * - removed sampling and usage of weights, now uses edge data instead
 * - removed detection of horizontal pixels, as it didn't make a difference visually
 * - Boosted the contribution that weight and edge data use to the final blending strength
 * - added several different, optional ways to determine blend strength from edge and weight data
 */
float3 ESMAASofteningPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float4 offset : TEXCOORD1) : SV_Target
{
	float3 a, b, c, d;

	float4 edgeData;
	#if __RENDERER__ >= 0xa000 // if DX10 or above
		// get edge data from the bottom (x), bottom-right (y), right (z),
		// and current pixels (w), in that order.
		float4 leftEdges = tex2Dgather(edgesSampler, texcoord, 0);
		float4 topEdges = tex2Dgather(edgesSampler, texcoord, 1);
		edgeData = float4(
			leftEdges.w,
			topEdges.w,
			leftEdges.z,
			topEdges.x
		);
	#else // if DX9
		edgeData = float4(
			SMAASampleLevelZero(edgesSampler, texcoord).rg,
			SMAASampleLevelZero(edgesSampler, offset.xy).r, 
			SMAASampleLevelZero(edgesSampler, offset.zw).g
		); 
	#endif


	// If background softening is disabled, return early if 
	// the pixel's depth corresponds with the background depth.
	float depth = ReShade::GetLinearizedDepth(texcoord);
	bool background = ESMAADisableBackgroundSoftening && depth > ESMAA_BACKGROUND_DEPTH_THRESHOLD;

	// Only texels with less than two edges lead to early return,
	// otherwise even straight lines would be softened, which would lead to blur
	float signifEdges = Lib::sum(edgeData) - 1.0;

	// Could be used as a Pre-processing pass as follows:
	// calculate # of corners
	// float corners = (edgeData.r + edgeData.b) * (edgeData.g + edgeData.a);
	// bool badEdgeData = corners <= 1f;
	// bool earlyReturn = !ESMAAEnableSoftening || signifEdges <= 0.0 || background || badEdgeData;

	bool earlyReturn = !ESMAAEnableSoftening || signifEdges <= 0.0 || background;
	if(earlyReturn) discard;

	// pattern:
	//  e f g
	//  h a b
	//  i c d

	#if __RENDERER__ >= 0xa000 // if DX10 or above
		// get RGB values from the c, d, b, and a positions, in order.
		float4 cdbared = tex2Dgather(ReShade::BackBuffer, texcoord, 0);
		float4 cdbagreen = tex2Dgather(ReShade::BackBuffer, texcoord, 1);
		float4 cdbablue = tex2Dgather(ReShade::BackBuffer, texcoord, 2);
		a = float3(cdbared.w, cdbagreen.w, cdbablue.w);
		float3 original = a;
		// This is redundant, but somehow improved performance. TODO: Revisit this
		if (earlyReturn) return original;
		b = float3(cdbared.z, cdbagreen.z, cdbablue.z);
		c = float3(cdbared.x, cdbagreen.x, cdbablue.x);
		d = float3(cdbared.y, cdbagreen.y, cdbablue.y);
	#else // if DX9
		a = SMAASampleLevelZero(ReShade::BackBuffer, texcoord).rgb;
		float3 original = a;
		// This is redundant, but somehow improved performance. TODO: Revisit this
		if (earlyReturn) return original;
		b = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(1, 0)).rgb;
		c = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(0, 1)).rgb;
		d = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(1, 1)).rgb;
	#endif
	float3 e = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, -1)).rgb;
	float3 f = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(0, -1)).rgb;
	float3 g = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(1, -1)).rgb;
	float3 h = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 0)).rgb;
	float3 i = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 1)).rgb;
	
	// pattern:
	//  e f g
	//  h a b
	//  i c d
	// Reinforced
	float3 bottomHalf = (h + a + b + i + c + d) / 6f;
	float3 topHalf = (h + a + b + e + f + g) / 6f;
	float3 leftHalf = (e + h + i + f + a + c) / 6f;
	float3 rightHalf = (f + a + c + g + b + d) / 6f;

	float3 diagHalfNW = (i + a + g + f + h + e) / 6f;
	float3 diagHalfSE = (i + a + g + b + d + c) / 6f;
	float3 diagHalfNE = (e + a + d + g + b + f) / 6f;
	float3 diagHalfSW = (e + a + d + h +  c + i) / 6f;

	float3 diag1 = (e + a + d) / 3f;
	float3 diag2 = (i + a + g) / 3f;

	float3 horz = (h + a + b) / 3f;
	float3 vert = (f + a + c) / 3f;

	float3 maxDesired = Lib::max(leftHalf, bottomHalf, diag1, diag2, topHalf, rightHalf, diagHalfNE, diagHalfNW,diagHalfSE,diagHalfSW);
	float3 minDesired = Lib::min(leftHalf, bottomHalf, diag1, diag2, topHalf, rightHalf, diagHalfNE, diagHalfNW,diagHalfSE,diagHalfSW);

	float3 maxLine = Lib::max(horz,vert,maxDesired);
	float3 minLine = Lib::min(horz,vert,minDesired);

	// Weakened
	float3 surround = (h + f + b + c + a) / 5f;
	float3 diagSurround = (e + g + i + d + a) / 5f;

	float3 maxUndesired = max(surround, diagSurround);
	float3 minUndesired = min(surround, diagSurround);

	const float DesiredPatternsWeight = 2f;
	const float LineWeight = 1.3f;

	float3 localavg = (
		(maxDesired + minDesired) * DesiredPatternsWeight 
		+ (maxLine + minLine) * LineWeight
		- maxUndesired - minUndesired 
		- a * ESMAASofteningExtraPixelSoftening
		) / (((DesiredPatternsWeight + LineWeight) * 2f - 2f) - ESMAASofteningExtraPixelSoftening);


	// Calculate strength by # of edges above 1
	float strength = signifEdges / 3.0; 

	// calculate # of corners
	float corners = (edgeData.r + edgeData.b) * (edgeData.g + edgeData.a);
	
	// Reduce strength for straight lines of 1 pixel thick and their endings, to preserve detail
	const float LINE_PRESERVATION_FACTOR = 0.6f; // TODO: consider turning into preprocessor constant and adding ui
	strength *= (corners == 0.0 || corners == 2.0) ? LINE_PRESERVATION_FACTOR : 1.0;

	// Calculate blend strength based on weight and edge data
	float scaledStrength = scaleSofteningStrength(strength);
	float maxblending = scaledStrength * ESMAASofteningStrength;
	
	return lerp(original, localavg, maxblending);
}

// TODO: refactor file so other passes use this too.
float4 gatherEdges(float2 texcoord)
{
	
	float4 edgeData;
	#if __RENDERER__ >= 0xa000 // if DX10 or above
		// get edge data from the bottom (x), bottom-right (y), right (z),
		// and current pixels (w), in that order.
		float4 leftEdges = tex2Dgather(edgesSampler, texcoord, 0);
		float4 topEdges = tex2Dgather(edgesSampler, texcoord, 1);
		edgeData = float4(
			leftEdges.w,
			topEdges.w,
			leftEdges.z,
			topEdges.x
		);
	#else // if DX9
  	float offset = mad(SMAA_RT_METRICS.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
		edgeData = float4(
			SMAASampleLevelZero(edgesSampler, texcoord).rg,
			SMAASampleLevelZero(edgesSampler, offset.xy).r, 
			SMAASampleLevelZero(edgesSampler, offset.zw).g
		); 
	#endif

	return edgeData;
}

float getRCASLuma(float3 rgb)
{
	// Use green as luma for max performance, at cost of more artifacting.
	// Future iterations could provide an alternative method by calculating
	// the dot product of rgb and luma weights of float3(1.0, 2.0, 1.0),
	// which is more precise
	return rgb.g * 2.0;
}

// Based on https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK/blob/main/sdk/include/FidelityFX/gpu/fsr1/ffx_fsr1.h#L684
//==============================================================================================================================
//
//                                      FSR - [RCAS] ROBUST CONTRAST ADAPTIVE SHARPENING
//
//------------------------------------------------------------------------------------------------------------------------------
// CAS uses a simplified mechanism to convert local contrast into a variable amount of sharpness.
// RCAS uses a more exact mechanism, solving for the maximum local sharpness possible before clipping.
// RCAS also has a built in process to limit sharpening of what it detects as possible noise.
// RCAS sharper does not support scaling, as it should be applied after EASU scaling.
// Pass EASU output straight into RCAS, no color conversions necessary.
//------------------------------------------------------------------------------------------------------------------------------
// RCAS is based on the following logic.
// RCAS uses a 5 tap filter in a cross pattern (same as CAS),
//    w                n
//  w 1 w  for taps  w m e 
//    w                s
// Where 'w' is the negative lobe weight.
//  output = (w*(n+e+w+s)+m)/(4*w+1)
// RCAS solves for 'w' by seeing where the signal might clip out of the {0 to 1} input range,
//  0 == (w*(n+e+w+s)+m)/(4*w+1) -> w = -m/(n+e+w+s)
//  1 == (w*(n+e+w+s)+m)/(4*w+1) -> w = (1-m)/(n+e+w+s-4*1)
// Then chooses the 'w' which results in no clipping, limits 'w', and multiplies by the 'sharp' amount.
// This solution above has issues with MSAA input as the steps along the gradient cause edge detection issues.
// So RCAS uses 4x the maximum and 4x the minimum (depending on equation)in place of the individual taps.
// As well as switching from 'm' to either the minimum or maximum (depending on side), to help in energy conservation.
// This stabilizes RCAS.
// RCAS does a simple highpass which is normalized against the local contrast then shaped,
//       0.25
//  0.25  -1  0.25
//       0.25
// This is used as a noise detection filter, to reduce the effect of RCAS on grain, and focus on real edges.
/**
 * @param texcoord: float2 The texel coordinates, equivalent to TEXCOORD
 * @param limit: float Value that limits the max amount of sharpening and prevents artifacts
 *	Lower values result in less artifacts, but also possibly less sharpening.
 *	Default value should be (0.25 - (1.0 / 16.0))
 * @param sharpness: float Degree of sharpening, non-linear. 
 *	range: 0.0..=1.33. Values of > 1.33 are possible but cause extreme artifacts.
 *	Recommended max value is 1.25. Likeliness of artifacts grows significantly above that value
 * @return float3 Sharpened RGB values of the target texel
 */
float3 rcas(float2 texcoord, float limit, float sharpness)
{
  // Algorithm uses minimal 3x3 pixel neighborhood.
  //    b
  //  d e f
  //    h
  float3 e = tex2D(colorLinearSampler, texcoord).rgb;

  float3 b = tex2Doffset(colorLinearSampler, texcoord, int2(0,-1)).rgb;
  float3 d = tex2Doffset(colorLinearSampler, texcoord, int2(-1,0)).rgb;
  float3 f = tex2Doffset(colorLinearSampler, texcoord, int2(1,0)).rgb;
  float3 h = tex2Doffset(colorLinearSampler, texcoord, int2(0,1)).rgb;

  // Get lumas times 2. Should use luma weights that are twice as large as normal.
  float bL = getRCASLuma(b);
  float dL = getRCASLuma(d);
  float eL = getRCASLuma(e);
  float fL = getRCASLuma(f);
  float hL = getRCASLuma(h);

  // Noise detection.
	float nz = (bL + dL + fL + hL) * 0.25 - eL;
	float range = max(max(max(bL, dL), max(hL, fL)), eL) - min(min(min(bL, dL), min(eL, fL)), hL);
	nz = saturate(abs(nz) * rcp(range));
	nz = -0.5 * nz + 1.0;

  // Min and max of ring.
  float3 minRGB = min(min(b, d), min(f, h));
  float3 maxRGB = max(max(b, d), max(f, h));
  // Immediate constants for peak range.
  float2 peakC = float2(1.0, -4.0);

  // Limiters, these need to use high precision reciprocal operations.
  // Decided to use standard rcp for now in hopes of optimizing it
  float3 hitMin = minRGB * rcp(4.0 * maxRGB);
  float3 hitMax = (peakC.xxx - maxRGB) * rcp(4.0 * minRGB + peakC.yyy);
  float3 lobeRGB = max(-hitMin, hitMax);
  float lobe = max(-limit, min(max(lobeRGB.r, max(lobeRGB.g, lobeRGB.b)), 0.0)) * sharpness;

	// Apply noise removal.
	lobe *= nz;

  // Resolve, which needs medium precision rcp approximation to avoid visible tonality changes.
  float rcpL = rcp(4.0 * lobe + 1.0);
  float3 output = ((b + d + f + h) * lobe + e) * rcpL;

  return output;
}


/**
 * Original: https://github.com/CeeJayDK/SweetFX/blob/master/Shaders/CAS.fx
 *
 * See description at the top of this file above for further credits.
 * @param texcoord: float2 The texel coordinates, equivalent to TEXCOORD
 * @param contrast: float Increases sharpening strength further.
 *	Range: 0.0..=1.0
 *	Default: 0.0
 * @param sharpening: float Degree of sharpening, linear.
 *	Range: 0.0..=1.0
 *	Default: 1.0
 * @return float3 Sharpened RGB values of the target texel
 */
float3 cas(float2 texcoord, float contrast, float sharpening)
{	
	// fetch a 3x3 neighborhood around the pixel 'e',
	//  a b c
	//  d(e)f
	//  g h i
	float3 b = tex2Doffset(colorLinearSampler, texcoord, int2(0, -1)).rgb;
	float3 d = tex2Doffset(colorLinearSampler, texcoord, int2(-1, 0)).rgb;
	
	#if __RENDERER__ >= 0xa000 // If DX10 or higher
		float2 offset = 0.5 * SMAA_RT_METRICS.xy;
		float4 red_efhi = tex2DgatherR(colorLinearSampler, texcoord + offset);
		
		float3 e = float3( red_efhi.w, red_efhi.w, red_efhi.w);
		float3 f = float3( red_efhi.z, red_efhi.z, red_efhi.z);
		float3 h = float3( red_efhi.x, red_efhi.x, red_efhi.x);
		float3 i = float3( red_efhi.y, red_efhi.y, red_efhi.y);
		
		float4 green_efhi = tex2DgatherG(colorLinearSampler, texcoord + offset);
		
		e.g = green_efhi.w;
		f.g = green_efhi.z;
		h.g = green_efhi.x;
		i.g = green_efhi.y;
		
		float4 blue_efhi = tex2DgatherB(colorLinearSampler, texcoord + offset);
		
		e.b = blue_efhi.w;
		f.b = blue_efhi.z;
		h.b = blue_efhi.x;
		i.b = blue_efhi.y;


	#else // If DX9
		float3 e = tex2D(colorLinearSampler, texcoord).rgb;
		float3 f = tex2Doffset(colorLinearSampler, texcoord, int2(1, 0)).rgb;
		float3 h = tex2Doffset(colorLinearSampler, texcoord, int2(0, 1)).rgb;
		float3 i = tex2Doffset(colorLinearSampler, texcoord, int2(1, 1)).rgb;
	#endif

	float3 g = tex2Doffset(colorLinearSampler, texcoord, int2(-1, 1)).rgb; 
	float3 a = tex2Doffset(colorLinearSampler, texcoord, int2(-1, -1)).rgb;
	float3 c = tex2Doffset(colorLinearSampler, texcoord, int2(1, -1)).rgb;
   

	// Soft min and max.
	//  a b c			 b
	//  d e f * 0.5  +  d e f * 0.5
	//  g h i			 h
	// These are 2.0x bigger (factored out the extra multiply).
	float3 mnRGB = min(min(min(d, e), min(f, b)), h);
	float3 mnRGB2 = min(mnRGB, min(min(a, c), min(g, i)));
	mnRGB += mnRGB2;

	float3 mxRGB = max(max(max(d, e), max(f, b)), h);
	float3 mxRGB2 = max(mxRGB, max(max(a, c), max(g, i)));
	mxRGB += mxRGB2;

	// Smooth minimum distance to signal limit divided by smooth max.
	float3 rcpMRGB = rcp(mxRGB);
	float3 ampRGB = saturate(min(mnRGB, 2.0 - mxRGB) * rcpMRGB);	
	
	// Shaping amount of sharpening.
	ampRGB = rsqrt(ampRGB);
	
	float peak = -3.0 * contrast + 8.0;
	float3 wRGB = -rcp(ampRGB * peak);

	float3 rcpWeightRGB = rcp(4.0 * wRGB + 1.0);

	//						  0 w 0
	//  Filter shape:		   w 1 w
	//						  0 w 0  
	float3 window = (b + d) + (f + h);
	float3 outColor = saturate((window * wRGB + e) * rcpWeightRGB);
	
	return lerp(e, outColor, sharpening);
}

// TODO: use pre-processing variables to disable this completely if necessary
float3 SharpeningPS(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET
{
	const uint RCAS = 1;
	const uint CAS = 2;

	// Gather all 4 edges of the current pixel
	float4 edges = gatherEdges(texcoord);
	float edgeCount = Lib::sum(edges);
	// Reduce sharpening strength based on number of edges
	// EdgeBias is negative or 0, so strengthModifier is <= 1.0;
	float strengthModifier = 1.0 + ((edgeCount / 4.0) * EdgeBias);

	// Early return if strength is 0 or negative
	if(strengthModifier <= 0.0) discard;

	float strength = SharpeningStrength * strengthModifier;

	// Separate the 0.0..=1.0 range from the 1.0..=2.0 range, so they can be processed differently.
	float baseSharpness = saturate(strength);
	float extraSharpness = saturate(strength - 1.0);

	if(SharpeningMethod == RCAS) {
		//TODO: test if putting these on top of function changes performance.
		// equivalent to RCAS_LIMIT (0.25 - (1.0 / 16.0))
		const float rcasLimit = 0.1875;
		const float rcasExtraSharpnessDivisor = 4.0;

		// Dividing top half of sharpening strength by 3.0 accounts for the fact that:
		// - sharpening effect increases faster at strength > 1.0 than at strength <= 1.0
		extraSharpness /= rcasExtraSharpnessDivisor;

		float sharpening = baseSharpness + extraSharpness;
		return rcas(texcoord, rcasLimit, sharpening);

	} else if (SharpeningMethod == CAS) {

		return cas(texcoord, extraSharpness, baseSharpness);
	}

	// if SharpeningMethod == 0 (None), just return current pixel
	return SMAASampleLevelZero(colorLinearSampler, texcoord).rgb;
}


// Rendering passes

technique ESMAA
{
	pass EdgeDetectionPass
	{
		VertexShader = SMAAEdgeDetectionWrapVS;
		PixelShader = EdgeDetectionWrapperPS;
		RenderTarget = edgesTex;
		ClearRenderTargets = true;
		StencilEnable = true;
		StencilPass = REPLACE;
		StencilRef = 1;
	}
	pass BlendWeightCalculationPass
	{
		VertexShader = SMAABlendingWeightCalculationWrapVS;
		PixelShader = SMAABlendingWeightCalculationWrapPS;
		RenderTarget = blendTex;
		ClearRenderTargets = true;
		StencilEnable = true;
		StencilPass = KEEP;
		StencilFunc = EQUAL;
		StencilRef = 1;
	}
	pass NeighborhoodBlendingPass
	{
		VertexShader = SMAANeighborhoodBlendingWrapVS;
		// VertexShader = PostProcessVS;
		PixelShader = SMAANeighborhoodBlendingWrapPS;
		StencilEnable = false;
		SRGBWriteEnable = true;
	}
	pass ImageSoftening
	{
		VertexShader = TSMAANeighborhoodBlendingVS;
		PixelShader = ESMAASofteningPS;
	}
	pass ImageSmoothing
	{
		VertexShader = TSMAANeighborhoodBlendingVS;
		PixelShader = SmoothingPS;
	}
	pass Sharpening
	{
		VertexShader = PostProcessVS;
		PixelShader = SharpeningPS;
		SRGBWriteEnable = true;
	}
}
