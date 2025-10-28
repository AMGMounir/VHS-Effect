# VHS/CRT Shader Effect 

A GLSL shader that simulates authentic VHS tape and CRT television artifacts, including tracking errors, ghosting, chromatic aberration, and degraded video quality.


## Features

- **Motion Blur/Ghosting** - Temporal bleeding effect from VHS tape playback
- **White Noise Bands** - Horizontal tracking error simulation
- **Chromatic Aberration** - RGB color separation typical of analog video
- **Pixelation/Quantization** - Degraded video quality with reduced color depth
- **Vertical Jitter** - Frame instability and tracking issues
- **Horizontal Jitter** - Horizontal sync errors
- **B&W Desaturation Bands** - Random black and white bands mimicking tape degradation
- **Static Noise** - Background white noise for authentic tape texture
- **4:3 Aspect Ratio Enforcement** - Letterboxing/pillarboxing for authentic CRT display
- **Color Noise** - Vertical color streaking effects

## Usage

### ShaderToy
1. Go to [ShaderToy](https://www.shadertoy.com/)
2. Create a new shader
3. Paste the code into the editor
4. Set `iChannel0` to your video or image source
5. Press play and record your own video.

### Other Platforms
This shader uses standard GLSL with ShaderToy conventions:
- `iResolution` - viewport resolution
- `iTime` - elapsed time in seconds
- `iChannel0` - input texture/video
- `fragCoord` - fragment coordinates
- `fragColor` - output color

Adapt these uniforms for your platform.


## Contributing 

Contributions are welcome! Whether you're fixing bugs, adding features, or improving documentation, your help is appreciated.

### Ways to Contribute

- **Report Bugs** - Found an issue? Open a bug report
- **Suggest Features** - Have an idea? Share it in the issues
- **Submit Pull Requests** - Improvements, optimizations, new effects
- **Improve Documentation** - Help others understand the code
- **Share Examples** - Show off what you've created with this shader

### Getting Started

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
   - Follow the existing code style
   - Comment complex sections
   - Test thoroughly
4. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```
5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```
6. **Open a Pull Request**

### Contribution Ideas

- [ ] Add RF interference patterns
- [ ] Create color bleeding effect
- [ ] Optimize performance for lower-end GPUs
- [ ] Add tape speed variation effects
- [ ] Build a parameter GUI/controls

### Code Style Guidelines

- Use meaningful variable names
- Comment non-obvious logic
- Keep functions focused and modular
- Test with different input sources
- Optimize where possible, but keep it readable

## Requirements

- WebGL-compatible browser (for ShaderToy)
- Or any GLSL-compatible shader environment

## Performance Notes

This shader uses multiple temporal samples which can be GPU-intensive. If you experience performance issues:
- Reduce `ghostSamples` (line 44)
- Increase `pixelBlockSize` (line 96)
- Optimize for your specific use case


## Acknowledgments
- Build over the groundwork of Caaaaaaarter on Shadertoy.
- Inspired by authentic VHS and CRT artifacts
- Thanks to all contributors!

---

Questions? Open an issue or start a discussion!
