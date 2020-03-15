// Copyright 2004-present Facebook. All Rights Reserved.

#include <metal_stdlib>
using namespace metal;

#import "IGGLKGradientShaderTypes.h"

// Vertex shader input data
typedef struct {
    float2 position [[attribute(IGGLKGradientShaderVertexBufferIndexPosition)]];
    float3 color    [[attribute(IGGLKGradientShaderVertexBufferIndexColor)]];
} VertexData;

// Fragment shader input data
typedef struct {
    float4 position [[position]];
    float4 color;
} RasterizerData;

#pragma mark - Vertex Functions

vertex RasterizerData IGGLKGradientShaderVertex(VertexData vertexIn [[ stage_in ]],
                                                constant float4x4 &u_modelViewProjectionMatrix [[ buffer(IGGLKGradientShaderVertexBufferIndexMVPMatrix) ]],
                                                constant float4x4 &u_angleMatrix [[ buffer(IGGLKGradientShaderVertexBufferIndexAngleMatrix) ]])
{
    RasterizerData vertexOut;

    vertexOut.position = u_modelViewProjectionMatrix * u_angleMatrix * float4(vertexIn.position, 0.0, 1.0);

    vertexOut.color = float4(vertexIn.color, 1.0);

    return vertexOut;
}

#pragma mark - Fragment Functions

fragment float4 IGGLKGradientShaderFragment(RasterizerData fragmentIn [[stage_in]])
{
    // We return the color we just set which will be written to our color attachment.
    return fragmentIn.color;
}
