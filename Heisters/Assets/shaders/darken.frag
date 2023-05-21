#define NUM_LIGHTS 101

struct Light {
    vec2 position;
    vec3 diffuse;
    int spread;
    float power;
    float constant;
    float linear;
    float quadratic;
};

uniform Light lights[NUM_LIGHTS];
uniform int num_lights;
uniform vec2 res;
uniform float darkness;

// round function
float round(float f) {
    return floor((f * 10) + 0.5)/10;
}

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords) {

    // gets pixel colors
    vec4 pixel = Texel(image, uvs);

    // normalizes screen coords (controls position)
    vec2 norm_screen = screen_coords / res;

    // makes diffusal vector (controls color)
    vec3 diffuse = vec3(0);

    // iterates through lights
    for (int i = 0; i < num_lights; i++) {
        Light light = lights[i];

        // normalized light position to screen size
        vec2 norm_pos = light.position / res;

        // gets distance between normalized position and screen coords and multiplies by power
        float distance = length(norm_pos - norm_screen) * light.power;

        // calculates attenution (controls power based on distance)
        // (distance ^ power) -- tightens spread (lower = more spread)
        // (linear * distance) -- controls fuzziness based on distance
        // quadratic -- tightens total spread (higher the value tighter the spread)
        // constant -- controls initial brightness (lower the brighter)

        float attenuation = 1.0 / (light.constant + (light.linear * distance) + light.quadratic * pow(distance, light.spread)); // falloff


        // multiplies light diffisal to attenuation and adds to total diffusal
        diffuse += light.diffuse * attenuation;

        // clamps diffusal between 0 and 1
        diffuse = clamp(diffuse, 0, 1.0);
    }

    // adds darkness to diffusal
    diffuse += darkness;

    // returns pixel with added diffusal (or color) at given position
    return pixel * vec4(diffuse, 1);
}