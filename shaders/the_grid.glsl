#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

void main() {
    vec2 uv = (gl_FragCoord.xy / u_resolution) * 2.0 - 1.0;
    // Handle aspect ratio
    uv.x *= u_resolution.x / u_resolution.y;
    
    // Save "original" uv value before space repeating has been applied
    vec2 uv0 = uv;
    
    vec3 finalColor = vec3(0.0);
    
    for(float i = 0.0; i <= 5.0; i ++ ) {
        uv = fract(uv * 4.0) - 0.5;
        // Distance to repeated spaces (uv has been modified above)
        float d = length(uv) * exp(length(uv0));
        d = (sin(d / 2.0)) / 10.0;
        
        // Neonify
        d = pow(0.01 / d, 5.0);
        
        vec3 color = vec3(1.0);
        finalColor += color * d;
    }
    
    gl_FragColor = vec4(finalColor, 1.0);
}