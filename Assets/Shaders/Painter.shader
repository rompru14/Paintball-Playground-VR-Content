Shader "Painter"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 0)
    }

    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline"}

        Cull Off ZWrite Off ZTest Off

        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "PainterForwardLitPass.hlsl"

            ENDHLSL
        }
    }
}