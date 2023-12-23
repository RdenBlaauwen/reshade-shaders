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
 
 // This shader includes code adapted from:
 
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
 
 /**============================================================================


                    NVIDIA FXAA 3.11 by TIMOTHY LOTTES


------------------------------------------------------------------------------
COPYRIGHT (C) 2010, 2011 NVIDIA CORPORATION. ALL RIGHTS RESERVED.
------------------------------------------------------------------------------*/

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

/////////////////////////////////////////////////////// CONFIGURABLE TOGGLES //////////////////////////////////////////////////////////////

#ifndef TSMAA_ADVANCED_MODE
	#define TSMAA_ADVANCED_MODE 0
#endif

#ifndef TSMAA_OUTPUT_MODE
	#define TSMAA_OUTPUT_MODE 0
#endif

/////////////////////////////////////////////////////// GLOBAL SETUP OPTIONS //////////////////////////////////////////////////////////////

uniform int TSMAAintroduction <
	ui_spacing = 3;
	ui_type = "radio";
	ui_label = "Version: 0.14";
	ui_text = "-------------------------------------------------------------------------\n"
			"DEDECTED Temporal Subpixel Morphological Anti-Aliasing, a shader by lordbean\n"
			"https://github.com/lordbean-git/TSMAA/\n"
			"-------------------------------------------------------------------------\n\n"
			"Currently Compiled Configuration:\n\n"
			#if TSMAA_ADVANCED_MODE
				"Advanced Mode:            on  *\n"
			#else
				"Advanced Mode:           off\n"
			#endif
			#if TSMAA_OUTPUT_MODE == 1
				"Output Mode:        HDR nits  *\n"
			#elif TSMAA_OUTPUT_MODE == 2
				"Output Mode:     PQ accurate  *\n"
			#elif TSMAA_OUTPUT_MODE == 3
				"Output Mode:       PQ approx  *\n"
			#else
				"Output Mode:       Gamma 2.2\n"
			#endif
			
			"\nValid Output Modes (TSMAA_OUTPUT_MODE):\n"
			"0: Gamma 2.2 (default)\n"
			"1: HDR, direct nits scale\n"
			"2: HDR10, accurate encoding\n"
			"3: HDR10, fast encoding\n"
			"\n-------------------------------------------------------------------------"
			"\nSee the 'Preprocessor definitions' section for color & feature toggles.\n"
			"-------------------------------------------------------------------------";
	ui_tooltip = "experimental beta";
	ui_category = "About";
	ui_category_closed = true;
>;

uniform int TsmaaAboutEOF <
	ui_type = "radio";
	ui_label = " ";
	ui_text = "\n--------------------------------------------------------------------------------";
>;


#if !TSMAA_ADVANCED_MODE
uniform uint TsmaaPreset <
	ui_type = "combo";
	ui_label = "Quality Preset\n\n";
	ui_tooltip = "Set TSMAA_ADVANCED_MODE to 1 to customize all options";
	ui_items = "Low\0Medium\0High\0Ultra\0";
> = 2;

#else
uniform float TsmaaEdgeThresholdCustom < __UNIFORM_SLIDER_FLOAT1
	ui_min = 0.0; ui_max = 1.0;
	ui_spacing = 4;
	ui_label = "Edge Detection Threshold";
	ui_tooltip = "Local contrast (luma difference) required to be considered an edge";
	ui_category = "SMAA";
	ui_category_closed = true;
> = 0.1;
#endif //TSMAA_ADVANCED_MODE

uniform bool SmaaHoriz <
	ui_label = "SmaaHoriz";
> = false;

uniform bool SmaaData <
	ui_label = "SmaaData";
> = false;

uniform bool SMAAEdge <
	ui_label = "SMAAEdge";
> = false;

uniform float MaxBlending <
	ui_type = "slider";
	ui_min = 0.5; ui_max = 1.0; ui_step = 0.01;
	ui_label = "MaxBlending";
> = 0.5;

#if TSMAA_OUTPUT_MODE == 1
uniform float TsmaaHdrNits < 
	ui_spacing = 3;
	ui_type = "slider";
	ui_min = 500.0; ui_max = 10000.0; ui_step = 100.0;
	ui_label = "HDR Nits";
	ui_tooltip = "If the scene brightness changes after TSMAA runs, try\n"
				 "adjusting this value up or down until it looks right.";
> = 1000.0;
#endif

