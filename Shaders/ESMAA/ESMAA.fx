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

uniform bool ESMAAEnableSoftening <
	ui_label = "Enable softening";
	ui_category = "Image Softening";
> = true;

uniform float ESMAASofteningStrength <
	ui_type = "slider";
	ui_min = 0.05; ui_max = 1.0; ui_step = 0.01;
	ui_label = "Blend modifier";
	ui_spacing = 2;
	ui_tooltip = "The degree to which a pixel is blended with the surrounding pixels.\n"
				 "Higher values = more softening, especially on more anomalous pixels.";
	ui_category = "Image Softening";
> = 0.9;

uniform float ESMAASofteningBaseStrength <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 0.5; ui_step = 0.01;
	ui_label = "Minimum strength";
	ui_tooltip = "The minimum amount amount of blending./n"
				 "Higher values = more softening, even on less anomalous pixels";
	ui_category = "Image Softening";
> = 0.2;

uniform bool ESMAAAvgDiffBasedSoftening <
	ui_label = "Soften based on average difference.";
	ui_tooltip = "Makes it so that blending strength is dependent on the difference between the target pixel \n"
				"and all it's surrounding pixels, rather than just the largest difference. \n"
				"Better at preserving detail, but may look more aliased.";
	ui_category = "Image Softening";
	ui_spacing = 1;
> = true;

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

#define __TSMAA_BUFFER_INFO float4(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT, BUFFER_WIDTH, BUFFER_HEIGHT)

// #define HQAA_Tex2D(tex, coord) tex2Dlod(tex, (coord).xyxy)
// #define TSMAA_Tex2D(tex, coord) tex2Dlod(tex, (coord).xyxy)
// #define TSMAA_DecodeTex2DOffset(tex, coord, offset) tex2Dlodoffset(tex, (coord).xyxy, offset)

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


#define ESMAAmax4(w,x,y,z) max(max(w,x),max(y,z))
#define ESMAAmax9(r,s,t,u,v,w,x,y,z) max(max(max(max(r,s),t),max(u,v)),max(max(w,x),max(y,z)))

#define ESMAAmin9(r,s,t,u,v,w,x,y,z) min(min(min(min(r,s),t),min(u,v)),min(min(w,x),min(y,z)))

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

void TSMAANeighborhoodBlendingVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float4 offset : TEXCOORD1)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
    offset = mad(__TSMAA_BUFFER_INFO.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
	// offset.xy -> pixel to the left
	// offset.zw -> pixel to the bottom
}

float3 ESMAASofteningPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float4 offset : TEXCOORD1) : SV_Target
{
	float3 a, b, c, d;
	
	float4 m = float4(
		SMAASampleLevelZero(blendSampler, offset.xy).a, 
		SMAASampleLevelZero(blendSampler, offset.zw).g, 
		SMAASampleLevelZero(blendSampler, texcoord).zx
	); // right(?), bottom, right(?), left(?) 
	bool horiz = max(m.x, m.z) > max(m.y, m.w);
    bool earlyExit = !ESMAAEnableSoftening || dot(m, float4(1,1,1,1)) == 0.0;
	// if(earlyExit){ // this was actually less performant for some reason
	// 	discard;
	// }
	// float maxblending = ESMAASofteningStrength + (TsmaaBlendCalcBalance * jitteroffset * ESMAAmax4(m.r, m.g, m.b, m.a)) + ((1 - TsmaaBlendCalcBalance) * jitteroffset * (dot(m, float4(1,1,1,1)) / 4.0));
	// float maxblending = ESMAASofteningStrength + (0.8 * jitteroffset * ESMAAmax4(m.r, m.g, m.b, m.a)) + (0.2 * jitteroffset * (dot(m, float4(1,1,1,1)) / 4.0));

	// float jitteroffset = 1.0 - min(ESMAASofteningStrength * 2.0, 0.5);
	// using both the max of m and avg of m made little difference. avg of m was slightly better at preserving detail, so I went with that.
	// float maxblending = ESMAASofteningStrength + (jitteroffset * (dot(m, float4(1,1,1,1)) / 4.0)); 
	
// pattern:
//  e f g
//  h a b
//  i c d

#if __RENDERER__ >= 0xa000
	float4 cdbared = tex2Dgather(ReShade::BackBuffer, texcoord, 0);
	float4 cdbagreen = tex2Dgather(ReShade::BackBuffer, texcoord, 1);
	float4 cdbablue = tex2Dgather(ReShade::BackBuffer, texcoord, 2);
	a = float3(cdbared.w, cdbagreen.w, cdbablue.w);
	float3 original = a;
	if (earlyExit) return original;
	b = float3(cdbared.z, cdbagreen.z, cdbablue.z);
	c = float3(cdbared.x, cdbagreen.x, cdbablue.x);
	d = float3(cdbared.y, cdbagreen.y, cdbablue.y);
#else
	a = SMAASampleLevelZero(ReShade::BackBuffer, texcoord).rgb;
	float3 original = a;
	if (earlyExit) return original;
	b = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(1, 0)).rgb;
	c = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(0, 1)).rgb;
	d = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(1, 1)).rgb;
#endif
	float3 e = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, -1)).rgb;
	float3 f = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(0, -1)).rgb;
	float3 g = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(1, -1)).rgb;
	float3 h = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 0)).rgb;
	float3 i = SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 1)).rgb;
	
	float3 x1 = (e + f + g) / 3.0;
	float3 x2 = (h + a + b) / 3.0;
	float3 x3 = (i + c + d) / 3.0;
	float3 cap = (h + e + f + g + b) / 5.0;
	float3 bucket = (h + i + c + d + b) / 5.0;
	if (!horiz)
	{
		x1 = (e + h + i) / 3.0;
		x2 = (f + a + c) / 3.0;
		x3 = (g + b + d) / 3.0;
		cap = (f + e + h + i + c) / 5.0;
		bucket = (f + g + b + d + c) / 5.0;
	}
	float3 xy1 = (e + a + d) / 3.0;
	float3 xy2 = (i + a + g) / 3.0;
	float3 diamond = (h + f + c + b) / 4.0;
	float3 square = (e + g + i + d) / 4.0;
	
	float3 highterm = ESMAAmax9(x1, x2, x3, xy1, xy2, diamond, square, cap, bucket);
	float3 lowterm = ESMAAmin9(x1, x2, x3, xy1, xy2, diamond, square, cap, bucket);
	
	float3 localavg = ((a + x1 + x2 + x3 + xy1 + xy2 + diamond + square + cap + bucket) - (highterm + lowterm)) / 8.0;

	
	float maxblending;
	float weight;
	if(ESMAAAvgDiffBasedSoftening){
		const float piHalf = 1.5707;
		weight = dot(m, float4(1,1,1,1)) / 4.0;
		weight = weight * (2.0 - weight);
		weight = sin(weight * piHalf);
	} else {
		weight = ESMAAmax4(m.r, m.g, m.b, m.a);
		weight = weight * (2.0 - weight);
	}
	maxblending = (ESMAASofteningBaseStrength + ((1-ESMAASofteningBaseStrength) * weight)) * ESMAASofteningStrength;
	
	return lerp(original, localavg, maxblending);
}

// float3 ESMAASofteningPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float4 offset : TEXCOORD1) : SV_Target{
// 	if(TSMAASofteningTest){
// 		return TSMAASofteningPS(vpos,texcoord,offset);
// 	}
// 	return HQAASofteningPS(vpos, texcoord);
// }

// Rendering passes

technique ESMAA
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
		VertexShader = TSMAANeighborhoodBlendingVS;
		PixelShader = ESMAASofteningPS;
	}
}