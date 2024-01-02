/**
* Commonly used convenience functions. These need to be tested for performance.
*/
namespace Lib
{
  namespace Shared
  {
    float dotArithmetic(float2 vec, float weight)
    {
      return dot(vec, float2(weight, weight));
    }
    float dotArithmetic(float3 vec, float weight)
    {
      return dot(vec, float3(weight, weight, weight));
    }
    float dotArithmetic(float4 vec, float weight)
    {
      return dot(vec, float4(weight, weight, weight, weight));
    }
  }

  static const float3 LUMA_WEIGHTS = float3(0.2126, 0.7152, 0.0722);

  // Uncomment code below for testing
  // /**
  // * From Lordbean's TSMAA
  // */
  // float dotweight(float3 middle, float3 neighbor, bool useluma, float3 weights)
  // {
  //   if (useluma) return dot(neighbor, weights);
  //   else return dot(abs(middle - neighbor), LUMA_WEIGHTS);
  // }

  float max3(float a, float b,float c)
  {
    return max(a,max(b,c));
  }
  float max4(float a,float b,float c,float d)
  {
    return max(a, max3(b,c,d));
  }
  float max5(float a,float b,float c,float d, float e)
  {
    return max(a, max4(b,c,d,e));
  }
  float max6(float a,float b,float c,float d, float e, float f)
  {
    return max(a, max5(b,c,d,e,f));
  }
  float max7(float a,float b,float c,float d, float e, float f, float g)
  {
    return max(a, max6(b,c,d,e,f,g));
  }
  float max8(float a,float b,float c,float d, float e, float f, float g, float h)
  {
    return max(a, max7(b,c,d,e,f,g,h));
  }
  float max9(float a,float b,float c,float d, float e, float f, float g, float h)
  {
    return max(a, max8(b,c,d,e,f,g,h,i));
  }

  float2 max3(float2 a, float2 b,float2 c)
  {
    return max(a,max(b,c));
  }
  float2 max4(float2 a,float2 b,float2 c,float2 d)
  {
    return max(a, max3(b,c,d));
  }
  float2 max5(float2 a,float2 b,float2 c,float2 d, float2 e)
  {
    return max(a, max4(b,c,d,e));
  }
  float2 max6(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f)
  {
    return max(a, max5(b,c,d,e,f));
  }
  float2 max7(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g)
  {
    return max(a, max6(b,c,d,e,f,g));
  }
  float2 max8(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g, float2 h)
  {
    return max(a, max7(b,c,d,e,f,g,h));
  }
  float2 max9(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g, float2 h)
  {
    return max(a, max8(b,c,d,e,f,g,h,i));
  }

  float3 max3(float3 a, float3 b,float3 c)
  {
    return max(a,max(b,c));
  }
  float3 max4(float3 a,float3 b,float3 c,float3 d)
  {
    return max(a, max3(b,c,d));
  }
  float3 max5(float3 a,float3 b,float3 c,float3 d, float3 e)
  {
    return max(a, max4(b,c,d,e));
  }
  float3 max6(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f)
  {
    return max(a, max5(b,c,d,e,f));
  }
  float3 max7(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g)
  {
    return max(a, max6(b,c,d,e,f,g));
  }
  float3 max8(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h)
  {
    return max(a, max7(b,c,d,e,f,g,h));
  }
  float3 max9(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h)
  {
    return max(a, max8(b,c,d,e,f,g,h,i));
  }

  float min3(float a, float b,float c)
  {
    return min(a,min(b,c));
  }
  float min4(float a,float b,float c,float d)
  {
    return min(a, min3(b,c,d));
  }
  float min5(float a,float b,float c,float d, float e)
  {
    return min(a, min4(b,c,d,e));
  }
  float min6(float a,float b,float c,float d, float e, float f)
  {
    return min(a, min5(b,c,d,e,f));
  }
  float min7(float a,float b,float c,float d, float e, float f, float g)
  {
    return min(a, min6(b,c,d,e,f,g));
  }
  float min8(float a,float b,float c,float d, float e, float f, float g, float h)
  {
    return min(a, min7(b,c,d,e,f,g,h));
  }
  float min9(float a,float b,float c,float d, float e, float f, float g, float h)
  {
    return min(a, min8(b,c,d,e,f,g,h,i));
  }

  float2 min3(float2 a, float2 b,float2 c)
  {
    return min(a,min(b,c));
  }
  float2 min4(float2 a,float2 b,float2 c,float2 d)
  {
    return min(a, min3(b,c,d));
  }
  float2 min5(float2 a,float2 b,float2 c,float2 d, float2 e)
  {
    return min(a, min4(b,c,d,e));
  }
  float2 min6(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f)
  {
    return min(a, min5(b,c,d,e,f));
  }
  float2 min7(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g)
  {
    return min(a, min6(b,c,d,e,f,g));
  }
  float2 min8(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g, float2 h)
  {
    return min(a, min7(b,c,d,e,f,g,h));
  }
  float2 min9(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g, float2 h)
  {
    return min(a, min8(b,c,d,e,f,g,h,i));
  }