uniform int TsmaaOptionsEOF <
	ui_type = "radio";
	ui_label = " ";
	ui_text = "\n--------------------------------------------------------------------------------";
>;

///////////////////////////////////////////////// HUMAN+MACHINE PRESET REFERENCE //////////////////////////////////////////////////////////

#if TSMAA_ADVANCED_MODE
uniform int TsmaaPresetBreakdown <
	ui_type = "radio";
	ui_label = " ";
	ui_text = "\n"
			  "------------------------------------------------\n"
			  "|        |       Edges       |      SMAA       |\n"
	          "|--Preset|-Threshold---Range-|-Corner---%Error-|\n"
	          "|--------|-----------|-------|--------|--------|\n"
			  "|     Low|   0.125   | 33.3% |   25%  |  High  |\n"
			  "|  Medium|   0.100   | 50.0% |   33%  |  High  |\n"
			  "|    High|   0.075   | 66.7% |   50%  |  High  |\n"
			  "|   Ultra|   0.050   | 80.0% |  100%  |  Skip  |\n"
			  "------------------------------------------------";
	ui_category = "Click me to see what settings each preset uses!";
	ui_category_closed = true;
>;

#define __TSMAA_EDGE_THRESHOLD (TsmaaEdgeThresholdCustom)

#else

static const float TSMAA_THRESHOLD_PRESET[4] = {0.125, 0.1, 0.075, 0.05};

#define __TSMAA_EDGE_THRESHOLD (TSMAA_THRESHOLD_PRESET[TsmaaPreset])

#endif //TSMAA_ADVANCED_MODE

/*****************************************************************************************************************************************/
/*********************************************************** UI SETUP END ****************************************************************/
/*****************************************************************************************************************************************/

/*****************************************************************************************************************************************/
/******************************************************** SYNTAX SETUP START *************************************************************/
/*****************************************************************************************************************************************/

#define __TSMAA_SMALLEST_COLOR_STEP rcp(pow(2, BUFFER_COLOR_BIT_DEPTH))
#define __TSMAA_LUMA_REF float3(0.333333, 0.333334, 0.333333)

#define __TSMAA_BUFFER_INFO float4(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT, BUFFER_WIDTH, BUFFER_HEIGHT)

#define TSMAA_Tex2D(tex, coord) tex2Dlod(tex, (coord).xyxy)
// #define TSMAA_DecodeTex2D(tex, coord) ConditionalDecode(tex2Dlod(tex, (coord).xyxy))
// #define TSMAA_DecodeTex2DOffset(tex, coord, offset) ConditionalDecode(tex2Dlodoffset(tex, (coord).xyxy, offset))


#define TSMAA_DecodeTex2D(tex, coord) tex2Dlod(tex, (coord).xyxy)
#define TSMAA_DecodeTex2DOffset(tex, coord, offset) tex2Dlodoffset(tex, (coord).xyxy, offset)

#define TSMAAmax3(x,y,z) max(max(x,y),z)
#define TSMAAmax4(w,x,y,z) max(max(w,x),max(y,z))
#define TSMAAmax5(v,w,x,y,z) max(max(max(v,w),x),max(y,z))
#define TSMAAmax6(u,v,w,x,y,z) max(max(max(u,v),max(w,x)),max(y,z))
#define TSMAAmax7(t,u,v,w,x,y,z) max(max(max(t,u),max(v,w)),max(max(x,y),z))
#define TSMAAmax8(s,t,u,v,w,x,y,z) max(max(max(s,t),max(u,v)),max(max(w,x),max(y,z)))
#define TSMAAmax9(r,s,t,u,v,w,x,y,z) max(max(max(max(r,s),t),max(u,v)),max(max(w,x),max(y,z)))
#define TSMAAmax10(q,r,s,t,u,v,w,x,y,z) max(max(max(max(q,r),max(s,t)),max(u,v)),max(max(w,x),max(y,z)))
#define TSMAAmax11(p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(p,q),max(r,s)),max(max(t,u),v)),max(max(w,x),max(y,z)))
#define TSMAAmax12(o,p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(o,p),max(q,r)),max(max(s,t),max(u,v))),max(max(w,x),max(y,z)))
#define TSMAAmax13(n,o,p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(n,o),max(p,q)),max(max(r,s),max(t,u))),max(max(max(v,w),x),max(y,z)))
#define TSMAAmax14(m,n,o,p,q,r,s,t,u,v,w,x,y,z) max(max(max(max(m,n),max(o,p)),max(max(q,r),max(s,t))),max(max(max(u,v),max(w,x)),max(y,z)))

