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
	ui_items = "Luminance edge detection\0Color edge detection\0Both, biasing Clarity\0Both, biasing Anti-Aliasing\0Experimental adaptive luma\0";
	ui_label = "Edge Detection Type";
	ui_tooltip = "Experimental adaptive luma only does special stuff if you enable adaptive threshold stuff";
> = 4;

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

uniform bool ESMAAEnableAdaptiveThreshold <
	ui_label = "Enable adaptive threshold";
> = false;

uniform bool ESMAAEnableAdaptiveThresholdExtraPrecision <
	ui_label = "adaptive threshold extra precision";
> = false;

uniform int DebugOutput < __UNIFORM_COMBO_INT1
	ui_items = "None\0View edges\0View weights\0";
	ui_label = "Debug Output";
> = false;

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


// uniform float ESMAABackgroundDepth <
// 	ui_type = "slider";
// 	ui_min = 0.8; ui_max = 0.999; ui_step = 0.001;
// 	ui_label = "Background threshold";
// 	ui_spacing = 2;
// 	ui_tooltip = "The maximum depth where softening is performed. Pixels at greater depth than this \n"
// 				 "are considered part of the background texture and will be skipped. The default should\n"
// 				 " work fine for most games, but you can adjust it if necessary.";
// 	ui_category = "Image Softening";
// > = 0.999;

uniform int ESMAAAnomalousPixelBlendingStrengthMethod < __UNIFORM_COMBO_INT1
	ui_category = "Image Softening";
	ui_items = "Strongly favor precision\0Favor precision\0Balanced\0Favor softening\0Strongly favor softening\0";
	ui_label = "Softening method";
	ui_tooltip = "This determines how the degree by which a pixel differs from it's surroundings is calculated.\n"
				 "\n"
				 "Methods that favor precision are conservative and only target the bigger outliers.\n"
				 "Recommended for people who like crisp images and just want to filter out extremes.\n"
				 "\n"
				 "Methods that favor softening are aggressive and even target pixels that differ slightly.\n"
				 "Recommended for people who like smooth images and don't mind risking blurriness.";
> = 2;

uniform int ESMAAAnomalousPixelScaling < __UNIFORM_COMBO_INT1
	ui_items = "Subtle\0Balanced\0Agressive\0";
	ui_label = "Strength scaling";
	ui_tooltip = "This determines how softening strength scales with the degree\n"
				"by which a pixel differs from it's surroundings.";
	ui_category = "Image Softening";
> = 1;

uniform int ESMAADivider <
	ui_category = "Image Softening";
	ui_type = "radio";
	ui_label = " ";
>;

uniform float ESMAASofteningBaseStrength <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 0.5; ui_step = 0.01;
	ui_label = "Minimum blending";
	ui_tooltip = "The minimum amount amount of blending./n"
				 "Higher values = more softening, even on less anomalous pixels";
	ui_category = "Image Softening";
> = 0.15;

uniform float ESMAASofteningStrength <
	ui_type = "slider";
	ui_min = 0.05; ui_max = 1.0; ui_step = 0.01;
	ui_label = "Blending strength";
	ui_tooltip = "The degree in which the final result is blended with the image.\n"
				 "Lower values = weaker effect.";
	ui_category = "Image Softening";
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

// depths greater than this are considered part of the background/skybox
#define ESMAA_BACKGROUND_DEPTH_THRESHOLD 0.999

#define ESMAAmax4(w,x,y,z) max(max(w,x),max(y,z))
#define ESMAAmax9(r,s,t,u,v,w,x,y,z) max(max(max(max(r,s),t),max(u,v)),max(max(w,x),max(y,z)))

#define ESMAAmin4(w,x,y,z) min(min(w,x),min(y,z))
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

float sum(float4 vc){
	return vc.x + vc.y + vc.z + vc.w;
}

float avg(float4 vc){
	return sum(vc) / 4.0;
}

// Used in the Softening pass to calculate the blending strength based
float getBlendingStrength(float4 weightData, float weightAvg, float edgeAvg){
	float strength;
	if(ESMAAAnomalousPixelBlendingStrengthMethod == 1)
	{
		float maxWeight = ESMAAmax4(weightData.r, weightData.g, weightData.b, weightData.a);
		strength = weightAvg * 0.4 + maxWeight * 0.6;
	} 
	else if(ESMAAAnomalousPixelBlendingStrengthMethod==2)
	{
		float maxWeight = ESMAAmax4(weightData.r, weightData.g, weightData.b, weightData.a);
		strength = weightAvg * 0.7 + maxWeight * 0.3;
		strength = edgeAvg  * 0.2 + strength * 0.8;
	}
	else if(ESMAAAnomalousPixelBlendingStrengthMethod==3)
	{
		float maxWeight = ESMAAmax4(weightData.r, weightData.g, weightData.b, weightData.a);
		strength = weightAvg * 0.4 + maxWeight * 0.6;
		strength = edgeAvg  * 0.3 + strength * 0.7;
	}
	else if(ESMAAAnomalousPixelBlendingStrengthMethod==4)
	{
		float maxWeight = ESMAAmax4(weightData.r, weightData.g, weightData.b, weightData.a);
		strength = (edgeAvg  + maxWeight)/2.0;
	} 
	else {
		strength = weightAvg;
	}
	return strength;
}

