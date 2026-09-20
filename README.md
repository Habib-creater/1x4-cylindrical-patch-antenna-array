# 1×4 Conformal Microstrip Patch Antenna Array

A 1×4 linear microstrip patch antenna array designed for 2 GHz and conformally bent onto a cylindrical surface with a radius of 300 mm (30 cm). The array was designed and simulated in **CST Studio Suite 2025**, with phase-corrected feeding used to compensate for the curvature and steer the main beam from broadside toward wide scan angles.

![Array overview](results/overview/1x4_Cylindrical_antenna.png)

The project includes the analytical design of the patch element, effective dielectric constant and fringing calculations, feed design, curvature-related phase correction, beam-scanning phase calculations, and CST simulation results.

The complete analytical derivation and design calculations are available in the [Design Calculations Report](docs/Design_Calculations_Report.pdf).

---

## Design Overview

The array consists of four inset-fed microstrip patch elements arranged along a cylindrical surface. The element spacing is selected as 0.5λ₀ at the 2 GHz design frequency.

The cylindrical geometry introduces different path lengths between the individual elements and the far-field observation direction. Phase corrections are therefore applied at the array ports to compensate for the curvature and control the beam direction.

### Design Specifications

| Parameter                  |                Value |
| -------------------------- | -------------------: |
| Design frequency           |                2 GHz |
| Substrate                  |         FR-4 (lossy) |
| Relative permittivity (εᵣ) |                  4.3 |
| Substrate height (h)       |               1.6 mm |
| Copper thickness           |             0.035 mm |
| Substrate size per element |       300 mm × 56 mm |
| Patch dimensions (W × L)   |    45.5 mm × 32.4 mm |
| Feed type                  | Inset-fed microstrip |
| Feedline width             |               3.1 mm |
| Inset notch depth          |                10 mm |
| Inset gap                  |                 1 mm |
| Element spacing            |                75 mm |
| Cylindrical bend radius    |               300 mm |

### Patch Optimization

The initial analytical calculation produced a patch length of **35.85 mm**. During CST simulation, the patch length was re-optimized to **32.4 mm** to account for feed-pin loading, impedance changes, and the effects of conformal bending.

The complete CST parameter set is provided in [`docs/Parameter_list.png`](docs/Parameter_list.png).

---

## Curvature Phase Correction

Bending the array introduces a physical path-length difference between the elements. For broadside radiation, phase compensation is applied to the outer elements to restore the required phase relationship across the curved aperture.

### Broadside Phase Correction — 0°

| Port                 | Position on Cylinder | Applied Phase |
| -------------------- | -------------------: | ------------: |
| Port 1 — Outer Left  |              -21.48° |        +44.4° |
| Port 2 — Inner Left  |               -7.16° |          0.0° |
| Port 3 — Inner Right |               +7.16° |          0.0° |
| Port 4 — Outer Right |              +21.48° |        +44.4° |

---

## Beam-Scanning Phase Control

Additional phase shifts were applied to steer the main beam away from broadside.

![Scan target phases](docs/Scanned_Target_phases.png)

| Target Angle | Port 1 |  Port 2 |  Port 3 |  Port 4 |
| -----------: | -----: | ------: | ------: | ------: |
|           0° | +44.4° |    0.0° |    0.0° |  +44.4° |
|          10° | +44.4° |  -31.3° |  -62.5° |  -49.4° |
|          20° | +44.4° |  -61.6° | -123.1° | -140.3° |
|          30° | +44.4° |  -90.0° | -180.0° | -225.6° |
|          40° | +44.4° | -135.0° | -250.0° | -310.0° |
|          50° | +44.4° | -160.0° | -295.0° | -375.0° |

The phase values for the 40° and 50° cases were manually refined in CST because the analytical phase relationship alone did not produce the desired beam direction at these wider scan angles.

---

## Simulated Results

The following table summarizes the main CST simulation results for the different steering conditions.