#define TSMAAmin3(x,y,z) min(min(x,y),z)
#define TSMAAmin4(w,x,y,z) min(min(w,x),min(y,z))
#define TSMAAmin5(v,w,x,y,z) min(min(min(v,w),x),min(y,z))
#define TSMAAmin6(u,v,w,x,y,z) min(min(min(u,v),min(w,x)),min(y,z))
#define TSMAAmin7(t,u,v,w,x,y,z) min(min(min(t,u),min(v,w)),min(min(x,y),z))
#define TSMAAmin8(s,t,u,v,w,x,y,z) min(min(min(s,t),min(u,v)),min(min(w,x),min(y,z)))
#define TSMAAmin9(r,s,t,u,v,w,x,y,z) min(min(min(min(r,s),t),min(u,v)),min(min(w,x),min(y,z)))
#define TSMAAmin10(q,r,s,t,u,v,w,x,y,z) min(min(min(min(q,r),min(s,t)),min(u,v)),min(min(w,x),min(y,z)))
#define TSMAAmin11(p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(p,q),min(r,s)),min(min(t,u),v)),min(min(w,x),min(y,z)))
#define TSMAAmin12(o,p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(o,p),min(q,r)),min(min(s,t),min(u,v))),min(min(w,x),min(y,z)))
#define TSMAAmin13(n,o,p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(n,o),min(p,q)),min(min(r,s),min(t,u))),min(min(min(v,w),x),min(y,z)))
#define TSMAAmin14(m,n,o,p,q,r,s,t,u,v,w,x,y,z) min(min(min(min(m,n),min(o,p)),min(min(q,r),min(s,t))),min(min(min(u,v),min(w,x)),min(y,z)))

#define TSMAAdotmax(x) max(max((x).r, (x).g), (x).b)
#define TSMAAdotmin(x) min(min((x).r, (x).g), (x).b)

/*****************************************************************************************************************************************/
/********************************************************* SYNTAX SETUP END **************************************************************/
/*****************************************************************************************************************************************/

/*****************************************************************************************************************************************/
/******************************************************** SUPPORT CODE START *************************************************************/
/*****************************************************************************************************************************************/

//////////////////////////////////////////////////////// PIXEL INFORMATION ////////////////////////////////////////////////////////////////

float dotweight(float3 middle, float3 neighbor, bool useluma, float3 weights)
{
	if (useluma) return dot(neighbor, weights);
	else return dot(abs(middle - neighbor), __TSMAA_LUMA_REF);
}

/////////////////////////////////////////////////////// TRANSFER FUNCTIONS ////////////////////////////////////////////////////////////////

#if TSMAA_OUTPUT_MODE == 2
float encodePQ(float x)
{
/*	float nits = 10000.0;
	float m2rcp = 0.012683; // 1 / (2523/32)
	float m1rcp = 6.277395; // 1 / (1305/8192)
	float c1 = 0.8359375; // 107 / 128
	float c2 = 18.8515625; // 2413 / 128
	float c3 = 18.6875; // 2392 / 128
*/
	float xpm2rcp = pow(saturate(x), 0.012683);
	float numerator = max(xpm2rcp - 0.8359375, 0.0);
	float denominator = 18.8515625 - (18.6875 * xpm2rcp);
	
	float output = pow(abs(numerator / denominator), 6.277395);
#if BUFFER_COLOR_BIT_DEPTH == 10
	output *= 500.0;
#else
	output *= 10000.0;
#endif

	return output;
}
float2 encodePQ(float2 x)
{
	float2 xpm2rcp = pow(saturate(x), 0.012683);
	float2 numerator = max(xpm2rcp - 0.8359375, 0.0);
	float2 denominator = 18.8515625 - (18.6875 * xpm2rcp);
	
	float2 output = pow(abs(numerator / denominator), 6.277395);
#if BUFFER_COLOR_BIT_DEPTH == 10
	output *= 500.0;
#else
	output *= 10000.0;
#endif

	return output;
}
float3 encodePQ(float3 x)
{
	float3 xpm2rcp = pow(saturate(x), 0.012683);
	float3 numerator = max(xpm2rcp - 0.8359375, 0.0);
	float3 denominator = 18.8515625 - (18.6875 * xpm2rcp);
	
	float3 output = pow(abs(numerator / denominator), 6.277395);
#if BUFFER_COLOR_BIT_DEPTH == 10
	output *= 500.0;
#else
	output *= 10000.0;
#endif

	return output;
}
float4 encodePQ(float4 x)
{
	float4 xpm2rcp = pow(saturate(x), 0.012683);
	float4 numerator = max(xpm2rcp - 0.8359375, 0.0);
	float4 denominator = 18.8515625 - (18.6875 * xpm2rcp);
	
	float4 output = pow(abs(numerator / denominator), 6.277395);
#if BUFFER_COLOR_BIT_DEPTH == 10
	output *= 500.0;
#else
	output *= 10000.0;
#endif

	return output;
}

