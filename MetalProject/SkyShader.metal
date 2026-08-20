//
//  SkyShader.metal
//  MetalProject
//
//  Created by Zach Zaborowski on 7/23/26.
//

#include <metal_stdlib>
#include "definitions.h"

using namespace metal;

struct FragmentSky
{
    float4 position [[position]];
    float3 direction;
};

vertex FragmentSky vertexShaderSky(const device SimpleVertex* vertices [[buffer(0)]],
                                   constant CameraFrame& camera [[buffer(1)]],
                                   unsigned int vid [[vertex_id]])
{
    FragmentSky frag;
    SimpleVertex vertex_in = vertices[vid];
    frag.position = float4(vertex_in.position, 1.0, 1.0);
    
    float dy = 0.414; // tan (pi/8)
    float dx = dy * 4.0 / 3.0;
    float2 screenPosNDC = vertex_in.position;
    
    frag.direction = normalize(camera.forward
                               - camera.right * screenPosNDC.x * dx
                               + camera.up * screenPosNDC.y * dy);
    
    return frag;
};


fragment float4 fragmentShaderSky(FragmentSky frag [[stage_in]],
                                  texturecube<float> skyTexture [[texture(0)]],
                                  sampler skySampler [[sampler(0)]])
{
    return skyTexture.sample(skySampler, frag.direction);
};


