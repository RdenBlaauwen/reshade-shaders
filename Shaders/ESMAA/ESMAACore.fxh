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
    * Warning: if this function returns a 1.0 somewhere it should not be assumed there is definitively an edge, as there is sometimes
    * a disconnect between geometric and visual info.
    * Warning: do NOT use this as a true edge-detection algo. It WILL lead to false positives and artifacts!
    */
    float2 DepthEdgeEstimation(
      float2 texcoord, 
      float4 offset[3],
      ESMAASampler2D(depthSampler), 
      float threshold,
      float predicationThreshold,
      bool useAntiNeighbourCheck,
      bool useSymmetricPredication
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

      float depthScaling = (0.3 + (0.7 * currDepth * (5 - ((5 + 0.3) * currDepth))));
      float detectionThreshold = threshold * depthScaling;

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
      float predictionThreshold = predicationThreshold * factor;

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

      if(useAntiNeighbourCheck){
        float3 antiNeighbs = float3(a, b, c);
        float2 antiDelta = abs(antiNeighbs.xx - float2(antiNeighbs.y, antiNeighbs.z));
        edges = step(detectionThreshold, antiDelta);

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

      if (localDelta > predictionThreshold) {
        if(useSymmetricPredication){
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
        return float2(0.5, 0.5); 
      }
      return float2(0.0, 0.0);
    }
  }

  namespace EdgeDetection
  {
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
    float2 getThresholdScale(float input, float floor, float scaleFactor){
      return Lib::clampScale(
        input, 
        scaleFactor, 
        floor, 
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
      float2 threshold = float2(baseThreshold, baseThreshold);
      if(enableAdaptiveThreshold){
        // use biggest local luma as basis
        maxLuma = Lib::max(L, Lleft, Ltop);
        // scaled maxLuma so that only dark places have a significantly lower threshold
        threshold *= getThresholdScale(maxLuma, threshScaleFloor, threshScaleFactor);
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
        // get the greates from  ALL lumas this time
        // float finalMaxLuma = max(maxLuma, max(Lright, max(Lbottom,max(Lleftleft,Ltoptop))));
        float finalMaxLuma = Lib::max(maxLuma, Lright, Lbottom, Lleftleft, Ltoptop);
        // scaled maxLuma so that only dark places have a significantly lower threshold
        threshold *= getThresholdScale(finalMaxLuma, threshScaleFloor, threshScaleFactor);
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
    * Color Edge Detection taken and adapted from the official SMAA.fxh file, provided by the original team. (TODO: fix credits)
    * Adapted to use adaptive thresholding. 
    * Does early return of edges instead of discarding, so that other detection methods can take over.
    *
    * IMPORTANT NOTICE: color edge detection requires gamma-corrected colors, and
    * thus 'colorTex' should be a non-sRGB texture.
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
