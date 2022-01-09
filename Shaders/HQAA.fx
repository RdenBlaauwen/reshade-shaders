/*               HQAA for ReShade 3.1.1+
 *
 *          (Hybrid high-Quality Anti-Aliasing)
 *
 *
 *     Smooshes FXAA and SMAA together as a single shader
 *
 * with customizations designed to maximize edge detection and
 *
 *                  minimize blurring
 *
 *          v9.7 beta - experimental HDR support
 *
 *                     by lordbean
 *
 */
 
 // This shader includes code adapted from:
 
 /**============================================================================


                    NVIDIA FXAA 3.11 by TIMOTHY LOTTES


------------------------------------------------------------------------------
COPYRIGHT (C) 2010, 2011 NVIDIA CORPORATION. ALL RIGHTS RESERVED.
------------------------------------------------------------------------------*/

/* AMD CONTRAST ADAPTIVE SHARPENING
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
// --------*/

/** SUBPIXEL MORPHOLOGICAL ANTI-ALIASING (SMAA)
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
 **/
 
 /*------------------------------------------------------------------------------
 * THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *-------------------------------------------------------------------------------*/


/*****************************************************************************************************************************************/
/*********************************************************** UI SETUP START **************************************************************/
/*****************************************************************************************************************************************/

#include "ReShadeUI.fxh"

uniform int HQAAintroduction <
	ui_type = "radio";
	ui_label = " ";
	ui_text = "\nHybrid high-Quality Anti-Aliasing, a shader by lordbean\n"
	          "Version: 9.7 beta\n"
			  "https://github.com/lordbean-git/HQAA/\n";
>;

uniform int preset <
	ui_type = "combo";
	ui_label = "Quality Preset\n\n";
	ui_tooltip = "For quick start use, pick a preset. If you'd prefer to fine tune, select Custom.";
	ui_category = "Presets";
	ui_items = "Potato\0Low\0Medium\0High\0Ultra\0GLaDOS\0Custom\0";
	ui_text = "\n";
> = 3;

uniform int presetbreakdown <
	ui_type = "radio";
	ui_label = " ";
	ui_text = "\n"
	          "|-Preset---Threshold---Subpix---Sharpen?---Mode---Corners---Quality---Texel-|\n"
	          "|--------|-----------|--------|----------|------|---------|---------|-------|\n"
	          "| Potato |   0.250   |  0.000 |    No    |  n/a |    0%   |   0.1   | 2.000 |\n"
			  "|  Low   |   0.200   |  0.125 |    No    |  n/a |    0%   |   0.2   | 1.500 |\n"
			  "| Medium |   0.125   |  0.375 |    No    |  n/a |    0%   |   0.4   | 1.000 |\n"
			  "|  High  |   0.100   |  0.625 |   Yes    | Auto |    0%   |   0.8   | 0.500 |\n"
			  "| Ultra  |   0.050   |  1.000 |   Yes    | Auto |    0%   |   1.0   | 0.250 |\n"
			  "| GLaDOS |   0.025   |  1.000 |   Yes    | Auto |   10%   |   1.5   | 0.125 |\n"
			  "-----------------------------------------------------------------------------";
	ui_category = "Click me to see what settings each preset uses!";
	ui_category_closed = true;
>;

uniform float EdgeThresholdCustom < __UNIFORM_SLIDER_FLOAT1
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Edge Detection Threshold";
	ui_tooltip = "Local contrast required to run shader";
    ui_category = "Custom Preset";
	ui_category_closed = true;
	ui_text = "\n------------------------------ Global Options ----------------------------------\n ";
> = 0.1;

uniform float SubpixCustom < __UNIFORM_SLIDER_FLOAT1
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Subpixel Effects Strength";
	ui_tooltip = "Lower = sharper image, Higher = more AA effect";
    ui_category = "Custom Preset";
	ui_category_closed = true;
> = 0.5;

uniform bool SharpenEnableCustom <
	ui_label = "Enable sharpening of anti-aliasing results?";
	ui_tooltip = "When enabled, HQAA will run CAS on FXAA and SMAA outputs";
	ui_category = "Custom Preset";
	ui_category_closed = true;
> = true;

uniform int SharpenAdaptiveCustom <
	ui_type = "radio";
	ui_items = "Automatic\0Manual\0";
	ui_label = "Sharpening Mode";
	ui_tooltip = "Automatic sharpening = HQAA will try to guess what amount\nof sharpening will look good on a per-pixel basis.\n\nManual sharpening = HQAA will always apply the\nsame amount of sharpening.";
	ui_category = "Custom Preset";
	ui_category_closed = true;
> = 0;

uniform float SharpenAmountCustom < __UNIFORM_SLIDER_FLOAT1
	ui_min = 0.000; ui_max = 1.000; ui_step = 0.005;
	ui_label = "Sharpening Amount";
	ui_tooltip = "Set the amount of manual sharpening to apply to anti-aliasing results";
	ui_category = "Custom Preset";
	ui_category_closed = true;
> = 0;

uniform float SmaaCorneringCustom < __UNIFORM_SLIDER_INT1
	ui_min = 0; ui_max = 100; ui_step = 1;
	ui_label = "SMAA Corner Rounding";
	ui_tooltip = "Affects the amount of blending performed when SMAA\ndetects crossing edges";
    ui_category = "Custom Preset";
	ui_category_closed = true;
	ui_text = "\n------------------------------- SMAA Options -----------------------------------\n ";
> = 20;

uniform float FxaaIterationsCustom < __UNIFORM_SLIDER_FLOAT1
	ui_min = 0; ui_max = 5; ui_step = 0.01;
	ui_label = "Quality Multiplier";
	ui_tooltip = "Multiplies the maximum number of edge gradient\nscanning iterations that FXAA will perform";
    ui_category = "Custom Preset";
	ui_category_closed = true;
	ui_text = "\n------------------------------- FXAA Options -----------------------------------\n ";
> = 0.5;

uniform float FxaaTexelSizeCustom < __UNIFORM_SLIDER_FLOAT1
	ui_min = 0.025; ui_max = 4.0; ui_step = 0.005;
	ui_label = "Edge Gradient Texel Size";
	ui_tooltip = "Determines how far along an edge FXAA will move\nfrom one scan iteration to the next.\n\nLower = slower, more accurate\nHigher = faster, more blurry";
	ui_category = "Custom Preset";
	ui_category_closed = true;
> = 0.5;

uniform uint debugmode <
	ui_type = "radio";
	ui_category = "Debug";
	ui_category_closed = true;
	ui_label = " ";
	ui_text = "\nDebug Mode:";
	ui_items = "Off\0Detected Edges\0SMAA Blend Weights\0FXAA results:\0";
> = 0;

uniform uint debugFXAApass <
	ui_type = "radio";
	ui_category = "Debug";
	ui_category_closed = true;
	ui_label = " ";
	ui_text = "-----------------";
	ui_items = "SMAA Positives\0SMAA Negatives\0";
> = 0;

uniform int debugexplainer <
	ui_type = "radio";
	ui_label = " ";
	ui_text = "----------------------------------------------------------------\n"
	          "                 HOW TO READ DEBUG RESULTS\n"
              "----------------------------------------------------------------\n"
			  "When viewing the detected edges, the colors shown in the texture\n"
			  "are not related to the image on the screen directly, rather they\n"
			  "are markers indicating the following:\n"
			  "- Green = Probable Horizontal Edge Here\n"
			  "- Red = Probable Vertical Edge Here\n"
			  "- Yellow = Probable Diagonal Edge Here\n\n"
			  "SMAA blending weights and FXAA results show what each related\n"
			  "pass is blending with the screen to produce its AA effect.\n"
	          "----------------------------------------------------------------";
	ui_category = "Debug";
	ui_category_closed = true;
>;

uniform float HqaaSharpenerStrength < __UNIFORM_SLIDER_FLOAT1
	ui_spacing = 5;
	ui_min = 0; ui_max = 10; ui_step = 0.1;
	ui_label = "Sharpening Strength";
	ui_tooltip = "Amount of sharpening to apply";
	ui_category = "Optional Sharpening (HQAACAS)";
	ui_category_closed = true;
> = 1.0;

uniform int sharpenerintro <
	ui_type = "radio";
	ui_label = " ";
	ui_text = "\nHQAA can optionally run Contrast-Adaptive Sharpening very similar to CAS.fx.\n"
	          "The advantage to using the technique built into HQAA is that it uses edge\n"
			  "data generated by the anti-aliasing technique to adjust the amount of sharpening\n"
			  "applied to areas that were processed to remove aliasing.\n\n"
			  "This feature is enabled or disabled in the ReShade effects list.";
	ui_category = "Optional Sharpening (HQAACAS)";
	ui_category_closed = true;
>;

uniform uint FramerateFloor < __UNIFORM_SLIDER_INT1
	ui_min = 30; ui_max = 120; ui_step = 1;
	ui_label = "Target Minimum Framerate";
	ui_tooltip = "HQAA will automatically reduce FXAA sampling quality if\nthe framerate drops below this number";
	ui_text = "\n";
> = 60;

uniform float frametime < source = "frametime"; >;

static const float HQAA_THRESHOLD_PRESET[7] = {0.25,0.2,0.125,0.1,0.05,0.025,1};
static const float HQAA_SUBPIX_PRESET[7] = {0,0.125,0.375,0.625,1.0,1.0,0};
static const bool HQAA_SHARPEN_ENABLE_PRESET[7] = {false,false,false,true,true,true,false};
static const float HQAA_SHARPEN_STRENGTH_PRESET[7] = {0,0,0,0,0,0,0};
static const int HQAA_SHARPEN_MODE_PRESET[7] = {0,0,0,0,0,0,0};
static const float HQAA_SMAA_CORNER_ROUNDING_PRESET[7] = {0,0,0,0,0,10,0};
static const float HQAA_FXAA_SCANNING_MULTIPLIER_PRESET[7] = {0.1,0.2,0.4,0.8,1,1.5,0};
static const float HQAA_FXAA_TEXEL_SIZE_PRESET[7] = {2,1.5,1,0.5,0.25,0.125,4};

