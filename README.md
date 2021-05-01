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
    - [mono](https://github.com/malloyca/HarmonEQ/releases/download/v0.4/HarmonEQ_mono.vst.zip)
    - [stereo](https://github.com/malloyca/HarmonEQ/releases/download/v0.4/HarmonEQ.vst.zip)
  - AU:
    - [mono](https://github.com/malloyca/HarmonEQ/releases/download/v0.4/HarmonEQ_mono.component.zip)
    - [stereo](https://github.com/malloyca/HarmonEQ/releases/download/v0.4/HarmonEQ.component.zip)
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
- MATLAB
  - DSP Toolbox
  - Audio Toolbox
  - MATLAB Coder (for exporting to JUCE)


## Development Roadmap
This project is currently in active development. The primary DSP functionality is implemented. Current work is on transition smoothing and UI refinements.

### Features intended for April 6 deadline:
- Harmonic controls:
  - Root control
    - off
    - Chromatic notes: A, A#/Bb, B, C, ..., G, G#/Ab
  - Chord type
    - no chord
    - 5
    - min
    - maj
    - aug
    - dim
    - min7
    - dom7
    - maj7
    - m7b5
    - dim7
- Control for the filters are split into five regions: low, low-mid, mid, high-mid, and high
  - The user can set the gain and Q factors for each region, but cannot affect individual filters directly
  - There are also four crossover controls for adjusting the frequency ranges for each region.
- Input gain control
  - Output gain control?


### TODO list:
- Test to see if the filter frequency jumps needs smoothing.
  - Due the nature of the controls, the filter bands get adjusted instantaneously instead of gradually like on a regular EQ. This seems to cause some quite apparent audio artifacts.
  - There are a few ways smoothing could be applied.
- Post instructions for removing plugins from quarantine on macOS

