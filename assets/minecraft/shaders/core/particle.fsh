#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec2 texCoord0;
in vec4 vertexColor;

flat in float isMarker;
flat in vec4 tint;

out vec4 fragColor;

void main() {
    if (isMarker == 1.0) {
        fragColor = vec4(254./255., tint.gb, 1);
        ivec2 iCoord = ivec2(gl_FragCoord.xy);
        if (
            (((iCoord.x + iCoord.y) & 1) == 1)
            || (abs(tint.g * 255. - 253.) < .5 && iCoord != ivec2(0, 0))
            || (abs(tint.g * 255. - 252.) < .5 && iCoord != ivec2(0, 2))
        ) {
            discard;
        }
        return;
    }

    
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    
}