#define __HQAA_EDGE_THRESHOLD (preset == 6 ? (EdgeThresholdCustom) : (HQAA_THRESHOLD_PRESET[preset]))
#define __HQAA_SUBPIX (preset == 6 ? (SubpixCustom) : (HQAA_SUBPIX_PRESET[preset]))
#define __HQAA_SHARPEN_ENABLE (preset == 6 ? (SharpenEnableCustom) : (HQAA_SHARPEN_ENABLE_PRESET[preset]))
#define __HQAA_SHARPEN_AMOUNT (preset == 6 ? (SharpenAmountCustom) : (HQAA_SHARPEN_STRENGTH_PRESET[preset]))
#define __HQAA_SHARPEN_MODE (preset == 6 ? (SharpenAdaptiveCustom) : (HQAA_SHARPEN_MODE_PRESET[preset]))
#define __HQAA_SMAA_CORNERING (preset == 6 ? (SmaaCorneringCustom) : (HQAA_SMAA_CORNER_ROUNDING_PRESET[preset]))
#define __HQAA_FXAA_SCAN_MULTIPLIER (preset == 6 ? (FxaaIterationsCustom) : (HQAA_FXAA_SCANNING_MULTIPLIER_PRESET[preset]))
#define __HQAA_FXAA_SCAN_GRANULARITY (preset == 6 ? (FxaaTexelSizeCustom) : (HQAA_FXAA_TEXEL_SIZE_PRESET[preset]))
#define __FXAA_THRESHOLD_FLOOR 0.004
#define __SMAA_THRESHOLD_FLOOR 0.004
#define __HQAA_DISPLAY_DENOMINATOR min(BUFFER_HEIGHT, BUFFER_WIDTH)
#define __HQAA_DISPLAY_NUMERATOR max(BUFFER_HEIGHT, BUFFER_WIDTH)
#define __HQAA_BUFFER_MULTIPLIER (__HQAA_DISPLAY_DENOMINATOR / 2160)
#define __HQAA_DESIRED_FRAMETIME float(1000 / FramerateFloor)


#ifndef HDR_BACKBUFFER_IS_LINEAR
	#define HDR_BACKBUFFER_IS_LINEAR 0
#endif

#ifndef HDR_DISPLAY_NITS
	#define HDR_DISPLAY_NITS 1000
#endif


/*****************************************************************************************************************************************/
/*********************************************************** UI SETUP END ****************************************************************/
/*****************************************************************************************************************************************/

/*****************************************************************************************************************************************/
/*********************************************************** SMAA CAS START **************************************************************/
/*****************************************************************************************************************************************/

float3 Sharpen(float2 texcoord, sampler2D sTexColor, float4 AAresult, float threshold, float subpix)
{
	// calculate sharpening parameters
	float sharpening = __HQAA_SHARPEN_AMOUNT;
	#if HDR_BACKBUFFER_IS_LINEAR
		float e = AAresult * (1 / HDR_DISPLAY_NITS);
	#else
		float e = AAresult;
	#endif
	
	if (__HQAA_SHARPEN_MODE == 0) {
		float strongestcolor = max(max(e.r, e.g), e.b);
		#if HDR_BACKBUFFER_IS_LINEAR
			strongestcolor *= 1 / HDR_DISPLAY_NITS;
		#endif
		float brightness = mad(strongestcolor, e.a, -0.375);
		sharpening = brightness * (1 - threshold);
	}
	
	// exit if the pixel doesn't seem to warrant sharpening
	if (sharpening <= 0)
		return AAresult.rgb;
	else {
	
	// proceed with CAS math
	// we're doing a fast version that only uses immediate neighbors
	
    float3 b = tex2Doffset(sTexColor, texcoord, int2(0, -1)).rgb;
    float3 d = tex2Doffset(sTexColor, texcoord, int2(-1, 0)).rgb;
    float3 f = tex2Doffset(sTexColor, texcoord, int2(1, 0)).rgb;
    float3 h = tex2Doffset(sTexColor, texcoord, int2(0, 1)).rgb;

    float3 mnRGB = min(min(min(d, AAresult.rgb), min(f, b)), h);
    float3 mxRGB = max(max(max(d, AAresult.rgb), max(f, b)), h);
	#if HDR_BACKBUFFER_IS_LINEAR
	mnRGB *= 1 / HDR_DISPLAY_NITS;
	mxRGB *= 1 / HDR_DISPLAY_NITS;
	#endif

    float3 rcpMRGB = rcp(mxRGB);
    float3 ampRGB = saturate(min(mnRGB, 2.0 - mxRGB) * rcpMRGB);
    
    ampRGB = rsqrt(ampRGB);
    
    float3 wRGB = -rcp(ampRGB * 8);

    float3 rcpWeightRGB = rcp(mad(4, wRGB, 1));

    float3 window = (b + d) + (f + h);
	#if HDR_BACKBUFFER_IS_LINEAR
	window *= 1 / HDR_DISPLAY_NITS;
	#endif
    float3 outColor = saturate(mad(window, wRGB, e.rgb) * rcpWeightRGB);
    
	#if HDR_BACKBUFFER_IS_LINEAR
	return lerp(AAresult.rgb, outColor, sharpening) * HDR_DISPLAY_NITS;
	#else
	return lerp(AAresult.rgb, outColor, sharpening);
	#endif
	}
}

/*****************************************************************************************************************************************/
/*********************************************************** SMAA CAS END ****************************************************************/
/*****************************************************************************************************************************************/

/*****************************************************************************************************************************************/
/*********************************************************** CAS CODE BLOCK START ********************************************************/
/*****************************************************************************************************************************************/

float3 HQAACASPS(float2 texcoord, sampler2D edgesTex, sampler2D sTexColor)
{
	float sharpenmultiplier = (1 - sqrt(__HQAA_EDGE_THRESHOLD)) * (sqrt(__HQAA_SUBPIX));
	
	if (__HQAA_SHARPEN_ENABLE == true) {
		float2 edgesdetected = tex2D(edgesTex, texcoord).rg;
		if (dot(edgesdetected, float2(1.0, 1.0)) != 0)
			sharpenmultiplier *= 0.25;
	}
	
	// set sharpening amount
	float sharpening = HqaaSharpenerStrength * sharpenmultiplier;
	
	// proceed with CAS math.
	
    float3 a = tex2Doffset(sTexColor, texcoord, int2(-1, -1)).rgb;
    float3 b = tex2Doffset(sTexColor, texcoord, int2(0, -1)).rgb;
    float3 c = tex2Doffset(sTexColor, texcoord, int2(1, -1)).rgb;
    float3 d = tex2Doffset(sTexColor, texcoord, int2(-1, 0)).rgb;
    float3 e = tex2D(sTexColor, texcoord).rgb;
    float3 f = tex2Doffset(sTexColor, texcoord, int2(1, 0)).rgb;
    float3 g = tex2Doffset(sTexColor, texcoord, int2(-1, 1)).rgb;
    float3 h = tex2Doffset(sTexColor, texcoord, int2(0, 1)).rgb;
    float3 i = tex2Doffset(sTexColor, texcoord, int2(1, 1)).rgb;

    float3 mnRGB = min(min(min(d, e), min(f, b)), h);
    float3 mnRGB2 = min(mnRGB, min(min(a, c), min(g, i)));
    mnRGB += mnRGB2;

    float3 mxRGB = max(max(max(d, e), max(f, b)), h);
    float3 mxRGB2 = max(mxRGB, max(max(a, c), max(g, i)));
    mxRGB += mxRGB2;
	
	#if HDR_BACKBUFFER_IS_LINEAR
	mnRGB *= 1 / HDR_DISPLAY_NITS;
	mxRGB *= 1 / HDR_DISPLAY_NITS;
	e *= 1 / HDR_DISPLAY_NITS;
	#endif

    float3 rcpMRGB = rcp(mxRGB);
    float3 ampRGB = saturate(min(mnRGB, 2.0 - mxRGB) * rcpMRGB);    
    
    ampRGB = rsqrt(ampRGB);
    
    float3 wRGB = -rcp(ampRGB * 8);

    float3 rcpWeightRGB = rcp(mad(4, wRGB, 1));

    float3 window = (b + d) + (f + h);
	#if HDR_BACKBUFFER_IS_LINEAR
	window *= 1 / HDR_DISPLAY_NITS;
	#endif
	
    float3 outColor = saturate(mad(window, wRGB, e) * rcpWeightRGB);
    
	#if HDR_BACKBUFFER_IS_LINEAR
	return lerp(e, outColor, sharpening) * HDR_DISPLAY_NITS;
	#else
	return lerp(e, outColor, sharpening);
	#endif
}

/*****************************************************************************************************************************************/
/*********************************************************** CAS CODE BLOCK END **********************************************************/
/*****************************************************************************************************************************************/


/*****************************************************************************************************************************************/
/*********************************************************** SMAA CODE BLOCK START *******************************************************/
/*****************************************************************************************************************************************/

// DX11 optimization
#if (__RENDERER__ == 0xb000 || __RENDERER__ == 0xb100)
	#define __SMAAGather(tex, coord) tex2Dgather(tex, coord, 0)
#endif

