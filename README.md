# Battery_ECM_Parameter_Estimation

Parameter estimation of 1st, 2nd, and 3rd order RC equivalent circuit models (ECMs) for lithium-ion batteries using a **two-stage linear least squares (LS)** approach with pulse–relaxation data.


## Overview

This repository demonstrates how to extract ECM parameters from voltage–current pulse experiments:

1. **Stage 1** – Estimate RC time constants (τ = R·C).
2. **Stage 2** – Solve a linear least squares problem to estimate: OCV, κ (slope term), ohmic resistance R₀, and the RC branch resistances Rₖ and Capacitors Cₖ are then computed as τ / Rₖ.

## Usage



<p align="center">
  <img src="SamplePulseRelaxationFit.png" alt="Pulse Relaxation Fit" width="500">
</p>

## Reference
Two-Stage Least Squares for Equivalent-Circuit Parameter Estimation of Lithium-ion Batteries Using Pulse-Relaxation Excitation (under review) 
