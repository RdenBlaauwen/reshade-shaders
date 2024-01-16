/////////////////////////////////// CREDITS ///////////////////////////////////
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

#include "../shared/lib.fxh"

// TODO: could have: make different implementations for different shader languages
#define ESMAASampler2D(tex) sampler tex
#define ESMAASample(tex, coord) tex2D(tex, coord)
#define ESMAASamplePoint(tex, coord) ESMAASample(tex, coord)
#define ESMAASampleLevelZeroOffset(tex, coord, offset) tex2Dlodoffset(tex, float4(coord, coord), offset)
#define ESMAAGatherRed(tex, coord) tex2Dgather(tex, texcoord, 0);
#define ESMAAGatherRedOffset(tex, coord, offset) tex2Dgatheroffset(tex, texcoord, offset, 0);

#define ESMAA_RENDERER __RENDERER__
#define ESMAA_RENDERER_D3D10 0xa000 
#define ESMAA_LUMA_REF float3(0.2126, 0.7152, 0.0722) // weights for luma calculations

namespace ESMAACore
{
  namespace Predication
  {
    /**
    * This function is meant for edge predication. It detects geometric edges using depth-detection with high accuracy, but in a symmetric fashion.
    * Which means it detects pixels around both sides of edges. This ironically makes it pretty bad for real edge detecion,
    * but potentially great for edge predication. I like to call it "edge prediction".
    * 
    * It works in two phases. First it does conventional predication using depth-based edge detection, just like normal SMAA. 
    * If this finds anything, it returns early. This will henceforth be refered to as "edge detection".
    * Otherwise it continues to do the "edge prediction" as described above. 
    * 
    * Strange as it may sound, this is actually a highly modified version of Lordbean's image softening,
    * taken from his TSMAA shader, adapted to use depth info instead. Works like a charm.
    * 
    * @param texcoord: float2 Coordinates of current texel, just like edge detection functions.
    * @param offset[3]: float4[3] Contains coordinates of 6 neighboring texels, equal to the ones used in edge detection functions.
    * @param ESMAASampler2D(depthSampler) Depthbuffer sampler. Assumes depthbuffer is logarithmic, and not reverted.
    * @param detectionThresh: float Used to detect presence of edges with high certainty. 
    *   Same as normal SMAA predication threshold. 
    *   Used for detecting (possible) edges with linearized depth, just like normal SMAA predication.
    *   Asymmetric, only detects edges to left and top.
    * @param predictionThresh: float Used to detect presence of edges with low certainty.
    *   Used for detecting possible edges with non-linear depth.
    *   Symmetric, detects possibility of edges in any direction. Can not distinguish between directions.
    * @param useOpposingEdgesCheck: bool Checks if edges can be detected to the right and bottom with high certainty.
    *   using detectionThresh and linearized depths. If any are found, it means the current texel is likely on the wrong side of edge,
    *   which leads to an early return with return val float2(0.0,0.0). Helps to make edge prediction more asymmetric.
    * @param compareLeftAndTopDeltaWithLocalAvg: bool Checks if delta between left and top is much greater than delta with local avg.
    *   This happens AFTER edge detection has failed.
    *   If true, return 1.0 for each significantly larger edge, instead of the normal 0.5 that edge prediction returns.
    *   Helps to detect presence of edges with higher certainty.
    *   Warning: Experimental, recommended value: false.
    * @return float2 Contains 2 numbers (RG channels) representing left and top edge, ranging from 0.0 - 1.0. 
    * 	1.0 meaning a geometric edge is definitely there.
    *	  0.0 meaning there is no geometric edge.
    *	  Anything in between is a "maybe".
    *
    * Warning: if this function returns a 1.0 somewhere it should not be assumed there is definitively an edge, as there is sometimes
    * a disconnect between geometric and visual data.
    * Warning: do NOT use this as a true edge-detection algo. It WILL lead to false positives and artifacts!
    */
    float2 DepthEdgeEstimation(
      float2 texcoord, 
      float4 offset[3],
      ESMAASampler2D(depthSampler), 
      float detectionThresh,
      float predictionThresh,
      bool useOpposingEdgesCheck,
      bool compareLeftAndTopDeltaWithLocalAvg
      )
    {
      // pattern:
      //  e f g
      //  h a b
      //  i c d
      float e,f,h,a, original;

      #if ESMAA_RENDERER >= ESMAA_RENDERER_D3D10 // if DX10 or above
        // get RGB values from the c, d, b, and a positions, in order.
        float4 hafe = ESMAAGatherRedOffset(depthSampler, texcoord, int2(-1, -1));
        e = hafe.w;
        f = hafe.z;
        h = hafe.x;
        a = hafe.y;
        original = a;
      #else // if DX9
        e = ESMAASampleLevelZeroOffset(depthSampler, texcoord, int2(-1, -1)).r;
        f = ESMAASampleLevelZeroOffset(depthSampler, texcoord, int2(0, -1)).r;
        h = ESMAASampleLevelZeroOffset(depthSampler, texcoord, int2(-1, 0)).r;
        a = SMAASampleLevelZero(depthSampler, texcoord).r;
        original = a;
      #endif


      float currDepth = Lib::linearizeDepth(a);
      float topDepth = Lib::linearizeDepth(f);
      float leftDepth = Lib::linearizeDepth(h);

      // Scale so that the treshold is lower closeup, higher at medium distances, and much lower far away.
      // TODO: refactor, isolate into separate function.
      // TODO: See if replacing by lookup table improves performance.
      float depthScaling = (0.3 + (0.7 * currDepth * (5 - ((5 + 0.3) * currDepth))));
      float detectionThreshold = detectionThresh * depthScaling;

      float3 neighbours = float3(currDepth, leftDepth, topDepth);
      float2 delta = abs(neighbours.xx - float2(neighbours.y, neighbours.z));
      float2 edges = step(detectionThreshold, delta);
      bool anyEdges = Lib::any(edges);

      // bool surface = false;
      // if(ESMAADepthDataSurfaceCheck && anyEdges > 0.0){
      // 	float2 farDeltas;
      // 	if(edges.r > 0.0){
      // 		float hLeft = ESMAASampleLevelZeroOffset(depthSampler, texcoord, int2(-2, 0)).r;
      // 		float leftLeftDepth = linearizeDepth(hLeft);
      // 		farDeltas.r = abs(leftDepth - leftLeftDepth);
      // 	}
      // 	if(edges.g > 0.0){
      // 		float fTop = ESMAASampleLevelZeroOffset(depthSampler, texcoord, int2(0, -2)).r;
      // 		float topTopDepth = linearizeDepth(fTop);
      // 		farDeltas.g = abs(topDepth - topTopDepth);
      // 	}
      // 	float2 farEdges = step(detectionThreshold,farDeltas);
      // 	surface = dot(farEdges, float2(1.0,1.0)) > 0.0;
      // }

      // Early return if there is an edge:
        // if (!surface && anyEdges > 0.0)
        //     return edges;

      if (anyEdges)
            return edges;

      float factor = a + saturate(0.001 - a) * 2.0;
      predictionThresh *= factor;

      float b,c,d;
      #if ESMAA_RENDERER >= ESMAA_RENDERER_D3D10 // if DX10 or above
        // get RGB values from the c, d, b, and a positions, in order.
        float4 cdba = ESMAAGatherRed(depthSampler, texcoord);
        b = cdba.z;
        c = cdba.x;
        d = cdba.y;
      #else // if DX9
        b = ESMAASampleLevelZeroOffset(depthSampler, texcoord, int2(1, 0)).r;
        c = ESMAASampleLevelZeroOffset(depthSampler, texcoord, int2(0, 1)).r;
        d = ESMAASampleLevelZeroOffset(depthSampler, texcoord, int2(1, 1)).r;
      #endif

      // TODO: consider only doing early return if all edges are negated by an opposing edge
      // rather than detection of any opposing edge.
      if(useOpposingEdgesCheck){
        float3 oppNeighbs = float3(a, b, c);
        float2 oppDelta = abs(oppNeighbs.xx - float2(oppNeighbs.y, oppNeighbs.z));
        edges = step(detectionThreshold, oppDelta);

        // Early return if there is an edge:
        if (Lib::any(edges))
          return float2(0.0, 0.0);
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

      float localDelta = abs(a - localAvg);

      if (localDelta > predictionThresh) {
        // TODO: Try using this to filter when opposing edges are greater than avg.
        if(compareLeftAndTopDeltaWithLocalAvg){
          // If delta between top, left and current is much greater than
          // delta of localaverage, return 1.0 for each detected edge.
          //TODO: Use log delta instead of linear delta,
          // because this is an apples and oranges comparison.
          float2 res = step(localDelta * 4.0, delta);
          // TODO: Shouldn't this be >= 1.0?
          if(Lib::sum(res) == 1.0){
            return res;
          }
        }
        // This is like saying "Maybe there's an edge here, maybe there isn't. 
        // Please keep an eye out for jaggies just in case.".
        return float2(0.5, 0.5); 
      }
      return float2(0.0, 0.0);
    }
  }

