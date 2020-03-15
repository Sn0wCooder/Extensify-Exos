attribute highp vec2 a_position;
attribute lowp vec3 a_color;

uniform highp mat4 u_modelViewProjectionMatrix;
uniform highp mat4 u_angleMatrix;

varying lowp vec3 v_color;

void main()
{
    gl_Position = u_modelViewProjectionMatrix * u_angleMatrix * vec4(a_position, 0.0, 1.0);
    v_color = a_color;
}