| Target Angle |       S11 | Resonant Frequency |     Gain | Actual Main Lobe | 3 dB Beamwidth | Sidelobe |
| -----------: | --------: | -----------------: | -------: | ---------------: | -------------: | -------: |
|           0° | -10.92 dB |          2.070 GHz | 7.08 dBi |             0.0° |          26.2° | -11.5 dB |
|          10° | -11.41 dB |          2.072 GHz | 6.94 dBi |             9.0° |          26.5° | -11.0 dB |
|          20° | -12.03 dB |          2.072 GHz | 6.54 dBi |            19.0° |          27.0° | -10.1 dB |
|          30° | -12.76 dB |          2.072 GHz | 5.89 dBi |            27.0° |          27.7° |  -9.1 dB |
|          40° | -13.74 dB |          2.068 GHz | 4.84 dBi |            35.0° |          28.5° |  -8.7 dB |
|          50° | -14.01 dB |          2.068 GHz |  3.8 dBi |            42.0° |          29.6° |  -6.5 dB |

Individual S11, gain, radiation-pattern, and efficiency plots for each scan condition are available in the corresponding folders under [`results/`](results/).

---

## Results Discussion

### Impedance Matching

Across the simulated scan conditions, the input reflection coefficient remains below **-10 dB**, ranging from **-10.92 dB to -14.01 dB**. The resonant frequency remains close to the 2 GHz design target, between approximately **2.068 and 2.072 GHz**.

The re-optimized 32.4 mm patch length therefore provides the required impedance response for the conformally bent configuration.

### Beam Steering

The array maintains close beam-pointing accuracy at smaller scan angles:

* **0°:** actual beam at 0°
* **10°:** actual beam at 9°
* **20°:** actual beam at 19°

At wider steering angles, the difference between the commanded and simulated beam direction increases. The 40° and 50° cases produce main-lobe directions of approximately 35° and 42°, respectively.

The wider-angle cases also show a reduction in gain and an increase in sidelobe level. Gain decreases from **7.08 dBi at broadside to 3.8 dBi at the 50° target**, while the sidelobe level changes from **-11.5 dB to -6.5 dB**.

This behavior is consistent with the limitations of wide-angle scanning in a small, curved four-element array, where the element radiation pattern and effective aperture increasingly affect the achievable beam direction.

---

## Simulation Results

### Broadside — 0°

Results for the broadside configuration are available in:

[`results/broadside/`](results/broadside/)

### 10° Scan

[`results/scan_10deg/`](results/scan_10deg/)

### 20° Scan

[`results/scan_20deg/`](results/scan_20deg/)

### 30° Scan

[`results/scan_30deg/`](results/scan_30deg/)

### 40° Scan

[`results/scan_40deg/`](results/scan_40deg/)

### 50° Scan

[`results/scan_50deg/`](results/scan_50deg/)

Additional VSWR results are available in:

[`results/vswr/`](results/vswr/)

---

## Project Structure

```text
1x4-cylindrical-patch-antenna-array/
├── design/
│   └── CST Studio Suite project files
│
├── docs/
│   ├── Design_Calculations_Report.pdf
│   ├── Parameter_list.png
│   └── Scanned_Target_phases.png
│
├── results/
│   ├── overview/
│   │   └── 1x4_Cylindrical_antenna.png
│   │
│   ├── broadside/
│   ├── scan_10deg/
│   ├── scan_20deg/
│   ├── scan_30deg/
│   ├── scan_40deg/
│   ├── scan_50deg/
│   └── vswr/
│
└── README.md
```

---

## Tools

* **CST Studio Suite 2025**
* Electromagnetic simulation
* Microstrip antenna design
* Phased-array analysis
* Beam-steering analysis

---

## Project Highlights

* Designed a **1×4 conformal microstrip patch antenna array**
* Designed for a **2 GHz** operating frequency
* Implemented a **300 mm cylindrical bending radius**
* Applied **phase correction** to compensate for curvature
* Investigated beam steering from **0° to 50°**
* Re-optimized patch dimensions through CST simulation
* Analyzed **S11, gain, beam direction, beamwidth, and sidelobe level**
* Documented analytical calculations and simulation results

---

## Author

**Habib Ur Rehman**

Electronics Engineering
University of Engineering and Technology, Peshawar
