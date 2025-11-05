#version 450

layout(location = 0) in vec3 inp_pos;
layout(location = 1) in vec3 inp_color;

layout(location = 0) out vec3 out_color;
layout(location = 1) out vec2 out_uv;

layout(set = 0, binding = 0) uniform UBO {
    mat4 model;
    mat4 view;
    mat4 proj;
} ubo;

void main() {
    /* Setup position with vertex index*/
    //
    // gl_VertexIndex   out_uv  gl_Position
    //          0       (0,0)   (-1,-1)
    //          1       (2,0)   ( 3,-1)
    //          2       (0,2)   (-1, 3)
    //
    //    Y
    //  3 |  :`.
    //    |  :  `.
    //  1 |  *----*.
    //    |  |    | `.
    // -1 |  *----*...`.
    //    +---------------- X
    //      -1    1    3
    // gl_Position is cliped to [-1, 1]
    // out_uv is cliped to [0, 1]
    //
    // With COUNTER_CLOCKWISE and vkCmdDraw(cmdbuf, 3, 1, 0, 0)
    out_uv = vec2((gl_VertexIndex << 1) & 2, gl_VertexIndex & 2);
    gl_Position = vec4(out_uv * 2.0f - 1.0f, 0.0f, 1.0f);

    /* Setup position with mvp matrix */
    out_color = inp_color;
    gl_Position = ubo.proj * ubo.view * ubo.model * vec4(inp_pos, 1.0);
}
