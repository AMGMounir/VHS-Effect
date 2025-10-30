float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 warpSmart(vec2 uv, float offsetValue, float currentTime)
{
    bool bendTop    = (offsetValue == 4.0);
    bool bendBottom = (offsetValue == -0.3);
    bool noBend     = (offsetValue == 0.5);

    if (noBend || (!bendTop && !bendBottom)) return uv;

    float baseStrength = 0.4 + 0.4 * rand(vec2(floor(currentTime / 2.0), 123.0));
    float jitter = 5.3 * sin(currentTime * 45.7 + 1.3);
    float strength = clamp(baseStrength + jitter, -1.0, 0.5);

    float curve;
    if (bendTop) {
        float curveRand = rand(vec2(floor(currentTime / 1.5), 456.0));
        curve = 7.0 + curveRand * 5.0;  // 7.0 → 12.0
    } else {
        curve = 8.0;
    }

    float localT = 0.0;
    float offset = 0.0;

    if (bendTop) {
        if (uv.y <= 0.5) return uv;
        localT = (uv.y - 0.5) * 2.0;
        offset = -strength * pow(localT, curve);
    }
    else if (bendBottom) {
        if (uv.y >= 0.5) return uv;
        localT = (0.5 - uv.y) * 2.0;
        offset = +strength * pow(localT, curve);
    }

    uv.x = clamp(uv.x + offset, 0.0, 1.0);
    return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float targetAspect = 4.0 / 3.0;
    float currentAspect = iResolution.x / iResolution.y;
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 center = vec2(0.5, 0.5);

    if (currentAspect > targetAspect) {
        float scale = currentAspect / targetAspect;
        uv.x = (uv.x - center.x) * scale + center.x;
        if (uv.x < 0.0 || uv.x > 1.0) {
            fragColor = vec4(0.0, 0.0, 0.0, 1.0);
            return;
        }
    } else {
        float scale = targetAspect / currentAspect;
        uv.y = (uv.y - center.y) * scale + center.y;
        if (uv.y < 0.0 || uv.y > 1.0) {
            fragColor = vec4(0.0, 0.0, 0.0, 1.0);
            return;
        }
    }

    vec2 adjustedFragCoord = uv * iResolution.xy;
    vec4 texColor = vec4(0.0);
    int ghostSamples = 3;

    for(int g = 0; g < ghostSamples; g++){
        float timeOffset    = float(g) * 0.016;
        float ghostWeight   = 1.0 / float(ghostSamples);
        float currentTime   = iTime - timeOffset;

        vec2 samplePosition = adjustedFragCoord.xy / iResolution.xy;
        samplePosition.y += (rand(vec2(currentTime)) - 0.5) / 18.0;

        float horizontalJitter = (rand(vec2(currentTime, adjustedFragCoord.y)) - 0.5) / 64.0;

        float timeSegment = floor(currentTime / 1.5);
        float valueIndex  = rand(vec2(timeSegment, 456.0));
        float offsetValue;

        if (valueIndex < 0.6) {
            offsetValue = 4.0;   
        }
        else if (valueIndex < 0.7) {
            offsetValue = -0.3; 
        }
        else {
            offsetValue = 0.5; 
        }

        float whiteNoiseOffset = (rand(vec2(currentTime * 0.5)) - offsetValue) * 0.22;
        float adjustedY = samplePosition.y + whiteNoiseOffset;

        float bwBandOffset = (rand(vec2(currentTime * 0.7 + 200.0)) - 0.5) * 2.5;
        float bwBandY = samplePosition.y + bwBandOffset;
        float bwBandPattern = rand(vec2(floor(bwBandY * 3.0), currentTime * 0.05));
        bool isInBWBand = bwBandPattern > 0.6;

        float colorNoiseOffset = (rand(vec2(currentTime * 0.7 + 100.0)) - 0.5) * 12.25;

        vec2 noiseSamplePos = samplePosition;
        noiseSamplePos.x += horizontalJitter;

        float whiteNoise = rand(vec2(floor(adjustedY * 1500.0),
                                    floor(noiseSamplePos.x * 50.0)) + vec2(currentTime, 0.0));

        vec2 warpUV = samplePosition;
        warpUV = warpSmart(warpUV, offsetValue, currentTime);

        if (whiteNoise > 15.5 - 50.0 * adjustedY || whiteNoise < 1.5 - 5.0 * adjustedY) {
            vec2 pixelatedPos = warpUV;
            float pixelBlockSize = 200.0;
            pixelatedPos = floor(pixelatedPos * pixelBlockSize) / pixelBlockSize;
            pixelatedPos.y = 1.0 - pixelatedPos.y;

            float aberrationAmount = 0.004;
            vec2 aberrationOffset = vec2(aberrationAmount, 0.0);
            float r = texture(iChannel0, pixelatedPos - aberrationOffset).r;
            float g = texture(iChannel0, pixelatedPos).g;
            float b = texture(iChannel0, pixelatedPos + aberrationOffset).b;
            vec4 frameColor = vec4(r, g, b, 1.0);

            vec2 pixelSize = 1.0 / iResolution.xy;
            vec4 sharpenKernel = vec4(0.0);
            sharpenKernel += texture(iChannel0, pixelatedPos + vec2(-pixelSize.x, 0.0)) * -0.25;
            sharpenKernel += texture(iChannel0, pixelatedPos + vec2( pixelSize.x, 0.0)) * -0.25;
            sharpenKernel += texture(iChannel0, pixelatedPos + vec2(0.0, -pixelSize.y)) * -0.25;
            sharpenKernel += texture(iChannel0, pixelatedPos + vec2(0.0,  pixelSize.y)) * -0.25;
            sharpenKernel += frameColor * 2.0;
            frameColor = mix(frameColor, sharpenKernel, 1.0);

            frameColor.rgb = floor(frameColor.rgb * 24.0) / 24.0;


            vec3 tint = vec3(0.88, 0.94, 1.12);
            frameColor.rgb *= tint;

            float brightnessBoost = 1.0 / max(max(tint.r, tint.g), tint.b);
            frameColor.rgb *= brightnessBoost * 0.98;
            frameColor.rgb = clamp(frameColor.rgb, 0.0, 1.0);

            // B&W band desaturation
            if (isInBWBand) {
                float gray = dot(frameColor.rgb, vec3(0.299, 0.587, 0.114));
                float desatAmount = 0.8;
                frameColor.rgb = mix(frameColor.rgb, vec3(gray), desatAmount);
            }

            texColor += frameColor * ghostWeight;
        }
        else {
            float staticNoise = rand(adjustedFragCoord.xy + vec2(currentTime * 10.0, 0.0));
            vec2 jitteredTextureSample = samplePosition;
            jitteredTextureSample.x += horizontalJitter;
            jitteredTextureSample.y = 1.0 - jitteredTextureSample.y;
            vec4 backgroundTexture = texture(iChannel0, jitteredTextureSample);

            float colorNoiseY = adjustedFragCoord.y + colorNoiseOffset * iResolution.y;
            vec4 colorNoise = (vec4(-0.5) + vec4(
                rand(vec2(colorNoiseY, currentTime)),
                rand(vec2(colorNoiseY, currentTime + 1.0)),
                rand(vec2(colorNoiseY, currentTime + 2.0)), 0.0)) * 2.5;

            vec4 noiseColor = vec4(staticNoise) * 0.9
                            + vec4(2.0) * 0.17
                            + colorNoise * 0.5
                            + backgroundTexture * 0.2;

            texColor += noiseColor * ghostWeight;
        }
    }

    fragColor = texColor;
}
