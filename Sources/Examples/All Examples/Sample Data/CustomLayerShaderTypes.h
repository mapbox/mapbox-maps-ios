#ifndef CustomLayerShaderTypes_h
#define CustomLayerShaderTypes_h

#include <simd/simd.h>

// Buffer indexes shared between shader and platform code to ensure Metal shader buffer inputs
// match Metal API buffer set calls.
typedef enum
{
    VertexInputIndexVertices = 0,
    VertexInputIndexTransformation = 1,
} VertexInputIndex;

typedef struct
{
    simd_float2 position;
    simd_float4 color;
} VertexData;

#endif /* CustomLayerShaderTypes_h */
