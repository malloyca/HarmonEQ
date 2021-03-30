# HarmonEQ - Harmonic Equalizer

This is a harmonic equalizer for audio developin MATLAB using the Audio Toolbox for the 2021 AES Student Plugin competition.
HarmonEQ differs from other equalizers in its control scheme. It is a parametric equalizer with indirect controls.
Rather than having precise control over filter frequencies, the user tunes HarmonEQ to a specific musical note or chord.
The user can then define gain and Q values for five different ranges: low, low-mid, mid, high-mid, high.


## Prereqs
- MATLAB
  - DSP Toolbox
  - Audio Toolbox


## Development Roadmap
This project is currently in active development.

### Features intended for April 6 deadline:
- Harmonic controls:
  - Root control
    - off
    - Chromatic notes: A, A#/Bb, B, C, ..., G, G#/Ab
  - Third
    - off
    - Sus2
    - Min3
    - Maj3
    - Sus4
  - Fifth
    - off
    - Dim5
    - Perf5
    - Aug5
  - Seventh
    - off
    - Dim7 (Maj6)
    - Min7
    - Maj7
- Control for the filters will be split into five regions: low, low-mid, mid, high-mid, and high
  - The user can set the gain and Q factors for each region, but cannot affect individual filters directly
  - There will also be four crossover controls for defining the frequency ranges for each region.
- Input gain control
  - Output gain control?


TODO list:
- Implement filters for thirds
  - This will need to update every time the root updates as well as when the quality of the third note is updated
- Test to see if the filter frequency jumps needs smoothing
- Is there a way to display the current chord?
  - Yes. This can be accomlished by having a dropdown box with a getter function that does nothing, but a setter function that updates every time there is a harmonic change.
  - In order to implement this, maybe I should convert the chord information to matrix form?
- Implement filters for fifths
- Implement filters for sevenths


## Bug List
- Although harmonic third setting initialize to 'off', the filters are on and being built.
