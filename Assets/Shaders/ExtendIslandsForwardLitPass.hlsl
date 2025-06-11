#pragma once

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float3 positionOS : POSITION;
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
};

TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
TEXTURE2D(_UVIslands); SAMPLER(sampler_UVIslands);

float4 _MainTex_ST;
float4 _MainTex_TexelSize;
float4 _UVIslands_ST;
float _ExtendDistance;

Interpolators Vertex(Attributes input)
{
    Interpolators output;
    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS);
    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    return output;
}

float4 Fragment(Interpolators input) : SV_Target
{
    float2 offsets[8] = {float2(-_ExtendDistance, 0), float2(_ExtendDistance, 0),
                         float2(0, _ExtendDistance), float2(0, -_ExtendDistance),
                         float2(-_ExtendDistance, _ExtendDistance), float2(_ExtendDistance, _ExtendDistance),
                         float2(_ExtendDistance, -_ExtendDistance), float2(-_ExtendDistance, -_ExtendDistance)};

	float2 uv = input.uv;
	float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
	float4 islands = SAMPLE_TEXTURE2D(_UVIslands, sampler_UVIslands, uv);

    if (islands.z < 1)
    {
        float4 extendedColor = color;

        [unroll(8)]
        for	(uint i = 0; i < 8; i++)
        {
            float2 currentUV = uv + offsets[i] * _MainTex_TexelSize.xy;
            float4 offsettedColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, currentUV);
            extendedColor = max(offsettedColor, extendedColor);
        }

        color = extendedColor;
    }

	return color;
}