/**
 * @SCALE_LINEAR
 * Meant for turning linear values super-linear: Makes it's input bigger in such a way that lower values become 
 * proportionally bigger than higher values. Output never exceeds 1.0;
 *
 * @param `val` input to be scaled
 * @return output val. Amplified in a non-linear fashion.
 */
float scale(float val){
    const float piHalf = 1.5707;
	return val = sin(val * piHalf);
}

/** 
 * Optionally scales the blending strength (ssee @SCALE_LINEAR).
 * Scaling depends on the value of `ESMAAAnomalousPixelScaling`.
 * 
 * @param `strength` The linear input strength 
 * @return The output strength. Same as input strength when `ESMAAAnomalousPixelScaling` is below 1.
 * 		   Amplified in a non-linear fashion when `ESMAAAnomalousPixelScaling` >= 1
 */
float scaleStrength(float strength){
	if(ESMAAAnomalousPixelScaling >= 1){ // Balanced
		// strength = strength * (2.0 - strength); // Tests turned out this was slower
		strength = scale(strength);
	}
	// no else-if, because it is a cumulative effect
	if(ESMAAAnomalousPixelScaling >= 2){ // Aggressive
		strength = scale(strength);
	}
	return strength;
}

//////////////////////////////// VERTEX SHADERS ////////////////////////////////

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

/**
 * Taken from Lordbean's TSMAA shader. For more credits, see description above.
 */
void ESMAABlendingVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float4 offset : TEXCOORD1)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
    offset = mad(SMAA_RT_METRICS.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
	// offset.xy -> pixel to the left
	// offset.zw -> pixel to the bottom
}

//////////////////////////////// PIXEL SHADERS (MUST BE WRAPPED) ////////////////////////////////
/**
 * Luma Edge Detection
 *
 * IMPORTANT NOTICE: luma edge detection requires gamma-corrected colors, and
 * thus 'colorTex' should be a non-sRGB texture.
 */
float2 CustomLumaEdgeDetectionPS(float2 texcoord,
                               float4 offset[3],
                               SMAATexture2D(colorTex)
                               ) {
    // Calculate lumas:
    float3 weights = float3(0.2126, 0.7152, 0.0722);
    float L = dot(SMAASamplePoint(colorTex, texcoord).rgb, weights);

    float Lleft = dot(SMAASamplePoint(colorTex, offset[0].xy).rgb, weights);
    float Ltop  = dot(SMAASamplePoint(colorTex, offset[0].zw).rgb, weights);

		float maxLuma = max(L, max(Lleft, Ltop));
		float2 threshold;
		if(ESMAAEnableAdaptiveThreshold){
			// scaled maxLuma so that only dark places have a significantly lower threshold
			maxLuma = scale(maxLuma);

			// Calculate the threshold
			// Multiplying by maxLuma should scale the threshold according to the maximum local brightness
    	threshold = float2(SMAA_THRESHOLD, SMAA_THRESHOLD) * maxLuma;
		} else {
    	threshold = float2(SMAA_THRESHOLD, SMAA_THRESHOLD);
		}

    // We do the usual threshold:
    float4 delta;
    delta.xy = abs(L - float2(Lleft, Ltop));
    float2 edges = step(threshold, delta.xy);

    // Then discard if there is no edge:
    if (dot(edges, float2(1.0, 1.0)) == 0.0)
        discard;

    // Calculate right and bottom deltas:
    float Lright = dot(SMAASamplePoint(colorTex, offset[1].xy).rgb, weights);
    float Lbottom  = dot(SMAASamplePoint(colorTex, offset[1].zw).rgb, weights);
    delta.zw = abs(L - float2(Lright, Lbottom));

    // Calculate the maximum delta in the direct neighborhood:
    float2 maxDelta = max(delta.xy, delta.zw);

    // Calculate left-left and top-top deltas:
    float Lleftleft = dot(SMAASamplePoint(colorTex, offset[2].xy).rgb, weights);
    float Ltoptop = dot(SMAASamplePoint(colorTex, offset[2].zw).rgb, weights);
    delta.zw = abs(float2(Lleft, Ltop) - float2(Lleftleft, Ltoptop));

    // Calculate the final maximum delta:
    maxDelta = max(maxDelta.xy, delta.zw);
    float finalDelta = max(maxDelta.x, maxDelta.y);

    // Local contrast adaptation:
    edges.xy *= step(finalDelta, SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR * delta.xy);

		if(ESMAAEnableAdaptiveThresholdExtraPrecision){
			// take ALL lumas into account this time
			float finalMaxLuma = max(maxLuma, max(Lright, max(Lbottom,max(Lleftleft,Ltoptop))));
			// scaled maxLuma so that only dark places have a significantly lower threshold
			finalMaxLuma = scale(finalMaxLuma);

			// Calculate the threshold
			// Multiplying by maxLuma should scale the threshold according to the maximum local brightness
    	threshold = float2(SMAA_THRESHOLD, SMAA_THRESHOLD) * finalMaxLuma;
    	edges = step(threshold, delta.xy);
		}

    return edges;
}

