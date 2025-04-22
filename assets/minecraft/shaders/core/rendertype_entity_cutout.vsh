/*
=== COPYRIGHT NOTICE ===
This shader code is written by KabanFriends.

Do not re-distribute this code without express permission from KabanFriends.
Please see the included LICENSE file for more information.
*/

#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec4 normal;

// Skybox
#moj_import <util.glsl>

uniform sampler2D Sampler0;
uniform vec3 ChunkOffset;

out vec3 toBlock;
out vec2 cornerUV;
out vec2 uvRatio;
out vec2 oneTexel;
out float isSkybox; //1.0 if skybox
out vec3 blockPos;

vec2[] corners = vec2[](
    vec2(0.0, 0.0),
    vec2(0.0, 1.0),
    vec2(1.0, 1.0),
    vec2(1.0, 0.0)
);

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(IViewRotMat * Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    // -- Skybox --
    // Calculate toBlock for the fragment shader
    vec3 pos = IViewRotMat * (Position + ChunkOffset);
    vec3 camPos = inverse(mat3(ModelViewMat)) * ModelViewMat[3].xyz;

    toBlock = pos - camPos;

    blockPos = ModelViewMat[3].xyz;

    vertexDistance = fog_distance(Position, FogShape);

    // Determine texture size
    bool skybox = false;
    float width;

    /*
    === USER GUIDE ===
    To add custom texture size for your skybox texture, add a new
    IF condition below with a unique alpha value.

    All pixels of the skybox texture must use the matching alpha value
    for its texture size.

    Texture width bigger than 3072.0 is not tested, and may cause issues. 

    Example:
    | else if (compfloat(texture(Sampler0, UV0).a, 0.5)) {
    |    skybox = true;
    |    width = 384.0;
    | }
    */
    vec2 samplerSize = textureSize(Sampler0, 0); // atlas size in pixels
    vec2 corner_shift = (corners[gl_VertexID % 4]-vec2(0.5,0.5))*-2.0;
    vec2 fixed_UV0 = UV0+corner_shift/samplerSize;
    if (compfloat(texture(Sampler0, fixed_UV0).a, 0.125)) {
        skybox = true;
        width = 768.0;
    }
    else if (compfloat(texture(Sampler0, fixed_UV0).a, 0.25)) {
        skybox = true;
        width = 3072.0;
    }

    isSkybox = 0.0;
    if (skybox) {
        //anti view bobbing technology
        // if (abs(ProjMat[3][3] - 1.0) > 0.01) { //check if the item is in the world and not in a gui
        //     mat4 projMat = ProjMat;
        //     vec3 position = Position;
        //     projMat[3].xy = vec2(0.0);
        //     position += vec3(ProjMat[3].xy, 0.0);

        //     gl_Position=projMat*ModelViewMat*vec4(position,1.);

        //     normal = projMat * ModelViewMat * vec4(Normal, 0.0);
        //     pos = IViewRotMat * (position + ChunkOffset);
        //     toBlock = pos - camPos;
        // }
        vec2 texSize;
        texSize = vec2(width, width * (2.0 / 3));

        // Find UV corner
        uvRatio = texSize / samplerSize;
        oneTexel = uvRatio / texSize;

        cornerUV = UV0 - (corners[gl_VertexID % 4] - oneTexel * 2)* uvRatio;

        isSkybox = 1.0;
    }
}
