// focus-dim.glsl — dim + desaturate the terminal when its window is unfocused.
// Makes focused-vs-unfocused unmistakable under AeroSpace, where macOS often
// leaves the cursor hollow without any other visual cue.
//
// Uniforms used (Ghostty >= 1.3):
//   iChannel0    - the rendered terminal
//   iFocus       - 1 when this surface is focused, 0 when not
//   iTime        - running seconds
//   iTimeFocus   - iTime value at the moment focus was last gained
//
// Tuning knobs:
const float DIM        = 0.55;  // brightness when unfocused (1.0 = no change, lower = darker)
const float DESATURATE = 0.45;  // 0 = keep colors, 1 = fully grayscale when unfocused
const float FADE       = 0.18;  // seconds for the focus-return fade

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 color = texture(iChannel0, uv);

    // Focused: fade from the dimmed look back to full over FADE seconds.
    // (1.0 = fully focused/normal, 0.0 = fully unfocused/dimmed)
    float focus = 1.0;
    if (iFocus == 0) {
        focus = 0.0;
    } else {
        focus = clamp((iTime - iTimeFocus) / FADE, 0.0, 1.0);
    }

    // Grayscale using perceptual luma.
    float luma = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 gray = vec3(luma);

    // Blend the two effects by how unfocused we are.
    float amount = 1.0 - focus;                 // 0 focused -> 1 unfocused
    vec3 desat = mix(color.rgb, gray, DESATURATE * amount);
    vec3 dimmed = desat * mix(1.0, DIM, amount);

    fragColor = vec4(dimmed, color.a);
}
