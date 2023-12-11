#include "ReShadeUI.fxh"

uniform float MASColorThreshold <
	ui_type = "slider";
	ui_min = 0.001;
	ui_max = 1.0;
	ui_step = 0.001;
	ui_label = "Color threshold";
> = 0.15;

uniform float MASDepthThreshold <
	ui_type = "slider";
	ui_min = 0.000;
	ui_max = 1.0;
	ui_step = 0.001;
	ui_label = "Depth threshold";
> = 0.004;

#define __LUM_WEIGHTS (float3( 0.299, 0.587, 0.114 ))
#define SMAA_THRESHOLD MASColorThreshold

#define ISmax3(x,y,z) max(max(x,y),z)
#define ISmax4(w,x,y,z) max(max(w,x),max(y,z))
#define ISmax5(v,w,x,y,z) max(max(max(v,w),x),max(y,z))
#define ISmax6(u,v,w,x,y,z) max(max(max(u,v),max(w,x)),max(y,z))
#define ISmax7(t,u,v,w,x,y,z) max(max(max(t,u),max(v,w)),max(max(x,y),z))
#define ISmax8(s,t,u,v,w,x,y,z) max(max(max(s,t),max(u,v)),max(max(w,x),max(y,z)))
#define ISmax9(r,s,t,u,v,w,x,y,z) max(max(max(max(r,s),t),max(u,v)),max(max(w,x),max(y,z)))
#define ISmax10(q,r,s,t,u,v,w,x,y,z) max(max(max(max(q,r),max(s,t)),max(u,v)),max(max(w,x),max(y,z)))
#define ISmax11(p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(p,q),max(r,s)),max(max(t,u),v)),max(max(w,x),max(y,z)))
#define ISmax12(o,p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(o,p),max(q,r)),max(max(s,t),max(u,v))),max(max(w,x),max(y,z)))
#define ISmax13(n,o,p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(n,o),max(p,q)),max(max(r,s),max(t,u))),max(max(max(v,w),x),max(y,z)))
#define ISmax14(m,n,o,p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(m,n),max(o,p)),max(max(q,r),max(s,t))),max(max(max(u,v),max(w,x)),max(y,z)))
#define ISmax15(l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(l,m),max(n,o)),max(max(p,q),max(r,s))),max(max(max(t,u),max(v,w)),max(max(x,y),z)))
#define ISmax16(k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(k,l),max(m,n)),max(max(o,p),max(q,r))),max(max(max(s,t),max(u,v)),max(max(w,x),max(y,z))))

#define ISmin3(x,y,z) min(min(x,y),z)
#define ISmin4(w,x,y,z) min(min(w,x),min(y,z))
#define ISmin5(v,w,x,y,z) min(min(min(v,w),x),min(y,z))
#define ISmin6(u,v,w,x,y,z) min(min(min(u,v),min(w,x)),min(y,z))
#define ISmin7(t,u,v,w,x,y,z) min(min(min(t,u),min(v,w)),min(min(x,y),z))
#define ISmin8(s,t,u,v,w,x,y,z) min(min(min(s,t),min(u,v)),min(min(w,x),min(y,z)))
#define ISmin9(r,s,t,u,v,w,x,y,z) min(min(min(min(r,s),t),min(u,v)),min(min(w,x),min(y,z)))
#define ISmin10(q,r,s,t,u,v,w,x,y,z) min(min(min(min(q,r),min(s,t)),min(u,v)),min(min(w,x),min(y,z)))
#define ISmin11(p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(p,q),min(r,s)),min(min(t,u),v)),min(min(w,x),min(y,z)))
#define ISmin12(o,p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(o,p),min(q,r)),min(min(s,t),min(u,v))),min(min(w,x),min(y,z)))
#define ISmin13(n,o,p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(n,o),min(p,q)),min(min(r,s),min(t,u))),min(min(min(v,w),x),min(y,z)))
#define ISmin14(m,n,o,p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(m,n),min(o,p)),min(min(q,r),min(s,t))),min(min(min(u,v),min(w,x)),min(y,z)))
#define ISmin15(l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(l,m),min(n,o)),min(min(p,q),min(r,s))),min(min(min(t,u),min(v,w)),min(min(x,y),z)))
#define ISmin16(k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(k,l),min(m,n)),min(min(o,p),min(q,r))),min(min(min(s,t),min(u,v)),min(min(w,x),min(y,z))))


#include "ReShade.fxh"

#define MAS_RT_METRICS float4(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT, BUFFER_WIDTH, BUFFER_HEIGHT)

