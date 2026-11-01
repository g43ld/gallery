#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

#define PI 3.14159

void main() {
    // Resolution normalization and aspect ratio
    vec2 uv = (gl_FragCoord.xy / u_resolution) * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

    vec3 finalColor = vec3(0);
    
    for(float i = 0.3; i < 4.0; i++) {

        // The late in the queue move faster
        float speed = PI * i * (u_time / 20.0);

        // Add boucing on each other
        speed = sin(speed);

        // Going circle
        float x = cos(4.0 * speed);
        float y = sin(4.0 * speed);

        // Radius of "circle" mvmt
        vec2 size = 0.4 * vec2(x, y);

        float red = i;
        float green = i - 0.2;
        float blue = length(vec2(x, y));

        finalColor += 0.02 / (length(uv - size)) * vec3(red, green, blue);
    }
    
    gl_FragColor = vec4(finalColor, 1);
}