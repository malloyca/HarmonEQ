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

TODO list:
- Implement initial ~~gain~~ and Q controls for root filters (do not need to be split into groups yet)
- Implement single third note filter for testing
  - This will need to update every time the root updates as well as when the quality of the third note is updated
- Test to see if the filter frequency jumps needs smoothing
- Is there a way to display the current chord?
  - Yes. This can be accomlished by having a dropdown box with a getter function that does nothing, but a setter function that updates every time there is a harmonic change.
  - In order to implement this, maybe I should convert the chord information to matrix form?
