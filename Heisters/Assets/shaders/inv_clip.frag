uniform vec2 clip_pos;
uniform float clipw;
uniform float cliph;

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords) {
    vec4 pixel = Texel(image, uvs);
    float a = pixel.a;

    if (screen_coords.x > clip_pos.x && 
        screen_coords.x < clip_pos.x + clipw && 
        screen_coords.y > clip_pos.y &&
        screen_coords.y < clip_pos.y + cliph) {
        a = 0;
    }

    return vec4(pixel.rgb, a);
}