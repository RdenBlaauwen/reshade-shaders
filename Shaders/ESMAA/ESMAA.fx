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

#include "../shared/lib.fxh"
// #include "ESMAACore.fxh"

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
	ui_items = "None\0View edges\0View weights\0Depth Edge estimation\0";
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

uniform bool ESMAAEnableLumaEdgeDetection <
	ui_category = "Edge Detection";
	ui_label = "EnableLumaEdgeDetection";
> = true;

uniform bool ESMAAEnableChromaEdgeDetection <
	ui_category = "Edge Detection";
	ui_label = "EnableChromaEdgeDetection";
> = true;

uniform bool ESMAAEnableDepthEdgeDetection <
	ui_category = "Edge Detection";
	ui_label = "EnableDepthEdgeDetection";
> = true;

uniform bool ESMAADepthPredicationAntiNeighbourCheck <
	ui_category = "Edge Detection";
	ui_label = "DepthPredicationAntiNeighbourCheck";
> = true;

uniform bool ESMAADepthPredicationSymmetric <
	ui_category = "Edge Detection";
	ui_label = "DepthPredicationSymmetric";
> = false;

uniform float EdgeDetectionThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Edge Detection Threshold";
	ui_min = 0.02; ui_max = 0.2; ui_step = 0.001;
> = 0.075;

uniform float DepthEdgeDetectionThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Depth Edge Detection Threshold";
	ui_min = 0.0001; ui_max = 0.10; ui_step = 0.0001;
	ui_tooltip = "Depth Edge detection threshold. If SMAA misses some edges try lowering this slightly.";
> = 0.01;

uniform float DepthEdgeAvgDetectionThreshold < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "DepthEdgeAvgDetectionThresh";
	ui_min = 0.1; ui_max = 10.0; ui_step = 0.1;
> = 2.0;

uniform float DepthAntiSymmetryThresh <
	ui_category = "Edge Detection";
	ui_type = "slider";
	ui_label = "DepthAntiSymmetryThresh";
	ui_min = 0.000000001; ui_max = 0.001; ui_step = 0.000000001;
> = 0.0001;

uniform float ContrastAdaptationFactor < __UNIFORM_DRAG_FLOAT1
	ui_category = "Edge Detection";
	ui_label = "Local Contrast Adaptation Factor";
	ui_min = 1.5; ui_max = 4.0; ui_step = 0.1;
	ui_tooltip = "High values increase anti-aliasing effect, but may increase artifacts.";
> = 2.0;

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
> = 1.5;

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
> = 1;

uniform int ESMAAAnomalousPixelScaling < __UNIFORM_COMBO_INT1
	ui_items = "Subtle\0Balanced\0Agressive\0";
	ui_label = "Strength scaling";
	ui_tooltip = "This determines how softening strength scales with the degree\n"
				"by which a pixel differs from it's surroundings.";
	ui_category = "Image Softening";
> = 2;

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
> = 0.05;

uniform float ESMAASofteningStrength <
	ui_type = "slider";
	ui_min = 0.05; ui_max = 1.0; ui_step = 0.01;
	ui_label = "Blending strength";
	ui_tooltip = "The degree in which the final result is blended with the image.\n"
				 "Lower values = weaker effect.";
	ui_category = "Image Softening";
> = 1.0;

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

// depths greater than this are considered part of the background/skybox
#define ESMAA_BACKGROUND_DEPTH_THRESHOLD 0.999
#define ESMAA_DEPTH_PREDICATION_THRESHOLD (0.000001 * pow(10,DepthEdgeAvgDetectionThreshold))
// weights for luma calculations
#define SMAA_LUMA_REF float3(0.2126, 0.7152, 0.0722)
#define __TSMAA_EDGE_THRESHOLD (EdgeDetectionThreshold)

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

