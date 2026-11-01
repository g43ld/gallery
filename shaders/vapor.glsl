#ifdef GL_ES
precision highp float;
#endif

#define NUM_OCTAVES 6

uniform float u_time;
uniform vec2 u_resolution;

float random(vec2 pos){
    return fract(sin(dot(pos.xy,vec2(13.9898,78.233)))*43758.5453123);
}

float noise(vec2 pos){
    vec2 i=floor(pos);
    vec2 f=fract(pos);
    float a=random(i+vec2(0.,0.));
    float b=random(i+vec2(1.,0.));
    float c=random(i+vec2(0.,1.));
    float d=random(i+vec2(1.,1.));
    vec2 u=f*f*(3.-2.*f);
    return mix(a,b,u.x)+(c-a)*u.y*(1.-u.x)+(d-b)*u.x*u.y;
}

float fbm(vec2 pos){
    float v=0.;
    float a=.5;
    vec2 shift=vec2(100.);
    mat2 rot=mat2(cos(.5),sin(.5),-sin(.5),cos(.5));
    for(int i=0;i<NUM_OCTAVES;i++){
        float dir=mod(float(i),2.)>.5?1.:-1.;
        v+=a*noise(pos-.05*dir*u_time);
        
        pos=rot*pos*2.+shift;
        a*=.5;
    }
    return v;
}

void main(void){
    vec2 p=(gl_FragCoord.xy*3.-u_resolution.xy)/min(u_resolution.x,u_resolution.y);
    p-=vec2(12.,0.);

    vec2 q=vec2(0.);
    q.x=fbm(p);
    q.y=fbm(p+vec2(1.));
    vec2 r=vec2(0.);
    r.x=fbm(p+q+vec2(1.7,1.2)+.15*u_time);
    r.y=fbm(p+q+vec2(8.3,2.8)+.126*u_time);
    float f=fbm(p+r);

    // DS: hornidev
    vec3 color=mix(
        vec3(1.,1.,2.),
        vec3(1.,1.,1.),
        clamp((f*f)*5.5,1.2,15.5)
    );
    
    color=mix(
        color,
        vec3(1.,1.,1.),
        clamp(length(q),2.,2.)
    );
    
    color=mix(
        color,
        vec3(.3,.2,1.),
        clamp(length(r.x),0.,5.)
    );
    
    color=(f*f*f*1.+.5*1.7*0.+.9*f)*color;
    
    gl_FragColor=vec4(color,1.);
}