  float3 min3(float3 a, float3 b,float3 c)
  {
    return min(a,min(b,c));
  }
  float3 min4(float3 a,float3 b,float3 c,float3 d)
  {
    return min(a, min3(b,c,d));
  }
  float3 min5(float3 a,float3 b,float3 c,float3 d, float3 e)
  {
    return min(a, min4(b,c,d,e));
  }
  float3 min6(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f)
  {
    return min(a, min5(b,c,d,e,f));
  }
  float3 min7(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g)
  {
    return min(a, min6(b,c,d,e,f,g));
  }
  float3 min8(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h)
  {
    return min(a, min7(b,c,d,e,f,g,h));
  }
  float3 min9(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h)
  {
    return min(a, min8(b,c,d,e,f,g,h,i));
  }

  // Uncomment code below in the process of testing
  // /**
  //  * From Lordbean's TSMAA
  //  */
  // float dotsat(float3 rgb, float L)
  // {
  //   return ((max3(rgb) - min3(rgb)) / (1.0 - (2.0 * L - 1.0) + trunc(L)));
  // }
  // /**
  // * From Lordbean's TSMAA
  // */
  // float dotsat(float3 rgb)
  // {
  //   float xl = dot(rgb, LUMA_WEIGHTS);
  //   return ((max3(rgb) - min3(rgb)) / (1.0 - (2.0 * xl - 1.0) + trunc(xl)));
  // }
  // Uncomment code above in the process of testing

  // Uncomment code below in the process of testing
  // float maxComp(float2 rg)
  // {
  //   return max(rg.r, rg.g);
  // }
  // float maxComp(float3 rgb)
  // {
  //   return max(maxComp(rgb.rg), rgb.b);
  // }
  // float maxComp(float4 rgba)
  // {
  //   return max(maxComp(rgba.rgb), rgba.a);
  // }
  // Uncomment code above in the process of testing
  
  float minComp(float2 rg)
  {
    return min(rg.r, rg.g);
  }
  float minComp(float3 rgb)
  {
    return min(minComp(rgb.rg), rgb.b);
  }
  float minComp(float4 rgba)
  {
    return min(minComp(rgba.rgb), rgba.a);
  }

  // Uncomment code below in the process of testing
  // float sum(float2 vec)
  // {
  //   return Shared::dotArithmetic(vec, 1.0);
  // }
  // float sum(float3 vec)
  // {
  //   return Shared::dotArithmetic(vec, 1.0);
  // }
  // float sum(float4 vec)
  // {
  //   return Shared::dotArithmetic(vec, 1.0);
  // }

  // float avg(float2 vec)
  // {
  //   return Shared::dotArithmetic(vec, 0.5);
  // }
  // float avg(float3 vec)
  // {
  //   return Shared::dotArithmetic(vec, 0.333333333);
  // }
  // float avg(float4 vec)
  // {
  //   return Shared::dotArithmetic(vec, 0.25);
  // }
  // float avg(float x, float y, float z, float w)
  // {
  //   return avg(float4(x,y,z,w));
  // }
  // Uncomment code above in the process of testing

  // // Uncomment code below in the process of testing
  // /**
  // * Turns a non-linear value into a linear value. Typically used to turn depth into linear depth.
  // * 
  // * Borrowed from DisplayDepth.fx, by CeeJay.dk (with many updates and additions by the Reshade community).
  // *
  // * @param float nonLinear non-linear value to be converted
  // * @param bool logarithmic whether the input value is logarithmic
  // * @param bool reverse whether the input is reversed.
  // * @return float input converted into linear
  // */
  // float linearize(float nonLinear, bool logarithmic, bool reversed) {
  //   const float C = 0.01;
  //   float linVal = nonLinear;
  //   if (logarithmic) // RESHADE_DEPTH_INPUT_IS_LOGARITHMIC
  //     linVal = (exp(linVal * log(C + 1.0)) - 1.0) / C;

  //   if (reversed) // RESHADE_DEPTH_INPUT_IS_REVERSED
  //     linVal = 1.0 - linVal;

  //   const float N = 1.0;
  //   linVal /= RESHADE_DEPTH_LINEARIZATION_FAR_PLANE - linVal * (RESHADE_DEPTH_LINEARIZATION_FAR_PLANE - N);

  //   return linVal;
  // }

  // /**
  // * A wrapper around linearize() that turns non-linear depth into linear depth.
  // * Uses Reshade's environment variables to decide how to convert depth.
  // *
  // * @param float nonLinear non-linear value to be converted
  // * @return float input converted into linear depth
  // */
  // float linearizeDepth(float depth) {
  //   return linearize(depth, RESHADE_DEPTH_INPUT_IS_LOGARITHMIC, RESHADE_DEPTH_INPUT_IS_REVERSED);
  // }
  // Uncomment code above in the process of testing

  /**
   * @SCALE_LINEAR
   * Meant for turning linear values super-linear: Makes it's input bigger in such a way that lower values become 
   * proportionally bigger than higher values. Output never exceeds 1.0;
   *
   * @param `val` input to be scaled
   * @return output val. Amplified in a non-linear fashion.
   */
  float sineScale(float val){
    const float piHalf = 1.5707;
    return val = sin(val * piHalf);
  }

  /**
   * @param input some factor with a value of threshold floor 0.0 - 1.0
   */
  float clampedScale(float input, float modifier, float floor, float ceil)
  {
    return clamp(input * modifier, floor, ceil);
  }
}