  namespace EdgeDetection
  {
    /**
    * Scales the input value so that lower and middle values get relatively bigger.
    * Result is clamped between floor and 1.0.
    * Useful for situation where extreme values shouldn't have a disproportionate effect.
    * 
    * @param input: float Some factor with a value of 0.0 - 1.0.
    * @param floor: float The minimum output.
    * @param scaleFactor: float The factor by which the input is multiplied.
    * @return float Factor that represents scaling strength. multiply threshold by this factor.
    */
    float getThresholdScale(float input, float floor, float scaleFactor){
      return Lib::clampScale(
        input, 
        scaleFactor, 
        floor, 
        1.0
        );
    }
    /**
    * Luma Edge Detection taken and adapted from the official SMAA.fxh file (see SMAA credits above).
    * Adapted to use adaptive thresholding. 
    * Does early return of edges instead of discarding, so that other detection methods can take over.
    *
    * IMPORTANT NOTICE: luma edge detection requires gamma-corrected colors, and
    * thus 'colorTex' should be a non-sRGB texture.
    *
    * @param texcoord: float2 Coordinates of current texel, represented by float values of 0.0 - 1.0.
    * @param offset[3]: float[3] Coordinates of neighbours.
    *   offset[0].xy: left neighbour.
    *   offset[0].zw: top neighbour.
    *   offset[1].xy: right neighbour.
    *   offset[1].zw: bottom neighbour.
    *   offset[2].xy: left neighbour twice removed.
    *   offset[2].zw: left neighbour twice removed.
    * @param ESMAASampler2D(colorTex) 2D sampler for gamma-corrected colors.
    *   texture properties:
    *     AddressU = Clamp; AddressV = Clamp;
	  *     MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
	  *     SRGBTexture = false;
    * @param baseThreshold: float The threshold that any delta must cross before being considered an edge.
    * @param localContrastAdaptationFactor: float See original SMAA shader for explanation.
    * @param enableAdaptiveThreshold: bool If true, edge detection lowers threshold based on the local max intensity.
    *   Compensates for fact that darker areas cannot have deltas as big as brighter areas.
    * @param threshScaleFloor: float Lowest value that the threshold can be lowered to.
    * @param threshScaleFactor: float Factor by which local max intensity is multiplied before clamping between 0.0 - 1.0
    *   Values above 1.0 means threshold is lowered less, prevents dark areas from having ridiculously low thresholds.
    * @return float2 Whether edges have been detected to left and top. 
    *   0.0 means no edge detected, 1.0 means edge detected. Nothing in between.
    *   x: Represents edge with left texel.
    *   y: Represents edge with top texel.
    */
    float2 LumaDetection(
      float2 texcoord,
      float4 offset[3],
      ESMAASampler2D(colorTex),
      float baseThreshold,
      float localContrastAdaptationFactor,
      bool enableAdaptiveThreshold,
      float threshScaleFloor,
      float threshScaleFactor
    ) {
      // Calculate lumas:
      float3 weights = ESMAA_LUMA_REF; // TODO: consider turning into param
      float L = dot(ESMAASamplePoint(colorTex, texcoord).rgb, weights);

      float Lleft = dot(ESMAASamplePoint(colorTex, offset[0].xy).rgb, weights);
      float Ltop  = dot(ESMAASamplePoint(colorTex, offset[0].zw).rgb, weights);

      // ADAPTIVE THRESHOLD START
      float maxLuma;
      float minLuma;
      float2 threshold = float2(baseThreshold, baseThreshold);
      if(enableAdaptiveThreshold){
        // use biggest local luma as basis
        maxLuma = Lib::max(L, Lleft, Ltop);
        minLuma = Lib::min(L, Lleft, Ltop);
        float range = maxLuma - minLuma;
        // scaled maxLuma so that only dark places have a significantly lower threshold
        threshold *= getThresholdScale(range, threshScaleFloor, threshScaleFactor);
      } 
      // ADAPTIVE THRESHOLD END

        // We do the usual threshold:
        float4 delta;
        delta.xy = abs(L - float2(Lleft, Ltop));
        float2 edges = step(threshold, delta.xy);

        // Early return if there is no edge:
        if (!Lib::any(edges))
            return edges;

        // Calculate right and bottom deltas:
        float Lright = dot(ESMAASamplePoint(colorTex, offset[1].xy).rgb, weights);
        float Lbottom  = dot(ESMAASamplePoint(colorTex, offset[1].zw).rgb, weights);
        delta.zw = abs(L - float2(Lright, Lbottom));

        // Calculate the maximum delta in the direct neighborhood:
        float2 maxDelta = max(delta.xy, delta.zw);

        // Calculate left-left and top-top deltas:
        float Lleftleft = dot(ESMAASamplePoint(colorTex, offset[2].xy).rgb, weights);
        float Ltoptop = dot(ESMAASamplePoint(colorTex, offset[2].zw).rgb, weights);
        delta.zw = abs(float2(Lleft, Ltop) - float2(Lleftleft, Ltoptop));

      // ADAPTIVE THRESHOLD second threshold check
      if(enableAdaptiveThreshold){
        // get therange from  ALL lumas this time
        float finalMaxLuma = Lib::max(maxLuma, Lright, Lbottom, Lleftleft, Ltoptop);
        float finalMinLuma = Lib::min(minLuma, Lright, Lbottom, Lleftleft, Ltoptop);
        float finalRange = finalMaxLuma - finalMinLuma;
        // scaled maxLuma so that only dark places have a significantly lower threshold
        threshold = float2(baseThreshold,baseThreshold) 
          * getThresholdScale(finalRange, threshScaleFloor, threshScaleFactor);
        // edges set to 1 if delta greater than thresholds, else set to 0
        edges = step(threshold, delta.xy);
      }
      // ADAPTIVE THRESHOLD second threshold check END

      // Calculate the final maximum delta:
      maxDelta = max(maxDelta.xy, delta.zw);
      float finalDelta = max(maxDelta.x, maxDelta.y);

      // Local contrast adaptation:
      edges.xy *= step(finalDelta, localContrastAdaptationFactor * delta.xy);

      return edges;
    }

