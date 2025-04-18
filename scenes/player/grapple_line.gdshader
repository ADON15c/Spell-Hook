shader_type canvas_item;

#define FLT_MAX 3.402823466e+38

uniform float start = 0.0;
uniform float end = 1.0;
uniform float tapper_distance = 0.5;

struct WaveParams {
    float wavelength;
    float frequency;
    float amplitude;
    float width;
    float offset;
    float varianceSeed;
    vec3 color;
};

const WaveParams waves[] = {
    WaveParams(0.0,0.0, 0.0,0.07, 0.00, 0.0,vec3(1,0.98,0.8)),
    WaveParams(0.6,0.12,0.17,0.05, 0.30, 2.2,vec3(1,0.4,0.8)),
    WaveParams(0.3,0.11,0.23,0.05, 0.75, 4.7,vec3(0.82,0.83,1))
};


float distanceToWave(in vec2 uv, in WaveParams wave) {

    float wavelength = wave.wavelength;// + sin(0.5*(TIME+uv.x)+wave.varianceSeed)/15.0;
    float frequency = wave.frequency;
    float amplitude = wave.amplitude;// + sin(0.5*(TIME+uv.x)+wave.varianceSeed)/50.0;
    float width = wave.width;// + sin(0.5*(TIME+uv.x)+wave.varianceSeed)/50.0;
    float offset = wave.offset;

   
    float angle = (uv.x*wavelength + TIME*frequency + offset)*PI*2.0;
    
    float height = amplitude * sin(angle);
    float depth = amplitude * cos(angle) + 1.0;
    
    if(abs((height+0.5) - uv.y) < width) {
        return depth;
    } else {
        return -1.0;
    }
}


void fragment() {
	if (UV.x < start || UV.x > end) {
		discard;
	}
	
    vec2 tappered_uv = UV;
	if (UV.x < tapper_distance+start) {
		tappered_uv.y = (tappered_uv.y-0.5)/sqrt((tappered_uv.x-start)/tapper_distance)+0.5;
	} else if (UV.x > end-tapper_distance) {
		tappered_uv.y = (tappered_uv.y-0.5)/sqrt((end-tappered_uv.x)/tapper_distance)+0.5;
	}
	
    
    float minDist = FLT_MAX;
    COLOR = vec4(0.0);
    for (int i = 0; i<waves.length(); i++) {
        WaveParams wave = waves[i];
        float dist = distanceToWave(tappered_uv, wave);
        if (dist >= 0.0 && dist < minDist) {
            minDist = dist;
            COLOR = vec4(wave.color, 1.0);
        }
    }
}