# HarmonEQ - Harmonic Equalizer

This is a harmonic equalizer for audio developed in MATLAB using the Audio Toolbox for the 2021 AES Student Plugin competition.
HarmonEQ differs from other equalizers in its control scheme. It is a parametric equalizer with indirect controls.
Rather than having precise control over filter frequencies, the user tunes HarmonEQ to a specific musical note or chord.
The user can then define gain and Q values for five different ranges: low, low-mid, mid, high-mid, high.

In the current iteration, there two sets of controls for testing while it is still being developed. The first set of controls apply to each chord tone across the entire frequency spectrum. The second set splits the controls into five bands with one gain control and one Q control affecting all filters within that band.

## Compiled plugins
Pre-compiled versions of the plugin are available:
- macOS
  - [VST](https://github.com/malloyca/HarmonEQ/releases/download/v0.2-alpha/HarmonEQ.vst.zip) (stereo only)
  - [AU](https://github.com/malloyca/HarmonEQ/releases/download/v0.2-alpha/HarmonEQ.component.zip) (stereo only)
- Windows
  - Coming soon. I need a Windows installation to compile for Windows...

### Installation instrucitons
- macOS
  - Download and unzip the VST and AU plugins.
  - Open Finder and go to the Home folder.
  - Navigate to `/Library/Audio/Plug-Ins/`.
  - Move `HarmonEQ.vst` to the `/VST/` folder and `HarmonEQ.component` to the `/components/` folder.

## Prereqs for compiling
- MATLAB
  - DSP Toolbox
  - Audio Toolbox
  - MATLAB Coder (for exporting to JUCE)


## Development Roadmap
This project is currently in active development. The primary DSP functionality is implemented. I am currently working on designing the UI.

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


### TODO list:
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
- Currently, changing a crossover frequency does not update the gain/Q for a filter being passed from one control region to another. Changing the chord also does not update this. I think the solution is to implement gain and Q updating in the `setUpdateRootFilter1`, etc functions instead of doing it directly in the setter functions. This should not be difficult to implement, but will require a lot of code revision.
