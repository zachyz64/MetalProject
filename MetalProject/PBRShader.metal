//
//  RayTracingShader.metal
//  MetalProject
//
//  Created by Zach Zaborowski on 7/15/26.
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

struct PBRValues
{
    float3 color;
    float3 normal;
    float3 specular;
    float3 roughness;
    float3 displacement;
    float3 bump;
    float3 gloss;
    float3 ao;
    float3 cavity;
};

float3 applyPBRDirectionalLight(DirectionalLight light, PBRValues values, float3 fragCam);
float3 applyPBRSpotlight(float3 position, Spotlight light, PBRValues values, float3 fragCam);
float3 applyPBRPointlight(float3 position, Pointlight light, PBRValues values, float3 fragCam);
float2 parallaxMapping(float height, float2 texCoords, float3 fragCam);

vertex Fragment vertexPBR(const VertexIn vertex_in [[stage_in]],
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

fragment float4 fragmentPBR(Fragment frag [[stage_in]],
                             texture2d_array<float> objectTexture [[texture(0)]],
                             sampler samplerObject [[sampler(0)]],
                             constant DirectionalLight& sun [[buffer(0)]],
                             constant Spotlight& spotlight [[buffer(1)]],
                             constant Pointlight* pointlights [[buffer(2)]],
                             constant FragmentData& fragUBO [[buffer(3)]])
{
    PBRValues texValues;
    float3 fragCamera = normalize(frag.cameraPos - frag.fragPos);
    
    // 4: Displacement
    texValues.displacement = float3(objectTexture.sample(samplerObject, frag.texCoord, 4));
    //frag.texCoord = parallaxMapping(texValues.displacement.r, frag.texCoord, fragCamera);
    
    // 0: BaseColor
    texValues.color = float3(objectTexture.sample(samplerObject, frag.texCoord, 0));
    float alpha = objectTexture.sample(samplerObject, frag.texCoord, 0).a;
    
    // 1: Normal
    texValues.normal = float3(objectTexture.sample(samplerObject, frag.texCoord, 1));
    texValues.normal = normalize(texValues.normal * 2.0 - 1.0);
    
    // 2: Specular
    texValues.specular = float3(objectTexture.sample(samplerObject, frag.texCoord, 2));
    texValues.specular = normalize(texValues.specular);
    // 3: Roughness
    
    // 5: Bump
    
    // 6: Gloss
    
    // 7: AO
    
    // 8: Cavity
    
    // Add Lighting
    float3 result = float3(0.0);
    
    //result += 0.1 * texValues.color; // Ambient
    result += 0.3 * applyPBRDirectionalLight(sun, texValues, fragCamera);
    result += 0.2 * applyPBRSpotlight(frag.fragPos, spotlight, texValues, fragCamera);
    for (uint i = 0; i < 2; ++i)
    {
        result += 0.25 * applyPBRPointlight(frag.fragPos, pointlights[i], texValues, fragCamera);
    }

    return float4(result, alpha);
}

float3 applyPBRDirectionalLight(DirectionalLight light, PBRValues values, float3 fragCam)
{
    float3 color = float3(0.0);
    
    float3 halfVec = normalize(-light.forward + fragCam);
    
    // Diffuse
    float lightAmount = max(0.0, dot(values.normal, -light.forward));
    color += lightAmount * values.color * light.color;
    
    // Specular
    lightAmount = pow(max(0.0, dot(values.normal, halfVec)), 64);
    color += lightAmount * values.color * light.color;
    
    return color;
}

float3 applyPBRSpotlight(float3 position, Spotlight light, PBRValues values, float3 fragCam)
{
    float3 color = float3(0.0);

    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    // Diffuse
    float3 lightAmount = max(0.0, dot(values.normal, fragLight)) * pow(max(0.0, dot(light.forward, fragLight)), 32);
    color += lightAmount * values.color * light.color;
    
    // Specular
    lightAmount = pow(max(0.0, dot(values.normal, halfVec)), 64);
    color += values.specular * values.color * light.color * pow(max(0.0, dot(light.forward, fragLight)), 16);
    
    return color;
}

float3 applyPBRPointlight(float3 position, Pointlight light, PBRValues values, float3 fragCam)
{
    float3 color = float3(0.0);
    
    // Directions
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    // Diffuse
    float3 lightAmount = max(0.0, dot(values.normal, fragLight));
    color += lightAmount * values.color * light.color;
    
    // Specular
    lightAmount = pow(max(0.0, dot(values.normal, halfVec)), 64);
    color += values.specular * values.color * light.color;
    
    return color;
}

float2 parallaxMapping(float height, float2 texCoords, float3 fragCam)
{
    float2 p = fragCam.xy / fragCam.z * height * 0.05;
    return texCoords - p;
}