// Configurable
#define __SMAA_MAX_SEARCH_STEPS 112
#define __SMAA_CORNER_ROUNDING (__HQAA_SMAA_CORNERING)
#define __SMAA_EDGE_THRESHOLD max(__SMAA_THRESHOLD_FLOOR, __HQAA_EDGE_THRESHOLD)
#define __SMAA_MAX_SEARCH_STEPS_DIAG 20
#define __SMAA_RT_METRICS float4(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT, BUFFER_WIDTH, BUFFER_HEIGHT)
#define __SMAATexture2D(tex) sampler tex
#define __SMAATexturePass2D(tex) tex
#define __SMAASampleLevelZero(tex, coord) tex2Dlod(tex, float4(coord, coord))
#define __SMAASampleLevelZeroPoint(tex, coord) __SMAASampleLevelZero(tex, coord)
#define __SMAASampleLevelZeroOffset(tex, coord, offset) tex2Dlodoffset(tex, float4(coord, coord), offset)
#define __SMAASample(tex, coord) tex2D(tex, coord)
#define __SMAASamplePoint(tex, coord) __SMAASample(tex, coord)
#define __SMAASampleOffset(tex, coord, offset) tex2Doffset(tex, coord, offset)
#define __SMAA_BRANCH [branch]
#define __SMAA_FLATTEN [flatten]
#define __SMAA_REPROJECTION 0
#define __SMAA_INCLUDE_VS 1
#define __SMAA_INCLUDE_PS 1
#define __SMAA_REPROJECTION_WEIGHT_SCALE 30.0
#define __SMAA_AREATEX_SELECT(sample) sample.rg
#define __SMAA_SEARCHTEX_SELECT(sample) sample.r
#define __SMAA_DECODE_VELOCITY(sample) sample.rg

// Constants
#define __SMAA_AREATEX_MAX_DISTANCE 16
#define __SMAA_AREATEX_MAX_DISTANCE_DIAG 20
#define __SMAA_AREATEX_PIXEL_SIZE (1.0 / float2(160.0, 560.0))
#define __SMAA_AREATEX_SUBTEX_SIZE (1.0 / 7.0)
#define __SMAA_SEARCHTEX_SIZE float2(66.0, 33.0)
#define __SMAA_SEARCHTEX_PACKED_SIZE float2(64.0, 16.0)
#define __SMAA_CORNER_ROUNDING_NORM (float(__SMAA_CORNER_ROUNDING) / 100.0)

/////////////////////////////////////////////// SMAA SUPPORT FUNCTIONS ////////////////////////////////////////////////////////////////////

/**
 * Gathers current pixel, and the top-left neighbors.
 */
float3 __SMAAGatherNeighbours(float2 texcoord,
                            float4 offset[3],
                            __SMAATexture2D(tex)) {
    #ifdef __SMAAGather
    return __SMAAGather(tex, texcoord + __SMAA_RT_METRICS.xy * float2(-0.5, -0.5)).grb;
    #else
    float P = __SMAASamplePoint(tex, texcoord).r;
    float Pleft = __SMAASamplePoint(tex, offset[0].xy).r;
    float Ptop  = __SMAASamplePoint(tex, offset[0].zw).r;
    return float3(P, Pleft, Ptop);
    #endif
}

/**
 * Conditional move:
 */
void SMAAMovc(bool2 cond, inout float2 variable, float2 value) {
    __SMAA_FLATTEN if (cond.x) variable.x = value.x;
    __SMAA_FLATTEN if (cond.y) variable.y = value.y;
}

void SMAAMovc(bool4 cond, inout float4 variable, float4 value) {
    SMAAMovc(cond.xy, variable.xy, value.xy);
    SMAAMovc(cond.zw, variable.zw, value.zw);
}

/////////////////////////////////////////////// SMAA VERTEX SHADERS ///////////////////////////////////////////////////////////////////////

#if __SMAA_INCLUDE_VS


void SMAAEdgeDetectionVS(float2 texcoord,
                         out float4 offset[3]) {
    offset[0] = mad(__SMAA_RT_METRICS.xyxy, float4(-1.0, 0.0, 0.0, -1.0), texcoord.xyxy);
    offset[1] = mad(__SMAA_RT_METRICS.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
    offset[2] = mad(__SMAA_RT_METRICS.xyxy, float4(-2.0, 0.0, 0.0, -2.0), texcoord.xyxy);
}


void SMAABlendingWeightCalculationVS(float2 texcoord,
                                     out float2 pixcoord,
                                     out float4 offset[3]) {
    pixcoord = texcoord * __SMAA_RT_METRICS.zw;

    // We will use these offsets for the searches later on (see @PSEUDO_GATHER4):
    offset[0] = mad(__SMAA_RT_METRICS.xyxy, float4(-0.25, -0.125,  1.25, -0.125), texcoord.xyxy);
    offset[1] = mad(__SMAA_RT_METRICS.xyxy, float4(-0.125, -0.25, -0.125,  1.25), texcoord.xyxy);

    // And these for the searches, they indicate the ends of the loops:
    offset[2] = mad(__SMAA_RT_METRICS.xxyy,
                    float4(-2.0, 2.0, -2.0, 2.0) * float(__SMAA_MAX_SEARCH_STEPS),
                    float4(offset[0].xz, offset[1].yw));
}


void SMAANeighborhoodBlendingVS(float2 texcoord,
                                out float4 offset) {
    offset = mad(__SMAA_RT_METRICS.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
}
#endif // __SMAA_INCLUDE_VS

/////////////////////////////////////////////// SMAA PIXEL SHADERS ////////////////////////////////////////////////////

#if __SMAA_INCLUDE_PS



/////////////////////////////////////////////// LUMA EDGE DETECTION ////////////////////////////////////////////////////
/**
 * IMPORTANT NOTICE: luma edge detection requires gamma-corrected colors, and
 * thus 'colorTex' should be a non-sRGB texture.
 */
float2 SMAALumaEdgeDetectionPS(float2 texcoord,
                               float4 offset[3],
                               __SMAATexture2D(colorTex),
							   __SMAATexture2D(gammaTex)
                               ) {
 // SMAA default luma weights: 0.2126, 0.7152, 0.0722

	float4 middle = float4(__SMAASamplePoint(colorTex, texcoord).rgb,__SMAASamplePoint(gammaTex, texcoord).a);
	
	// calculate the threshold
	float adjustmentrange = (__SMAA_EDGE_THRESHOLD - __SMAA_THRESHOLD_FLOOR) * __HQAA_SUBPIX * 0.5;
	
	float strongestcolor = max(max(middle.r, middle.g), middle.b);
	float estimatedgamma = (0.3333 * middle.r) + (0.3334 * middle.g) + (0.3333 * middle.b);
	float estimatedbrightness = (strongestcolor + estimatedgamma) * 0.5;
	float thresholdOffset = mad(estimatedbrightness, adjustmentrange, -adjustmentrange);
	
	float weightedthreshold = __SMAA_EDGE_THRESHOLD + thresholdOffset;
	
	float2 threshold = float2(weightedthreshold, weightedthreshold);
	
	// calculate color channel weighting
	float4 weights = float4(0.26, 0.39, 0.24, 0.11);
	weights *= middle;
	float scale = rcp(weights.r + weights.g + weights.b + weights.a);
	weights *= scale;
	
	bool runLumaDetection = (weights.r + weights.g) > (weights.b + weights.a);
	float2 edges = float2(0,0);
	
	if (runLumaDetection) {
		
	
    float L = dot(middle, weights);

    float Lleft = dot(float4(__SMAASamplePoint(colorTex, offset[0].xy).rgb,__SMAASamplePoint(gammaTex, offset[0].xy).a), weights);
    float Ltop  = dot(float4(__SMAASamplePoint(colorTex, offset[0].zw).rgb,__SMAASamplePoint(gammaTex, offset[0].zw).a), weights);

    // We do the usual threshold:
    float4 delta;
    delta.xy = abs(L - float2(Lleft, Ltop));
    edges = step(threshold, delta.xy);
	
	if (dot(edges, float2(1,1)) != 0) {
	// scale has a floor value of 0.25 on a pure bright white pixel
	float contrastadaptation = 0.75 + scale;

    // Calculate right and bottom deltas:
    float Lright = dot(float4(__SMAASamplePoint(colorTex, offset[1].xy).rgb,__SMAASamplePoint(gammaTex, offset[1].xy).a), weights);
    float Lbottom  = dot(float4(__SMAASamplePoint(colorTex, offset[1].zw).rgb,__SMAASamplePoint(gammaTex, offset[1].zw).a), weights);
    delta.zw = abs(L - float2(Lright, Lbottom));

    // Calculate the maximum delta in the direct neighborhood:
    float2 maxDelta = max(delta.xy, delta.zw);

    // Calculate left-left and top-top deltas:
    float Lleftleft = dot(float4(__SMAASamplePoint(colorTex, offset[2].xy).rgb,__SMAASamplePoint(gammaTex, offset[2].xy).a), weights);
    float Ltoptop = dot(float4(__SMAASamplePoint(colorTex, offset[2].zw).rgb,__SMAASamplePoint(gammaTex, offset[2].zw).a), weights);
    delta.zw = abs(float2(Lleft, Ltop) - float2(Lleftleft, Ltoptop));

    // Calculate the final maximum delta:
    maxDelta = max(maxDelta.xy, delta.zw);
    float finalDelta = max(maxDelta.x, maxDelta.y);

    // Local contrast adaptation:
	edges.xy *= step(finalDelta, contrastadaptation * delta.xy);
	}
	}
    return edges;
}


#if !defined(__SMAA_DISABLE_DIAG_DETECTION)

/////////////////////////////////////////////// DIAGONAL SEARCH FUNCTIONS ////////////////////////////////////////////////////

/**
 * Allows to decode two binary values from a bilinear-filtered access.
 */
float2 SMAADecodeDiagBilinearAccess(float2 e) {
    // Bilinear access for fetching 'e' have a 0.25 offset, and we are
    // interested in the R and G edges:
    //
    // +---G---+-------+
    // |   x o R   x   |
    // +-------+-------+
    //
    // Then, if one of these edge is enabled:
    //   Red:   (0.75 * X + 0.25 * 1) => 0.25 or 1.0
    //   Green: (0.75 * 1 + 0.25 * X) => 0.75 or 1.0
    //
    // This function will unpack the values (mad + mul + round):
    // wolframalpha.com: round(x * abs(5 * x - 5 * 0.75)) plot 0 to 1
    e.r = e.r * abs(5.0 * e.r - 5.0 * 0.75);
    return round(e);
}

float4 SMAADecodeDiagBilinearAccess(float4 e) {
    e.rb = e.rb * abs(5.0 * e.rb - 5.0 * 0.75);
    return round(e);
}


float2 SMAASearchDiag1(__SMAATexture2D(HQAAedgesTex), float2 texcoord, float2 dir, out float2 e) {
    float4 coord = float4(texcoord, -1.0, 1.0);
    float3 t = float3(__SMAA_RT_METRICS.xy, 1.0);
    while (coord.z < float(__SMAA_MAX_SEARCH_STEPS_DIAG - 1) &&
           coord.w > 0.9) {
        coord.xyz = mad(t, float3(dir, 1.0), coord.xyz);
        e = __SMAASampleLevelZero(HQAAedgesTex, coord.xy).rg;
        coord.w = dot(e, float2(0.5, 0.5));
    }
    return coord.zw;
}

float2 SMAASearchDiag2(__SMAATexture2D(HQAAedgesTex), float2 texcoord, float2 dir, out float2 e) {
    float4 coord = float4(texcoord, -1.0, 1.0);
    coord.x += 0.25 * __SMAA_RT_METRICS.x; // See @SearchDiag2Optimization
    float3 t = float3(__SMAA_RT_METRICS.xy, 1.0);
    while (coord.z < float(__SMAA_MAX_SEARCH_STEPS_DIAG - 1) &&
           coord.w > 0.9) {
        coord.xyz = mad(t, float3(dir, 1.0), coord.xyz);

        // @SearchDiag2Optimization
        // Fetch both edges at once using bilinear filtering:
        e = __SMAASampleLevelZero(HQAAedgesTex, coord.xy).rg;
        e = SMAADecodeDiagBilinearAccess(e);

        // Non-optimized version:
        // e.g = __SMAASampleLevelZero(HQAAedgesTex, coord.xy).g;
        // e.r = __SMAASampleLevelZeroOffset(HQAAedgesTex, coord.xy, int2(1, 0)).r;

        coord.w = dot(e, float2(0.5, 0.5));
    }
    return coord.zw;
}

/** 
 * Similar to SMAAArea, this calculates the area corresponding to a certain
 * diagonal distance and crossing edges 'e'.
 */
float2 SMAAAreaDiag(__SMAATexture2D(HQAAareaTex), float2 dist, float2 e, float offset) {
    float2 texcoord = mad(float2(__SMAA_AREATEX_MAX_DISTANCE_DIAG, __SMAA_AREATEX_MAX_DISTANCE_DIAG), e, dist);

    // We do a scale and bias for mapping to texel space:
    texcoord = mad(__SMAA_AREATEX_PIXEL_SIZE, texcoord, 0.5 * __SMAA_AREATEX_PIXEL_SIZE);

    // Diagonal areas are on the second half of the texture:
    texcoord.x += 0.5;

    // Move to proper place, according to the subpixel offset:
    texcoord.y += __SMAA_AREATEX_SUBTEX_SIZE * offset;

    // Do it!
    return __SMAA_AREATEX_SELECT(__SMAASampleLevelZero(HQAAareaTex, texcoord));
}

/**
 * This searches for diagonal patterns and returns the corresponding weights.
 */
float2 SMAACalculateDiagWeights(__SMAATexture2D(HQAAedgesTex), __SMAATexture2D(HQAAareaTex), float2 texcoord, float2 e, float4 subsampleIndices) {
    float2 weights = float2(0.0, 0.0);

    // Search for the line ends:
    float4 d;
    float2 end;
    if (e.r > 0.0) {
        d.xz = SMAASearchDiag1(__SMAATexturePass2D(HQAAedgesTex), texcoord, float2(-1.0,  1.0), end);
        d.x += float(end.y > 0.9);
    } else
        d.xz = float2(0.0, 0.0);
    d.yw = SMAASearchDiag1(__SMAATexturePass2D(HQAAedgesTex), texcoord, float2(1.0, -1.0), end);

    __SMAA_BRANCH
    if (d.x + d.y > 2.0) { // d.x + d.y + 1 > 3
        // Fetch the crossing edges:
        float4 coords = mad(float4(-d.x + 0.25, d.x, d.y, -d.y - 0.25), __SMAA_RT_METRICS.xyxy, texcoord.xyxy);
        float4 c;
        c.xy = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.xy, int2(-1,  0)).rg;
        c.zw = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.zw, int2( 1,  0)).rg;
        c.yxwz = SMAADecodeDiagBilinearAccess(c.xyzw);

        // Non-optimized version:
        // float4 coords = mad(float4(-d.x, d.x, d.y, -d.y), __SMAA_RT_METRICS.xyxy, texcoord.xyxy);
        // float4 c;
        // c.x = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.xy, int2(-1,  0)).g;
        // c.y = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.xy, int2( 0,  0)).r;
        // c.z = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.zw, int2( 1,  0)).g;
        // c.w = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.zw, int2( 1, -1)).r;

        // Merge crossing edges at each side into a single value:
        float2 cc = mad(float2(2.0, 2.0), c.xz, c.yw);

        // Remove the crossing edge if we didn't found the end of the line:
        SMAAMovc(bool2(step(0.9, d.zw)), cc, float2(0.0, 0.0));

        // Fetch the areas for this line:
        weights += SMAAAreaDiag(__SMAATexturePass2D(HQAAareaTex), d.xy, cc, subsampleIndices.z);
    }

    // Search for the line ends:
    d.xz = SMAASearchDiag2(__SMAATexturePass2D(HQAAedgesTex), texcoord, float2(-1.0, -1.0), end);
    if (__SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord, int2(1, 0)).r > 0.0) {
        d.yw = SMAASearchDiag2(__SMAATexturePass2D(HQAAedgesTex), texcoord, float2(1.0, 1.0), end);
        d.y += float(end.y > 0.9);
    } else
        d.yw = float2(0.0, 0.0);

    __SMAA_BRANCH
    if (d.x + d.y > 2.0) { // d.x + d.y + 1 > 3
        // Fetch the crossing edges:
        float4 coords = mad(float4(-d.x, -d.x, d.y, d.y), __SMAA_RT_METRICS.xyxy, texcoord.xyxy);
        float4 c;
        c.x  = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.xy, int2(-1,  0)).g;
        c.y  = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.xy, int2( 0, -1)).r;
        c.zw = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.zw, int2( 1,  0)).gr;
        float2 cc = mad(float2(2.0, 2.0), c.xz, c.yw);

        // Remove the crossing edge if we didn't found the end of the line:
        SMAAMovc(bool2(step(0.9, d.zw)), cc, float2(0.0, 0.0));

        // Fetch the areas for this line:
        weights += SMAAAreaDiag(__SMAATexturePass2D(HQAAareaTex), d.xy, cc, subsampleIndices.w).gr;
    }

    return weights;
}
#endif


