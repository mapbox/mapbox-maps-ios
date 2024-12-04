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

vertex RasterizerData vertexShader(uint vertexID [[vertex_id]],
                                     constant VertexData *vertices [[buffer(VertexInputIndexVertices)]],
                                     constant float4x4 &transformation [[buffer(VertexInputIndexTransformation)]])
{
    RasterizerData out;

    // Index into the array of positions to get the current vertex.
    VertexData currentVertex = vertices[vertexID];

    // transform vertex position according to the transformation matrix
    out.position = transformation * float4(currentVertex.position, 0, 1);

    // pass the input color to the rasterizer
    out.color = currentVertex.color;

    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // Return the interpolated color.
    return in.color;
}
