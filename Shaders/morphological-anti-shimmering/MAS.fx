#include "ReShadeUI.fxh"

uniform float MASColorThreshold <
	ui_type = "slider";
	ui_min = 0.001;
	ui_max = 1.0;
	ui_step = 0.001;
	ui_label = "Color threshold";
> = 0.12;

uniform float MASDepthThreshold <
	ui_type = "slider";
	ui_min = 0.001;
	ui_max = 1.0;
	ui_step = 0.001;
	ui_label = "Color threshold";
> = 0.004;

#define __LUM_WEIGHTS (float3( 0.299, 0.587, 0.114 ))

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

static const uint PATTERN_CODE_LUT[8] = {1,2,4,8,16,32,64,128};


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

// TODO: comments, docs, unittest
float DepthWeightCalcPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET 
{
	const float minDepth = 0.15;
	const float minWeight = 0.5;
	const float peakDepth = 0.75;
	const float peakWeight = 1.0;
	const float maxDepth = 0.999;
	const float maxWeight = 0.75;

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

float PatternDetectionPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD, float4 offset: TEXCOORD1) : SV_TARGET 
{
	float depthWeight = tex2Dlod(DepthWeightBuffer, texcoord.xyxy).r;
	if(depthWeight == 0.0) {
		return 0.0;
		// discard; // x3570, x4121, x4014
	}

	float targetDepth = ReShade::GetLinearizedDepth(texcoord);
	float3 targetColor = MASSampleInputBuffer(ReShade::BackBuffer, texcoord).rgb;

	const uint maxHitsInARow = 2;
	uint i = 0;
	uint hitsInARow = 0;	
	uint code = 0;
	uint hitMap[8] = {0,0,0,0,0,0,0,0};
	while (hitsInARow <= maxHitsInARow && i < 8) {
		float2 neighCoords = GetNeighbourCoords(texcoord, offset, i);

		float depth = ReShade::GetLinearizedDepth(neighCoords);

		// bool isSame = false;
		if(!depthDiffIsSignificant(depth, targetDepth)){
			float3 color = MASSampleInputBuffer(ReShade::BackBuffer, neighCoords).rgb;
			if(!colorDiffIsSignificant(color, targetColor)){
				hitMap[i] = 1;
				// isSame = true;
				code += PATTERN_CODE_LUT[i];
			}
		}
		hitsInARow = (hitMap[i] == 1) ? hitsInARow + 1 : max(0, hitsInARow - 1);
		i++;
	}
	if(hitsInARow > maxHitsInARow){
		discard;
	}
	uint nrOfBoundaryHits = hitMap[0] + hitMap[1] + hitMap[6] + hitMap[7];
	if(nrOfBoundaryHits > maxHitsInARow){
		discard;
	}

	// TODO: wip
	// return neighCoordsSum;
	return code / 255.0;
	// return 255;
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

float3 DrawPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET {
	float data = MASSampleInputBuffer(PatternCodeBuffer, texcoord.xy).r;
	return float3(data,0.0,0.0);
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
		VertexShader = PostProcessVS;
		PixelShader = DrawPS;
	}
	// pass DebugPS
	// {
	// 	VertexShader = PostProcessVS;
	// 	PixelShader = TestNeighbourHoodValuesCanBePutIntoFloat;
	// }
}
