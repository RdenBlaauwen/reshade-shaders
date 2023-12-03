#include "ReShadeUI.fxh"

#define MASSampleInputBuffer(tex, coord) tex2D(tex, coord)

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

texture2D DepthWeightTex
#if __RESHADE__ >= 50000
< pooled = true; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = R8;
}
sampler2D = DepthWeightBuffer {
	Texture = DepthWeightTex;
}

texture2D PatternCodeTex
#if __RESHADE__ >= 50000
< pooled = true; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = R8;
}
sampler2D = PatternCodeBuffer {
	Texture = PatternCodeTex;
}

// TODO: comments, docs, unittest
float DepthWeightCalcPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET {
	const float minDepth = 0.15;
	const float minWeight = 0.5;
	const float peakDepth = 0.75;
	const float peakWeight = 1.0;
	const float maxDepth = 0.999;
	const float maxWeight = 0.75;

	// float currDepth = ReShade::GetLinearizedDepth(texcoord);
	float currDepth = 0.5;
	if(depth < minDepth || depth > maxDepth) {
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

float PatternDetectPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD, float4 offset : TEXCOORD1) : SV_TARGET 
{
	float depthWeight = tex2Dlod(DepthWeightBuffer, texcoord);
	if(depthWeight == 0.0) {
		discard;
	}

	// TODO: wip
}

float DrawPS(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET {
	// TODO: wip
}


technique Morphological Anti Shimmering  <
	ui_tooltip = "";
>
{
	pass DepthWeightCalculation
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthWeightCalcPS;
		RenderTarget = DepthWeightBuffer;
		ClearRenderTargets = true;
	}
	pass PatternDetection
	{
		VertexShader = MASPatternDetectionVS;
		PixelShader = PatternDetectPS;
		RenderTarget = PatternCodeTex;
		ClearRenderTargets = true;
	}
	pass Blend
	{
		VertexShader = PostProcessVS;
		PixelShader = BlendPS;
	}
}