/////////////////////////////////////////////// X,Y SEARCH FUNCTIONS ////////////////////////////////////////////////////
/**
 * This allows to determine how much length should we add in the last step
 * of the searches. It takes the bilinearly interpolated edge (see 
 * @PSEUDO_GATHER4), and adds 0, 1 or 2, depending on which edges and
 * crossing edges are active.
 */
float SMAASearchLength(__SMAATexture2D(HQAAsearchTex), float2 e, float offset) {
    // The texture is flipped vertically, with left and right cases taking half
    // of the space horizontally:
    float2 scale = __SMAA_SEARCHTEX_SIZE * float2(0.5, -1.0);
    float2 bias = __SMAA_SEARCHTEX_SIZE * float2(offset, 1.0);

    // Scale and bias to access texel centers:
    scale += float2(-1.0,  1.0);
    bias  += float2( 0.5, -0.5);

    // Convert from pixel coordinates to texcoords:
    // (We use __SMAA_SEARCHTEX_PACKED_SIZE because the texture is cropped)
    scale *= 1.0 / __SMAA_SEARCHTEX_PACKED_SIZE;
    bias *= 1.0 / __SMAA_SEARCHTEX_PACKED_SIZE;

    // Lookup the search texture:
    return __SMAA_SEARCHTEX_SELECT(__SMAASampleLevelZero(HQAAsearchTex, mad(scale, e, bias)));
}

/**
 * Horizontal/vertical search functions for the 2nd pass.
 */
float SMAASearchXLeft(__SMAATexture2D(HQAAedgesTex), __SMAATexture2D(HQAAsearchTex), float2 texcoord, float end) {
    float2 e = float2(0.0, 1.0);
	float threshold = mad(0.5,sqrt(__SMAA_EDGE_THRESHOLD),0.5);
    while (texcoord.x > end && 
           (e.g > threshold) && // Is there some edge not activated?
           e.r == 0) { // Or is there a crossing edge that breaks the line?
        e = __SMAASampleLevelZero(HQAAedgesTex, texcoord).rg;
        texcoord = mad(-float2(2.0, 0.0), __SMAA_RT_METRICS.xy, texcoord);
    }

    float offset = mad(-(255.0 / 127.0), SMAASearchLength(__SMAATexturePass2D(HQAAsearchTex), e, 0.0), 3.25);
    return mad(__SMAA_RT_METRICS.x, offset, texcoord.x);
}

float SMAASearchXRight(__SMAATexture2D(HQAAedgesTex), __SMAATexture2D(HQAAsearchTex), float2 texcoord, float end) {
    float2 e = float2(0.0, 1.0);
	float threshold = mad(0.5,sqrt(__SMAA_EDGE_THRESHOLD),0.5);
    while (texcoord.x < end && 
           (e.g > threshold) && // Is there some edge not activated?
           e.r == 0) { // Or is there a crossing edge that breaks the line?
        e = __SMAASampleLevelZero(HQAAedgesTex, texcoord).rg;
        texcoord = mad(float2(2.0, 0.0), __SMAA_RT_METRICS.xy, texcoord);
    }
    float offset = mad(-(255.0 / 127.0), SMAASearchLength(__SMAATexturePass2D(HQAAsearchTex), e, 0.5), 3.25);
    return mad(-__SMAA_RT_METRICS.x, offset, texcoord.x);
}

