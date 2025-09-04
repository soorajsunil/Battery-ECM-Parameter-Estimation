# Battery ECM Parameter Estimation
Parameter estimation of 1st, 2nd, and 3rd order RC equivalent circuit models (ECMs) for lithium-ion batteries using a **two-stage linear least squares (LS)** approach with pulse–relaxation data.

## Overview
This repository demonstrates how to extract ECM parameters from battery pulse-relaxation experiments:
1. **Stage 1 (LS-1)** – Estimate RC time constants:  
  τₙ =  Rₙ Cₙ, n=1,2,3

2. **Stage 2 (LS-2)** – With τₙ fixed, solve a linear least squares problem to estimate:  
   - Open-circuit voltage (OCV)  
   - OCV slope term (κ)  
   - Ohmic resistance (R₀)  
   - RC branch resistances (Rₙ, n=1,2,3)  

   Capacitances are then recovered as:  
   Cₙ = τₙ / Rₙ

## Usage
Run demo:
```
Battery_ECM_Parameter_Estimation/Demo.m
```
Run function: 
```matlab
[theta_1RC] = twoStageLS(vbatt, ibatt, t, '1RC');
[theta_2RC] = twoStageLS(vbatt, ibatt, t, '2RC');
[theta_3RC] = twoStageLS(vbatt, ibatt, t, '3RC');
```
<p align="center">
  <img src="SamplePulseRelaxationFit.png" alt="Pulse Relaxation Fit" width="500">
</p>

## Reference
Two-Stage Least Squares for Equivalent-Circuit Parameter Estimation of Lithium-ion Batteries Using Pulse-Relaxation Excitation (under review) 
