#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

float irregularRadius(vec2 uv) {
    // Stretch and bend the distance field to form loose, uneven ellipses.
    vec2 p = uv - vec2(-0.08, 0.0);
    p.x *= 0.56;
    p.x += sin(p.y * 2.1) * 0.045;
    p.y += sin(p.x * 2.7) * 0.025;

    float radius = length(p);
    float angle = atan(p.y, p.x);

    // The perturbations grow with the rings, keeping the small center calm.
    float wobble = sin(angle * 3.0 + radius * 5.0) * cos(u_time) * 0.1;
    wobble += sin(angle * 7.0 - radius * 3.5) * 0.018;
    wobble += sin(angle * 11.0 + radius * 2.0) * 0.008;

    return radius * (1.0 + wobble);
}

void main() {
    // Aspect-correct coordinates centered around zero.
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution) / u_resolution.y;
    float radius = irregularRadius(uv);

    float control = 0.100 * (0.5 - 0.5 * cos(u_time));
    float progress = control / 0.100;

    // 0.5 is the maximum possible distanceToRing value.
    float outerEdge = mix(0.5, 0.100, progress);
    float innerEdge = outerEdge - 0.1;

    // A sub-linear radial scale makes the gaps widen toward the outside.
    // Advancing the phase continuously pushes every contour outwards.
    float phase = pow(max(radius, 0.0001), 0.72) * 25.0 - u_time * 1.2;
    float distanceToRing = abs(fract(phase) - 0.5);
    float line = 1.0 - smoothstep(
        innerEdge,
        outerEdge,
        distanceToRing
    );

    vec3 background = vec3(0.0235, 0.0314, 0.0235);
    vec3 ink = vec3(0.0549, 0.0431, 0.8392);
    vec3 color = mix(background, ink, line);

    gl_FragColor = vec4(color, 1.0);
}