#define MASSampleInputBuffer(tex, coord) tex2D(tex, coord)

texture2D DepthWeightTex
#if __RESHADE__ >= 50000
< pooled = true; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = R8;
};
sampler2D DepthWeightBuffer {
	Texture = DepthWeightTex;
};

texture2D PatternCodeTex
#if __RESHADE__ >= 50000
< pooled = true; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = R8;
};
sampler2D PatternCodeBuffer {
	Texture = PatternCodeTex;
};

// static const float PATTERN_CODE_LUT[8] = {1.0,2.0,4.0,8.0,16.0,32.0,64.0,128.0};
// The above values divided by 255.0
static const uint PATTERN_CODE_LUT_LEN = 8;
static const float PATTERN_CODE_LUT[PATTERN_CODE_LUT_LEN] = {
	0.00392156862745098,
	0.00784313725490196,
	0.0156862745098039,
	0.0313725490196078,
	0.0627450980392157,
	0.125490196078431,
	0.250980392156863,
	0.501960784313725
};

bool depthDiffIsSignificant(float depthA, float depthB)
{
	return abs(depthA - depthB) >= MASDepthThreshold;
}

float getWeightedDiff(float3 colorA, float3 colorB)
{
	float3 diff = abs( (colorA - colorB) );
	return dot( diff.rgb, __LUM_WEIGHTS.rgb);
}


bool colorDiffIsSignificant(float3 colorA, float3 colorB)
{
	return getWeightedDiff(colorA, colorB) >= MASColorThreshold;
}

// bool colorDiffIsSignificant(float3 colorA, float3 colorB)
// {
// 	float3 diff = abs(colorA - colorB);
// 	float maxDelta = max(diff.r, max(diff.g, diff.b));
// 	float edge = step(SMAA_THRESHOLD, maxDelta);

// 	// if(diff.r < 0.0 || diff.g < 0.0 || diff.b < 0.0){
// 	// 	return true;
// 	// }
// 	return maxDelta > 0.2;
// 	// if(dot(edge, 1.0) == 0.0){
// 	// 	return false;
// 	// }
// 	// return true;
// }

float2 GetNeighbourCoords(float2 texcoord : TEXCOORD, float4 offset : TEXCOORD1, uint index)
{
	float2 res;
	if (index <= 3) {
		if(index <= 1) {
			if (index == 0) {
				// TODO: consider putting this in pre-processor values
				res = float2(texcoord.x, offset.z);
			} else {
				res = float2(offset.yz);
			}
		} else {
			if (index == 2) {
				res = float2(offset.y, texcoord.y);
			} else {
				res = float2(offset.yw);
			}
		}
	} else {
		if(index <= 5) {
			if (index == 4) {
				res = float2(texcoord.x, offset.w);
			} else {
				res = float2(offset.xw);
			}
		} else {
			if (index == 6) {
				res = float2(offset.x, texcoord.y);
			} else {
				res = float2(offset.xz);
			}
		}
	}

	return res;
}

/**
 * Turn float ranging from 0 - 255 into a float ranging from 255 - 0, and the othe way around.
 * This makes it possible to distinguish coords with 0 matches (index: 0)
 * from "empty" coords (read: untouched coords that should be skipped)
 */
float invert(float patternCode)
{
	// const float MAX_VAL_8_BIT = 255.0;
	// the subtraction inverts the value. 
	return 1.0 - patternCode;
}

// TODO: comments, docs, unittest
float DepthWeightCalcPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET 
{
	// TODO: move to preprocessor values, make UI controls for them
	// const float minDepth = 0.15;
	// const float minWeight = 0.5;
	// const float peakDepth = 0.75;
	// const float peakWeight = 1.0;
	// const float maxDepth = 0.999;
	// const float maxWeight = 0.75;

	const float minDepth = 0.0;
	const float minWeight = 1.0;
	const float peakDepth = 0.75;
	const float peakWeight = 1.0;
	const float maxDepth = 0.999;
	const float maxWeight = 1.0;

	float currDepth = ReShade::GetLinearizedDepth(texcoord);
	// float currDepth = 0.5;
	if(currDepth < minDepth || currDepth > maxDepth) {
		discard;
	}

	float depthBlendWeight;

	// TODO: move to preprocessed strategies for optimalisation
	if (currDepth == minDepth) {
		depthBlendWeight = minWeight;
	} 
	else if(currDepth < peakDepth){
		float minToPeakDiff = peakDepth - minDepth;
		float minToCurrDiff = currDepth - minDepth;

		float ratio = minToCurrDiff / minToPeakDiff;

		depthBlendWeight = lerp(minWeight, peakWeight, ratio);
	} 
	else if (currDepth = peakDepth){
		depthBlendWeight = peakWeight;
	}
	else if(currDepth > peakDepth){
		float peakToMaxDiff = maxDepth - peakDepth;
		float peakToCurrDiff = currDepth - peakDepth;

		float ratio = peakToCurrDiff / peakToMaxDiff;

		depthBlendWeight = lerp(peakWeight, maxWeight, ratio);
	} 
	else if (currDepth == maxDepth) {
		depthBlendWeight = maxWeight;
	}

	return depthBlendWeight;
}

