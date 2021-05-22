# HarmonEQ - Harmonic Equalizer

This is a harmonic equalizer for audio developed in MATLAB using the Audio Toolbox for the 2021 AES Student Plugin competition.
HarmonEQ differs from other equalizers in its control scheme. It is a parametric equalizer with indirect controls.
Rather than having precise control over filter frequencies, the user tunes HarmonEQ to a specific musical note or chord.
The user can then define gain and Q values for five different ranges: low, low-mid, mid, high-mid, high.

Development is currently ongoing and stable functionality is not guaranteed.

## Compiled plugins
Pre-compiled versions of the plugin are available:
- macOS
  - VST:
    - [mono (v0.4)](https://github.com/malloyca/HarmonEQ/releases/download/v0.4/HarmonEQ_mono.vst.zip)
    - [stereo](https://github.com/malloyca/HarmonEQ/releases/download/v0.5/HarmonEQ.vst.zip)
  - AU:
    - [mono (v0.4)](https://github.com/malloyca/HarmonEQ/releases/download/v0.4/HarmonEQ_mono.component.zip)
    - [stereo](https://github.com/malloyca/HarmonEQ/releases/download/v0.5/HarmonEQ.component.zip)
- Windows
  - Coming soon. I need a Windows installation in order to be able to compile for Windows...

### Installation instrucitons
- macOS
  - Download and unzip the VST and AU plugins.
  - Open Finder and go to the Home folder.
  - Navigate to `/Library/Audio/Plug-Ins/`.
  - Move `HarmonEQ.vst` to the `/VST/` folder and `HarmonEQ.component` to the `/components/` folder.
  - On newer versions of macOS (10.14 or 10.15 and later) you will need to manually remove the plugins from quarantine. Instructions for that will be posted soon.

## Prereqs for compiling
- MATLAB R2021a
  - DSP Toolbox
  - Audio Toolbox
  - MATLAB Coder (for exporting to JUCE)
