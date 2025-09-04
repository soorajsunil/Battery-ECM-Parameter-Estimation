function [theta_hat] = twoStageLS(vbatt, ibatt, t, model)
% Estimate ECM parameters from pulse-relaxation data for 1RC, 2RC, or 3RC models

vbatt = vbatt(:);                     % Ensure column vector
ibatt = ibatt(:);                     % Ensure column vector
t     = t(:); t = t - t(1);           % Ensure column vector and start from zero

vrest = vbatt(ibatt < 5e-3 & ibatt > -5e-3);   % Rest voltage samples (|current| < 5mA)
trest = t(ibatt < 5e-3 & ibatt > -5e-3);       % Corresponding rest times

switch model
    case '1RC'
        tau1                     = LS1_1RC(vrest, trest);                    
        [OCV, kappa, R0, R1, C1] = LS2_1RC(vbatt, ibatt, t, tau1);
        theta_hat                = [OCV, kappa, R0, R1, C1];                        

    case '2RC'
        [tau1, tau2]                = LS1_2RC(vrest, trest);
        [OCV0,kappa,R0,R1,C1,R2,C2] = LS2_2RC(vbatt, ibatt, t, tau1, tau2);
        theta_hat                   = [OCV0,kappa,R0,R1,C1,R2,C2];

    case '3RC'
        [tau1, tau2, tau3]                = LS1_3RC(vrest, trest);
        [OCV0,kappa,R0,R1,C1,R2,C2,R3,C3] = LS2_3RC(vbatt, ibatt, t, tau1, tau2, tau3);
        theta_hat                         = [OCV0,kappa,R0,R1,C1,R2,C2,R3,C3];

end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1-RC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tau1 = LS1_1RC(vrest, trest)
V     = cumtrapz(trest, vrest);               % ∫v(t) dt
H     = [ones(size(trest)), trest, -V];       % Linear model matrix
theta = H \ vrest;                            % Least-squares fit
gamma = theta(3);                             % Extract gamma
tau1  = 1 / gamma;                            % tau = 1 / gamma
end

function [OCV0, kappa, R0, R1, C1] = LS2_1RC(vbatt, ibatt, t, tau1)
I     = cumtrapz(t, ibatt);                      % ∫i(t) dt
i1    = currentRC(ibatt, t, tau1);               % RC branch current
M     = [ones(size(vbatt)), I, ibatt, i1];       % Model matrix
theta = M \ vbatt;                               % Least-squares fit
OCV0   = theta(1);                                % Open-circuit voltage
kappa = theta(2);                                % OCV linear slope term 
R0    = theta(3);                                % Series resistance
R1    = theta(4);                                % RC resistance
C1    = tau1 / R1;                               % Capacitance from tau
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2-RC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tau1, tau2] = LS1_2RC(vrest, trest)
V     = cumtrapz(trest, vrest);               % ∫v(t) dt
V1    = cumtrapz(trest, V);                   % ∫∫v(t) dt^2
H     = [ones(size(trest)), trest, trest.^2, -V, -V1];
theta = H \ vrest;                            % Least-squares fit
bk    = abs(roots([1 -theta(end-1) theta(end)])); % Roots of char. equation
tau1  = 1 / bk(1);                            % First time constant
tau2  = 1 / bk(2);                            % Second time constant
end

function [OCV0,kappa,R0,R1,C1,R2,C2] = LS2_2RC(vbatt, ibatt, t, tau1, tau2)
I  = cumtrapz(t, ibatt);                      % ∫i(t) dt
i1 = currentRC(ibatt, t, tau1);               % First RC branch current
i2 = currentRC(ibatt, t, tau2);               % Second RC branch current
M     = [ones(size(vbatt)), I ibatt, i1, i2]; % Model matrix
theta = M \ vbatt;                            % Least-squares fit
OCV0  = theta(1);                               % Open-circuit voltage
kappa = theta(2);
R0    = theta(3);                               % Series resistance
R1    = theta(4);                               % First RC resistance
R2    = theta(5);                               % Second RC resistance

C1  = tau1 / R1;                              % First capacitance
C2  = tau2 / R2;                              % Second capacitance
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3-RC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tau1, tau2, tau3] = LS1_3RC(vrest, t)
V  = cumtrapz(t, vrest);                      % ∫v(t) dt
V1 = cumtrapz(t, V);                          % ∫∫v(t) dt^2
V2 = cumtrapz(t, V1);                         % ∫∫∫v(t) dt^3
H  = [ones(size(t)), t, t.^2, t.^3, -V, -V1, -V2];
theta = H \ vrest;                            % Least-squares fit
bk = abs(roots([1 -theta(5) theta(6) -theta(7)])); % Cubic root equation
tau1 = 1 / bk(1);                             % First time constant
tau2 = 1 / bk(2);                             % Second time constant
tau3 = 1 / bk(3);                             % Third time constant
end

function [OCV0,kappa,R0,R1,C1,R2,C2,R3,C3] = LS2_3RC(vbatt, ibatt, t, tau1, tau2, tau3)
I  = cumtrapz(t, ibatt);                      % ∫i(t) dt
i1 = currentRC(ibatt, t, tau1);               % First RC branch current
i2 = currentRC(ibatt, t, tau2);               % Second RC branch current
i3 = currentRC(ibatt, t, tau3);               % Third RC branch current
M     = [ones(size(vbatt)), I, ibatt, i1, i2, i3]; % Model matrix
theta = M \ vbatt;                            % Least-squares fit
OCV0  = theta(1);                               % Open-circuit voltage
kappa = theta(2);
R0  = theta(3);                               % Series resistance
R1  = theta(4);                               % First RC resistance
R2  = theta(5);                               % Second RC resistance
R3  = theta(6);                               % Third RC resistance

C1  = tau1 / R1;                              % First capacitance
C2  = tau2 / R2;                              % Second capacitance
C3  = tau3 / R3;                              % Third capacitance

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i1 = currentRC(ibatt, t, tau)
% Simulates current through one RC branch (discrete-time filter)
i1    = nan(size(ibatt));                  % Preallocate
del   = mean(diff(t));                     % Time step fixed
i1(1) = (1 - exp(-del/tau)) * ibatt(1);    % Initial condition

for k = 2:length(ibatt)
    i1(k) = exp(-del/tau)*i1(k-1) + (1 - exp(-del/tau))*ibatt(k);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
