# Simulink Hearing Aid

> A modular digital hearing-aid simulation developed using **MATLAB R2025b** and **Simulink** for the **MathWorks Excellence in Innovation Challenge — Project 241**.

---

## Overview

**Simulink Hearing Aid** is an engineering-focused simulation of a modern digital hearing-aid signal-processing system developed using MATLAB and Simulink.

The project explores how Digital Signal Processing (DSP) techniques can be combined to improve the audibility and quality of speech for a simulated hearing-loss profile.

Rather than applying uniform amplification to an entire audio signal, the system uses frequency-selective processing to independently process low-, mid-, and high-frequency components. The processed bands are reconstructed and passed through additional signal-conditioning stages before real-time audio playback.

The project is developed as a modular Simulink model supported by MATLAB-based analysis and experimentation.

The implementation includes:

* Multi-band FIR filtering
* Frequency-dependent gain compensation
* Dynamic Range Compression (DRC)
* Noise reduction
* Adaptive feedback cancellation
* Output protection
* Real-time audio playback
* Waveform and spectrum analysis
* RMS-based signal-level analysis
* Input/output comparison
* MATLAB-based experimental development
* TIMIT speech-dataset support

The project is intended as an **engineering and educational simulation** and is not a clinically validated hearing-aid device.

---

## Objectives

The project aims to:

* Study the signal-processing architecture of modern digital hearing aids.
* Develop a complete hearing-aid DSP pipeline using Simulink.
* Implement frequency-dependent amplification using multi-band processing.
* Apply DSP techniques to improve speech audibility and listening quality.
* Investigate Dynamic Range Compression for controlling signal dynamics.
* Reduce unwanted background components.
* Investigate adaptive feedback cancellation.
* Analyse the effect of individual processing stages using MATLAB and Simulink.
* Validate the complete system using real audio and speech data.
* Provide a reproducible MATLAB/Simulink implementation.
* Demonstrate model-based design for a practical DSP application.

---

## System Architecture

The completed system follows a modular, frame-based audio-processing architecture.

The primary signal flow is:

Audio Input → Pre-processing → Frequency Filtering → Multi-band Gain Compensation → Dynamic Range Compression → Noise Reduction → Feedback Cancellation → Output Protection → Audio Output

The frequency-selective processing stage divides the incoming signal into three parallel paths:

Audio Input → Low FIR → Low Gain ┐
Audio Input → Mid FIR → Mid Gain ├→ Summation → Compensated Audio
Audio Input → High FIR → High Gain ┘

The reconstructed signal is subsequently passed through the remaining processing stages before being delivered to the audio output interface.

This architecture allows each major processing stage to be inspected, tested, and modified independently.

---

## Multi-band Processing

A major component of the system is the frequency-selective processing stage.

The incoming audio is divided into three frequency regions using FIR filters:

* Low-frequency band
* Mid-frequency band
* High-frequency band

Each band is then passed through an independent gain stage.

This allows the system to represent frequency-dependent hearing loss, where certain frequency regions may require greater amplification than others.

The current reference gain configuration is:

| Frequency Band |          Gain | Approx. Linear Gain |
| -------------- | ------------: | ------------------: |
| Low            |          0 dB |                 1.0 |
| Mid            |         +8 dB |                2.51 |
| High           | +15 to +20 dB |           5.62–10.0 |

These values represent the project's generic simulation profile and **are not clinical prescription values**.

---

## FIR Filtering

The frequency-processing stage uses Finite Impulse Response (FIR) filters.

FIR filtering was selected because of its:

* Stable implementation
* Predictable frequency response
* Linear-phase characteristics
* Suitability for multi-band processing
* Straightforward implementation in Simulink

The implemented FIR configuration uses:

* Filter order: **376**
* Number of taps: **377**
* Sampling frequency: **16 kHz**
* Group delay: **188 samples**
* Approximate group delay: **11.75 ms**

The group delay is calculated from the linear-phase FIR relationship:

**τg = N / 2**

where `N = 376`.

---

## Dynamic Range Compression

Dynamic Range Compression (DRC) is used to control the relationship between signal amplitude and applied amplification.

The objective is to make weaker speech components more audible while preventing unnecessarily high amplification of stronger signals.

The system evaluates signal-level behaviour using moving RMS analysis.

The current Moving RMS configuration uses:

| Parameter     |          Value |
| ------------- | -------------: |
| Method        | Sliding window |
| Window length |   1024 samples |
| Overlap       |      0 samples |

The RMS analysis is used to compare signal-level behaviour before and after processing and to observe the effect of dynamic processing.

---

