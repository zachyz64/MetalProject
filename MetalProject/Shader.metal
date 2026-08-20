//
//  shader.metal
//  MetalProject
//
//  Created by Zach Zaborowski on 7/6/26.
//

#include <metal_stdlib>
#include "definitions.h"

using namespace metal;

struct VertexIn
{
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
    float3 normal [[attribute(2)]];
};

struct Fragment
{
    float4 position [[position]];
    float2 texCoord;
    float3 normal;
    float3 cameraPos;
    float3 fragPos;
};

float3 applyDirectionalLight(float3 normal, DirectionalLight light, float3 baseColor, float3 fragCam);
float3 applySpotlight(float3 position, float3 normal, Spotlight light, float3 baseColor, float3 fragCam);
float3 applyPointlight(float3 position, float3 normal, Pointlight light, float3 baseColor, float3 fragCam);


vertex Fragment vertexLit(const VertexIn vertex_in [[stage_in]],
                           constant matrix_float4x4& model [[buffer(1)]],
                           constant CameraParameters &camera [[buffer(2)]])
{
    matrix_float3x3 model3x3;
    model3x3.columns[0] = model.columns[0].xyz;
    model3x3.columns[1] = model.columns[1].xyz;
    model3x3.columns[2] = model.columns[2].xyz;
    
    Fragment frag;
    frag.position = camera.projection * camera.view * model * float4(vertex_in.position, 1.0);
    frag.texCoord = vertex_in.texCoord;
    frag.normal = model3x3 * vertex_in.normal;
    frag.cameraPos = float3(model * float4(camera.position, 1.0));
    frag.fragPos = float3(model * float4(vertex_in.position, 1.0));
    return frag;
}

fragment float4 fragmentLit(Fragment frag [[stage_in]],
                             texture2d<float> objectTexture [[texture(0)]],
                             sampler samplerObject [[sampler(0)]],
                             constant DirectionalLight& sun [[buffer(0)]],
                             constant Spotlight& spotlight [[buffer(1)]],
                             constant Pointlight* pointlights [[buffer(2)]],
                             constant FragmentData& fragUBO [[buffer(3)]])
{
    float3 baseColor = float3(objectTexture.sample(samplerObject, frag.texCoord));
    float alpha = objectTexture.sample(samplerObject, frag.texCoord).a;
    
    // Directions
    float3 fragCamera = normalize(frag.cameraPos - frag.fragPos);
    
    // Ambient
    float3 color = 0.2 * baseColor;
    
    // Directional lighting
    color += applyDirectionalLight(frag.normal, sun, baseColor, fragCamera);
     
    // Spotlights
    color += applySpotlight(frag.fragPos, frag.normal, spotlight, baseColor, fragCamera);
    
    // Pointlights
    for (uint i = 0; i < fragUBO.lightCount; ++i)
    {
        color += applyPointlight(frag.fragPos, frag.normal, pointlights[i], baseColor, fragCamera);
    }
    
    return float4(color, alpha);
}

float3 applyDirectionalLight(float3 normal, DirectionalLight light, float3 baseColor, float3 fragCam)
{
    float3 color = float3(0.0);
    
    float3 halfVec = normalize(-light.forward + fragCam);
    
    // Diffuse
    float lightAmount = max(0.0, dot(normal, -light.forward));
    color += lightAmount * baseColor * light.color;
    
    // Specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    color += lightAmount * baseColor * light.color;
    
    return color;
}

float3 applySpotlight(float3 position, float3 normal, Spotlight light, float3 baseColor, float3 fragCam)
{
    float3 color = float3(0.0);

    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    // Diffuse
    float3 lightAmount = max(0.0, dot(normal, fragLight)) * pow(max(0.0, dot(light.forward, fragLight)), 32);
    color += lightAmount * baseColor * light.color;
    
    // Specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    color += lightAmount * baseColor * light.color * pow(max(0.0, dot(light.forward, fragLight)), 16);
    
    return color;
}

float3 applyPointlight(float3 position, float3 normal, Pointlight light, float3 baseColor, float3 fragCam)
{
    float3 color = float3(0.0);
    
    // Directions
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    // Diffuse
    float3 lightAmount = max(0.0, dot(normal, fragLight));
    color += lightAmount * baseColor * light.color;
    
    // Specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    color += lightAmount * baseColor * light.color;
    
    return color;
}