/**
 * Prepares the 4 components that will be used to create offsets for texture sampling
 */
void MASPatternDetectionVS(
	in uint id : SV_VertexID,
	out float4 position : SV_Position, 
	out float2 texcoord : TEXCOORD0, 
	out float4 offset : TEXCOORD1 //TODO: check what this means exactly and if it's good practice/desirable
	) {
		// This needs to happen in every vertex shader function?
		PostProcessVS(id, position, texcoord);
	/**
	 * x -> x-1
	 * y -> x+1
	 * z -> y-1
	 * w -> y+1
	 */
    offset = mad(MAS_RT_METRICS.xxyy, float4(-1.0, 1.0, -1.0, 1.0), texcoord.xxyy);
}

// float PatternDetectionPSTest(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD, float4 offset: TEXCOORD1) : SV_TARGET 
// {
// 	float depthWeight = tex2Dlod(DepthWeightBuffer, texcoord.xyxy).r;
// 	if(depthWeight == 0.0) {
// 		return 0.0;
// 		// discard; // Error codes: x3570, x4121, x4014
// 	}

// 	// float3 targetColor = MASSampleInputBuffer(ReShade::BackBuffer, texcoord).rgb;
// 	// float3 N = MASSampleInputBuffer(ReShade::BackBuffer, GetNeighbourCoords(texcoord, offset, 0)).rgb;
// 	// float maxDelta = max(targetColor.r,max(targetColor.g,targetColor.b));
// 	// return maxDelta < 0.5 ? 1.0 : 0.0;

// 	// float3 white = float3(0.32,0.325,0.33);
// 	float3 black = float3(0.329,0.329,0.337);
// 	float3 black2 = float3(0.11,0.113,0.137);

// 	return !colorDiffIsSignificant(black2, black) ? 1.0 : 0.0;

// 	// float targetDepth = ReShade::GetLinearizedDepth(texcoord);
// 	// float NDepth = ReShade::GetLinearizedDepth(GetNeighbourCoords(texcoord, offset, 3));

// 	// return depthDiffIsSignificant(targetDepth, NDepth) ? 1.0 : 0.0;
// }

float PatternDetectionPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD, float4 offset: TEXCOORD1) : SV_TARGET 
{
	float depthWeight = tex2Dlod(DepthWeightBuffer, texcoord.xyxy).r;
	if(depthWeight == 0.0) {
		return 0.0;
		// discard; // Error codes: x3570, x4121, x4014
	}

	float targetDepth = ReShade::GetLinearizedDepth(texcoord);
	float3 targetColor = MASSampleInputBuffer(ReShade::BackBuffer, texcoord).rgb;

	const uint nrOfNeighbs = 8;
	const uint maxMatchesInARow = 1;
	uint i = 0;
	uint matchesInARow = 0;	
	float code = 0.0;
	uint matchMap[nrOfNeighbs] = {0,0,0,0,0,0,0,0};
	while (matchesInARow <= maxMatchesInARow && i < nrOfNeighbs) {
		float2 neighCoords = GetNeighbourCoords(texcoord, offset, i);

		float depth = ReShade::GetLinearizedDepth(neighCoords);

		// bool isSame = false;
		if(!depthDiffIsSignificant(depth, targetDepth)){
			float3 color = MASSampleInputBuffer(ReShade::BackBuffer, neighCoords).rgb;
			if(!colorDiffIsSignificant(color, targetColor)){
				matchMap[i] = 1;
				// isSame = true;
				code += PATTERN_CODE_LUT[i];
				matchesInARow += 2;
			}
		}
		matchesInARow = max(0, matchesInARow - 1);
		// matchesInARow = (matchMap[i] == 1) ? matchesInARow + 1 : max(0, matchesInARow - 1);
		i++;
	}

	// matchesInARow has already gone over limit before all 8 neighbours are searched, return early.
	if(matchesInARow > maxMatchesInARow){
		discard;
	}
	// Early tests showed false negatives occurred around the beginning and end of the cycle,
	// because matches in the beginning and end would not be recognised as belonging to the same structure
	// Continuing the additions and subtractions to/from matchesInARow for about half a cycle fixes this
	i = 0;
	while (matchesInARow <= maxMatchesInARow && i < 4) {
		if(matchMap[i] == 1){
			matchesInARow += 1;
		} else {
			matchesInARow = max(0, matchesInARow - 1);
		}
		i++;
	}
	// Check again
	if(matchesInARow > maxMatchesInARow){
		discard;
	}

	return invert(code);
	// return 0.5;
	// return code;
}

