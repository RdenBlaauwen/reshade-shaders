
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

// #include "../shared/lib.fxh" // Not necesssary as long as "ESMAACore.fxh" is included
#include "ESMAACore.fxh"

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
	ui_items = "None\0View edges\0View weights\0Depth Edge estimation\0 Simple Depth Edge estimation\0";
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
	ui_items = "None\0Filtered edges\0Local average\0";
	ui_label = "DepthPredicationMethod";
> = 2;

// Threshold for detecting edges around edges of geometric objects or even polygons
uniform float PredicationEdgeThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Predication Edge Threshold";
	ui_min = 0.020; ui_max = 0.050; ui_step = 0.001;
> = 0.030;

uniform float DepthEdgeDetectionThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Threshold for local avg";
	ui_min = 0.01; ui_max = 0.05; ui_step = 0.001;
	ui_tooltip = "Depth Edge detection threshold. If SMAA misses some edges try lowering this slightly.";
> = 0.02;

uniform float DepthEdgeDetectionThreshold2 < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Threshold for filtered edges";
	ui_min = 0.00001; ui_max = 0.001; ui_step = 0.00001;
	ui_tooltip = "Depth Edge detection threshold. If SMAA misses some edges try lowering this slightly.";
> = 0.00002;

uniform float DepthEdgeAvgDetectionThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "DepthEdgeAvgDetectionThresh";
	ui_min = 0.1; ui_max = 2.0; ui_step = 0.1;
> = 0.8;

uniform int ESMAADivider2 <
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

uniform float ESMAAThreshScaleFactor <
	ui_category = "Edge Detection";
	ui_type = "slider";
	ui_label = "Threshold scaling factor";
	ui_min = 0.8; ui_max = 3.0; ui_step = 0.1;
	ui_tooltip = "Lower values detect more in darker areas, but may cause artifacts and blur.";
> = 2.0;

uniform float ESMAAThresholdFloor <
	ui_type = "slider";
	ui_category = "Edge Detection";
	ui_label = "Threshold floor";
	ui_min = 0.1; ui_max = 0.5; ui_step = 0.01;
	ui_tooltip = "The lowest the threshold can go. Higher values help prevent artifacts and\n"
				 "blur, but may cause the shader to miss some jaggies in darker areas";
> = 0.21;

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

uniform bool ESMAAEnableSmoothing <
	ui_category = "Smoothing";
	ui_label = "Enable 'smoothing' AA";
> = true;

uniform float ESMAASmoothingMinStrength <
	ui_type = "slider";
	ui_category = "Smoothing";
	ui_label = "Minimum smoothing strength";
	ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
> = 0.0;

// creates max value for the `maxblending` var
uniform float ESMAASmoothingStrengthMod <
	ui_type = "slider";
	ui_category = "Smoothing";
	ui_label = "Strength modifier";
	ui_min = 0.0; ui_max = 1.25; ui_step = 0.01;
> = 1.0;

uniform uint ESMAASmoothingMaxIterations <
	ui_type = "slider";
	ui_category = "Smoothing";
	ui_label = "SmoothingMaxIterations";
	ui_min = 5; ui_max = 20; ui_step = 1;
> = 10;


// depths greater than this are considered part of the background/skybox
#define ESMAA_BACKGROUND_DEPTH_THRESHOLD 0.999
#define ESMAA_DEPTH_PREDICATION_THRESHOLD (0.000001 * pow(10,DepthEdgeAvgDetectionThreshold))
// weights for luma calculations
#define TSMAA_LUMA_REF float3(0.2126, 0.7152, 0.0722)

/**
 * SMAA preprocessor variables, from Lordbean's ASSMAA
 */
#ifdef SMAA_PRESET_CUSTOM
	#define SMAA_THRESHOLD EdgeDetectionThreshold
	#define SMAA_DEPTH_THRESHOLD DepthEdgeDetectionThreshold
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
#define __TSMAA_EDGE_THRESHOLD (PredicationEdgeThreshold)

#include "SMAA.fxh"
#include "ReShade.fxh"

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

