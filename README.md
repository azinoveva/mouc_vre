# mouc_vre
Multiobjective Unit Commitment Problem for Variable Renewable Networks

## The code is HEAVILY under construction!

### TODO list:
- [x] Rewrite matrix A5 in "flipped" dimensions
- [ ] Constraints overhaul
- [ ] Second objective (VRE) implementation
- [ ] (big one) Benchmark *gurobi* -- this can be also used later for SeDuMi
- [ ] (even bigger one) Implement for SeDuMi solver

### Generator parameters
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