## Noise Reduction

The noise-reduction stage is designed to reduce unwanted background components while preserving speech information.

The objective is not complete noise elimination. Instead, the processing aims to improve the effective signal-to-noise relationship while avoiding excessive speech distortion.

The performance of this stage is evaluated using:

* Time-domain waveform comparison
* Frequency-domain analysis
* Signal-level measurements
* Subjective listening evaluation

---

## Adaptive Feedback Cancellation

Acoustic feedback is a major limitation in high-gain hearing-aid systems.

Feedback occurs when sound produced by the output receiver couples back into the microphone and is amplified again, potentially creating an unstable oscillation.

The project includes an adaptive feedback-cancellation stage intended to reduce this unwanted feedback path.

The architecture allows the feedback-processing stage to estimate unwanted feedback components and suppress them before the final audio output.

The implementation also provides a foundation for further investigation of adaptive algorithms such as LMS and NLMS.

---

## Output Protection

An output-protection subsystem is included before the final audio output.

Its purpose is to prevent excessive signal levels from reaching the playback interface and to reduce the possibility of clipping or undesirable output behaviour.

The output-protection stage therefore acts as the final signal-conditioning layer before audio reproduction.

---

## Real-Time Audio Processing

The completed Simulink model supports real-time audio playback through the computer audio interface.

The audio processing chain operates using frame-based DSP, allowing incoming audio to be processed continuously rather than requiring the entire recording to be loaded into memory.

The final processed signal is delivered to the configured audio output device.

The real-time system has been experimentally verified using live audio input and successful audible playback.

---

## Signal Analysis

The project includes signal-monitoring and visualisation stages throughout the processing chain.

The analysis includes:

* Input waveform
* Output waveform
* Input spectrum
* Output spectrum
* Low-band signal
* Mid-band signal
* High-band signal
* RMS measurements
* Input/output comparisons
* Signal-level analysis

These measurements allow the behaviour of the system to be evaluated both objectively through signal analysis and subjectively through listening.

---

## Experimental Results

Experimental evaluation of the completed system demonstrated:

* Successful end-to-end Simulink execution.
* Successful real-time audio playback.
* Clear audible output after processing.
* Correct operation of the multi-band processing paths.
* Independent visibility of low-, mid-, and high-frequency signals.
* Successful Dynamic Range Compression operation.
* Successful RMS-based signal analysis.
* Observable differences between input and processed output.
* Frequency-dependent amplification according to the configured hearing-loss profile.
* Successful operation of the output-protection stage.
* Stable final audio reproduction.

Representative parameters include:

| Parameter              |         Value |
| ---------------------- | ------------: |
| DSP Sampling Frequency |        16 kHz |
| FIR Filter Order       |           376 |
| FIR Taps               |           377 |
| FIR Group Delay        |   188 samples |
| Approx. FIR Delay      |      11.75 ms |
| Low Gain               |          0 dB |
| Mid Gain               |         +8 dB |
| High Gain              | +15 to +20 dB |
| Moving RMS Window      |  1024 samples |

The observed output characteristics vary with the input audio, recording conditions, and configured processing parameters.

---

## MATLAB and Simulink Workflow

MATLAB and Simulink are used for different but complementary parts of the project.

**MATLAB** is used for:

* Audio-data analysis
* Filter development
* Parameter exploration
* Experimental evaluation
* Spectrum analysis
* Result generation
* Dataset investigation

**Simulink** is used for:

* System-level modelling
* DSP subsystem integration
* Real-time signal processing
* Audio streaming
* Signal visualisation
* End-to-end system validation

The overall development workflow is:

Research → Requirements → Architecture → MATLAB Development → Simulink Implementation → Subsystem Testing → Integration → Experimental Validation

---

## Dataset

The repository contains the **TIMIT speech dataset** under:

`Data/datasets/TIMIT/`

The dataset is used for speech-processing experiments and evaluation.

A smaller set of sample data is maintained under:

`Data/sample/`

The dataset and sample-data directories are kept separate so that lightweight demonstrations can be performed without requiring the complete dataset.

---

## Single Entry Point

The repository provides a single entry point for running the completed project:

`run_hearingaid.m`

The purpose of this script is to provide a simple and reproducible execution path without requiring the user to manually locate individual MATLAB scripts or Simulink models.

The intended workflow is:

run_hearingaid.m → Project Setup → Required Configuration → Final Simulink Model → Complete DSP Processing → Analysis → Final Results

The entry point is designed to prepare the required environment, load the necessary configuration and data, launch the final hearing-aid model, and provide the resulting analysis.

