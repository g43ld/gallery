#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

vec3 palette(float t) {
    vec3 a = vec3(1.0, 1.0, 1.0);
    //vec3 a = vec3(0.2314, 0.2588, 1.0);
    
    return a + a * cos(6.28318 * (a * t + a));
}

// The whole game is to map the 2D coordinate of a pixel to an output color.
// The work is done in parrallel for all pixels.
void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution) / u_resolution.y;
        
    // Save "original" uv value before space repeating has been applied
    vec2 uv0 = uv;
    
    vec3 finalColor = vec3(0.0);
    
    for(float i = 0.0; i <= 5.0; i ++ ) {
        uv = fract(uv * 1.5) - 0.5;
        
        // Distance to repeated spaces (uv has been modified above)
        float d = length(uv) * exp(-length(uv0));
        
        // Setting color with palette function, according to the distance
        // of the current pixel to the center of the canvas (uv0 map to the
        // uv value before space repeating has been applied)
        vec3 color = palette(length(uv0) + i * 0.4);
        
        // Concentric circles effect
        d = sin(d * 8.0 + u_time) / 8.0;
        d = abs(d);
        // Neon effect, see 1.0 / x function curve
        // pow function for contrast
        d = pow(0.01 / d, 1.9);
        
        finalColor += color * d;
    }
    
    // FragColor is the final color of the current pixel
    gl_FragColor = vec4(finalColor, 1.0);
}