// Used in the Softening pass to calculate the blending strength based
// float getBlendingStrength(float4 weightData, float weightAvg, float edgeAvg){
// 	float strength;
// 	if(ESMAAAnomalousPixelBlendingStrengthMethod == 1)
// 	{
// 		float maxWeight = Lib::max(weightData.r, weightData.g, weightData.b, weightData.a);
// 		strength = weightAvg * 0.4 + maxWeight * 0.6;
// 	} 
// 	else if(ESMAAAnomalousPixelBlendingStrengthMethod==2)
// 	{
// 		float maxWeight = Lib::max(weightData.r, weightData.g, weightData.b, weightData.a);
// 		strength = weightAvg * 0.7 + maxWeight * 0.3;
// 		strength = edgeAvg  * 0.2 + strength * 0.8;
// 	}
// 	else if(ESMAAAnomalousPixelBlendingStrengthMethod==3)
// 	{
// 		float maxWeight = Lib::max(weightData.r, weightData.g, weightData.b, weightData.a);
// 		strength = weightAvg * 0.4 + maxWeight * 0.6;
// 		strength = edgeAvg  * 0.3 + strength * 0.7;
// 	}
// 	else if(ESMAAAnomalousPixelBlendingStrengthMethod==4)
// 	{
// 		float maxWeight = Lib::max(weightData.r, weightData.g, weightData.b, weightData.a);
// 		strength = (edgeAvg  + maxWeight)/2.0;
// 	} 
// 	else {
// 		strength = weightAvg;
// 	}
// 	return strength;
// }

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
	const float2 edgeThreshold = float2(SMAA_THRESHOLD,SMAA_THRESHOLD);

	float2 threshold;
	if (DepthPredicationMethod > 0){
		// Threshold for geometric edges
		const float2 predicationThreshold = float2(PredicationEdgeThreshold, PredicationEdgeThreshold);

		float2 predication;
		if(DepthPredicationMethod == 1) {
			// Higher values = more confidence that an edge is there
			predication = ESMAACore::Predication::FilteredDepthPredication(
				texcoord, 
				offset, 
				ReShade::DepthBuffer, 
				DepthEdgeDetectionThreshold2,
				ESMAA_DEPTH_PREDICATION_THRESHOLD,
				false,
				false
			);
		} else if(DepthPredicationMethod == 2) {
			// Higher values = more confidence that an edge is there
			predication = ESMAACore::Predication::LocalAverageDepthPredication(
				texcoord, 
				offset, 
				ReShade::DepthBuffer, 
				SMAA_DEPTH_THRESHOLD,
				ESMAA_DEPTH_PREDICATION_THRESHOLD,
				false,
				false
			);
		}

		// The higher the predication values (certainty), the closer to predicationThreshold 
		threshold = lerp(edgeThreshold, predicationThreshold, Lib::max(predication));
	} else {
		// if no depth predication, the threshold is just the edge threshold.
		threshold = edgeThreshold;
		// threshold = 0.075;
	}


	if(EdgeDetectionMethod == 0){
		return ESMAACore::EdgeDetection::LumaDetection(
			texcoord, 
			offset, 
			colorGammaSampler, 
			threshold, 
			SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR, 
			ESMAAEnableAdaptiveThreshold, 
			ESMAAThresholdFloor, 
			ESMAAThreshScaleFactor
		);
	} else if(EdgeDetectionMethod == 1){
		return ESMAACore::EdgeDetection::ChromaDetection(
			texcoord, 
			offset, 
			colorGammaSampler, 
			threshold, 
			SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR, 
			ESMAAEnableAdaptiveThreshold, 
			ESMAAThresholdFloor, 
			ESMAAThreshScaleFactor
		);
	} else if(EdgeDetectionMethod == 2){
		return ESMAACore::EdgeDetection::EuclideanLumaDetection(
			texcoord, 
			offset, 
			colorGammaSampler, 
			threshold, 
			SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR, 
			ESMAAEnableAdaptiveThreshold, 
			ESMAAThresholdFloor, 
			ESMAAThreshScaleFactor
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
		ESMAAThresholdFloor, 
		ESMAAThreshScaleFactor
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
	if (DebugOutput == 3) {
		// construct a custom set of offsets suitable for LocalAverageDepthPredication(),
		// because it usually needs the offsets generated by SMAAEdgeDetectionWrapVS
		float4 edgeOffset[3];
		edgeOffset[0] = float4(-offset.x,offset.y,offset.z,-offset.w);
		edgeOffset[1] = float4(offset.x,offset.y,offset.z,offset.w);
		edgeOffset[2] = float4(-offset.x*2.0,offset.y,offset.z,-offset.w*2.0);

		float2 depthEdges = ESMAACore::Predication::LocalAverageDepthPredication(
			texcoord, 
			edgeOffset, 
			ReShade::DepthBuffer, 
			SMAA_DEPTH_THRESHOLD,
			ESMAA_DEPTH_PREDICATION_THRESHOLD,
			false,
			false
		);
		return float3(depthEdges, 0.0);
	}
	if (DebugOutput == 4) {
		// construct a custom set of offsets suitable for LocalAverageDepthPredication(),
		// because it usually needs the offsets generated by SMAAEdgeDetectionWrapVS
		float4 edgeOffset[3];
		edgeOffset[0] = float4(-offset.x,offset.y,offset.z,-offset.w);
		edgeOffset[1] = float4(offset.x,offset.y,offset.z,offset.w);
		edgeOffset[2] = float4(-offset.x*2.0,offset.y,offset.z,-offset.w*2.0);

		float2 depthEdges = ESMAACore::Predication::FilteredDepthPredication(
			texcoord, 
			edgeOffset, 
			ReShade::DepthBuffer, 
			DepthEdgeDetectionThreshold2,
			ESMAA_DEPTH_PREDICATION_THRESHOLD,
			false,
			false
		);
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
 * A little gem that combines well with SMAA, but not very performant.
 *
 * Adapted from Lordbean's TSMAA shader. 
 */
float3 TSMAASmoothingPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float4 offset : TEXCOORD1) : SV_Target
 {
	float2 midEdges = SMAASampleLevelZero(edgesSampler, texcoord).rg;

	float4 midWeights = float4(
		SMAASampleLevelZero(blendSampler, offset.xy).a, 
		SMAASampleLevelZero(blendSampler, offset.zw).g, 
		SMAASampleLevelZero(blendSampler, texcoord).zx
	);

	// Early return if no edges or weights found or smoothing is turned off.
	if(!ESMAAEnableSmoothing || (!any(midWeights)) && !any(midEdges)) discard;

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
    bool earlyExit = (range < __TSMAA_EDGE_THRESHOLD);
	if (earlyExit) return original;

	float lumaNW = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1,-1)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaSE = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 1, 1)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaNE = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 1,-1)).rgb, useluma, TSMAA_LUMA_REF);
    float lumaSW = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 1)).rgb, useluma, TSMAA_LUMA_REF);

	// These vals serve as caches, so they can be used later without having to redo them
	// It's just an optimisation thing
	float lumaNWSW = lumaNW + lumaSW;
	float lumaNS = lumaN + lumaS;
	float lumaNESE = lumaNE + lumaSE;
	float lumaSWSE = lumaSW + lumaSE;
	float lumaWE = lumaW + lumaE;
	float lumaNWNE = lumaNW + lumaNE;
	
    bool horzSpan = (abs(mad(-2.0, lumaW, lumaNWSW)) + mad(2.0, abs(mad(-2.0, lumaM, lumaNS)), abs(mad(-2.0, lumaE, lumaNESE)))) >= (abs(mad(-2.0, lumaS, lumaSWSE)) + mad(2.0, abs(mad(-2.0, lumaM, lumaWE)), abs(mad(-2.0, lumaN, lumaNWNE))));	
    float lengthSign = horzSpan ? BUFFER_RCP_HEIGHT : BUFFER_RCP_WIDTH;
	
	bool smaahoriz = max(midWeights.x, midWeights.z) > max(midWeights.y, midWeights.w);
    bool smaadata = Lib::any(midWeights);
	float maxblending = 0.5 + (0.5 * Lib::max(midWeights.r, midWeights.g, midWeights.b, midWeights.a));
	if (((horzSpan) && ((smaahoriz) && (smaadata))) || ((!horzSpan) && ((!smaahoriz) && (smaadata)))) maxblending *= 0.5;
    else maxblending = min(maxblending * 1.5, 1.0);

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
				// lumaEndN = dotweightopt(mid, posN, useluma);
				lumaEndN = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posN).rgb, useluma, TSMAA_LUMA_REF);
				lumaEndN -= lumaNN;
				doneN = abs(lumaEndN) >= gradientScaled;
			}
			if (!doneP)
			{
				posP += offNP;
				// lumaEndP = dotweightopt(mid, posP, useluma);
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
	maxblending = max(maxblending, ESMAASmoothingMinStrength) * ESMAASmoothingStrengthMod;
	
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
	
	// Various shapes that can be present
	float3 x1 = (e + f + g) / 3.0;
	float3 x2 = (h + a + b) / 3.0;
	float3 x3 = (i + c + d) / 3.0;
	float3 cap = (h + e + f + g + b) / 5.0;
	float3 bucket = (h + i + c + d + b) / 5.0;
	float3 xy1 = (e + a + d) / 3.0;
	float3 xy2 = (i + a + g) / 3.0;
	float3 diamond = (h + f + c + b) / 4.0;
	float3 square = (e + g + i + d) / 4.0;
	
	// Get the most divergent shapes..
	float3 highterm = Lib::max(x1, x2, x3, xy1, xy2, diamond, square, cap, bucket);
	float3 lowterm = Lib::min(x1, x2, x3, xy1, xy2, diamond, square, cap, bucket);
	// ...and subtract them from the average of all shapes
	float3 localavg = ((a + x1 + x2 + x3 + xy1 + xy2 + diamond + square + cap + bucket) - (highterm + lowterm)) / 8.0;

	// Calculate strength by # of edges above 1
	float strength = signifEdges / 3.0; 

	// calculate # of corners
	float corners = (edgeData.r + edgeData.b) * (edgeData.g + edgeData.a);
	
	// Reduce strength for straight lines of 1 pixel thick and their endings, to preserve detail
	const float LINE_PRESERVATION_FACTOR = 0.6; // TODO: consider turning into preprocessor constant and adding ui
	strength *= (corners == 0.0 || corners == 2.0) ? LINE_PRESERVATION_FACTOR : 1.0;

	// Calculate blend strength based on weight and edge data
	float scaledStrength = scaleSofteningStrength(strength);
	float maxblending = scaledStrength * ESMAASofteningStrength;
	
	return lerp(original, localavg, maxblending);
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
		PixelShader = TSMAASmoothingPS;
	}
}
