#version 150

#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out vec2 texCoord0;
out vec4 vertexColor;
flat out float isMarker;
flat out vec4 tint;

vec2[] corners = vec2[](
    vec2(0, 1),
    vec2(0, 0),
    vec2(1, 0),
    vec2(1, 1)
);

const float minGreen = 252.0;
const float maxGreen = 253.0;

void main() {
    tint = Color;

    if (abs(Color.r * 255. - 254.) < .5 && Color.g * 255. > minGreen - .5 && Color.g * 255. < maxGreen + .5) {
        isMarker = 1.;
        vec2 screenPos = 0.125 * corners[gl_VertexID % 4] - 1.0;
        gl_Position = vec4(screenPos, 0.0, 1.0);
        vertexDistance = 0.0;
        texCoord0 = vec2(0);
        vertexColor = vec4(0);
        return;
    }
    isMarker = 0.;

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);


    vertexDistance = fog_distance(Position, FogShape);
    texCoord0 = UV0;
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
}