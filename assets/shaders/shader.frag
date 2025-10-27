#version 460 core

in vec3 color;
in vec2 textureCoor;

out vec4 FragColor;
out vec4 FragTexture;

uniform sampler2D basic;

void main()
{
        FragColor = vec4(0.5, 0.4, 0.3, 1.0);
        FragTexture = texture(basic, textureCoor);
}
