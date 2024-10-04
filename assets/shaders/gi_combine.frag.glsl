#version 450

layout(location = 0) in vec2 aUV;
out vec4 color;

uniform sampler2D lighting_pass;
uniform sampler2D cone_tracing_pass;
uniform sampler2D ssr_pass;


void main(void)
{
    vec4 direct = texture(lighting_pass, aUV);
    vec4 indirect = texture(cone_tracing_pass, aUV);
    vec4 ssr = texture(ssr_pass, aUV);
    color = mix(direct, indirect + ssr, (length(indirect) / 2.0)) * 2.0;
} 