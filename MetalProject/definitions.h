//
//  definitions.h
//  MetalProject
//
//  Created by Zach Zaborowski on 7/7/26.
//

#ifndef definitions_h
#define definitions_h

#include <simd/simd.h>

struct Vertex
{
    vector_float3 position;
    vector_float4 color;
};

struct SimpleVertex
{
    vector_float2 position;
};

struct CameraParameters
{
    simd_float4x4 view;
    simd_float4x4 projection;
    simd_float3 position;
};

struct CameraFrame {
    simd_float3 forward;
    simd_float3 right;
    simd_float3 up;
    float aspect;
};

struct DirectionalLight
{
    simd_float3 forward;
    simd_float3 color;
};

struct Spotlight
{
    simd_float3 forward;
    simd_float3 position;
    simd_float3 color;
};

struct Pointlight
{
    simd_float3 position;
    simd_float3 color;
};

struct FragmentData
{
    unsigned int lightCount;
};

#define    OBJECT_TYPE_GROUND 0
#define    OBJECT_TYPE_CHARACTER 1
#define    OBJECT_TYPE_MOUSE 2
#define    OBJECT_TYPE_POINT_LIGHT 3
#define    OBJECT_TYPE_PLAYER 4

#define    PIPELINE_TYPE_LIT 0
#define    PIPELINE_TYPE_EMISSIVE 1
#define    PIPELINE_TYPE_PBR 2
#define    PIPELINE_TYPE_POST 3
#define    PIPELINE_TYPE_SKY 4

#endif /* definitions_h */
