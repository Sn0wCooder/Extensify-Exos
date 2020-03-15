// Copyright 2004-present Facebook. All Rights Reserved.

#include <metal_stdlib>
using namespace metal;

#import "IGGLKBackgroundShaderTypes.h"

// Vertex shader input data
typedef struct {
    float2 position [[attribute(IGGLKBackgroundShaderVertexBufferIndexPosition)]];
} VertexData;

// Fragment shader input data
typedef struct {
    float4 position [[position]];
    float2 fragCoord;
} RasterizerData;

#pragma mark - Vertex Functions

vertex RasterizerData IGGLKBackgroundShaderVertex(VertexData vertexIn [[ stage_in ]],
                                                  constant float4x4 &u_modelViewProjectionMatrix [[ buffer(IGGLKBackgroundShaderVertexBufferIndexMVPMatrix) ]],
                                                  constant float2 &u_origin [[ buffer(IGGLKBackgroundShaderVertexBufferIndexOrigin) ]])
{
    RasterizerData vertexOut;
    vertexOut.position = u_modelViewProjectionMatrix * float4(vertexIn.position, 0.0, 1.0);
    vertexOut.fragCoord = vertexIn.position - u_origin;
    return vertexOut;
}

#pragma mark - Fragment Functions

// @brief   Calculates the alpha of a point in a rounded rect.
//
// @param   point   A point in the rectangle to check. Ranges from (0,0) to (2a, 2b).
// @param   centerPoint     The center point of the rectangle. Equal to (a, b).
// @param   cornerRadius    The radius of the corners.
// @param   fadeDistance    The distance over which to fade the alpha from 1.0 to 0.0.
//                          This value should be in the range (0.0, cornerRadius).
//
// @return  The alpha value for a point in a rounded rect.
//          > 0.0 if the point lies within the rounded rect
//          0.0 if the point lies outside the rounded rect
float alphaForPointInRoundedRect(float2 point, float2 centerPoint, float cornerRadius, float fadeDistance)
{
    // Imagine the rectangle is divided into four quadrants with the origin at the center point
    // Map the current position to the first quadrant
    float2 adjustedPosition = abs(point - centerPoint);

    // Create a rectangle with size (a - r, b - r)
    float2 innerRectSize = (centerPoint - cornerRadius);

    // Calculate the position of the point in the outer rect
    float2 positionInOuterRect = (adjustedPosition - innerRectSize);

    // If `positionInOuterRect` is <= 0.0, we know it lies within the inner rectangle
    // We can just clamp these points to 0.0
    // Note: Due to rounding errors, an expected value of 0.0 may be slightly larger.
    //       To account for this we use a small value rather than 0.0 as the edge in
    //       our step function.
    positionInOuterRect = positionInOuterRect * step(0.00001, positionInOuterRect);

    // Calculate the alpha of the point
    return 1.0 - smoothstep(cornerRadius - fadeDistance, cornerRadius + 1.0e-30, length(positionInOuterRect));
}

fragment float4 IGGLKBackgroundShaderFragment(RasterizerData fragmentIn [[stage_in]],
                                              constant float2 &u_centerPoint [[ buffer(IGGLKBackgroundShaderFragmentBufferIndexCenterPoint) ]],
                                              constant float4 &u_color [[ buffer(IGGLKBackgroundShaderFragmentBufferIndexColor) ]],
                                              constant float &u_cornerRadius [[ buffer(IGGLKBackgroundShaderFragmentBufferIndexCornerRadius) ]],
                                              constant float &u_alpha [[ buffer(IGGLKBackgroundShaderFragmentBufferIndexAlpha) ]])
{
    float alpha = alphaForPointInRoundedRect(fragmentIn.fragCoord, u_centerPoint, u_cornerRadius, 0.0);
    if (alpha == 0.0) discard_fragment();
    return float4(u_color.rgb, u_color.a * u_alpha * alpha);
}
