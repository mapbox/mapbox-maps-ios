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
    simd_float3 position;
    simd_float4 color;
} VertexData;

typedef struct
{
    simd_float3 pos_merc;
    simd_float3 pos_ecef;
    simd_float3 color;
} GlobeVertexData;

typedef struct
{
    simd_float4x4 u_matrix_merc;
    simd_float4x4 u_matrix_ecef;
    float    u_transition;
    float    u_point_size;
} GlobeUniforms;
#endif /* CustomLayerShaderTypes_h */
