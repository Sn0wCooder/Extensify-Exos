// (c) Facebook, Inc. and its affiliates. Confidential and proprietary.

#include <metal_stdlib>
using namespace metal;

#import "Internal/IGBoomerangShaderTypes.h"

// Vertex shader input data
typedef struct {
    float2 position [[attribute(IGBoomerangShaderVertexBufferIndexPosition)]];
} VertexData;

// Fragment shader input data
typedef struct {
    float4 position [[position]];
    float2 texCoord;
} RasterizerData;

#pragma mark - Vertex Functions

vertex RasterizerData IGBoomerangShaderVertex(VertexData vertexIn [[ stage_in ]],
                                              constant float4x4 &u_modelViewProjectionMatrix [[ buffer(IGBoomerangShaderVertexBufferIndexMVPMatrix) ]])
{
    float4 destCoord = u_modelViewProjectionMatrix * float4(vertexIn.position, 0.0, 1.0);

    RasterizerData vertexOut;
    vertexOut.position = destCoord;
    vertexOut.texCoord = destCoord.xy * float2(0.5, -0.5) + 0.5;
    return vertexOut;
}

#pragma mark - Fragment Functions

fragment float4 IGBoomerangShaderFragment(RasterizerData fragmentIn [[stage_in]],
                                          texture2d<float> texture [[ texture(IGBoomerangShaderFragmentTextureIndexTexture) ]],
                                          constant float2 &u_renderSize [[ buffer(IGBoomerangShaderFragmentBufferIndexRenderSize) ]],
                                          constant float &u_amplitude [[ buffer(IGBoomerangShaderFragmentBufferIndexAmplitude) ]],
                                          constant float &u_frequency [[ buffer(IGBoomerangShaderFragmentBufferIndexFrequency) ]])
{

    float ratio = u_renderSize.y / (1.78 * u_renderSize.x); // to keep the same freq in different aspect ratios
    float offset = sin(fragmentIn.texCoord.y * u_frequency * ratio) * u_amplitude;
    float2 offsetUv = fragmentIn.texCoord + float2(offset, 0.0);

    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    return texture.sample(textureSampler, offsetUv);
}