float SMAASearchYUp(__SMAATexture2D(HQAAedgesTex), __SMAATexture2D(HQAAsearchTex), float2 texcoord, float end) {
    float2 e = float2(1.0, 0.0);
	float threshold = mad(0.5,sqrt(__SMAA_EDGE_THRESHOLD),0.5);
    while (texcoord.y > end && 
           (e.r > threshold) && // Is there some edge not activated?
           e.g == 0) { // Or is there a crossing edge that breaks the line?
        e = __SMAASampleLevelZero(HQAAedgesTex, texcoord).rg;
        texcoord = mad(-float2(0.0, 2.0), __SMAA_RT_METRICS.xy, texcoord);
    }
    float offset = mad(-(255.0 / 127.0), SMAASearchLength(__SMAATexturePass2D(HQAAsearchTex), e.gr, 0.0), 3.25);
    return mad(__SMAA_RT_METRICS.y, offset, texcoord.y);
}

float SMAASearchYDown(__SMAATexture2D(HQAAedgesTex), __SMAATexture2D(HQAAsearchTex), float2 texcoord, float end) {
    float2 e = float2(1.0, 0.0);
	float threshold = mad(0.5,sqrt(__SMAA_EDGE_THRESHOLD),0.5);
    while (texcoord.y < end && 
           (e.r > threshold) && // Is there some edge not activated?
           e.g == 0) { // Or is there a crossing edge that breaks the line?
        e = __SMAASampleLevelZero(HQAAedgesTex, texcoord).rg;
        texcoord = mad(float2(0.0, 2.0), __SMAA_RT_METRICS.xy, texcoord);
    }
    float offset = mad(-(255.0 / 127.0), SMAASearchLength(__SMAATexturePass2D(HQAAsearchTex), e.gr, 0.5), 3.25);
    return mad(-__SMAA_RT_METRICS.y, offset, texcoord.y);
}

/** 
 * Ok, we have the distance and both crossing edges. So, what are the areas
 * at each side of current edge?
 */
float2 SMAAArea(__SMAATexture2D(HQAAareaTex), float2 dist, float e1, float e2, float offset) {
    // Rounding prevents precision errors of bilinear filtering:
    float2 texcoord = mad(float2(__SMAA_AREATEX_MAX_DISTANCE, __SMAA_AREATEX_MAX_DISTANCE), round(4.0 * float2(e1, e2)), dist);
    
    // We do a scale and bias for mapping to texel space:
    texcoord = mad(__SMAA_AREATEX_PIXEL_SIZE, texcoord, 0.5 * __SMAA_AREATEX_PIXEL_SIZE);

    // Move to proper place, according to the subpixel offset:
    texcoord.y = mad(__SMAA_AREATEX_SUBTEX_SIZE, offset, texcoord.y);

    // Do it!
    return __SMAA_AREATEX_SELECT(__SMAASampleLevelZero(HQAAareaTex, texcoord));
}


void SMAADetectHorizontalCornerPattern(__SMAATexture2D(HQAAedgesTex), inout float2 weights, float4 texcoord, float2 d) {
    #if !defined(__SMAA_DISABLE_CORNER_DETECTION)
    float2 leftRight = step(d.xy, d.yx);
    float2 rounding = (1.0 - __SMAA_CORNER_ROUNDING_NORM) * leftRight;

//    rounding /= leftRight.x + leftRight.y; // Reduce blending for pixels in the center of a line.

    float2 factor = float2(1.0, 1.0);
    factor.x -= rounding.x * __SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord.xy, int2(0,  1)).r;
    factor.x -= rounding.y * __SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord.zw, int2(1,  1)).r;
    factor.y -= rounding.x * __SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord.xy, int2(0, -2)).r;
    factor.y -= rounding.y * __SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord.zw, int2(1, -2)).r;

    weights *= saturate(factor);
    #endif
}

void SMAADetectVerticalCornerPattern(__SMAATexture2D(HQAAedgesTex), inout float2 weights, float4 texcoord, float2 d) {
    #if !defined(__SMAA_DISABLE_CORNER_DETECTION)
    float2 leftRight = step(d.xy, d.yx);
    float2 rounding = (1.0 - __SMAA_CORNER_ROUNDING_NORM) * leftRight;

//    rounding /= leftRight.x + leftRight.y;

    float2 factor = float2(1.0, 1.0);
    factor.x -= rounding.x * __SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord.xy, int2( 1, 0)).g;
    factor.x -= rounding.y * __SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord.zw, int2( 1, 1)).g;
    factor.y -= rounding.x * __SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord.xy, int2(-2, 0)).g;
    factor.y -= rounding.y * __SMAASampleLevelZeroOffset(HQAAedgesTex, texcoord.zw, int2(-2, 1)).g;

    weights *= saturate(factor);
    #endif
}


float4 SMAABlendingWeightCalculationPS(float2 texcoord,
                                       float2 pixcoord,
                                       float4 offset[3],
                                       __SMAATexture2D(HQAAedgesTex),
                                       __SMAATexture2D(HQAAareaTex),
                                       __SMAATexture2D(HQAAsearchTex),
                                       float4 subsampleIndices) { // Just pass zero for SMAA 1x, see @SUBSAMPLE_INDICES.
    float4 weights = float4(0.0, 0.0, 0.0, 0.0);

    float2 e = __SMAASample(HQAAedgesTex, texcoord).rg;

    __SMAA_BRANCH
    if (e.g > 0.0) { // Edge at north
        #if !defined(__SMAA_DISABLE_DIAG_DETECTION)
        // Diagonals have both north and west edges, so searching for them in
        // one of the boundaries is enough.
        weights.rg = SMAACalculateDiagWeights(__SMAATexturePass2D(HQAAedgesTex), __SMAATexturePass2D(HQAAareaTex), texcoord, e, subsampleIndices);

        // We give priority to diagonals, so if we find a diagonal we skip 
        // horizontal/vertical processing.
        __SMAA_BRANCH
        if (weights.r == -weights.g) { // weights.r + weights.g == 0.0
        #endif

        float2 d;

        // Find the distance to the left:
        float3 coords;
        coords.x = SMAASearchXLeft(__SMAATexturePass2D(HQAAedgesTex), __SMAATexturePass2D(HQAAsearchTex), offset[0].xy, offset[2].x);
        coords.y = offset[1].y; // offset[1].y = texcoord.y - 0.25 * __SMAA_RT_METRICS.y (@CROSSING_OFFSET)
        d.x = coords.x;

        // Now fetch the left crossing edges, two at a time using bilinear
        // filtering. Sampling at -0.25 (see @CROSSING_OFFSET) enables to
        // discern what value each edge has:
        float e1 = __SMAASampleLevelZero(HQAAedgesTex, coords.xy).r;

        // Find the distance to the right:
        coords.z = SMAASearchXRight(__SMAATexturePass2D(HQAAedgesTex), __SMAATexturePass2D(HQAAsearchTex), offset[0].zw, offset[2].y);
        d.y = coords.z;

        // We want the distances to be in pixel units (doing this here allow to
        // better interleave arithmetic and memory accesses):
        d = abs(round(mad(__SMAA_RT_METRICS.zz, d, -pixcoord.xx)));

        // SMAAArea below needs a sqrt, as the areas texture is compressed
        // quadratically:
        float2 sqrt_d = sqrt(d);

        // Fetch the right crossing edges:
        float e2 = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.zy, int2(1, 0)).r;

        // Ok, we know how this pattern looks like, now it is time for getting
        // the actual area:
        weights.rg = SMAAArea(__SMAATexturePass2D(HQAAareaTex), sqrt_d, e1, e2, subsampleIndices.y);

        // Fix corners:
        coords.y = texcoord.y;
        SMAADetectHorizontalCornerPattern(__SMAATexturePass2D(HQAAedgesTex), weights.rg, coords.xyzy, d);

        #if !defined(__SMAA_DISABLE_DIAG_DETECTION)
        } else
            e.r = 0.0; // Skip vertical processing.
        #endif
    }

    __SMAA_BRANCH
    if (e.r > 0.0) { // Edge at west
        float2 d;

        // Find the distance to the top:
        float3 coords;
        coords.y = SMAASearchYUp(__SMAATexturePass2D(HQAAedgesTex), __SMAATexturePass2D(HQAAsearchTex), offset[1].xy, offset[2].z);
        coords.x = offset[0].x; // offset[1].x = texcoord.x - 0.25 * __SMAA_RT_METRICS.x;
        d.x = coords.y;

        // Fetch the top crossing edges:
        float e1 = __SMAASampleLevelZero(HQAAedgesTex, coords.xy).g;

        // Find the distance to the bottom:
        coords.z = SMAASearchYDown(__SMAATexturePass2D(HQAAedgesTex), __SMAATexturePass2D(HQAAsearchTex), offset[1].zw, offset[2].w);
        d.y = coords.z;

        // We want the distances to be in pixel units:
        d = abs(round(mad(__SMAA_RT_METRICS.ww, d, -pixcoord.yy)));

        // SMAAArea below needs a sqrt, as the areas texture is compressed 
        // quadratically:
        float2 sqrt_d = sqrt(d);

        // Fetch the bottom crossing edges:
        float e2 = __SMAASampleLevelZeroOffset(HQAAedgesTex, coords.xz, int2(0, 1)).g;

        // Get the area for this direction:
        weights.ba = SMAAArea(__SMAATexturePass2D(HQAAareaTex), sqrt_d, e1, e2, subsampleIndices.x);

        // Fix corners:
        coords.x = texcoord.x;
        SMAADetectVerticalCornerPattern(__SMAATexturePass2D(HQAAedgesTex), weights.ba, coords.xyxz, d);
    }

    return weights;
}

