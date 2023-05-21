extern vec2 pixelsize;
extern vec3 outline_color;
extern float size = 2;
extern float smoothness = 1;

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 fc) {
    float a = 0;
    for(float y = -size; y <= size; ++y) {
        for(float x = -size; x <= size; ++x) {
            a += Texel(texture, uv + vec2(x * pixelsize.x, y * pixelsize.y)).a;
        }
    }
    a = color.a * min(1, a / (2 * size * smoothness + 1));

    return vec4(outline_color.rgb, a - Texel(texture, uv).a);
}