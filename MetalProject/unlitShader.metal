//
//  unlitShader.metal
//  MetalProject
//
//  Created by Zach Zaborowski on 7/13/26.
//

#include <metal_stdlib>
#include "definitions.h"

using namespace metal;

struct VertexUnlit
{
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct FragmentUnlit
{
    float4 position [[position]];
    float2 texCoord;
};

vertex FragmentUnlit vertexUnlit(const VertexUnlit vertex_in [[stage_in]],
                                 constant matrix_float4x4& model [[buffer(1)]],
                                 constant CameraParameters &camera [[buffer(2)]])
{
    FragmentUnlit frag;
    frag.position = camera.projection * camera.view * model * float4(vertex_in.position, 1.0);
    frag.texCoord = vertex_in.texCoord;

    return frag;
}

fragment float4 fragmentUnlit(FragmentUnlit frag [[stage_in]],
                             texture2d<float> objectTexture [[texture(0)]],
                             sampler samplerObject [[sampler(0)]],
                             constant float3& tint [[buffer(0)]])
{
    float3 baseColor = float3(objectTexture.sample(samplerObject, frag.texCoord));
    float alpha = objectTexture.sample(samplerObject, frag.texCoord).a;
    
    return float4(tint * baseColor, alpha);
}