float decodePQ(float x)
{
/*	float nits = 10000.0;
	float m2 = 78.84375 // 2523 / 32
	float m1 = 0.159302; // 1305 / 8192
	float c1 = 0.8359375; // 107 / 128
	float c2 = 18.8515625; // 2413 / 128
	float c3 = 18.6875; // 2392 / 128
*/
#if BUFFER_COLOR_BIT_DEPTH == 10
	float xpm1 = pow(saturate(x / 500.0), 0.159302);
#else
	float xpm1 = pow(saturate(x / 10000.0), 0.159302);
#endif
	float numerator = 0.8359375 + (18.8515625 * xpm1);
	float denominator = 1.0 + (18.6875 * xpm1);
	
	return saturate(pow(abs(numerator / denominator), 78.84375));
}
float2 decodePQ(float2 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	float2 xpm1 = pow(saturate(x / 500.0), 0.159302);
#else
	float2 xpm1 = pow(saturate(x / 10000.0), 0.159302);
#endif
	float2 numerator = 0.8359375 + (18.8515625 * xpm1);
	float2 denominator = 1.0 + (18.6875 * xpm1);
	
	return saturate(pow(abs(numerator / denominator), 78.84375));
}
float3 decodePQ(float3 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	float3 xpm1 = pow(saturate(x / 500.0), 0.159302);
#else
	float3 xpm1 = pow(saturate(x / 10000.0), 0.159302);
#endif
	float3 numerator = 0.8359375 + (18.8515625 * xpm1);
	float3 denominator = 1.0 + (18.6875 * xpm1);
	
	return saturate(pow(abs(numerator / denominator), 78.84375));
}
float4 decodePQ(float4 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	float4 xpm1 = pow(saturate(x / 500.0), 0.159302);
#else
	float4 xpm1 = pow(saturate(x / 10000.0), 0.159302);
#endif
	float4 numerator = 0.8359375 + (18.8515625 * xpm1);
	float4 denominator = 1.0 + (18.6875 * xpm1);
	
	return saturate(pow(abs(numerator / denominator), 78.84375));
}
#endif //TSMAA_OUTPUT_MODE == 2

#if TSMAA_OUTPUT_MODE == 3
float fastencodePQ(float x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	float y = saturate(x) * 4.728708;
#else
	float y = saturate(x) * 10.0;
#endif
	y *= y;
	y *= y;
	return y;
}
float2 fastencodePQ(float2 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	float2 y = saturate(x) * 4.728708;
#else
	float2 y = saturate(x) * 10.0;
#endif
	y *= y;
	y *= y;
	return y;
}
float3 fastencodePQ(float3 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	float3 y = saturate(x) * 4.728708;
#else
	float3 y = saturate(x) * 10.0;
#endif
	y *= y;
	y *= y;
	return y;
}
float4 fastencodePQ(float4 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	float4 y = saturate(x) * 4.728708;
#else
	float4 y = saturate(x) * 10.0;
#endif
	y *= y;
	y *= y;
	return y;
}

float fastdecodePQ(float x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	return saturate((sqrt(sqrt(clamp(x, __TSMAA_SMALLEST_COLOR_STEP, 500.0))) / 4.728708));
#else
	return saturate((sqrt(sqrt(clamp(x, __TSMAA_SMALLEST_COLOR_STEP, 10000.0))) / 10.0));
#endif
}
float2 fastdecodePQ(float2 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	return saturate((sqrt(sqrt(clamp(x, __TSMAA_SMALLEST_COLOR_STEP, 500.0))) / 4.728708));
#else
	return saturate((sqrt(sqrt(clamp(x, __TSMAA_SMALLEST_COLOR_STEP, 10000.0))) / 10.0));
#endif
}
float3 fastdecodePQ(float3 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	return saturate((sqrt(sqrt(clamp(x, __TSMAA_SMALLEST_COLOR_STEP, 500.0))) / 4.728708));
#else
	return saturate((sqrt(sqrt(clamp(x, __TSMAA_SMALLEST_COLOR_STEP, 10000.0))) / 10.0));
#endif
}
float4 fastdecodePQ(float4 x)
{
#if BUFFER_COLOR_BIT_DEPTH == 10
	return saturate((sqrt(sqrt(clamp(x, __TSMAA_SMALLEST_COLOR_STEP, 500.0))) / 4.728708));
#else
	return saturate((sqrt(sqrt(clamp(x, __TSMAA_SMALLEST_COLOR_STEP, 10000.0))) / 10.0));
#endif
}
#endif //TSMAA_OUTPUT_MODE == 3

