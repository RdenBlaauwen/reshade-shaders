/**
* Commonly used convenience functions. These need to be tested for performance.
*/

/////////////////////////////////// CREDITS ///////////////////////////////////
// Do not distribute without giving credit to the original author(s).
// All original code not attributed to the below authors is made by
// Robert den Blaauwen aka "RdenBlaauwen" (rdenblaauwen@gmail.com)
/**
 * This code includes depth linearization functions adapted from DisplayDepth.fx,
 * written by CeeJay.dk (with many updates and additions by the Reshade community).
 * https://github.com/crosire/reshade-shaders/blob/slim/Shaders/DisplayDepth.fx 
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

  // TODO: try changing into pre-processor val
  static const float3 LUMA_WEIGHTS = float3(0.2126, 0.7152, 0.0722);

  float max(float a, float b,float c)
  {
    return max(a,max(b,c));
  }
  float max(float a,float b,float c,float d)
  {
    return max(a, max(b,c,d));
  }
  float max(float a,float b,float c,float d, float e)
  {
    return max(a, max(b,c,d,e));
  }
  float max(float a,float b,float c,float d, float e, float f)
  {
    return max(a, max(b,c,d,e,f));
  }
  float max(float a,float b,float c,float d, float e, float f, float g)
  {
    return max(a, max(b,c,d,e,f,g));
  }
  float max(float a,float b,float c,float d, float e, float f, float g, float h)
  {
    return max(a, max(b,c,d,e,f,g,h));
  }
  float max(float a,float b,float c,float d, float e, float f, float g, float h, float i)
  {
    return max(a, max(b,c,d,e,f,g,h,i));
  }

  float2 max(float2 a, float2 b,float2 c)
  {
    return max(a,max(b,c));
  }
  float2 max(float2 a,float2 b,float2 c,float2 d)
  {
    return max(a, max(b,c,d));
  }
  float2 max(float2 a,float2 b,float2 c,float2 d, float2 e)
  {
    return max(a, max(b,c,d,e));
  }
  float2 max(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f)
  {
    return max(a, max(b,c,d,e,f));
  }
  float2 max(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g)
  {
    return max(a, max(b,c,d,e,f,g));
  }
  float2 max(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g, float2 h)
  {
    return max(a, max(b,c,d,e,f,g,h));
  }
  float2 max(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g, float2 h, float2 i)
  {
    return max(a, max(b,c,d,e,f,g,h,i));
  }

  float3 max(float3 a, float3 b,float3 c)
  {
    return max(a,max(b,c));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d)
  {
    return max(a, max(b,c,d));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d, float3 e)
  {
    return max(a, max(b,c,d,e));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f)
  {
    return max(a, max(b,c,d,e,f));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g)
  {
    return max(a, max(b,c,d,e,f,g));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h)
  {
    return max(a, max(b,c,d,e,f,g,h));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h, float3 i)
  {
    return max(a, max(b,c,d,e,f,g,h,i));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h, float3 i, float3 j)
  {
    return max(a, max(b,c,d,e,f,g,h,i,j));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h, float3 i, float3 j, float3 k)
  {
    return max(a, max(b,c,d,e,f,g,h,i,j,k));
  }
  float3 max(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h, float3 i, float3 j, float3 k, float3 l)
  {
    return max(a, max(b,c,d,e,f,g,h,i,j,k,l));
  }

  float min(float a, float b,float c)
  {
    return min(a,min(b,c));
  }
  float min(float a,float b,float c,float d)
  {
    return min(a, min(b,c,d));
  }
  float min(float a,float b,float c,float d, float e)
  {
    return min(a, min(b,c,d,e));
  }
  float min(float a,float b,float c,float d, float e, float f)
  {
    return min(a, min(b,c,d,e,f));
  }
  float min(float a,float b,float c,float d, float e, float f, float g)
  {
    return min(a, min(b,c,d,e,f,g));
  }
  float min(float a,float b,float c,float d, float e, float f, float g, float h)
  {
    return min(a, min(b,c,d,e,f,g,h));
  }
  float min(float a,float b,float c,float d, float e, float f, float g, float h, float i)
  {
    return min(a, min(b,c,d,e,f,g,h,i));
  }

  float2 min(float2 a, float2 b,float2 c)
  {
    return min(a,min(b,c));
  }
  float2 min(float2 a,float2 b,float2 c,float2 d)
  {
    return min(a, min(b,c,d));
  }
  float2 min(float2 a,float2 b,float2 c,float2 d, float2 e)
  {
    return min(a, min(b,c,d,e));
  }
  float2 min(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f)
  {
    return min(a, min(b,c,d,e,f));
  }
  float2 min(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g)
  {
    return min(a, min(b,c,d,e,f,g));
  }
  float2 min(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g, float2 h)
  {
    return min(a, min(b,c,d,e,f,g,h));
  }
  float2 min(float2 a,float2 b,float2 c,float2 d, float2 e, float2 f, float2 g, float2 h, float2 i)
  {
    return min(a, min(b,c,d,e,f,g,h,i));
  }

  float3 min(float3 a, float3 b,float3 c)
  {
    return min(a,min(b,c));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d)
  {
    return min(a, min(b,c,d));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d, float3 e)
  {
    return min(a, min(b,c,d,e));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f)
  {
    return min(a, min(b,c,d,e,f));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g)
  {
    return min(a, min(b,c,d,e,f,g));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h)
  {
    return min(a, min(b,c,d,e,f,g,h));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h, float3 i)
  {
    return min(a, min(b,c,d,e,f,g,h,i));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h, float3 i, float3 j)
  {
    return min(a, min(b,c,d,e,f,g,h,i,j));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h, float3 i, float3 j, float3 k)
  {
    return min(a, min(b,c,d,e,f,g,h,i,j,k));
  }
  float3 min(float3 a,float3 b,float3 c,float3 d, float3 e, float3 f, float3 g, float3 h, float3 i, float3 j, float3 k, float3 l)
  {
    return min(a, min(b,c,d,e,f,g,h,i,j,k,l));
  }

  float max(float2 rg)
  {
    return max(rg.r, rg.g);
  }
  float max(float3 rgb)
  {
    return max(max(rgb.rg), rgb.b);
  }
  float max(float4 rgba)
  {
    return max(max(rgba.rgb), rgba.a);
  }
  
  float min(float2 rg)
  {
    return min(rg.r, rg.g);
  }
  float min(float3 rgb)
  {
    return min(min(rgb.rg), rgb.b);
  }
  float min(float4 rgba)
  {
    return min(min(rgba.rgb), rgba.a);
  }

  float sum(float2 vec)
  {
    return Shared::dotArithmetic(vec, 1.0);
  }
  float sum(float3 vec)
  {
    return Shared::dotArithmetic(vec, 1.0);
  }
  float sum(float4 vec)
  {
    return Shared::dotArithmetic(vec, 1.0);
  }

  float avg(float2 vec)
  {
    return Shared::dotArithmetic(vec, 0.5);
  }
  float avg(float3 vec)
  {
    const float mod = 1.0 / 3.0;
    return Shared::dotArithmetic(vec, mod);
  }
  float avg(float4 vec)
  {
    return Shared::dotArithmetic(vec, 0.25);
  }
  float avg(float x, float y, float z, float w)
  {
    return avg(float4(x,y,z,w));
  }

  /**
   * Custom implementations of any() that appears to run slightly faster than vanilla.
   */
  bool any(float2 vec)
  {
    return sum(vec) > 0.0;
  }
  bool any(float3 vec)
  {
    return sum(vec) > 0.0;
  }
  bool any(float4 vec)
  {
    return sum(vec) > 0.0;
  }

  /**
  * From Lordbean's TSMAA
  */
  float dotweight(float3 middle, float3 neighbor, bool useluma, float3 weights)
  {
    if (useluma) return dot(neighbor, weights);
    else return dot(abs(middle - neighbor), LUMA_WEIGHTS);
  }

  /**
   * From Lordbean's TSMAA
   */
  float dotsat(float3 rgb, float L)
  {
    return ((max(rgb) - min(rgb)) / (1.0 - (2.0 * L - 1.0) + trunc(L)));
  }
  /**
  * From Lordbean's TSMAA
  */
  float dotsat(float3 rgb)
  {
    float xl = dot(rgb, LUMA_WEIGHTS);
    return ((max(rgb) - min(rgb)) / (1.0 - (2.0 * xl - 1.0) + trunc(xl)));
  }

  /**
  * Turns a non-linear value into a linear value. Typically used to turn depth into linear depth.
  * 
  * From DisplayDepth.fx, by CeeJay.dk (with many updates and additions by the Reshade community).
  *
  * @param float nonLinear non-linear value to be converted
  * @param bool logarithmic whether the input value is logarithmic
  * @param bool reverse whether the input is reversed.
  * @return float input converted into linear
  */
  float linearize(float nonLinear, float farPlane, bool logarithmic, bool reversed) {
    const float C = 0.01;
    float linVal = nonLinear;
    if (logarithmic) // RESHADE_DEPTH_INPUT_IS_LOGARITHMIC
      linVal = (exp(linVal * log(C + 1.0)) - 1.0) / C;

    if (reversed) // RESHADE_DEPTH_INPUT_IS_REVERSED
      linVal = 1.0 - linVal;

    const float N = 1.0;
    linVal /= farPlane - linVal * (farPlane - N);

    return linVal;
  }

  /**
  * A wrapper around linearize() that turns non-linear depth into linear depth.
  * Uses Reshade's environment variables to decide how to convert depth.
  *
  * @param float nonLinear non-linear value to be converted
  * @return float input converted into linear depth
  */
  float linearizeDepth(float depth) {
    return linearize(
      depth, 
      RESHADE_DEPTH_LINEARIZATION_FAR_PLANE, 
      RESHADE_DEPTH_INPUT_IS_LOGARITHMIC, 
      RESHADE_DEPTH_INPUT_IS_REVERSED
    );
  }

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
  float clampScale(float input, float modifier, float floor, float ceil)
  {
    return clamp(input * modifier, floor, ceil);
  }

  float luma(float3 rgb) {
    const float3 LUMA_WEIGHTS = float3(0.2126, 0.7152, 0.0722);
    return dot(rgb, LUMA_WEIGHTS);
  }
}