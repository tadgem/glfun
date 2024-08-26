#version 450

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aUV;

layout(location = 0) out vec2 oUV;
layout(location = 1) out vec3 oPosition;
layout(location = 2) out vec3 oNormal;

uniform mat4 u_mvp;
uniform mat4 u_model;


void main()
{
    oUV = aUV;
    oPosition = aPos * u_model;
    oNormal = aNormal * u_model
    gl_Position = u_mvp * vec4(aPos.x, aPos.y, aPos.z, 1.0);
}