#if TSMAA_OUTPUT_MODE == 1
float encodeHDR(float x)
{
	return saturate(x) * TsmaaHdrNits;
}
float2 encodeHDR(float2 x)
{
	return saturate(x) * TsmaaHdrNits;
}
float3 encodeHDR(float3 x)
{
	return saturate(x) * TsmaaHdrNits;
}
float4 encodeHDR(float4 x)
{
	return saturate(x) * TsmaaHdrNits;
}

float decodeHDR(float x)
{
	return saturate(x / TsmaaHdrNits);
}
float2 decodeHDR(float2 x)
{
	return saturate(x / TsmaaHdrNits);
}
float3 decodeHDR(float3 x)
{
	return saturate(x / TsmaaHdrNits);
}
float4 decodeHDR(float4 x)
{
	return saturate(x / TsmaaHdrNits);
}
#endif //TSMAA_OUTPUT_MODE == 1

float ConditionalEncode(float x)
{
#if TSMAA_OUTPUT_MODE == 1
	return encodeHDR(x);
#elif TSMAA_OUTPUT_MODE == 2
	return encodePQ(x);
#elif TSMAA_OUTPUT_MODE == 3
	return fastencodePQ(x);
#else
	return x;
#endif
}
float2 ConditionalEncode(float2 x)
{
#if TSMAA_OUTPUT_MODE == 1
	return encodeHDR(x);
#elif TSMAA_OUTPUT_MODE == 2
	return encodePQ(x);
#elif TSMAA_OUTPUT_MODE == 3
	return fastencodePQ(x);
#else
	return x;
#endif
}
float3 ConditionalEncode(float3 x)
{
#if TSMAA_OUTPUT_MODE == 1
	return encodeHDR(x);
#elif TSMAA_OUTPUT_MODE == 2
	return encodePQ(x);
#elif TSMAA_OUTPUT_MODE == 3
	return fastencodePQ(x);
#else
	return x;
#endif
}
float4 ConditionalEncode(float4 x)
{
#if TSMAA_OUTPUT_MODE == 1
	return encodeHDR(x);
#elif TSMAA_OUTPUT_MODE == 2
	return encodePQ(x);
#elif TSMAA_OUTPUT_MODE == 3
	return fastencodePQ(x);
#else
	return x;
#endif
}

float ConditionalDecode(float x)
{
#if TSMAA_OUTPUT_MODE == 1
	return decodeHDR(x);
#elif TSMAA_OUTPUT_MODE == 2
	return decodePQ(x);
#elif TSMAA_OUTPUT_MODE == 3
	return fastdecodePQ(x);
#else
	return x;
#endif
}
float2 ConditionalDecode(float2 x)
{
#if TSMAA_OUTPUT_MODE == 1
	return decodeHDR(x);
#elif TSMAA_OUTPUT_MODE == 2
	return decodePQ(x);
#elif TSMAA_OUTPUT_MODE == 3
	return fastdecodePQ(x);
#else
	return x;
#endif
}
float3 ConditionalDecode(float3 x)
{
#if TSMAA_OUTPUT_MODE == 1
	return decodeHDR(x);
#elif TSMAA_OUTPUT_MODE == 2
	return decodePQ(x);
#elif TSMAA_OUTPUT_MODE == 3
	return fastdecodePQ(x);
#else
	return x;
#endif
}
float4 ConditionalDecode(float4 x)
{
#if TSMAA_OUTPUT_MODE == 1
	return decodeHDR(x);
#elif TSMAA_OUTPUT_MODE == 2
	return decodePQ(x);
#elif TSMAA_OUTPUT_MODE == 3
	return fastdecodePQ(x);
#else
	return x;
#endif
}

