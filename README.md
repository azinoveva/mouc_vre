# Multiobjective Unit Commitment Problem for Variable Renewable Networks

This repository contains the supplementary materials for my thesis. It includes MATLAB code, result files, and a benchmarking script for reproducing the results. The results are generated using a combination of commercial and open-source software.

## Contents

- `benchmarking.mlx`: MATLAB live script to reproduce the results.
- `results/`: Folder containing the result files in .mat format.
- `*.m`: MATLAB code used for the thesis, including the main scripts and functions.
- `README.md`: This file.

## Prerequisites

### MATLAB

- MATLAB (tested with version R2024a)

### Open-source Software
- [SeDuMi](https://sedumi.ie.lehigh.edu)
- [YALMIP](https://yalmip.github.io/)

### Commercial Software

- [Gurobi](https://www.gurobi.com/): Requires installation and an academic license.

### Cloning the Repository

```bash
git clone https://github.com/azinoveva/mouc_vre.git
cd mouc_vre
```
## Installation

- MATLAB: Make sure MATLAB is installed on your system.
- SeDuMi: Download and add SeDuMi to your MATLAB path. Follow the instructions on the SeDuMi GitHub page.
- YALMIP: Download and add YALMIP to your MATLAB path. Follow the instructions on the YALMIP website.
- Gurobi: Install Gurobi from the official website. Follow the instructions to activate your academic license. Add Gurobi to your MATLAB path by following the instructions provided by Gurobi.

## Reproducing Results

- Ensure all prerequisites are installed and configured.
- Open MATLAB and navigate to the cloned repository directory.
- Run the benchmarking.mlx live script to reproduce the results.

```matlab
open('benchmarking.mlx')
```

⚠️ The SeDuMi block can take multiple hours to run. Unpack the precomputed `results.mat` from the `results/` folder for a shortcut. ⚠️


## Generator parameters


| Unit | G_max | a   | b      | C_run  | C_start  | T_min |
| ---  | --- | ---   | ---      | ---  | ---  | --- |
| U1   | 455 | 16.19 | 0.00048  | 1000 | 9000 |  8  |
| U2   | 455 | 17.26 | 0.00031  | 970  |10000 |  8  |
| U3   | 130 | 16.6  | 0.002    | 700  |1100  |  5  |
| U4   | 130 | 16.5  | 0.00211  | 680  |1120  |  5  |
| U5   | 162 | 19.7  | 0.00398  | 450  |1800  |  6  |
| U6   | 80  | 22.26 | 0.00712  | 370  |340   |  3  |
| U7   | 85  | 27.74 | 0.000793 | 480  |520   |  3  |
| U8   | 55  | 25.92 | 0.00413  | 660  |60    |  1  |
| U9   | 55  | 27.27 | 0.002221 | 665  |60    |  1  |
| U10  | 55  | 27.79 | 0.00173  | 670  |60    |  1  |
