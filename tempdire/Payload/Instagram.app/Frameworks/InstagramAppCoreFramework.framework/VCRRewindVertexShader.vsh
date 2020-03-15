attribute highp vec2 a_position;

uniform highp mat4 u_modelViewProjectionMatrix;

varying highp vec2 v_texCoord;

void main()
{
    highp vec4 destCoord = u_modelViewProjectionMatrix * vec4(a_position, 0.0, 1.0);
    gl_Position = destCoord;
    v_texCoord = destCoord.xy * 0.5 + 0.5;
}
