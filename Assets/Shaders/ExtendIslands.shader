Shader "ExtendIslands"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _UVIslands ("Texture UVIsalnds", 2D) = "white" {}
        _ExtendDistance ("ExtendDistance", float) = 1
    }

    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque"}

        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "ExtendIslandsForwardLitPass.hlsl"

            ENDHLSL
        }
    }
}