//////////////////////////////////////////////////// SATURATION CALCULATIONS //////////////////////////////////////////////////////////////

float dotsat(float3 color)
{
	float luma = dot(color, __TSMAA_LUMA_REF);
	return ((TSMAAdotmax(color) - TSMAAdotmin(color)) / (1.0 - (2.0 * luma - 1.0) + trunc(luma)));
}
float dotsat(float4 x)
{
	return dotsat(x.rgb);
}

///////////////////////////////////////////////////// SMAA HELPER FUNCTIONS ///////////////////////////////////////////////////////////////

void TSMAAMovc(bool2 cond, inout float2 variable, float2 value)
{
    [flatten] if (cond.x) variable.x = value.x;
    [flatten] if (cond.y) variable.y = value.y;
}
void TSMAAMovc(bool4 cond, inout float4 variable, float4 value)
{
    TSMAAMovc(cond.xy, variable.xy, value.xy);
    TSMAAMovc(cond.zw, variable.zw, value.zw);
}

/***************************************************************************************************************************************/
/******************************************************** SUPPORT CODE END *************************************************************/
/***************************************************************************************************************************************/

/***************************************************************************************************************************************/
/*********************************************************** SHADER SETUP START ********************************************************/
/***************************************************************************************************************************************/

#include "ReShade.fxh"

//////////////////////////////////////////////////////////// TEXTURES ///////////////////////////////////////////////////////////////////

texture TSMAAedgesTex
#if __RESHADE__ >= 50000
< pooled = true; >
#else
< pooled = false; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = RGBA8;
};

texture TSMAAedgesTexX2
#if __RESHADE__ >= 50000
< pooled = true; >
#else
< pooled = false; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;
	Format = RGBA8;
};

texture TSMAAblendTex
#if __RESHADE__ >= 50000
< pooled = true; >
#else
< pooled = false; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;

#if BUFFER_COLOR_BIT_DEPTH == 10
	Format = RGB10A2;
#elif BUFFER_COLOR_BIT_DEPTH > 8
	Format = RGBA16F;
#else
	Format = RGBA8;
#endif
};

texture TSMAAoldblendTex
#if __RESHADE__ >= 50000
< pooled = true; >
#else
< pooled = false; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;

#if BUFFER_COLOR_BIT_DEPTH == 10
	Format = RGB10A2;
#elif BUFFER_COLOR_BIT_DEPTH > 8
	Format = RGBA16F;
#else
	Format = RGBA8;
#endif
};

texture TSMAAoldbufferTex
#if __RESHADE__ >= 50000
< pooled = true; >
#else
< pooled = false; >
#endif
{
	Width = BUFFER_WIDTH;
	Height = BUFFER_HEIGHT;

#if BUFFER_COLOR_BIT_DEPTH == 10
	Format = RGB10A2;
#elif BUFFER_COLOR_BIT_DEPTH > 8
	Format = RGBA16F;
#else
	Format = RGBA8;
#endif
};

texture TSMAAareaTex < source = "AreaTex.png"; >
{
	Width = 160;
	Height = 560;
	Format = RG8;
};

texture TSMAAsearchTex < source = "SearchTex.png"; >
{
	Width = 64;
	Height = 16;
	Format = R8;
};

//////////////////////////////////////////////////////////// SAMPLERS ///////////////////////////////////////////////////////////////////

sampler TSMAAsamplerEdges
{
	Texture = TSMAAedgesTex;
};

sampler TSMAAsamplerWeights
{
	Texture = TSMAAblendTex;
};

sampler TSMAAsamplerOldWeights
{
	Texture = TSMAAoldblendTex;
};

//////////////////////////////////////////////////////////// VERTEX SHADERS /////////////////////////////////////////////////////////////

void TSMAANeighborhoodBlendingVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0, out float4 offset : TEXCOORD1)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
    offset = mad(__TSMAA_BUFFER_INFO.xyxy, float4( 1.0, 0.0, 0.0,  1.0), texcoord.xyxy);
}

/*****************************************************************************************************************************************/
/*********************************************************** SHADER SETUP END ************************************************************/
/*****************************************************************************************************************************************/

/*****************************************************************************************************************************************/
/********************************************************** SMAA SHADER CODE START *******************************************************/
/*****************************************************************************************************************************************/

