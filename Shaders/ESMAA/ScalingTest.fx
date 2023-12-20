#include "ReShadeUI.fxh"

uniform uint TestRuns <
	ui_type = "slider";
	ui_min =0; ui_max = 500; ui_step = 1;
	ui_label = "nr of tests";
> = 1;

uniform bool UseSinScale <
	ui_label = "use sinScale";
> = false;

#include "ReShade.fxh"

float simpleScale(float linearVal){
    return linearVal * (2.0 - linearVal);
}

float sinScale(float linearVal){
    const float piHalf = 1.5707;
	return linearVal = sin(linearVal * piHalf);
}

float TestPS(
	float4 position : SV_Position,
	float2 texcoord : TEXCOORD0) : SV_Target
{
    float target = tex2D(ReShade::BackBuffer, texcoord).b;
    
    if(!UseSinScale){
        for(uint i = 0; i < TestRuns; i++){
            target = sinScale(target);
        }
    } else {
        for(uint i = 0; i < TestRuns; i++){
            target = simpleScale(target);
        }
    }

    return target;
}

technique ScalingTest {
    pass Test
	{
		VertexShader = PostProcessVS;
		PixelShader = TestPS;
	}
}