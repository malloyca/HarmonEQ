# HarmonEQ - Harmonic Equalizer

This is a harmonic equalizer for audio developed in MATLAB using the Audio Toolbox for the 2021 AES Student Plugin competition.
HarmonEQ differs from other equalizers in its control scheme. It is a parametric equalizer with indirect controls.
Rather than having precise control over filter frequencies, the user tunes HarmonEQ to a specific musical note or chord.
The user can then define gain and Q values for five different ranges: low, low-mid, mid, high-mid, high.

In the current iteration, there are gain and Q factor controls for each chord tone. The five region control scheme is currently under development.


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
- Implement controls by range.
- Test to see if the filter frequency jumps needs smoothing.
  - Due the nature of the controls, the filter bands get adjusted instantaneously instead of gradually like on a regular EQ. This seems to cause some quite apparent audio artifacts.
  - There are a few ways smoothing could be applied.
- Is there a way to display the current chord?
  - Currently you see the settings for the root, third, fifth, and seventh. It would be more satisfying and give the user good feedback if it had a way to display a chord as Fmin7 instead of F / Min3 / Perf5 / Min7. That's not the way we think.
  -  Yes. This can be accomlished by having a dropdown box with a getter function that does nothing, but a setter function that updates every time there is a harmonic change.
  - In order to implement this, maybe I should convert the chord information to matrix form?
    - It might actually be simpler programming-wise to use the currently existing `thirdIntervalDistance`, etc attributes to creat a set of rules for concatenating the chord names to set the drop-down box.
  - A fun complication is dealing with "incomplete" chords (i.e., C7 (no fifth)). There are going to be a lot of option in this drop-down menu...


## Bug List
