#version 460 core

in vec3 color;
in vec2 textureCoor;

out vec4 FragColor;

uniform sampler2D basic;

void main()
{
        FragColor = texture(basic, textureCoor);
}