//////////////////////////////////////////////////////// SMOOTHING ////////////////////////////////////////////////////////////////////////
float3 TSMAASmoothingPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0, float4 offset : TEXCOORD1) : SV_Target
{
	// bool smaahoriz = max(m.x, m.z) > max(m.y, m.w);
	bool smaahoriz = SmaaHoriz; // TODO: try 'true'
	// bool smaadata = dot(m, float4(1,1,1,1)) != 0.0;
	bool smaadata = SmaaData;
	// float maxblending = 0.5 + (0.5 * TSMAAmax4(m.r, m.g, m.b, m.a));
	float maxblending = MaxBlending;
	float3 middle = TSMAA_Tex2D(ReShade::BackBuffer, texcoord).rgb;
	float3 original = middle;

	// middle = ConditionalDecode(middle);

	float lumaM = dot(middle, __TSMAA_LUMA_REF);
	float chromaM = dotsat(middle);
	bool useluma = lumaM > chromaM;
	if (!useluma) lumaM = 0.0;

	float lumaS = dotweight(middle, TSMAA_DecodeTex2DOffset(ReShade::BackBuffer, texcoord, int2( 0, 1)).rgb, useluma, __TSMAA_LUMA_REF);
	float lumaE = dotweight(middle, TSMAA_DecodeTex2DOffset(ReShade::BackBuffer, texcoord, int2( 1, 0)).rgb, useluma, __TSMAA_LUMA_REF);
	float lumaN = dotweight(middle, TSMAA_DecodeTex2DOffset(ReShade::BackBuffer, texcoord, int2( 0,-1)).rgb, useluma, __TSMAA_LUMA_REF);
	float lumaW = dotweight(middle, TSMAA_DecodeTex2DOffset(ReShade::BackBuffer, texcoord, int2(-1, 0)).rgb, useluma, __TSMAA_LUMA_REF);

	float maxLuma = TSMAAmax5(lumaS, lumaE, lumaN, lumaW, lumaM);
	float minLuma = TSMAAmin5(lumaS, lumaE, lumaN, lumaW, lumaM);

	float lumaRange = maxLuma - minLuma;

	// early exit check
	// bool SMAAedge = any(TSMAA_Tex2D(TSMAAsamplerEdges, texcoord).rg);
	bool SMAAedge = SMAAEdge;
	bool earlyExit = (lumaRange < __TSMAA_EDGE_THRESHOLD) && (!SMAAedge);
	if (earlyExit) return original;
	
	float lumaNW = dotweight(middle, TSMAA_DecodeTex2DOffset(ReShade::BackBuffer, texcoord, int2(-1,-1)).rgb, useluma, __TSMAA_LUMA_REF);
	float lumaSE = dotweight(middle, TSMAA_DecodeTex2DOffset(ReShade::BackBuffer, texcoord, int2( 1, 1)).rgb, useluma, __TSMAA_LUMA_REF);
	float lumaNE = dotweight(middle, TSMAA_DecodeTex2DOffset(ReShade::BackBuffer, texcoord, int2( 1,-1)).rgb, useluma, __TSMAA_LUMA_REF);
	float lumaSW = dotweight(middle, TSMAA_DecodeTex2DOffset(ReShade::BackBuffer, texcoord, int2(-1, 1)).rgb, useluma, __TSMAA_LUMA_REF);

	bool horzSpan = (abs(mad(-2.0, lumaW, lumaNW + lumaSW)) + mad(2.0, abs(mad(-2.0, lumaM, lumaN + lumaS)), abs(mad(-2.0, lumaE, lumaNE + lumaSE)))) >= (abs(mad(-2.0, lumaS, lumaSW + lumaSE)) + mad(2.0, abs(mad(-2.0, lumaM, lumaW + lumaE)), abs(mad(-2.0, lumaN, lumaNW + lumaNE))));	
	float lengthSign = horzSpan ? BUFFER_RCP_HEIGHT : BUFFER_RCP_WIDTH;
	if (((horzSpan) && ((smaahoriz) && (smaadata))) || ((!horzSpan) && ((!smaahoriz) && (smaadata)))) {
		maxblending *= 0.5;
	} else {
		maxblending = min(maxblending * 1.5, 1.0);
	}
	float2 lumaNP = float2(lumaN, lumaS);
	TSMAAMovc(bool(!horzSpan).xx, lumaNP, float2(lumaW, lumaE));
	
	float gradientN = lumaNP.x - lumaM;
	float gradientS = lumaNP.y - lumaM;
	float lumaNN = lumaNP.x + lumaM;

	if (abs(gradientN) >= abs(gradientS)) lengthSign = -lengthSign;
	else lumaNN = lumaNP.y + lumaM;
	
	float2 posB = texcoord;
	
	float texelsize = 0.5;

	float2 offNP = float2(0.0, BUFFER_RCP_HEIGHT * texelsize);
	TSMAAMovc(bool(horzSpan).xx, offNP, float2(BUFFER_RCP_WIDTH * texelsize, 0.0));
	TSMAAMovc(bool2(!horzSpan, horzSpan), posB, float2(posB.x + lengthSign / 2.0, posB.y + lengthSign / 2.0));
	
	float2 posN = posB - offNP;
	float2 posP = posB + offNP;
	
	float lumaEndN = dotweight(middle, TSMAA_DecodeTex2D(ReShade::BackBuffer, posN).rgb, useluma, __TSMAA_LUMA_REF);
	float lumaEndP = dotweight(middle, TSMAA_DecodeTex2D(ReShade::BackBuffer, posP).rgb, useluma, __TSMAA_LUMA_REF);

	float gradientScaled = max(abs(gradientN), abs(gradientS)) * 0.25;
	bool lumaMLTZero = mad(0.5, -lumaNN, lumaM) < 0.0;
	
	lumaNN *= 0.5;
	
	lumaEndN -= lumaNN;
	lumaEndP -= lumaNN;

	bool doneN = abs(lumaEndN) >= gradientScaled;
	bool doneP = abs(lumaEndP) >= gradientScaled;
	bool doneNP;
	
	// 10 pixel scan distance
	uint iterations = 0;
	uint maxiterations = 20;
	
	[loop] while (iterations < maxiterations)
	{
		doneNP = doneN && doneP;
		if (doneNP) break;
		if (!doneN)
		{
			posN -= offNP;
			lumaEndN = dotweight(middle, TSMAA_DecodeTex2D(ReShade::BackBuffer, posN).rgb, useluma, __TSMAA_LUMA_REF);
			lumaEndN -= lumaNN;
			doneN = abs(lumaEndN) >= gradientScaled;
		}
		if (!doneP)
		{
			posP += offNP;
			lumaEndP = dotweight(middle, TSMAA_DecodeTex2D(ReShade::BackBuffer, posP).rgb, useluma, __TSMAA_LUMA_REF);
			lumaEndP -= lumaNN;
			doneP = abs(lumaEndP) >= gradientScaled;
		}
		iterations++;
    }
	
	float2 dstNP = float2(texcoord.y - posN.y, posP.y - texcoord.y);
	TSMAAMovc(bool(horzSpan).xx, dstNP, float2(texcoord.x - posN.x, posP.x - texcoord.x));
	
	bool goodSpan = (dstNP.x < dstNP.y) ? ((lumaEndN < 0.0) != lumaMLTZero) : ((lumaEndP < 0.0) != lumaMLTZero);
	float pixelOffset = mad(-rcp(dstNP.y + dstNP.x), min(dstNP.x, dstNP.y), 0.5);
	float subpixOut = pixelOffset * maxblending;

	[branch] if (!goodSpan)
	{
		subpixOut = mad(mad(2.0, lumaS + lumaE + lumaN + lumaW, lumaNW + lumaSE + lumaNE + lumaSW), 0.083333, -lumaM) * rcp(lumaRange); //ABC
		subpixOut = pow(saturate(mad(-2.0, subpixOut, 3.0) * (subpixOut * subpixOut)), 2.0) * maxblending * pixelOffset; // DEFGH
	}

	float2 posM = texcoord;
	TSMAAMovc(bool2(!horzSpan, horzSpan), posM, float2(posM.x + lengthSign * subpixOut, posM.y + lengthSign * subpixOut));
    
	return TSMAA_Tex2D(ReShade::BackBuffer, posM).rgb;
}

/***************************************************************************************************************************************/
/********************************************************** SMAA SHADER CODE END *******************************************************/
/***************************************************************************************************************************************/

technique Smoothing <
	ui_tooltip = "============================================================\n"
				 "Temporal Subpixel Morphological Anti-Aliasing uses past\n"
				 "frame data in all stages of the shader to try to enhance the\n"
				 "overall anti-aliasing effect. This is an experimental shader\n"
				 "and may not necessarily produce desirable output.\n"
				 "============================================================";
>
{
	pass Smoothing
	{
		VertexShader = TSMAANeighborhoodBlendingVS;
		PixelShader = TSMAASmoothingPS;
	}
}