float3 BlendPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD, float4 offset: TEXCOORD1) : SV_TARGET {
	float targetCodeRaw = MASSampleInputBuffer(PatternCodeBuffer, texcoord.xy).r;
	if(targetCodeRaw == 0.0){
		discard;
	}
	float targetCode = invert(targetCodeRaw);

	uint sameDepth = 0;
	float3 sameDepthSum = float3(0.0,0.0,0.0);
	uint diffDepth = 0;
	float3 diffDepthSum = float3(0.0,0.0,0.0);

	[unroll] for (i = PATTERN_CODE_LUT_LEN - 1; i >= 0; i--){
		float match = PATTERN_CODE_LUT[i];
		if(targetCode >= match){
			targetCode -= match;
		} else {
			float2 neighCoords = GetNeighbourCoords(texcoord, offset, i);

			float depth = ReShade::GetLinearizedDepth(neighCoords);

			float3 color = MASSampleInputBuffer(ReShade::BackBuffer, neighCoords).rgb;
			if(depthDiffIsSignificant(depth, targetDepth)){
				diffDepth++;
				diffDepthSum += color;
			} else {
				sameDepth++;
				sameDepthSum += color;
			}
		}
	}

	return ((sameDepthSum / sameDepth) + (diffDepthSum/ diffDepth))/2.0;
}

float3 TestAsUIntCanDecodeFloat(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET {
	float data = MASSampleInputBuffer(PatternCodeBuffer, texcoord.xy).r;
	if(data == 0.0){
		return float3(0.0,0.0,0.0);
	}
	float inverted = invert(data);
	return lerp(float3(1.0,0.0,0.0),float3(0.0,1.0,0.0), inverted);
}

float3 TestBitOperatorsCanDetectOriginalValue(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET {
	float data = MASSampleInputBuffer(PatternCodeBuffer, texcoord.xy).r;
	uint a = data * 255;
	uint correctBit = ((a >> 6) & 1);
	if( correctBit == 1){
		return float3(1.0,0.0,0.0);
	}
	return float3(0.0,0.0,0.0);
}

float3 DrawMatchesPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET {
	float rawMatches = MASSampleInputBuffer(PatternCodeBuffer, texcoord.xy).r;
	float3 debugCol = lerp(float3(0.0,0.0,1.0), float3(1.0,0.0,0.0), (rawMatches > 0.0)?1.0:0.0);
	float3 originalCol = tex2Dlod(ReShade::BackBuffer, texcoord.xyxy).rgb;
	return lerp(originalCol, debugCol, 0.5);
}

float3 DrawPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET {
	float rawCode = MASSampleInputBuffer(PatternCodeBuffer, texcoord.xy).r;
	float3 debugCol = float3(0.0,0.0,0.0);
	if (rawCode > 0.0) {
		debugCol = float3(1.0,0.0,0.0);
	}
	float3 originalCol = tex2Dlod(ReShade::BackBuffer, texcoord.xyxy).rgb;
	return lerp(originalCol, debugCol, 0.5);
}


technique MorphologicalAntiShimmering  <
	ui_tooltip = "";
>
{
	pass DepthWeightCalculation
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthWeightCalcPS;
		RenderTarget = DepthWeightTex;
		ClearRenderTargets = true;
	}
	pass PatternDetection
	{
		VertexShader = MASPatternDetectionVS;
		PixelShader = PatternDetectionPS;
		RenderTarget = PatternCodeTex;
		ClearRenderTargets = true;
	}
	pass Blend
	{
		VertexShader = MASPatternDetectionVS;
		PixelShader = DrawPS;
		// TODO: consider `SRGBWriteEnable = true;`
	}
	// pass TestAsUInt
	// {
	// 	VertexShader = PostProcessVS;
	// 	PixelShader = TestAsUIntCanDecodeFloat;
	// }
}