### Running the Project

After opening the repository in MATLAB and ensuring the required toolboxes are available, execute:

```matlab
run_hearingaid
```

The script serves as the primary starting point for the final project implementation.

---

## Repository Structure

```text
Simulink-Hearing-Aid/
│
├── Data/
│   ├── datasets/
│   │   └── TIMIT/
│   │
│   └── sample/
│
├── Documentation/
│
├── Models/
│   ├── MATLAB/
│   │   ├── Development/
│   │   ├── Experiments/
│   │   └── Final/
│   │
│   └── Simulink/
│
├── Results/
│
├── .gitignore
├── LICENSE
├── README.md
└── run_hearingaid.m
```

### Data

Contains speech datasets and sample audio files used for testing and experimentation.

### Models/MATLAB/Development

Contains MATLAB scripts developed during implementation, debugging, and early-stage development.

### Models/MATLAB/Experiments

Contains experimental MATLAB scripts used for analysis, comparisons, parameter evaluation, and validation.

### Models/MATLAB/Final

Contains the cleaned and final MATLAB implementations used by the completed project.

### Models/Simulink

Contains the Simulink models forming the main hearing-aid processing system.

### Results

Contains generated plots, analysis figures, comparison results, and other outputs produced during final evaluation.

---

## Software Requirements

The project was developed and tested using:

* MATLAB R2025b
* Simulink R2025b
* Audio Toolbox
* DSP System Toolbox
* Signal Processing Toolbox

A functional computer audio input/output interface is required for real-time audio operation.

---

## Engineering Design Philosophy

The project prioritises engineering understanding, modularity, reproducibility, and experimental validation.

Each major DSP operation is implemented as a defined processing stage rather than combining the entire system into a single opaque model.

This provides:

* Easier debugging
* Independent subsystem verification
* Clear signal tracing
* Parameter transparency
* Easier experimentation
* Future extensibility

The project therefore demonstrates not only the final hearing-aid simulation but also the model-based engineering process used to develop it.

---

## AI-Assisted Development Disclosure

Artificial intelligence tools were used during the development of this project as **supporting engineering tools**.

AI assistance was limited primarily to:

* Troubleshooting MATLAB and Simulink errors.
* Interpreting error messages and suggesting possible debugging approaches.
* Exploring MATLAB and Simulink code patterns.
* Improving naming consistency for variables, blocks, files, and subsystems.
* Supporting literature and technical research.
* Reviewing technical explanations during documentation development.

AI-generated suggestions were not treated as authoritative implementation decisions.

The system architecture, DSP design, parameter selection, Simulink implementation, integration, testing, experimental evaluation, and final engineering decisions were performed and verified by the author.

Where AI-generated suggestions were used during troubleshooting or development, they were reviewed and tested within the actual MATLAB/Simulink environment before being incorporated.

Experimental measurements and reported system results were obtained from the implemented project rather than generated or assumed by an AI system.

This disclosure is provided to maintain transparency regarding the project's development process.

---

## Limitations

This project is an engineering simulation and does not represent a clinically validated hearing-aid device.

Important limitations include:

* The implemented hearing-loss profile is generic rather than based on an individual clinical audiogram.
* Gain values are simulation parameters and should not be interpreted as medical prescriptions.
* The system has not undergone clinical hearing-aid validation.
* Real-time performance depends partly on the host computer and audio hardware.
* The simulated acoustic feedback path does not completely reproduce the behaviour of a physical ear, receiver, and microphone arrangement.
* Commercial hearing aids employ additional proprietary algorithms and hardware-level optimisation outside the scope of this project.
* Objective clinical measures of speech intelligibility and hearing-aid benefit are outside the current scope.

---

## Future Development

The modular architecture provides a foundation for further development.

Potential future work includes:

* Audiogram-based personalised gain fitting.
* More detailed multi-band Dynamic Range Compression.
* Improved adaptive feedback cancellation.
* Advanced noise-reduction algorithms.
* Automatic acoustic-environment classification.
* Directional microphone processing.
* Beamforming.
* Machine-learning-based speech enhancement.
* Embedded implementation on ARM or DSP hardware.
* Dedicated audio-codec integration.
* Hardware prototype development.
* Formal computational-load and latency benchmarking.
* Objective speech-intelligibility evaluation.

---

## Challenge Information

### MathWorks Excellence in Innovation Challenge

**Project Number:** 241

**Project Title:** Simulink Hearing Aid

This project was developed as an entry for the MathWorks Excellence in Innovation Challenge and demonstrates the application of MATLAB and Simulink to a practical Digital Signal Processing problem.
