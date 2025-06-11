#pragma once

#include "PainterUtils.hlsl"

TEXTURE2D(_MainTexture); SAMPLER(sampler_MainTexture);

float4 _MainTexture_ST;

float3 _PaintableWorldPosition;
float3 _PainterPosition;
float _Radius;
float _Hardness;
float _AlphaStrength;
float _ColorStrength;
float4 _Color;
float _PrepareUV;

struct Attributes
{
    float3 positionOS : POSITION;
	float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
};

Interpolators Vertex(Attributes input)
{
    Interpolators output;
    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS);
	output.positionWS = positionInputs.positionWS;
    output.uv = input.uv;
	float4 uv = float4(0, 0, 0, 1);
    uv.xy = float2(1, _ProjectionParams.x) * (input.uv.xy * float2(2, 2) - float2(1, 1));
	output.positionCS = uv;
    return output;
}

float4 Fragment(Interpolators input) : SV_Target
{
    if (_PrepareUV > 0)
    {
        return float4(0, 0, 1, 1);
    }

    float2 uv = input.uv;
    float4 color = SAMPLE_TEXTURE2D(_MainTexture, sampler_MainTexture, uv);
    float3 localPos = input.positionWS - _PaintableWorldPosition;
    float f = mask(localPos, _PainterPosition, _Radius, _Hardness);
    float edge = f * _AlphaStrength;
    color.a = lerp(color.a, _Color.a, edge);
    color.rgb = lerp(color.rgb, _Color.rgb, _ColorStrength);
    return color;
    //return lerp(color, _Color, edge);
}