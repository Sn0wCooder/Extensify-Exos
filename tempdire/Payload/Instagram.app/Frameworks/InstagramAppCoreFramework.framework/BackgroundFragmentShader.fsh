varying highp vec2 v_fragCoord;

uniform highp vec2 u_centerPoint;   // The center point of the node's size in points
uniform lowp vec4 u_color;          // The background color
uniform highp float u_cornerRadius; // The corner radius in points
uniform highp float u_alpha;        // The alpha value of the node (including inherited alpha)

// @brief   Calculates the alpha of a point in a rounded rect.
//
// @param   point           A point in the rectangle to check. Ranges from (0,0) to (2a, 2b).
// @param   centerPoint     The center point of the rectangle. Equal to (a, b).
// @param   cornerRadius    The radius of the corners.
// @param   fadeDistance    The distance over which to fade the alpha from 1.0 to 0.0.
//                          This value should be in the range (0.0, cornerRadius).
//
// @return  The alpha value for a point in a rounded rect.
//          > 0.0 if the point lies within the rounded rect
//          0.0 if the point lies outside the rounded rect
highp float alphaForPointInRoundedRect(highp vec2 point, highp vec2 centerPoint, highp float cornerRadius, highp float fadeDistance)
{
    // Imagine the rectangle is divided into four quadrants with the origin at the center point
    // Map the current position to the first quadrant
    highp vec2 adjustedPosition = abs(point - centerPoint);

    // Create a rectangle with size (a - r, b - r)
    highp vec2 innerRectSize = (centerPoint - cornerRadius);

    // Calculate the position of the point in the outer rect
    highp vec2 positionInOuterRect = (adjustedPosition - innerRectSize);

    // If `positionInOuterRect` is <= 0.0, we know it lies within the inner rectangle
    // We can just clamp these points to 0.0
    // Note: Due to rounding errors, an expected value of 0.0 may be slightly larger.
    //       To account for this we use a small value rather than 0.0 as the edge in
    //       our step function.
    positionInOuterRect = positionInOuterRect * step(0.00001, positionInOuterRect);

    // Calculate the alpha of the point
    return 1.0 - smoothstep(cornerRadius - fadeDistance, cornerRadius + 1.0e-30, length(positionInOuterRect));
}

void main()
{
    highp float alpha = alphaForPointInRoundedRect(v_fragCoord, u_centerPoint, u_cornerRadius, 0.0);
    if (alpha == 0.0) discard;
    gl_FragColor = vec4(u_color.rgb, u_color.a * u_alpha * alpha);
}
