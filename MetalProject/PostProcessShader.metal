//
//  PostProcessShader.metal
//  MetalProject
//
//  Created by Zach Zaborowski on 7/21/26.
//

#include <metal_stdlib>
#include "definitions.h"

using namespace metal;

struct FragmentPost
{
    float4 position [[position]];
    float2 texCoord;
};

vertex FragmentPost vertexShaderPost(const device SimpleVertex* vertices [[buffer(0)]],
                                      unsigned int vid [[vertex_id]])
{
    FragmentPost frag;
    SimpleVertex vertex_in = vertices[vid];
    frag.position = float4(vertex_in.position, 0.0, 1.0);
    frag.texCoord = 0.5 * (float2(1.0) + vertex_in.position);
    frag.texCoord.y *= -1;
    
    return frag;
};


fragment float4 fragmentShaderPost(FragmentPost frag [[stage_in]],
                                   texture2d<float> screenTexture [[texture(0)]],
                                   sampler screenSampler [[sampler(0)]])
{
    float3 baseColor = float3(screenTexture.sample(screenSampler, frag.texCoord));
    float average = 0.3333 * (baseColor.r + baseColor.g + baseColor.b);
    
    const float offset = 1.0 / 300.0;
    float2 offsets[9] = {
        float2(-offset,  offset),
        float2(    0.0,  offset),
        float2( offset,  offset),
        float2(-offset,     0.0),
        float2(    0.0,     0.0),
        float2( offset,     0.0),
        float2(-offset, -offset),
        float2(    0.0, -offset),
        float2( offset, -offset)
    };
    
    float blurKernel[9] = {
      1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0,
      2.0 / 16.0, 4.0 / 16.0, 2.0 / 16.0,
      1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0
    };
    
    float3 sampleTex[9];
    for (int i = 0; i < 9; ++i)
    {
        sampleTex[i] = float3(screenTexture.sample(screenSampler, frag.texCoord + offsets[i]));
    }
    float3 col = float3(0.0);
    for (int i = 0; i < 9; ++i)
    {
        col += sampleTex[i] * blurKernel[i];
    }
    
    float3 result = baseColor;
    return float4(result, 1.0);
};
