uniform vec2 start, end;

float parabola( float x, float k ){
    return pow( 4.0 * x * (1.0-x), k );
}

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 sc) {

    vec2 norm_screen = (sc - start) / (end - start);

    float dx = abs(end.x - start.x);
    float dy = abs(end.y - start.y);

    if (dx > dy) { // x gradient
        return vec4(1, 0, 0, parabola(norm_screen.y, dy));
    }
    else { // y gradient
        return vec4(1, 0, 0, parabola(norm_screen.x, dx));
    }
}

// multiply/div by val to stay within set val
// add/sub to/from val to cover whole rect