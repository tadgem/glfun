#version 450

out vec4 FragColor;

layout (location = 0) in vec2 aUV;

uniform sampler2D uDiffuseSampler;


void main()
{
   FragColor = texture(uDiffuseSampler, aUV);
}