float4 SMAANeighborhoodBlendingPS(float2 texcoord,
                                  float4 offset,
                                  __SMAATexture2D(colorTex),
                                  __SMAATexture2D(HQAAblendTex)
                                  ) {
    // Fetch the blending weights for current pixel:
    float4 m;
    m.x = __SMAASample(HQAAblendTex, offset.xy).a; // Right
    m.y = __SMAASample(HQAAblendTex, offset.zw).g; // Top
    m.wz = __SMAASample(HQAAblendTex, texcoord).xz; // Bottom / Left
	
	float4 color = float4(0,0,0,0);

    // Is there any blending weight with a value greater than 0.0?
    __SMAA_BRANCH
    if (dot(m, float4(1.0, 1.0, 1.0, 1.0)) < 1e-5) {
        color = __SMAASampleLevelZero(colorTex, texcoord);
    } else {
        bool horiz = max(m.x, m.z) > max(m.y, m.w); // max(horizontal) > max(vertical)

        // Calculate the blending offsets:
        float4 blendingOffset = float4(0.0, m.y, 0.0, m.w);
        float2 blendingWeight = m.yw;
        SMAAMovc(bool4(horiz, horiz, horiz, horiz), blendingOffset, float4(m.x, 0.0, m.z, 0.0));
        SMAAMovc(bool2(horiz, horiz), blendingWeight, m.xz);
        blendingWeight /= dot(blendingWeight, float2(1.0, 1.0));

        // Calculate the texture coordinates:
        float4 blendingCoord = mad(blendingOffset, float4(__SMAA_RT_METRICS.xy, -__SMAA_RT_METRICS.xy), texcoord.xyxy);

        // We exploit bilinear filtering to mix current pixel with the chosen
        // neighbor:
        color = blendingWeight.x * __SMAASampleLevelZero(colorTex, blendingCoord.xy);
        color += blendingWeight.y * __SMAASampleLevelZero(colorTex, blendingCoord.zw);
    }
	
	if (__HQAA_SHARPEN_ENABLE == true)
		return float4(Sharpen(texcoord, colorTex, color, __SMAA_EDGE_THRESHOLD, -1), color.a);
	else
		return color;
}

#endif // SMAA_INCLUDE_PS
/***************************************************************************************************************************************/
/*********************************************************** SMAA CODE BLOCK END *******************************************************/
/***************************************************************************************************************************************/
// I'm a nested comment!
/***************************************************************************************************************************************/
/*********************************************************** FXAA CODE BLOCK START *****************************************************/
/***************************************************************************************************************************************/

#define __FxaaTexLuma4(t, p) textureGather(t, p, lumatype)
#define __FxaaTexOffLuma4(t, p, o) textureGatherOffset(t, p, o, lumatype)
#define __FxaaAdaptiveLuma(t) __FxaaAdaptiveLumaSelect(t, lumatype)

#define __FxaaTexTop(t, p) tex2Dlod(t, float4(p, 0.0, 0.0))
#define __FxaaTexOff(t, p, o, r) tex2Dlod(t, float4(p + (o * r), 0, 0))

#define __FXAA_MODE_NORMAL 0
#define __FXAA_MODE_SPURIOUS_PIXELS 2
#define __FXAA_MODE_SMAA_DETECTION_POSITIVES 3
#define __FXAA_MODE_SMAA_DETECTION_NEGATIVES 4

float __FxaaAdaptiveLumaSelect (float4 rgba, int lumatype)
// Luma types match variable positions. 0=R 1=G 2=B
{
	if (lumatype == 0)
		return (((1 - rgba.a) * rgba.r) + rgba.a);
	else if (lumatype == 2)
		return (((1 - rgba.a) * rgba.b) + rgba.a);
	else
		return (((1 - rgba.a) * rgba.g) + rgba.a);
}

float4 FxaaAdaptiveLumaPixelShader(float2 pos, sampler2D tex, sampler2D edgestex,
 float2 fxaaQualityRcpFrame, float fxaaQualitySubpix,
 float fxaaIncomingEdgeThreshold, float fxaaQualityEdgeThresholdMin, int pixelmode)
 {
    float4 rgbyM = __FxaaTexTop(tex, pos);
	float baseThreshold = max(fxaaIncomingEdgeThreshold, __FXAA_THRESHOLD_FLOOR);
	
	 if (pixelmode == __FXAA_MODE_SMAA_DETECTION_POSITIVES) {
		 float2 SMAAedges = tex2D(edgestex, pos).rg;
		 bool noSMAAedges = dot(float2(1.0, 1.0), SMAAedges) == 0;
		 if (noSMAAedges)
			 return rgbyM;
	 }
	 if (pixelmode == __FXAA_MODE_SMAA_DETECTION_NEGATIVES) {
		 float2 SMAAedges = tex2D(edgestex, pos).rg;
		 bool SMAAran = dot(float2(1.0, 1.0), SMAAedges) > 1e-5;
		 if (SMAAran)
			 return rgbyM;
	 }
    float2 posM;
    posM.x = pos.x;
    posM.y = pos.y;
	
	int lumatype = 1; // assume green is luma until determined otherwise
	
	float maxcolor = max(max(rgbyM.r, rgbyM.g), rgbyM.b);
	bool stronggreen = rgbyM.g > (rgbyM.r + rgbyM.b);
	
	if (stronggreen == false && rgbyM.g != maxcolor) // check if luma color needs changed
	{
		bool strongred = rgbyM.r > (rgbyM.g + rgbyM.b);
		bool strongblue = rgbyM.b > (rgbyM.g + rgbyM.r);
		
		if (strongred == true || rgbyM.r == maxcolor)
			lumatype = 0;
		else
			lumatype = 2;
	}
			
	float lumaMa = __FxaaAdaptiveLuma(rgbyM);
	
	float gammaM = (0.3333 * rgbyM.r) + (0.3334 * rgbyM.g) + (0.3333 * rgbyM.b);
	float adjustmentrange = (baseThreshold * __HQAA_SUBPIX) * 0.125;
	float estimatedbrightness = (lumaMa + gammaM) * 0.5;
	float thresholdOffset = mad(estimatedbrightness, adjustmentrange, -adjustmentrange);
	
	float fxaaQualityEdgeThreshold = baseThreshold + thresholdOffset;
	
	
    float lumaS = __FxaaAdaptiveLuma(__FxaaTexOff(tex, posM, float2( 0, 1), fxaaQualityRcpFrame.xy));
    float lumaE = __FxaaAdaptiveLuma(__FxaaTexOff(tex, posM, float2( 1, 0), fxaaQualityRcpFrame.xy));
    float lumaN = __FxaaAdaptiveLuma(__FxaaTexOff(tex, posM, float2( 0,-1), fxaaQualityRcpFrame.xy));
    float lumaW = __FxaaAdaptiveLuma(__FxaaTexOff(tex, posM, float2(-1, 0), fxaaQualityRcpFrame.xy));
    float lumaNW = __FxaaAdaptiveLuma(__FxaaTexOff(tex, posM, float2(-1,-1), fxaaQualityRcpFrame.xy));
    float lumaSE = __FxaaAdaptiveLuma(__FxaaTexOff(tex, posM, float2( 1, 1), fxaaQualityRcpFrame.xy));
    float lumaNE = __FxaaAdaptiveLuma(__FxaaTexOff(tex, posM, float2( 1,-1), fxaaQualityRcpFrame.xy));
    float lumaSW = __FxaaAdaptiveLuma(__FxaaTexOff(tex, posM, float2(-1, 1), fxaaQualityRcpFrame.xy));
	
	// shoot me please
    float rangeMax = max(max(max(max(max(max(max(max(lumaS,lumaE),lumaN),lumaW),lumaNW),lumaSE),lumaNE),lumaSW),lumaMa);
    float rangeMin = min(min(min(min(min(min(min(min(lumaS,lumaE),lumaN),lumaW),lumaNW),lumaSE),lumaNE),lumaSW),lumaMa);
	
    float rangeMaxScaled = rangeMax * fxaaQualityEdgeThreshold;
    float range = rangeMax - rangeMin;
    float rangeMaxClamped = max(fxaaQualityEdgeThresholdMin, rangeMaxScaled);
	
	bool earlyExit = (range < rangeMaxClamped);
	
	if (pixelmode == __FXAA_MODE_SMAA_DETECTION_POSITIVES)
		earlyExit = (rgbyM.r + rgbyM.g + rgbyM.b) < fxaaQualityEdgeThresholdMin;
		
	if (earlyExit)
		return rgbyM;
	
	// green luma default weights
	float4 weights = float4(0.125, 0.625, 0.125, 0.125);
	
	if (lumatype == 0)
		weights = float4(0.625, 0.125, 0.125, 0.125);
	else if (lumatype == 2)
		weights = float4(0.125, 0.125, 0.625, 0.125);
	
	weights *= rgbyM;
	weights *= rcp(weights.r + weights.g + weights.b + weights.a);
	
	float blendfactor = __FxaaAdaptiveLuma(weights);
	
    float lumaNS = lumaN + lumaS;
    float lumaWE = lumaW + lumaE;
    float subpixRcpRange = 1.0/range;
    float subpixNSWE = lumaNS + lumaWE;
    float edgeHorz1 = mad(-2, lumaMa, lumaNS);
    float edgeVert1 = mad(-2, lumaMa, lumaWE);
	
    float lumaNESE = lumaNE + lumaSE;
    float lumaNWNE = lumaNW + lumaNE;
    float edgeHorz2 = mad(-2, lumaE, lumaNESE);
    float edgeVert2 = mad(-2, lumaN, lumaNWNE);
	
    float lumaNWSW = lumaNW + lumaSW;
    float lumaSWSE = lumaSW + lumaSE;
    float edgeHorz4 = mad(2, abs(edgeHorz1), abs(edgeHorz2));
    float edgeVert4 = mad(2, abs(edgeVert1), abs(edgeVert2));
    float edgeHorz3 = mad(-2, lumaW, lumaNWSW);
    float edgeVert3 = mad(-2, lumaS, lumaSWSE);
    float edgeHorz = abs(edgeHorz3) + edgeHorz4;
    float edgeVert = abs(edgeVert3) + edgeVert4;
	
    float subpixNWSWNESE = lumaNWSW + lumaNESE;
    float lengthSign = fxaaQualityRcpFrame.x;
    bool horzSpan = edgeHorz >= edgeVert;
    float subpixA = mad(2, subpixNSWE, subpixNWSWNESE);
	
    if(!horzSpan) {
		lumaN = lumaW;
		lumaS = lumaE;
	}
    else lengthSign = fxaaQualityRcpFrame.y;
    float subpixB = mad((1.0/12.0), subpixA, -lumaMa);
	
    float gradientN = lumaN - lumaMa;
    float gradientS = lumaS - lumaMa;
    float lumaNN = lumaN + lumaMa;
    float lumaSS = lumaS + lumaMa;
    bool pairN = abs(gradientN) >= abs(gradientS);
    float gradient = max(abs(gradientN), abs(gradientS));
    if(pairN) lengthSign = -lengthSign;
    float subpixC = saturate(abs(subpixB) * subpixRcpRange);
	
    float2 posB;
    posB.x = posM.x;
    posB.y = posM.y;
    float2 offNP;
    offNP.x = (!horzSpan) ? 0.0 : fxaaQualityRcpFrame.x;
    offNP.y = ( horzSpan) ? 0.0 : fxaaQualityRcpFrame.y;
    if(!horzSpan) posB.x = mad(0.5, lengthSign, posB.x);
    else posB.y = mad(0.5, lengthSign, posB.y);
	
    float2 posN;
    posN = posB - offNP;
	
    float2 posP;
    posP = posB + offNP;
	
    float subpixD = mad(-2, subpixC, 3);
    float lumaEndN = __FxaaAdaptiveLuma(__FxaaTexTop(tex, posN));
    float subpixE = pow(subpixC, 2);
    float lumaEndP = __FxaaAdaptiveLuma(__FxaaTexTop(tex, posP));
	
    if(!pairN) lumaNN = lumaSS;
    float gradientScaled = gradient * 1.0/4.0;
    float lumaMM = mad(0.5, -lumaNN, lumaMa);
    float subpixF = subpixD * subpixE;
    bool lumaMLTZero = lumaMM < 0.0;
	
	float2 granularity = float2(__HQAA_FXAA_SCAN_GRANULARITY, __HQAA_FXAA_SCAN_GRANULARITY);
	
    lumaEndN = mad(0.5, -lumaNN, lumaEndN);
    lumaEndP = mad(0.5, -lumaNN, lumaEndP);
	
    bool doneN = abs(lumaEndN) >= gradientScaled;
    bool doneP = abs(lumaEndP) >= gradientScaled;
    bool doneNP = doneN && doneP;
	
    if(!doneN) posN = mad(granularity, -offNP, posN);
    if(!doneP) posP = mad(granularity, offNP, posP);
	
	uint iterations = 0;
	uint maxiterations = trunc(__HQAA_DISPLAY_DENOMINATOR * 0.05) * __HQAA_FXAA_SCAN_MULTIPLIER;
	
	if (frametime > __HQAA_DESIRED_FRAMETIME && maxiterations > 3)
		maxiterations = max(3, trunc(rcp(frametime - __HQAA_DESIRED_FRAMETIME + 1) * maxiterations));
	
    while(!doneNP && iterations < maxiterations) {
		
        if(!doneN) {
			lumaEndN = __FxaaAdaptiveLuma(__FxaaTexTop(tex, posN.xy));
			lumaEndN = mad(0.5, -lumaNN, lumaEndN);
			doneN = (abs(lumaEndN) >= gradientScaled) || !(posN.x > 0 && posN.y > 0);
		}
		
        if(!doneP) {
			lumaEndP = __FxaaAdaptiveLuma(__FxaaTexTop(tex, posP.xy));
			lumaEndP = mad(0.5, -lumaNN, lumaEndP);
			doneP = (abs(lumaEndP) >= gradientScaled) || !((BUFFER_HEIGHT - posP.y) > 0 && (BUFFER_WIDTH - posP.x) > 0);
		}
		
        if(!doneN) posN = mad(granularity, -offNP, posN);
        if(!doneP) posP = mad(granularity, offNP, posP);
		
        doneNP = doneN && doneP;
		iterations++;
    }
	
    float dstN = posM.x - posN.x;
    float dstP = posP.x - posM.x;
	
    if(!horzSpan) {
		dstN = posM.y - posN.y;
		dstP = posP.y - posM.y;
	}
	
    bool goodSpanN = (lumaEndN < 0.0) != lumaMLTZero;
    float spanLength = (dstP + dstN);
    bool goodSpanP = (lumaEndP < 0.0) != lumaMLTZero;
    float spanLengthRcp = rcp(spanLength);
	
    bool directionN = dstN < dstP;
    float dst = min(dstN, dstP);
    bool goodSpan = directionN ? goodSpanN : goodSpanP;
    float subpixG = subpixF * subpixF;
    float pixelOffset = mad(-spanLengthRcp, dst, 0.5);
    float subpixH = subpixG * fxaaQualitySubpix;
	
    float pixelOffsetGood = goodSpan ? pixelOffset : 0.0;
    float pixelOffsetSubpix = max(pixelOffsetGood, subpixH);
	
    if(!horzSpan) posM.x = mad(lengthSign, pixelOffsetSubpix, posM.x);
    else posM.y = mad(lengthSign, pixelOffsetSubpix, posM.y);
	
	// Establish result
	float4 resultAA = float4(tex2D(tex,posM).rgb, lumaMa);
	float4 weightedresult = (pixelmode == __FXAA_MODE_SMAA_DETECTION_NEGATIVES ? (lerp(rgbyM, resultAA, blendfactor)) : (resultAA));
	
	// fart the result
	if (__HQAA_SHARPEN_ENABLE == true)
		return float4(Sharpen(pos, tex, weightedresult, fxaaQualityEdgeThreshold, fxaaQualitySubpix), weightedresult.a);
	else
		return weightedresult;
}

