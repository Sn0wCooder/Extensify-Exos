varying highp vec2 v_texCoord;

uniform sampler2D u_texture;
uniform highp vec2 u_renderSize;
uniform highp float u_amplitude;
uniform highp float u_frequency;

void main()
{
    highp float ratio = u_renderSize.y / (1.78 * u_renderSize.x); // to keep the same freq in different aspect ratios
    highp float offset = sin(v_texCoord.y * u_frequency * ratio) * u_amplitude;
    highp vec2 offsetUv = v_texCoord + vec2(offset, 0.0);

    gl_FragColor = texture2D(u_texture, offsetUv);
}