// Used in the Softening pass to calculate the blending strength based
float getBlendingStrength(float4 weightData, float weightAvg, float edgeAvg){
	float strength;
	if(ESMAAAnomalousPixelBlendingStrengthMethod == 1)
	{
		float maxWeight = Lib::max(weightData.r, weightData.g, weightData.b, weightData.a);
		strength = weightAvg * 0.4 + maxWeight * 0.6;
	} 
	else if(ESMAAAnomalousPixelBlendingStrengthMethod==2)
	{
		float maxWeight = Lib::max(weightData.r, weightData.g, weightData.b, weightData.a);
		strength = weightAvg * 0.7 + maxWeight * 0.3;
		strength = edgeAvg  * 0.2 + strength * 0.8;
	}
	else if(ESMAAAnomalousPixelBlendingStrengthMethod==3)
	{
		float maxWeight = Lib::max(weightData.r, weightData.g, weightData.b, weightData.a);
		strength = weightAvg * 0.4 + maxWeight * 0.6;
		strength = edgeAvg  * 0.3 + strength * 0.7;
	}
	else if(ESMAAAnomalousPixelBlendingStrengthMethod==4)
	{
		float maxWeight = Lib::max(weightData.r, weightData.g, weightData.b, weightData.a);
		strength = (edgeAvg  + maxWeight)/2.0;
	} 
	else {
		strength = weightAvg;
	}
	return strength;
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
		strength = Lib::sineScale(strength);
	}
	// no else-if, because it is a cumulative effect
	if(ESMAAAnomalousPixelScaling >= 2){ // Aggressive
		strength = Lib::sineScale(strength);
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
void TSMAANeighborhoodBlendingVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float4 offset : TEXCOORD1)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
    offset = mad(SMAA_RT_METRICS.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
	// offset.xy -> pixel to the left
	// offset.zw -> pixel to the bottom
}

//////////////////////////////// EDGE DETECTION FUNCTIONS (MUST BE WRAPPED) ////////////////////////////////

/**
 * This function is meant for edge predication. It detects geometric edges using depth-detection with high accuracy, but in a symmetric fashion.
 * Which means it detects pixels around both sides of edges. This ironically makes it pretty bad for real edge detecion,
 * but potentially great for edge predication. I like to call it "edge prediction".
 * 
 * It works in two phases. First it does conventional edge-based edge detection. If this finds anything, it returns early.
 * Otherwise it continues to do the "edge prediction" as described above. 
 * 
 * Strange as it may sound, this is actually a highly modified version of Lordbean's image softening,
 * adapted to use depth info instead. Worked like a charm
 * 
 * @param float2 texcoord coordinates of current texel, just like edge detection functions
 * @param float4 offset[3] contains coordinates of 6 neighboring texels, equal to the ones used in edge detection functions
 * @return float2 contains 2 numbers (RG channels) representing left and top edge, ranging from 0.0 - 1.0. 
 * 	1.0 meaning a geometric edge is definitely there
 *	0.0 meaning there is no geometric edge
 *	anything in between is a "maybe".
 *
 * Warning: if this fucntion returns a 1.0 somewhere it should not be assumed there is definitively an edge, as there is sometimes
 * a disconnect between geometric and visual info.
 * Warning: do NOT use this as a true edge-detection algo. It WILL lead to false positives and artifacts!
 */