/***************************************************************************************************************************************/
/*********************************************************** FXAA CODE BLOCK END *******************************************************/
/***************************************************************************************************************************************/

///////////////////////////////////////////////////////////// SUPPORT PASSES ////////////////////////////////////////////////////////////

float4 GenerateImageColorShiftLeftPS(float4 input)
{
	return float4(input.g, input.b, input.r, input.a);
}
float4 GenerateImageNegativeColorShiftLeftPS(float4 input)
{
	return float4(1.0 - input.g, 1.0 - input.b, 1.0 - input.r, input.a);
}
float4 GenerateImageColorShiftRightPS(float4 input)
{
	return float4(input.b, input.r, input.g, input.a);
}
float4 GenerateImageNegativeColorShiftRightPS(float4 input)
{
	return float4(1.0 - input.b, 1.0 - input.r, 1.0 - input.g, input.a);
}
float4 GenerateImageNegativePS(float4 input)
{
	return float4(1.0 - input.r, 1.0 - input.g, 1.0 - input.b, input.a);
}


/***************************************************************************************************************************************/
/*********************************************************** SHADER CODE START *********************************************************/
/***************************************************************************************************************************************/

#include "ReShade.fxh"


//////////////////////////////////////////////////////////// TEXTURES ///////////////////////////////////////////////////////////////////

texture HQAAedgesTex < pooled = true; >
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = RG8;
};
texture HQAAblendTex < pooled = true; >
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = RGBA8;
};

texture HQAAareaTex < source = "AreaTex.png"; >
{
	Width = 160;
	Height = 560;
	Format = RG8;
};
texture HQAAsearchTex < source = "SearchTex.png"; >
{
	Width = 64;
	Height = 16;
	Format = R8;
};

texture HQAAnegativeTex < pooled = true; >
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
#if (BUFFER_COLOR_BIT_DEPTH == 10)
	Format = RGB10A2;
#else
	Format = RGBA8;
#endif
};


//////////////////////////////////////////////////////////// SAMPLERS ///////////////////////////////////////////////////////////////////

sampler HQAAcolorGammaSampler
{
	Texture = ReShade::BackBufferTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler HQAAcolorLinearSampler
{
	Texture = ReShade::BackBufferTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
#if HDR_BACKBUFFER_IS_LINEAR
	SRGBTexture = false;
#else
	SRGBTexture = true;
#endif
};
sampler HQAAnegativeGammaSampler
{
	Texture = HQAAnegativeTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler HQAAedgesSampler
{
	Texture = HQAAedgesTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler HQAAblendSampler
{
	Texture = HQAAblendTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler HQAAareaSampler
{
	Texture = HQAAareaTex;
	AddressU = Clamp; AddressV = Clamp; AddressW = Clamp;
	MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};
sampler HQAAsearchSampler
{
	Texture = HQAAsearchTex;
	AddressU = Clamp; AddressV = Clamp; AddressW = Clamp;
	MipFilter = Point; MinFilter = Point; MagFilter = Point;
	SRGBTexture = false;
};

//////////////////////////////////////////////////////////// VERTEX SHADERS /////////////////////////////////////////////////////////////

void HQSMAAEdgeDetectionWrapVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position,
	out float2 texcoord : TEXCOORD0,
	out float4 offset[3] : TEXCOORD1)
{
	PostProcessVS(id, position, texcoord);
	SMAAEdgeDetectionVS(texcoord, offset);
}
void HQSMAABlendingWeightCalculationWrapVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position,
	out float2 texcoord : TEXCOORD0,
	out float2 pixcoord : TEXCOORD1,
	out float4 offset[3] : TEXCOORD2)
{
	PostProcessVS(id, position, texcoord);
	SMAABlendingWeightCalculationVS(texcoord, pixcoord, offset);
}
void HQSMAANeighborhoodBlendingWrapVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position,
	out float2 texcoord : TEXCOORD0,
	out float4 offset : TEXCOORD1)
{
	PostProcessVS(id, position, texcoord);
	SMAANeighborhoodBlendingVS(texcoord, offset);
}

//////////////////////////////////////////////////////////// PIXEL SHADERS //////////////////////////////////////////////////////////////

float4 GenerateImageColorShiftLeftWrapPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return GenerateImageColorShiftLeftPS(tex2D(HQAAcolorGammaSampler, texcoord));
}
float4 GenerateImageNegativeColorShiftLeftWrapPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return GenerateImageNegativeColorShiftLeftPS(tex2D(HQAAcolorGammaSampler, texcoord));
}
float4 GenerateImageColorShiftRightWrapPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return GenerateImageColorShiftRightPS(tex2D(HQAAcolorGammaSampler, texcoord));
}
float4 GenerateImageNegativeColorShiftRightWrapPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return GenerateImageNegativeColorShiftRightPS(tex2D(HQAAcolorGammaSampler, texcoord));
}
float4 GenerateImageNegativeWrapPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return GenerateImageNegativePS(tex2D(HQAAcolorGammaSampler, texcoord));
}

float2 HQSMAAEdgeDetectionWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float4 offset[3] : TEXCOORD1) : SV_Target
{
	return SMAALumaEdgeDetectionPS(texcoord, offset, HQAAcolorGammaSampler, HQAAcolorLinearSampler);
}
float2 HQSMAANegativeEdgeDetectionWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float4 offset[3] : TEXCOORD1) : SV_Target
{
	return SMAALumaEdgeDetectionPS(texcoord, offset, HQAAnegativeGammaSampler, HQAAnegativeGammaSampler);
}
float4 HQSMAABlendingWeightCalculationWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float2 pixcoord : TEXCOORD1,
	float4 offset[3] : TEXCOORD2) : SV_Target
{
	return SMAABlendingWeightCalculationPS(texcoord, pixcoord, offset, HQAAedgesSampler, HQAAareaSampler, HQAAsearchSampler, 0.0);
}
float4 HQSMAANeighborhoodBlendingWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float4 offset : TEXCOORD1) : SV_Target
{
	return SMAANeighborhoodBlendingPS(texcoord, offset, HQAAcolorLinearSampler, HQAAblendSampler);
}

float3 FXAAPixelShaderSMAADetectionPositives(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float TotalSubpix = __HQAA_SUBPIX * 0.375;
	if (__HQAA_BUFFER_MULTIPLIER < 1)
		TotalSubpix *= __HQAA_BUFFER_MULTIPLIER;
	
	float threshold = max(__FXAA_THRESHOLD_FLOOR,__HQAA_EDGE_THRESHOLD);
	
	float4 result = FxaaAdaptiveLumaPixelShader(texcoord,HQAAcolorGammaSampler,HQAAedgesSampler,BUFFER_PIXEL_SIZE,TotalSubpix,threshold,0.004,__FXAA_MODE_SMAA_DETECTION_POSITIVES);
	
	if (debugmode == 3 && debugFXAApass == 0) {
		bool validResult = abs(dot(result,float4(1,1,1,1)) - dot(tex2D(HQAAcolorGammaSampler,texcoord), float4(1,1,1,1))) > 1e-5;
		if (validResult)
			return result.rgb;
		else
			return float3(0.0, 0.0, 0.0);
	}
	else
		return result.rgb;
}
float3 FXAAPixelShaderSMAADetectionNegatives(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	// debugs 1 and 2 need to output from the last pass in the technique
	if (debugmode == 1)
		return tex2D(HQAAedgesSampler, texcoord).rgb;
	if (debugmode == 2)
		return tex2D(HQAAblendSampler, texcoord).rgb;
	
	float TotalSubpix = __HQAA_SUBPIX * 0.625;
	if (__HQAA_BUFFER_MULTIPLIER < 1)
		TotalSubpix *= __HQAA_BUFFER_MULTIPLIER;
	
	float threshold = max(__FXAA_THRESHOLD_FLOOR,__HQAA_EDGE_THRESHOLD);
	threshold = sqrt(threshold);
	
	float4 result = FxaaAdaptiveLumaPixelShader(texcoord,HQAAcolorGammaSampler,HQAAedgesSampler,BUFFER_PIXEL_SIZE,TotalSubpix,threshold,0.004,__FXAA_MODE_SMAA_DETECTION_NEGATIVES);
	
	if (debugmode == 3 && debugFXAApass == 1) {
		bool validResult = abs(dot(result,float4(1,1,1,1)) - dot(tex2D(HQAAcolorGammaSampler,texcoord), float4(1,1,1,1))) > 1e-5;
		if (validResult)
			return result.rgb;
		else
			return float3(0.0, 0.0, 0.0);
	}
	else
		return result.rgb;
}

float3 HQAACASWrapPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	return HQAACASPS(texcoord, HQAAedgesSampler, HQAAcolorLinearSampler);
}

/***************************************************************************************************************************************/
/*********************************************************** SHADER CODE END ***********************************************************/
/***************************************************************************************************************************************/

technique HQAA <
	ui_tooltip = "============================================================\n"
				 "Hybrid high-Quality Anti-Aliasing combines techniques of\n"
				 "both SMAA and FXAA to produce best possible image quality\n"
				 "from using both. HQAA uses customized edge detection methods\n"
				 "designed for maximum possible aliasing detection.\n"
				 "============================================================";
>
{
	pass SMAAEdgeDetection
	{
		VertexShader = HQSMAAEdgeDetectionWrapVS;
		PixelShader = HQSMAAEdgeDetectionWrapPS;
		RenderTarget = HQAAedgesTex;
		ClearRenderTargets = true;
		StencilEnable = true;
		StencilPass = REPLACE;
		StencilRef = 1;
	}
	pass GenerateBufferNegative
	{
		VertexShader = PostProcessVS;
		PixelShader = GenerateImageNegativeWrapPS;
		RenderTarget = HQAAnegativeTex;
		ClearRenderTargets = true;
	}
	pass SMAAalteredBufferEdgeDetection
	{
		VertexShader = HQSMAAEdgeDetectionWrapVS;
		PixelShader = HQSMAANegativeEdgeDetectionWrapPS;
		RenderTarget = HQAAedgesTex;
		ClearRenderTargets = false;
		BlendEnable = true;
		BlendOp = MAX;
		BlendOpAlpha = MAX;
		StencilEnable = true;
		StencilPass = REPLACE;
		StencilRef = 1;
	}
	pass GenerateBufferColorShiftRight
	{
		VertexShader = PostProcessVS;
		PixelShader = GenerateImageColorShiftRightWrapPS;
		RenderTarget = HQAAnegativeTex;
		ClearRenderTargets = true;
	}
	pass SMAAalteredBufferEdgeDetection
	{
		VertexShader = HQSMAAEdgeDetectionWrapVS;
		PixelShader = HQSMAANegativeEdgeDetectionWrapPS;
		RenderTarget = HQAAedgesTex;
		ClearRenderTargets = false;
		BlendEnable = true;
		BlendOp = MAX;
		BlendOpAlpha = MAX;
		StencilEnable = true;
		StencilPass = REPLACE;
		StencilRef = 1;
	}
	pass GenerateBufferColorShiftLeft
	{
		VertexShader = PostProcessVS;
		PixelShader = GenerateImageColorShiftLeftWrapPS;
		RenderTarget = HQAAnegativeTex;
		ClearRenderTargets = true;
	}
	pass SMAAalteredBufferEdgeDetection
	{
		VertexShader = HQSMAAEdgeDetectionWrapVS;
		PixelShader = HQSMAANegativeEdgeDetectionWrapPS;
		RenderTarget = HQAAedgesTex;
		ClearRenderTargets = false;
		BlendEnable = true;
		BlendOp = MAX;
		BlendOpAlpha = MAX;
		StencilEnable = true;
		StencilPass = REPLACE;
		StencilRef = 1;
	}
	pass GenerateBufferColorShiftRightNegative
	{
		VertexShader = PostProcessVS;
		PixelShader = GenerateImageNegativeColorShiftRightWrapPS;
		RenderTarget = HQAAnegativeTex;
		ClearRenderTargets = true;
	}
	pass SMAAalteredBufferEdgeDetection
	{
		VertexShader = HQSMAAEdgeDetectionWrapVS;
		PixelShader = HQSMAANegativeEdgeDetectionWrapPS;
		RenderTarget = HQAAedgesTex;
		ClearRenderTargets = false;
		BlendEnable = true;
		BlendOp = MAX;
		BlendOpAlpha = MAX;
		StencilEnable = true;
		StencilPass = REPLACE;
		StencilRef = 1;
	}
	pass GenerateBufferColorShiftLeftNegative
	{
		VertexShader = PostProcessVS;
		PixelShader = GenerateImageNegativeColorShiftLeftWrapPS;
		RenderTarget = HQAAnegativeTex;
		ClearRenderTargets = true;
	}
	pass SMAAalteredBufferEdgeDetection
	{
		VertexShader = HQSMAAEdgeDetectionWrapVS;
		PixelShader = HQSMAANegativeEdgeDetectionWrapPS;
		RenderTarget = HQAAedgesTex;
		ClearRenderTargets = false;
		BlendEnable = true;
		BlendOp = MAX;
		BlendOpAlpha = MAX;
		StencilEnable = true;
		StencilPass = REPLACE;
		StencilRef = 1;
	}
	pass SMAABlendWeightCalculation
	{
		VertexShader = HQSMAABlendingWeightCalculationWrapVS;
		PixelShader = HQSMAABlendingWeightCalculationWrapPS;
		RenderTarget = HQAAblendTex;
		ClearRenderTargets = true;
		StencilEnable = true;
		StencilPass = KEEP;
		StencilFunc = EQUAL;
		StencilRef = 1;
	}
	pass SMAANeighborhoodBlending
	{
		VertexShader = HQSMAANeighborhoodBlendingWrapVS;
		PixelShader = HQSMAANeighborhoodBlendingWrapPS;
		StencilEnable = false;
#if HDR_BACKBUFFER_IS_LINEAR
		SRGBWriteEnable = false;
#else
		SRGBWriteEnable = true;
#endif
	}
	pass FXAABlendPositives
	{
		VertexShader = PostProcessVS;
		PixelShader = FXAAPixelShaderSMAADetectionPositives;
	}
	pass FXAACheckNegatives
	{
		VertexShader = PostProcessVS;
		PixelShader = FXAAPixelShaderSMAADetectionNegatives;
	}
}

technique HQAACAS <
	ui_tooltip = "HQAA Optional CAS pass";
>
{
	pass CAS
	{
		VertexShader = PostProcessVS;
		PixelShader = HQAACASWrapPS;
#if HDR_BACKBUFFER_IS_LINEAR
		SRGBWriteEnable = false;
#else
		SRGBWriteEnable = true;
#endif
	}
}
