#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#include "CustomLayerShaderTypes.h"

struct RasterizerData
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];

    // Interpolated color value to be passed to fragment.
    float4 color;
};

// === Simple shaders ===

vertex RasterizerData vertexShader(uint vertexID [[vertex_id]],
                                     constant VertexData *vertices [[buffer(VertexInputIndexVertices)]],
                                     constant float4x4 &transformation [[buffer(VertexInputIndexTransformation)]])
{
    RasterizerData out;

    // Index into the array of positions to get the current vertex.
    VertexData currentVertex = vertices[vertexID];

    // transform vertex position according to the transformation matrix
    out.position = transformation * float4(currentVertex.position, 1.0);

    // pass the input color to the rasterizer
    out.color = currentVertex.color;

    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    return in.color;
}

// === Globe blending shaders ===
struct GlobeVertexOut {
    float4 position [[position]];
    float4 color;
    float  point_size [[point_size]];
};

vertex GlobeVertexOut globeVertexShader(
                                        uint vertexID [[vertex_id]],
                                        constant GlobeVertexData *vertices [[buffer(0)]],
                                        constant GlobeUniforms &uniforms   [[buffer(1)]]
                                        )
{
    GlobeVertexOut out;

    float4 pos_merc = uniforms.u_matrix_merc * float4(vertices[vertexID].pos_merc, 1.0);
    float4 pos_ecef = uniforms.u_matrix_ecef * float4(vertices[vertexID].pos_ecef, 1.0);

    float t = clamp(uniforms.u_transition, 0.0, 1.0);
    out.position = mix(pos_merc, pos_ecef, t);
    out.color = float4(vertices[vertexID].color, 1.0);
    out.point_size = uniforms.u_point_size; // Set point size from uniform

    return out;
}

fragment float4 globeFragmentShader(RasterizerData in [[stage_in]])
{
    return in.color;
}