float2 DepthEdgeEstimation(float2 texcoord, float4 offset[3])
{
	// pattern:
	//  e f g
	//  h a b
	//  i c d
	float e,f,h,a, original;

	#if __RENDERER__ >= 0xa000 // if DX10 or above
		// get RGB values from the c, d, b, and a positions, in order.
		float4 hafe = tex2Dgatheroffset(ReShade::DepthBuffer, texcoord, int2(-1, -1), 0);
		e = hafe.w;
		f = hafe.z;
		h = hafe.x;
		a = hafe.y;
		original = a;
	#else // if DX9
		e = SMAASampleLevelZeroOffset(ReShade::DepthBuffer, texcoord, int2(-1, -1)).r;
		f = SMAASampleLevelZeroOffset(ReShade::DepthBuffer, texcoord, int2(0, -1)).r;
		h = SMAASampleLevelZeroOffset(ReShade::DepthBuffer, texcoord, int2(-1, 0)).r;
		a = SMAASampleLevelZero(ReShade::DepthBuffer, texcoord).r;
		original = a;
	#endif


	float currDepth = Lib::linearizeDepth(a);
	float topDepth = Lib::linearizeDepth(f);
	float leftDepth = Lib::linearizeDepth(h);

	// TODO: refactor this: encapsulate into method for this kind of scaling
	float depthScaling = (0.3 + (0.7 * currDepth * (5 - ((5 + 0.3) * currDepth))));
	float detectionThreshold = SMAA_DEPTH_THRESHOLD * depthScaling;

	float3 neighbours = float3(currDepth, leftDepth, topDepth);
	float2 delta = abs(neighbours.xx - float2(neighbours.y, neighbours.z));
	float2 edges = step(detectionThreshold, delta);
	bool anyEdges = Lib::any(edges);

	// bool surface = false;
	// if(ESMAADepthDataSurfaceCheck && anyEdges){
	// 	float2 farDeltas;
	// 	if(edges.r > 0.0){
	// 		float hLeft = SMAASampleLevelZeroOffset(ReShade::DepthBuffer, texcoord, int2(-2, 0)).r;
	// 		float leftLeftDepth = Lib::linearizeDepth(hLeft);
	// 		farDeltas.r = abs(leftDepth - leftLeftDepth);
	// 	}
	// 	if(edges.g > 0.0){
	// 		float fTop = SMAASampleLevelZeroOffset(ReShade::DepthBuffer, texcoord, int2(0, -2)).r;
	// 		float topTopDepth = Lib::linearizeDepth(fTop);
	// 		farDeltas.g = abs(topDepth - topTopDepth);
	// 	}
	// 	float2 farEdges = step(detectionThreshold,farDeltas);
	// 	surface = dot(farEdges, float2(1.0,1.0)) > 0.0;
	// }

	// Early return if there is an edge:
    // if (!surface && anyEdges)
    //     return edges;

	if (anyEdges)
        return edges;

	float factor = a + saturate(0.001 - a) * 2.0;
	float predictionThreshold = ESMAA_DEPTH_PREDICATION_THRESHOLD * factor;

	float b,c,d;
	#if __RENDERER__ >= 0xa000 // if DX10 or above
		// get RGB values from the c, d, b, and a positions, in order.
		float4 cdba = tex2Dgather(ReShade::DepthBuffer, texcoord, 0);
		b = cdba.z;
		c = cdba.x;
		d = cdba.y;
	#else // if DX9
		b = SMAASampleLevelZeroOffset(ReShade::DepthBuffer, texcoord, int2(1, 0)).r;
		c = SMAASampleLevelZeroOffset(ReShade::DepthBuffer, texcoord, int2(0, 1)).r;
		d = SMAASampleLevelZeroOffset(ReShade::DepthBuffer, texcoord, int2(1, 1)).r;
	#endif

	if(ESMAADepthPredicationAntiNeighbourCheck){
		float3 antiNeighbs = float3(a, b, c);
		float2 antiDelta = abs(antiNeighbs.xx - float2(antiNeighbs.y, antiNeighbs.z));
		edges = step(detectionThreshold, antiDelta);

		// Early return if there is an edge:
		if (Lib::any(edges))
			return float2(0.0,0.0);
	}

	// float x1 = (e + f + g) / 3.0;
	// float x2 = (h + b) / 2.0;
	// float x3 = (i + c + d) / 3.0;
	float x1 = f;
	float x2 = (h + b) / 2.0;
	float x3 = c;

	// float xy1 = (e + d) / 2.0;
	// float xy2 = (i + g) / 2.0;

	float localAvg = (x1 + x2 + x3) / 3.0;
	// float edgeAvg = (h+f)/2.0;

	float localDelta = abs(a - localAvg);

    if (localDelta > predictionThreshold) {
		if(ESMAADepthPredicationSymmetric){
			// If delta between top, left and current is much greater than 
			// delta of localaverage, return 1.0 for each detected edge
			//TODO: use log delta instead of linear delta
			// cause this is an apples and pears comparison
			float2 res = step(localDelta * 4.0, delta);
			if(Lib::sum(res) == 1.0){
				return res;
			}
		}
		// This is like saying "Maybe there's an edge here, maybe there isn't. Please keep an eye out for jaggies just in case."
		return float2(0.5,0.5); 
	}
	return float2(0.0,0.0);
}


