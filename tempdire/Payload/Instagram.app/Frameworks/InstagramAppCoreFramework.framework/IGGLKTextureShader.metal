// Copyright 2004-present Facebook. All Rights Reserved.

#include <metal_stdlib>
using namespace metal;

#import "IGGLKTextureShaderTypes.h"

// Vertex shader input data
typedef struct {
    float2 position [[attribute(IGGLKTextureShaderVertexBufferIndexPosition)]];
    float2 texCoord [[attribute(IGGLKTextureShaderVertexBufferIndexTexCoord)]];
} VertexData;

// Fragment shader input data
typedef struct {
    float4 position [[position]];
    float2 texCoord;
} RasterizerData;

#pragma mark - Vertex Functions

vertex RasterizerData IGGLKTextureShaderVertex(VertexData vertexIn [[ stage_in ]],
                                     constant float4x4 &u_modelViewProjectionMatrix [[ buffer(IGGLKTextureShaderVertexBufferIndexMVPMatrix) ]])
{
    RasterizerData vertexOut;
    vertexOut.position = u_modelViewProjectionMatrix * float4(vertexIn.position, 0.0, 1.0);
    vertexOut.texCoord = vertexIn.texCoord;
    return vertexOut;
}

#pragma mark - Fragment Functions

fragment float4 IGGLKTextureShaderFragment(RasterizerData fragmentIn [[stage_in]],
                                 texture2d<float> texture [[ texture(IGGLKTextureShaderFragmentTextureIndexRGB) ]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);

    const float4 colorSample = texture.sample(textureSampler, fragmentIn.texCoord);
    return colorSample;
}

fragment float4 IGGLKTextureShaderFragmentYUV(RasterizerData fragmentIn [[stage_in]],
                                              texture2d<float> lumaTexture [[ texture(IGGLKTextureShaderFragmentYUVTextureIndexLuma) ]],
                                              texture2d<float> chromaTexture [[ texture(IGGLKTextureShaderFragmentYUVTextureIndexChroma) ]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);

    const float4x4 ycbcrToRGBTransform = float4x4(
                                                  float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                  float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                  float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                  float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
                                                  );

    // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate
    float4 ycbcr = float4(lumaTexture.sample(textureSampler, fragmentIn.texCoord).r,
                          chromaTexture.sample(textureSampler, fragmentIn.texCoord).rg, 1.0);

    // Return converted RGB color
    return ycbcrToRGBTransform * ycbcr;
}