    /**
    * Color Edge Detection taken and adapted from the official SMAA.fxh file (see SMAA credits above).
    * Adapted to use adaptive thresholding. 
    * Does early return of edges instead of discarding, so that other detection methods can take over.
    *
    * IMPORTANT NOTICE: color edge detection requires gamma-corrected colors, and
    * thus 'colorTex' should be a non-sRGB texture.
    *
    * @param texcoord: float2 Coordinates of current texel, represented by float values of 0.0 - 1.0.
    * @param offset[3]: float[3] Coordinates of neighbours.
    *   offset[0].xy: left neighbour.
    *   offset[0].zw: top neighbour.
    *   offset[1].xy: right neighbour.
    *   offset[1].zw: bottom neighbour.
    *   offset[2].xy: left neighbour twice removed.
    *   offset[2].zw: left neighbour twice removed.
    * @param ESMAASampler2D(colorTex) 2D sampler for gamma-corrected colors.
    *   texture properties:
    *     AddressU = Clamp; AddressV = Clamp;
	  *     MipFilter = Point; MinFilter = Linear; MagFilter = Linear;
	  *     SRGBTexture = false;
    * @param baseThreshold: float The threshold that any delta must cross before being considered an edge.
    * @param localContrastAdaptationFactor: float See original SMAA shader for explanation.
    * @param enableAdaptiveThreshold: bool If true, edge detection lowers threshold based on the local max intensity.
    *   Compensates for fact that darker areas cannot have deltas as big as brighter areas.
    * @param threshScaleFloor: float Lowest value that the threshold can be lowered to.
    * @param threshScaleFactor: float Factor by which local max intensity is multiplied before clamping between 0.0 - 1.0
    *   Values above 1.0 means threshold is lowered less, prevents dark areas from having ridiculously low thresholds.
    * @return float2 Whether edges have been detected to left and top. 
    *   0.0 means no edge detected, 1.0 means edge detected. Nothing in between.
    *   x: Represents edge with left texel.
    *   y: Represents edge with top texel.
    */
    float2 ChromaDetection(
      float2 texcoord,
      float4 offset[3],
      ESMAASampler2D(colorTex),
      float baseThreshold,
      float localContrastAdaptationFactor,
      bool enableAdaptiveThreshold,
      float threshScaleFloor,
      float threshScaleFactor
    ) {
        // Calculate color deltas:
        float4 delta;
        float3 C = ESMAASamplePoint(colorTex, texcoord).rgb;

        float3 Cleft = ESMAASamplePoint(colorTex, offset[0].xy).rgb;
        float3 t = abs(C - Cleft);
        delta.x = Lib::max(t);

        float3 Ctop  = ESMAASamplePoint(colorTex, offset[0].zw).rgb;
        t = abs(C - Ctop);
        delta.y = Lib::max(t);

      // ADAPTIVE THRESHOLD START

      float maxChroma;
      float2 threshold = float2(baseThreshold, baseThreshold);
      if(enableAdaptiveThreshold){
        maxChroma = Lib::max(
          Lib::max(C),
          Lib::max(Cleft),
          Lib::max(Ctop)
        );
        // scale maxChroma so that only dark places have a significantly lower threshold
        threshold *= getThresholdScale(maxChroma, threshScaleFloor, threshScaleFactor);
      }

      // ADAPTIVE THRESHOLD END

        // We do the usual threshold:
        float2 edges = step(threshold, delta.xy);

        // Early return if there is no edge:
        if (!Lib::any(edges))
            return edges;

        // Calculate right and bottom deltas:
        float3 Cright = ESMAASamplePoint(colorTex, offset[1].xy).rgb;
        t = abs(C - Cright);
        delta.z = Lib::max(t);

        float3 Cbottom  = ESMAASamplePoint(colorTex, offset[1].zw).rgb;
        t = abs(C - Cbottom);
        delta.w = Lib::max(t);

        // Calculate the maximum delta in the direct neighborhood:
        float2 maxDelta = max(delta.xy, delta.zw);

        // Calculate left-left and top-top deltas:
        float3 Cleftleft  = ESMAASamplePoint(colorTex, offset[2].xy).rgb;
        t = abs(Cleft - Cleftleft);
        delta.z = Lib::max(t);

        float3 Ctoptop = ESMAASamplePoint(colorTex, offset[2].zw).rgb;
        t = abs(Ctop - Ctoptop);
        delta.w = Lib::max(t);

        // Calculate the final maximum delta:
        maxDelta = max(maxDelta.xy, delta.zw);
        float finalDelta = max(maxDelta.x, maxDelta.y);

      // ADAPTIVE THRESHOLD second threshold check

      if(enableAdaptiveThreshold){
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
        threshold *= getThresholdScale(finalMaxChroma, threshScaleFloor, threshScaleFactor);
        // edges = step(threshold, delta.xy);
        edges = step(threshold, delta.xy);
      }
      
      // ADAPTIVE THRESHOLD second threshold check END

        // Local contrast adaptation:
        edges.xy *= step(finalDelta, localContrastAdaptationFactor * delta.xy);

        return edges;
    }
  }
}