/**
 * Used in edge detection methods to adapt threshold to magnitude of local pixels
 * Scales the input value so that lower and middle values get relatively bigger.
 * Useful for situation where extreme values shouldn't have a disproportionate effect.
 * Result is clamped between threshold floor and 1.0.
 * 
 * @param input some factor with a value of threshold floor 0.0 - 1.0, used to scale the threshold
 * 	Can be somehting like a luma or an rgb component
 * @return float2 with the scaled threshold twice, for easy use in edge thresholding
 */
float2 getThresholdScale(float input){
	return Lib::clampScale(
		input, 
		ESMAAThreshScaleFactor, 
		ESMAAThresholdFloor, 
		1.0
		);
}

/**
 * Luma Edge Detection taken and adapted from the official SMAA.fxh file, provided by the original team. (TODO: fix credits)
 * Adapted to use adaptive thresholding. 
 * Does early return of edges instead of discarding, so that other detection methods can take over.
 *
 * IMPORTANT NOTICE: luma edge detection requires gamma-corrected colors, and
 * thus 'colorTex' should be a non-sRGB texture.
 */
float2 ESMAALumaEdgeDetection(
		float2 texcoord,
		float4 offset[3],
		SMAATexture2D(colorTex)
	) {
	// Calculate lumas:
	float3 weights = SMAA_LUMA_REF;
	float L = dot(SMAASamplePoint(colorTex, texcoord).rgb, weights);

	float Lleft = dot(SMAASamplePoint(colorTex, offset[0].xy).rgb, weights);
	float Ltop  = dot(SMAASamplePoint(colorTex, offset[0].zw).rgb, weights);

	// ADAPTIVE THRESHOLD
	float maxLuma;
	float2 threshold = float2(SMAA_THRESHOLD, SMAA_THRESHOLD);
	if(ESMAAEnableAdaptiveThreshold){
		// use biggest local luma as basis
		maxLuma = Lib::max(L, Lleft, Ltop);
		// scaled maxLuma so that only dark places have a significantly lower threshold
		threshold *= getThresholdScale(maxLuma);
	} 

    // We do the usual threshold:
    float4 delta;
    delta.xy = abs(L - float2(Lleft, Ltop));
    float2 edges = step(threshold, delta.xy);

    // Early return if there is no edge:
    if (!Lib::any(edges))
        return edges;

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

	// ADAPTIVE THRESHOLD second threshold check
	if(ESMAAEnableAdaptiveThreshold){
		// get the greatest of  ALL lumas this time
		float finalMaxLuma = max(maxLuma, max(Lright, max(Lbottom,max(Lleftleft,Ltoptop))));
		// scaled maxLuma so that only dark places have a significantly lower threshold
		threshold *= getThresholdScale(finalMaxLuma);
		// edges set to 1 if delta greater than threshold, else set to 0
		edges = step(threshold, delta.xy);
	}

    // Calculate the final maximum delta:
    maxDelta = max(maxDelta.xy, delta.zw);
    float finalDelta = max(maxDelta.x, maxDelta.y);

    // Local contrast adaptation:
    edges.xy *= step(finalDelta, SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR * delta.xy);

    return edges;
}

/**
 * Color Edge Detection taken and adapted from the official SMAA.fxh file, provided by the original team. (TODO: fix credits)
 * Adapted to use adaptive thresholding. 
 * Does early return of edges instead of discarding, so that other detection methods can take over.
 *
 * IMPORTANT NOTICE: color edge detection requires gamma-corrected colors, and
 * thus 'colorTex' should be a non-sRGB texture.
 */