//////////////////////////////// PIXEL SHADERS (WRAPPERS) ////////////////////////////////

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
	else if (EdgeDetectionType == 3)
		return CustomLumaEdgeDetectionPS(texcoord, offset, colorGammaSampler);
	else
		return ((SMAALumaEdgeDetectionPS(texcoord, offset, colorGammaSampler) + SMAAColorEdgeDetectionPS(texcoord, offset, colorGammaSampler))/2);
}

float4 TestBlendingWeightPS(float2 texcoord : TEXCOORD0) : SV_TARGET
{
	return float4(0.25,0.5,0.75,1.0);
}

float4 SMAABlendingWeightCalculationWrapPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float2 pixcoord : TEXCOORD1,
	float4 offset[3] : TEXCOORD2) : SV_Target
{
	// return TestBlendingWeightPS(texcoord);
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

/**
 * A modified version of Lordbean's Softening pass, taken from his TSMAA shader.
 * It works by averaging divergent pixels with their surroundings.
 * 
 * - modified the way weights are collected, by only collecting from the current pixel
 * - removed detection of horizontal pixels, as it didn't make a difference visually
 * - added edge data to be considered as well
 * - Boosted the contribution that weight and edge data use to the final blending strength
 * - added several different, optional ways to determine blend strength from edge and weight data
 * 
 * For more credits, see description above.
 */
float3 ESMAASofteningPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float4 offset : TEXCOORD1) : SV_Target
{
	float3 a, b, c, d;
	
	// The way this data is collected is probably wrong, considering official SMAA code does it differently. 
	// weightData for instance should be something like:
	// float4 weightData = float4(
	// 	SMAASampleLevelZero(blendSampler, offset.xy).a, // Right
	// 	SMAASampleLevelZero(blendSampler, offset.zw).g, // Top
	// 	SMAASampleLevelZero(blendSampler, texcoord).xz // Bottom / Left
	// ); 
	// but for some reason, the below implementation seems to yield better results as far as I can see.
	// TODO: See if these two can be replaced with something that makes sense
	float4 weightData = SMAASampleLevelZero(blendSampler, texcoord).xyzw;
	float4 edgeData = float4(
		SMAASampleLevelZero(edgesSampler, texcoord).rg,
		SMAASampleLevelZero(edgesSampler, offset.xy).r, 
		SMAASampleLevelZero(edgesSampler, offset.zw).g
	); 

	float weightSum = sum(weightData);
	float edgeSum = sum(edgeData);
    bool noDelta = (weightSum + edgeSum) == 0.0;

	// If background softening is disabled, return early if 
	// the pixel's depth corresponds with the background depth.
	float depth = ReShade::GetLinearizedDepth(texcoord);
	bool background = ESMAADisableBackgroundSoftening && depth > ESMAA_BACKGROUND_DEPTH_THRESHOLD;


	bool earlyReturn = !ESMAAEnableSoftening || noDelta || background;
	
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
	if (earlyReturn) return original;
	b = float3(cdbared.z, cdbagreen.z, cdbablue.z);
	c = float3(cdbared.x, cdbagreen.x, cdbablue.x);
	d = float3(cdbared.y, cdbagreen.y, cdbablue.y);
#else // if DX9
	a = SMAASampleLevelZero(ReShade::BackBuffer, texcoord).rgb;
	float3 original = a;
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
	float3 highterm = ESMAAmax9(x1, x2, x3, xy1, xy2, diamond, square, cap, bucket);
	float3 lowterm = ESMAAmin9(x1, x2, x3, xy1, xy2, diamond, square, cap, bucket);
	// ...and subtract them from the average of all shapes
	float3 localavg = ((a + x1 + x2 + x3 + xy1 + xy2 + diamond + square + cap + bucket) - (highterm + lowterm)) / 8.0;

	float weightAvg = weightSum / 4.0;
	float edgeAvg = edgeSum / 4.0;

	// Calculate blend strength based on weight and edge data
	float strength = getBlendingStrength(weightData, weightAvg, edgeAvg);
	// Optional scaling, so less deviant pixels get softened too
	float scaledStrength = scaleStrength(strength);
	float maxblending = (ESMAASofteningBaseStrength + ((1-ESMAASofteningBaseStrength) * scaledStrength)) * ESMAASofteningStrength;
	
	return lerp(original, localavg, maxblending);
}

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
		VertexShader = ESMAABlendingVS;
		PixelShader = ESMAASofteningPS;
	}
}