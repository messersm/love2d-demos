// Source of the light in screen coordinates
extern vec2 sourcePos;

number dist(vec2 pos1, vec2 pos2) {
    return (pos1.x - pos2.x) * (pos1.x - pos2.x) +
           (pos1.y - pos2.y) * (pos1.y - pos2.y);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
    vec4 pixel = Texel(texture, texture_coords);
    number distance = dist(sourcePos, screen_coords);

    if (distance > 10000.0) {
        pixel.r = 0.0;
        pixel.g = 0.0;
        pixel.b = 0.0;
    }
    // For some reason this doesn't cause problems
    // even if distance is 0...
    else {
        pixel.r *= 1000.0 / distance;
        pixel.g *= 1000.0 / distance;
        pixel.b *= 1000.0 / distance;
    }
    return pixel * color;
}
