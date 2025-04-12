#version 150

#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);

    if ((Color.x * 255.0) == 61.0){ // #3d3b30: color to shift forward and avoid zfighting on holotext
        if ((Color.y * 255.0) == 59.0){
            if ((Color.z * 255.0) == 48.0){
                vec4 shine_color = vec4(1.0,1.0,1.0,1.0);
                switch (gl_VertexID % 4) {
                    case 0: shine_color = vec4(0.2,0.2,0.2,1.0); break;
                    case 3: shine_color = vec4(0.2,0.2,0.2,1.0); break;
                    case 1: shine_color = vec4(0.,0.,0.,1.0); break;
                    case 2: shine_color = vec4(0.,0.,0.,1.0); break;
                }

                vertexColor = shine_color * texelFetch(Sampler2, UV2 / 16, 0);

                gl_Position = ProjMat * (ModelViewMat * vec4(Position, 1.0)+vec4(0.0,0.0,0.001,0.0));
                
            }
        }
    }


    texCoord0 = UV0;
}
