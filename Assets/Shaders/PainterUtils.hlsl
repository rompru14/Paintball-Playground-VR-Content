#pragma once

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_BrushTexture); SAMPLER(sampler_BrushTexture);

float4 _BrushTexture_ST;

float3 xUnitVec3 = float3(1.0, 0.0, 0.0);
float3 yUnitVec3 = float3(0.0, 1.0, 0.0);

float3 clampMagnitude(float3 vec, float maxLength)
{
    float lengthVec = length(vec);
    float sqrLength = lengthVec * lengthVec;
    if (sqrLength > maxLength * maxLength)
        return normalize(vec) * maxLength;
    return vec;
}

float4 setAxisAngle(float3 axis, float rad)
{
    rad = rad * 0.5;
    float s = sin(rad);
    return float4(s * axis[0], s * axis[1], s * axis[2], cos(rad));
}

float4 multQuat(float4 q1, float4 q2) 
{
    return float4
        (q1.w * q2.x + q1.x * q2.w + q1.z * q2.y - q1.y * q2.z,
        q1.w * q2.y + q1.y * q2.w + q1.x * q2.z - q1.z * q2.x,
        q1.w * q2.z + q1.z * q2.w + q1.y * q2.x - q1.x * q2.y,
        q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z);
}

float3 rotateVector(float4 quat, float3 vec)
{
    float4 qv = multQuat(quat, float4(vec, 0.0));
    return multQuat(qv, float4(-quat.x, -quat.y, -quat.z, quat.w)).xyz;
}

float4 rotationTo(float3 a, float3 b)
{
    float vecDot = dot(a, b);
    float3 tmpvec3 = float3(0, 0, 0);
    if (vecDot < -0.999999)
    {
        tmpvec3 = cross(xUnitVec3, a);
        if (length(tmpvec3) < 0.000001)
        {
            tmpvec3 = cross(yUnitVec3, a);
        }
        tmpvec3 = normalize(tmpvec3);
        return setAxisAngle(tmpvec3, PI);
    }
    else if (vecDot > 0.999999)
    {
        return float4(0, 0, 0, 1);
    }
    else
    {
        tmpvec3 = cross(a, b);
        float4 _out = float4(tmpvec3[0], tmpvec3[1], tmpvec3[2], 1.0 + vecDot);
        return normalize(_out);
    }
}

float mask(float3 position, float3 center, float radius, float hardness)
{
    float dist = distance(center, position);

    float resX = -0.5;
    float resY = -0.5;

    if (dist <= 1)
    {
        float3 vecZ = float3(0, 0, 1);
        float3 centerXZ = normalize(float3(center.x, 0, center.z));
                    
        float zDot = dot(centerXZ, vecZ);
        if (zDot < 0)
            vecZ *= -1;

        float3 resCenter = center;
        float3 resPos = position;
        float4 rotQuat = rotationTo(vecZ, center);
        resCenter = rotateVector(rotQuat, center);
        resPos = rotateVector(rotQuat, position);

        float3 diff = resPos - resCenter;
        diff = clampMagnitude(diff, 1);
        resX = diff.x;
        resY = diff.y;
    }

    float2 brushUVXY = float2(0.5 + resX, 0.5 + resY);
    float4 brushCol = SAMPLE_TEXTURE2D(_BrushTexture, sampler_BrushTexture, brushUVXY);

    float paintVal = 1 - smoothstep(radius * hardness, radius, dist);
    return paintVal * brushCol.g;
    //return brushCol;
}