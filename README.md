# TMDD Model Simulator

A Shiny application for exploring Target-Mediated Drug Disposition (TMDD) in a two-compartment pharmacokinetic model.

## Overview

This interactive tool allows users to simulate and visualize the complex dynamics of drugs that exhibit target-mediated drug disposition. The app includes:
- Two-compartment PK model with TMDD in the central compartment
- Interactive parameter adjustment
- Single and multiple dose simulations
- Customizable plotting options

## Model Structure

### PK Components
- Two-compartment model with first-order absorption
- Central and peripheral compartments
- Linear clearance from central compartment

### TMDD Components
- Drug-receptor binding (kon/koff)
- Receptor turnover (synthesis/degradation)
- Complex internalization
- Free and bound drug/receptor tracking

## Features

### Parameter Controls
- **PK Parameters**: CL, V1, Q, V2
- **TMDD Parameters**: kon, koff, kint, kdeg, Rc0
- **Dosing Options**: Single/Multiple doses with flexible intervals

### Visualization
- Multiple concentration-time profiles
- Selectable variables (Total/Free Drug/Receptor)
- Linear/Log scale options
- Adjustable y-axis range
- Multi-dose comparison

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/TMDD-simulator.git
```

2. Install required R packages:
```r
install.packages(c("shiny", "mrgsolve", "dplyr", "ggplot2"))
```

3. Run the app:
```r
shiny::runApp("TMDD-simulator")
```

## Usage

1. Select dosing regime (single/multiple)
2. Adjust PK and TMDD parameters using sliders
3. Choose variables to display
4. Modify plot settings as needed
5. Explore "About" tab for detailed explanations

## File Structure

```
TMDD-simulator/
├── scripts/
│   ├── ui.R           # User interface definition
│   ├── server.R       # Server logic
│   └── TMDD_model.cpp # mrgsolve model specification
└── README.md
```

## References

Based on:
- Dua, P., et al. (2015). A Tutorial on Target-Mediated Drug Disposition (TMDD) Models. CPT Pharmacometrics Syst Pharmacol, 4(6):324-37.

## Author

Jane Knöchel

## License

This work is licensed under the Creative Commons Attribution 4.0 International License.
See https://creativecommons.org/licenses/by/4.0/legalcode for details.
