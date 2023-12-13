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
 *                               for ReShade 3.0+
 */

//------------------- Preprocessor Settings -------------------

#if !defined(SMAA_PRESET_LOW) && !defined(SMAA_PRESET_MEDIUM) && !defined(SMAA_PRESET_HIGH) && !defined(SMAA_PRESET_ULTRA)
#define SMAA_PRESET_CUSTOM // Do not use a quality preset by default
#endif

//----------------------- UI Variables ------------------------ 

#include "ReShadeUI.fxh"

uniform int EdgeDetectionType < __UNIFORM_COMBO_INT1
	ui_items = "Luminance edge detection\0Color edge detection\0Both, biasing Clarity\0Both, biasing Anti-Aliasing\0";
	ui_label = "Edge Detection Type";
> = 3;

#ifdef SMAA_PRESET_CUSTOM
uniform float EdgeDetectionThreshold < __UNIFORM_DRAG_FLOAT1
	ui_min = 0.05; ui_max = 0.2; ui_step = 0.001;
	ui_label = "Edge Detection Threshold";
> = 0.0625;

uniform int MaxSearchSteps < __UNIFORM_SLIDER_INT1
	ui_min = 1; ui_max = 112;
	ui_label = "Max Search Steps";
	ui_tooltip = "Determines the radius SMAA will search for aliased edges";
> = 112;

uniform int MaxSearchStepsDiagonal < __UNIFORM_SLIDER_INT1
	ui_min = 1; ui_max = 20;
	ui_label = "Max Search Steps Diagonal";
	ui_tooltip = "Determines the radius SMAA will search for diagonal aliased edges";
> = 20;

uniform int CornerRounding < __UNIFORM_SLIDER_INT1
	ui_min = 0; ui_max = 100;
	ui_label = "Corner Rounding";
	ui_tooltip = "Determines the percent of anti-aliasing to apply to corners";
> = 10;

uniform float ContrastAdaptationFactor < __UNIFORM_DRAG_FLOAT1
	ui_min = 1.0; ui_max = 8.0; ui_step = 0.01;
	ui_label = "Local Contrast Adaptation Factor";
	ui_tooltip = "Low values preserve detail, high values increase anti-aliasing effect";
> = 1.60;
#endif

uniform int DebugOutput < __UNIFORM_COMBO_INT1
	ui_items = "None\0View edges\0View weights\0";
	ui_label = "Debug Output";
> = false;

uniform float HqaaEdgeThresholdCustom <
	ui_type = "slider";
	ui_min = 0.02; ui_max = 1.0;
	ui_spacing = 3;
	ui_label = "Edge Detection Threshold";
	ui_tooltip = "Local contrast required to be considered an edge.\n\n"
				 "Recommended range: [0.05..0.15]";
	ui_category = "Global";
	ui_category_closed = true;
> = 0.05;

uniform float HqaaImageSoftenStrength <
	ui_type = "slider";
	ui_spacing = 3;
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.001;
	ui_label = "Softening Strength";
	ui_tooltip = "HQAA image softening measures error-controlled\n"
				"average differences for the neighborhood around\n"
				"every pixel to apply a subtle blur effect to the\n"
				"scene. Warning: may eat stars.\n\n"
				 "Recommended range: [0.0..0.1]";
	ui_category = "Image Softening";
	ui_category_closed = true;
> = 0.0;

uniform float HqaaImageSoftenOffset <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
	ui_label = "Sampling Offset";
	ui_tooltip = "Adjust this value up or down to expand or\n"
				 "contract the sampling patterns around the\n"
				 "central pixel. Effectively, this gives the\n"
				 "middle dot either less or more weight in\n"
				 "each sample pattern, causing the overall\n"
				 "result to look either more or less blurred.\n\n"
				 "Recommended range: [0.667..0.9]";
	ui_category = "Image Softening";
	ui_category_closed = true;
> = 0.666667;

