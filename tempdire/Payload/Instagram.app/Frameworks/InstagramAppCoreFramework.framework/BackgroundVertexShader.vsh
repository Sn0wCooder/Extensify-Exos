attribute highp vec2 a_position;

uniform highp vec2 u_origin;    // The origin point of the node's bounds in points
uniform highp mat4 u_modelViewProjectionMatrix;

varying highp vec2 v_fragCoord;

void main()
{
    gl_Position = u_modelViewProjectionMatrix * vec4(a_position, 0.0, 1.0);
    v_fragCoord = a_position - u_origin;
}
