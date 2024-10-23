#version 450

layout(location = 0) in vec3 inp_color;
layout(location = 1) in vec3 inp_uv;

layout(location = 0) out vec4 out_color;

layout(set = 0, binding = 1) uniform sampler2D tex;


void main() {
    out_color = vec4(inp_color, 1.0);

    out_color = texture(tex, inp_uv);
}

