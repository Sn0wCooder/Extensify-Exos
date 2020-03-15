varying highp vec2 v_texCoord;

uniform sampler2D u_lumaTexture;
uniform sampler2D u_chromaTexture;

// BT.601 full range
highp mat3 colorConversionMatrix = mat3(1.0,    1.0,   1.0,
                                        0.0, -0.343, 1.765,
                                        1.4, -0.711,   0.0);

void main() {
    mediump vec3 yuv;
    yuv.x = texture2D(u_lumaTexture, v_texCoord).r;
    yuv.yz = texture2D(u_chromaTexture, v_texCoord).rg - vec2(0.5, 0.5);

    lowp vec3 rgb;
    rgb = colorConversionMatrix * yuv;

    gl_FragColor = vec4(rgb, 1.0);
}