uniform bool HqaaSoftenerSpuriousDetection <
	ui_label = "Spurious Pixel Correction";
	ui_tooltip = "Uses different blending strength when an\n"
				 "overly bright or dark pixel (compared to\n"
				 "its surroundings) is detected.\n\n"
				 "Recommended setting: enabled";
	ui_spacing = 3;
	ui_category = "Image Softening";
	ui_category_closed = true;
> = true;

uniform float HqaaSoftenerSpuriousThreshold <
	ui_label = "Detection Threshold";
	ui_tooltip = "Difference in contrast between the middle\n"
				 "pixel and the neighborhood around it to be\n"
				 "considered a spurious pixel\n\n"
				 "Recommended range: [0.1..0.2]";
	ui_min = 0.0; ui_max = 0.5; ui_step = 0.001;
	ui_type = "slider";
	ui_category = "Image Softening";
	ui_category_closed = true;
> = 0.125;

uniform float HqaaSoftenerSpuriousStrength <
	ui_label = "Spurious Softening Strength\n\n";
	ui_tooltip = "Overrides the base softening strength to this\n"
				 "when a pixel is flagged as spurious. Using\n"
				 "a strength >1.0 is only recommended when the\n"
				 "sampling offset is <1.0.\n\n"
				 "Recommended range: [0.75..1.0]";
	ui_type = "slider";
	ui_min = 0; ui_max = 2.0; ui_step = 0.001;
	ui_category = "Image Softening";
	ui_category_closed = true;
> = 1.0;

#ifdef SMAA_PRESET_CUSTOM
	#define SMAA_THRESHOLD EdgeDetectionThreshold
	#define SMAA_MAX_SEARCH_STEPS MaxSearchSteps
	#define SMAA_CORNER_ROUNDING CornerRounding
	#define SMAA_MAX_SEARCH_STEPS_DIAG MaxSearchStepsDiagonal
	#define SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR ContrastAdaptationFactor
#endif

#define SMAA_RT_METRICS float4(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT, BUFFER_WIDTH, BUFFER_HEIGHT)
#define SMAA_CUSTOM_SL 1
#define __HQAA_CONST_HALFROOT2 0.707107
#define __HQAA_BUFFER_MULT saturate(BUFFER_HEIGHT / 1440.)
#define __HQAA_THRESHOLD_FLOOR 0.0361
#define __HQAA_EDGE_THRESHOLD clamp(HqaaEdgeThresholdCustom, __HQAA_THRESHOLD_FLOOR, 1.00)
#define __HQAA_LUMA_REF float3(0.2126, 0.7152, 0.0722)

#define HQAA_Tex2D(tex, coord) tex2Dlod(tex, (coord).xyxy)

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

#define HQAAmax3(x,y,z) max(max(x,y),z)
#define HQAAmax10(q,r,s,t,u,v,w,x,y,z) max(max(max(max(q,r),max(s,t)),max(u,v)),max(max(w,x),max(y,z)))

#define HQAAmin3(x,y,z) min(min(x,y),z)
#define HQAAmin10(q,r,s,t,u,v,w,x,y,z) min(min(min(min(q,r),min(s,t)),min(u,v)),min(min(w,x),min(y,z)))

#if (__RENDERER__ == 0xb000 || __RENDERER__ == 0xb100)
	#define SMAAGather(tex, coord) tex2Dgather(tex, coord, 0)
#endif

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

// Vertex shaders

void SMAAEdgeDetectionWrapVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position,
	out float2 texcoord : TEXCOORD0,
	out float4 offset[3] : TEXCOORD1)
{
	PostProcessVS(id, position, texcoord);
	SMAAEdgeDetectionVS(texcoord, offset);
}
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
void SMAANeighborhoodBlendingWrapVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position,
	out float2 texcoord : TEXCOORD0,
	out float4 offset : TEXCOORD1)
{
	PostProcessVS(id, position, texcoord);
	SMAANeighborhoodBlendingVS(texcoord, offset);
}

// Pixel shaders

float2 SMAAEdgeDetectionWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float4 offset[3] : TEXCOORD1) : SV_Target
{
	if (EdgeDetectionType == 0)
		return SMAALumaEdgeDetectionPS(texcoord, offset, colorGammaSampler);
	else if (EdgeDetectionType == 1)
		return SMAAColorEdgeDetectionPS(texcoord, offset, colorGammaSampler);
	else if (EdgeDetectionType == 2)
		return (SMAAColorEdgeDetectionPS(texcoord, offset, colorGammaSampler) && SMAALumaEdgeDetectionPS(texcoord, offset, colorGammaSampler));
	else
		return ((SMAALumaEdgeDetectionPS(texcoord, offset, colorGammaSampler) + SMAAColorEdgeDetectionPS(texcoord, offset, colorGammaSampler))/2);
}
float4 SMAABlendingWeightCalculationWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float2 pixcoord : TEXCOORD1,
	float4 offset[3] : TEXCOORD2) : SV_Target
{
	return SMAABlendingWeightCalculationPS(texcoord, pixcoord, offset, edgesSampler, areaSampler, searchSampler, 0.0);
}

float3 SMAANeighborhoodBlendingWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float4 offset : TEXCOORD1) : SV_Target
{
	if (DebugOutput == 1)
		return tex2D(edgesSampler, texcoord).rgb;
	if (DebugOutput == 2)
		return tex2D(blendSampler, texcoord).rgb;

	return SMAANeighborhoodBlendingPS(texcoord, offset, colorLinearSampler, blendSampler).rgb;
}

float3 HQAASofteningPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float3 original = HQAA_Tex2D(ReShade::BackBuffer, texcoord).rgb;
    float4 edgedata = HQAA_Tex2D(edgesSampler, texcoord);
	bool lowdetail = !any(edgedata.rg);
    bool horiz = edgedata.g;
    bool possiblediag = lowdetail ? false : all(edgedata.rg);
    bool diag = false;
	float2 pixstep = 
		float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT) * 
		(lowdetail ? (clamp(HqaaImageSoftenOffset, 0.0, 4.0) * 0.5) : clamp(HqaaImageSoftenOffset, 0.0, 4.0)) * 
		__HQAA_BUFFER_MULT;
	float2 pixstepdiag = pixstep * __HQAA_CONST_HALFROOT2;
	bool highdelta = false;
	
	if (possiblediag)
	{
		bool4 nearbydiags = bool4(
			all(HQAA_Tex2D(edgesSampler, texcoord + float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT))), 
			all(HQAA_Tex2D(edgesSampler, texcoord - float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT))), 
			all(HQAA_Tex2D(edgesSampler, texcoord + float2(-BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT))), 
			all(HQAA_Tex2D(edgesSampler, texcoord + float2(BUFFER_RCP_WIDTH, -BUFFER_RCP_HEIGHT)))
		);
		diag = any(nearbydiags);
	}
	
