uniform int image_size = 16;
uniform float falloff = 20;
// uniform bool do_pow = false;

// uniform float qy;
// uniform float qh; 
// uniform float ih;

// uniform float qx;
// uniform float qw; 
// uniform float iw;


// -- shaders.gradient:send('qy', ent.image.rsheet[ent.image.quad_num].y)
// -- shaders.gradient:send('qh', ent.image.rsheet[ent.image.quad_num].qh)
// -- shaders.gradient:send('ih', ent.image.rsheet[ent.image.quad_num].sh)

// -- shaders.gradient:send('qx', ent.image.rsheet[ent.image.quad_num].x)
// -- shaders.gradient:send('qw', ent.image.rsheet[ent.image.quad_num].qw)
// -- shaders.gradient:send('iw', ent.image.rsheet[ent.image.quad_num].sw)

// float parabola( float x, float k ){
//     return pow( 4.0*x*(1.0-x), k );
// }

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords) {

    
    // float ydiff = (uvs.y * ih - qy) / qh;
    // ydiff = pow(ydiff, 3);

    // float xdiff = (uvs.x * iw - qx) / qw;

    // if (do_pow) {
        // xdiff = parabola(xdiff, 2);
    // }

    // else {
        // xdiff = 0;
    // }

    // ydiff = clamp(ydiff, 0, 1.0);
    // xdiff = clamp(xdiff, 0, 1.0);

    // float ty = xdiff * 0;


    // gets pixel colors
    vec4 pixel = Texel(image, uvs);

    return vec4(0, 0, 0, pixel.a/3);
}