float2 ESMAAChromaEdgeDetection(
	float2 texcoord,
  float4 offset[3],
  SMAATexture2D(colorTex)
) 
{
    // Calculate color deltas:
    float4 delta;
    float3 C = SMAASamplePoint(colorTex, texcoord).rgb;

    float3 Cleft = SMAASamplePoint(colorTex, offset[0].xy).rgb;
    float3 t = abs(C - Cleft);
    delta.x = Lib::max(t);

    float3 Ctop  = SMAASamplePoint(colorTex, offset[0].zw).rgb;
    t = abs(C - Ctop);
    delta.y = Lib::max(t);

	// ADAPTIVE THRESHOLD
	float maxChroma;
	float2 threshold = float2(SMAA_THRESHOLD, SMAA_THRESHOLD);
	if(ESMAAEnableAdaptiveThreshold){
		maxChroma = Lib::max(
			Lib::max(C),
			Lib::max(Cleft),
			Lib::max(Ctop)
		);
		// scale maxChroma so that only dark places have a significantly lower threshold
		threshold *= getThresholdScale(maxChroma);
	}

    // We do the usual threshold:
    float2 edges = step(threshold, delta.xy);

    // Early return if there is no edge:
    if (!Lib::any(edges))
        return edges;

    // Calculate right and bottom deltas:
    float3 Cright = SMAASamplePoint(colorTex, offset[1].xy).rgb;
    t = abs(C - Cright);
    delta.z = Lib::max(t);

    float3 Cbottom  = SMAASamplePoint(colorTex, offset[1].zw).rgb;
    t = abs(C - Cbottom);
    delta.w = Lib::max(t);

    // Calculate the maximum delta in the direct neighborhood:
    float2 maxDelta = max(delta.xy, delta.zw);

    // Calculate left-left and top-top deltas:
    float3 Cleftleft  = SMAASamplePoint(colorTex, offset[2].xy).rgb;
    t = abs(Cleft - Cleftleft);
    delta.z = Lib::max(t);

    float3 Ctoptop = SMAASamplePoint(colorTex, offset[2].zw).rgb;
    t = abs(Ctop - Ctoptop);
    delta.w = Lib::max(t);

    // Calculate the final maximum delta:
    maxDelta = max(maxDelta.xy, delta.zw);
    float finalDelta = max(maxDelta.x, maxDelta.y);

	// ADAPTIVE THRESHOLD second threshold check
	if(ESMAAEnableAdaptiveThreshold){
		// take ALL greatest components into account this time
		float finalMaxChroma = Lib::max(
			maxChroma, 
			Lib::max(Cright), 
			Lib::max(Cbottom),
			Lib::max(Cleftleft),
			Lib::max(Ctoptop)
		);
		// scaled finalMaxChroma so that only dark places have a significantly lower threshold
		// Multiplying by finalMaxChroma should scale the threshold according to the maximum local brightness
		threshold *= getThresholdScale(finalMaxChroma);
		// edges = step(threshold, delta.xy);
		edges = step(threshold, delta.xy);
	}
	
    // Local contrast adaptation:
    edges.xy *= step(finalDelta, SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR * delta.xy);

    return edges;
}

/**
 * Depth Edge Detection taken and adapted from the official SMAA.fxh file, provided by the original team. (TODO: fix credits)
 * Does not discard edges, so that other detection methods can take over if edges are 0 if needed.
 * Adapted to use ReShades own depth buffer, no texture needed.
 *
 * TODO: implement adaptive threshold that decreases threshold for closer depths
 */
float2 ESMAADepthEdgeDetection(float2 texcoord, float4 offset[3]) 
{
	float P = ReShade::GetLinearizedDepth(texcoord);
	float Pleft = ReShade::GetLinearizedDepth(offset[0].xy);
	float Ptop  = ReShade::GetLinearizedDepth(offset[0].zw);
	float3 neighbours = float3(P, Pleft, Ptop);

	float2 depthDelta = abs(neighbours.xx - float2(neighbours.y, neighbours.z));
	return step(SMAA_DEPTH_THRESHOLD, depthDelta);
}

//////////////////////////////// PIXEL SHADERS (WRAPPERS) ////////////////////////////////

/**
 * Custom edge detection pass that uses one or more edge detection methods in succession
 */
float2 ESMAAHybridEdgeDetectionPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0,
	float4 offset[3] : TEXCOORD1) : SV_Target
{
	float2 edges;
	bool edgesFound = false;
	if(ESMAAEnableLumaEdgeDetection){
		edges = ESMAALumaEdgeDetection(texcoord, offset, colorGammaSampler);
		edgesFound = Lib::any(edges);
	}
	if(ESMAAEnableChromaEdgeDetection && !edgesFound){
		edges = ESMAAChromaEdgeDetection(texcoord, offset, colorGammaSampler);
		edgesFound = Lib::any(edges);
	}
	if(ESMAAEnableDepthEdgeDetection && !edgesFound){
		edges = ESMAADepthEdgeDetection(texcoord, offset);
		edgesFound = Lib::any(edges);
	}
	// if(!edgesFound) discard;
	return edges;
}

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
		// construct a custom set of offsets suitable for DepthEdgeEstimation(),
		// because it usually needs the offsets generated by SMAAEdgeDetectionWrapVS
		float4 edgeOffset[3];
		edgeOffset[0] = float4(-offset.x,offset.y,offset.z,-offset.w);
		edgeOffset[1] = float4(offset.x,offset.y,offset.z,offset.w);
		edgeOffset[2] = float4(-offset.x*2.0,offset.y,offset.z,-offset.w*2.0);

		float2 depthEdges = DepthEdgeEstimation(texcoord, edgeOffset);
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
	
	float lumaM = dot(mid, SMAA_LUMA_REF);
	float chromaM = Lib::dotsat(mid, lumaM);
	bool useluma = lumaM > chromaM;
	if (!useluma) lumaM = 0.0;

	float lumaS = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 0, 1)).rgb, useluma, SMAA_LUMA_REF);
    float lumaE = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 1, 0)).rgb, useluma, SMAA_LUMA_REF);
    float lumaN = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 0,-1)).rgb, useluma, SMAA_LUMA_REF);
    float lumaW = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 0)).rgb, useluma, SMAA_LUMA_REF);
    
    float rangeMax = Lib::max(lumaS, lumaE, lumaN, lumaW, lumaM);
    float rangeMin = Lib::min(lumaS, lumaE, lumaN, lumaW, lumaM);
	
    float range = rangeMax - rangeMin;
    
	// early exit check
    bool earlyExit = (range < __TSMAA_EDGE_THRESHOLD);
	if (earlyExit) return original;

	float lumaNW = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1,-1)).rgb, useluma, SMAA_LUMA_REF);
    float lumaSE = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 1, 1)).rgb, useluma, SMAA_LUMA_REF);
    float lumaNE = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2( 1,-1)).rgb, useluma, SMAA_LUMA_REF);
    float lumaSW = Lib::dotweight(mid, SMAASampleLevelZeroOffset(ReShade::BackBuffer, texcoord, int2(-1, 1)).rgb, useluma, SMAA_LUMA_REF);

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

	float lumaEndN = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posN).rgb, useluma, SMAA_LUMA_REF);
    float lumaEndP = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posP).rgb, useluma, SMAA_LUMA_REF);
	
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
				lumaEndN = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posN).rgb, useluma, SMAA_LUMA_REF);
				lumaEndN -= lumaNN;
				doneN = abs(lumaEndN) >= gradientScaled;
			}
			if (!doneP)
			{
				posP += offNP;
				// lumaEndP = dotweightopt(mid, posP, useluma);
				lumaEndP = Lib::dotweight(mid, SMAASampleLevelZero(ReShade::BackBuffer, posP).rgb, useluma, SMAA_LUMA_REF);
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

	float weightSum = Lib::sum(weightData);
	float edgeSum = Lib::sum(edgeData);
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
	float3 highterm = Lib::max(x1, x2, x3, xy1, xy2, diamond, square, cap, bucket);
	float3 lowterm = Lib::min(x1, x2, x3, xy1, xy2, diamond, square, cap, bucket);
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
		PixelShader = ESMAAHybridEdgeDetectionPS;
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