// pattern:
//  e f g
//  h a b
//  i c d
	
	float3 a = original;
	float3 b = HQAA_Tex2D(ReShade::BackBuffer, texcoord + float2(pixstep.x, 0)).rgb;
	float3 c = HQAA_Tex2D(ReShade::BackBuffer, texcoord + float2(0, pixstep.y)).rgb;
	float3 d = HQAA_Tex2D(ReShade::BackBuffer, texcoord + pixstepdiag).rgb;
	float3 e = HQAA_Tex2D(ReShade::BackBuffer, texcoord - pixstepdiag).rgb;
	float3 f = HQAA_Tex2D(ReShade::BackBuffer, texcoord - float2(0, pixstep.y)).rgb;
	float3 g = HQAA_Tex2D(ReShade::BackBuffer, texcoord + float2(pixstepdiag.x, -pixstepdiag.y)).rgb;
	float3 h = HQAA_Tex2D(ReShade::BackBuffer, texcoord - float2(pixstep.x, 0)).rgb;
	float3 i = HQAA_Tex2D(ReShade::BackBuffer, texcoord + float2(-pixstepdiag.x, pixstepdiag.y)).rgb;
	float3 surroundavg = (b + c + d + e + f + g + h + i) / 8.0;
	
	if (HqaaSoftenerSpuriousDetection)
	{
    	float spuriousthreshold = rcp(__HQAA_EDGE_THRESHOLD * rcp(edgedata.a)) * saturate(HqaaSoftenerSpuriousThreshold);
		float middledelta = dot(abs(a - surroundavg), __HQAA_LUMA_REF);
		highdelta = middledelta > spuriousthreshold;
	}
	
	if (HqaaSoftenerSpuriousDetection && !highdelta && (HqaaImageSoftenStrength == 0.0)) return original;
	
	float3 highterm = float3(0.0, 0.0, 0.0);
	float3 lowterm = float3(1.0, 1.0, 1.0);
	
	float3 diag1;
	float3 diag2;
	float3 square;
	if (diag)
	{
		square = (h + f + c + b + a) / 5.0;
		diag1 = (e + d + a) / 3.0;
		diag2 = (g + i + a) / 3.0;
		highterm = HQAAmax3(highterm, diag1, diag2);
		lowterm = HQAAmin3(lowterm, diag1, diag2);
	}
	else square = (e + g + i + d + a) / 5.0;
	
	float3 x1;
	float3 x2;
	float3 x3;
	float3 xy1;
	float3 xy2;
	float3 xy3;
	float3 xy4;
	float3 box = (e + f + g + h + b + i + c + d + a) / 9.0;
	
	if (lowdetail)
	{
		x1 = (f + c + a) / 3.0;
		x2 = (h + b + a) / 3.0;
		x3 = surroundavg;
		xy1 = (e + d + a) / 3.0;
		xy2 = (i + g + a) / 3.0;
		xy3 = (e + f + g + i + c + d + a) / 7.0;
		xy4 = (e + h + i + g + b + d + a) / 7.0;
		square = (e + g + i + d + a) / 5.0;
	}
	else if (!horiz)
	{
		x1 = (e + h + i + a) / 4.0;
		x2 = (f + c + a) / 3.0;
		x3 = (g + b + d + a) / 4.0;
		xy1 = (e + c + a) / 3.0;
		xy2 = (g + c + a) / 3.0;
		xy3 = (f + i + a) / 3.0;
		xy4 = (f + d + a) / 3.0;
	}
	else
	{
		x1 = (e + f + g + a) / 4.0;
		x2 = (h + b + a) / 3.0;
		x3 = (i + c + d + a) / 4.0;
		xy1 = (h + g + a) / 3.0;
		xy2 = (h + d + a) / 3.0;
		xy3 = (b + e + a) / 3.0;
		xy4 = (b + i + a) / 3.0;
	}
	
	highterm = HQAAmax10(x1, x2, x3, xy1, xy2, xy3, xy4, box, square, highterm);
	lowterm = HQAAmin10(x1, x2, x3, xy1, xy2, xy3, xy4, box, square, lowterm);
	
	float3 localavg;
	if (!diag) localavg = ((x1 + x2 + x3 + xy1 + xy2 + xy3 + xy4 + square + box) - (highterm + lowterm)) / 7.0;
	else localavg = ((x1 + x2 + x3 + xy1 + xy2 + xy3 + xy4 + square + box + diag1 + diag2) - (highterm + lowterm)) / 9.0;
	
	return lerp(original, localavg, (highdelta ? clamp(HqaaSoftenerSpuriousStrength, 0.0, 4.0) : saturate(HqaaImageSoftenStrength)));
}

// Rendering passes

technique ASSMAA
{
	pass EdgeDetectionPass
	{
		VertexShader = SMAAEdgeDetectionWrapVS;
		PixelShader = SMAAEdgeDetectionWrapPS;
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
		VertexShader = PostProcessVS;
		PixelShader = HQAASofteningPS;
	}
}