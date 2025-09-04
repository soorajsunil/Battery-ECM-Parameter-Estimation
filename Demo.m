clc, clear, close all;

%% Load data
BattData = load('SamplePulseRelaxationData.mat');

vbatt = BattData.vpulse;
ibatt = BattData.ipulse;
t     = BattData.tpulse;

%%  1-RC estimation
[theta_1RC] = twoStageLS(vbatt, ibatt, t, '1RC');

% unpack estimated parameters
OCV0  = theta_1RC(1);
kappa = theta_1RC(2);
R0    = theta_1RC(3);
R1    = theta_1RC(4);
C1    = theta_1RC(5);

% voltage prediction
i1    = currentRC(ibatt, t, R1*C1);
v_1RC = OCV0 + ibatt*R0 + i1*R1 + kappa*trapz(t,ibatt);

%%  2-RC estimation

[theta_2RC] = twoStageLS(vbatt, ibatt, t, '2RC');
OCV0 = theta_2RC(1);
kappa = theta_2RC(2);
R0  = theta_2RC(3);
R1  = theta_2RC(4);
C1  = theta_2RC(5);
R2  = theta_2RC(6);
C2  = theta_2RC(7);

% voltage prediction
i1    = currentRC(ibatt, t, R1*C1);
i2    = currentRC(ibatt, t, R2*C2);
v_2RC = OCV0 + ibatt*R0 + i1*R1 + i2*R2  + kappa*trapz(t,ibatt);

%%  3-RC

[theta_3RC] = twoStageLS(vbatt, ibatt, t, '3RC');
OCV0 = theta_3RC(1);
kappa = theta_3RC(2);
R0  = theta_3RC(3);
R1  = theta_3RC(4);
C1  = theta_3RC(5);
R2  = theta_3RC(6);
C2  = theta_3RC(7);
R3  = theta_3RC(8);
C3  = theta_3RC(9);

% voltage prediction
i1    = currentRC(ibatt, t, R1*C1);
i2    = currentRC(ibatt, t, R2*C2);
i3    = currentRC(ibatt, t, R3*C3);
v_3RC = OCV0 + ibatt*R0 + i1*R1 + i2*R2 + i3*R3 + kappa*trapz(t,ibatt);

%%

f=figure(Position=[100,100,600,600]); 

nexttile(1)
hold on; axis('padded'); grid on; box on;
xlabel('Time (s)',Interpreter='latex'); ylabel('Voltage (V)',Interpreter='latex'); 
legend(Location='best')
plot(t-t(1),vbatt,'-',DisplayName='Measurements')
plot(t-t(1),v_1RC,'--',DisplayName='1-RC model')
plot(t-t(1),v_2RC,'--',DisplayName='2-RC model')
plot(t-t(1),v_3RC,'--',DisplayName='3-RC model')

nexttile(2)
hold on; axis('padded'); grid on; box on;
xlabel('Time (s)',Interpreter='latex'); 
ylabel('$\vert$ Voltage error $\vert$ (mV)',Interpreter='latex'); 
legend(Location='best')
plot(t-t(1),nan(size(t)),HandleVisibility="off")
plot(t-t(1),abs(vbatt-v_1RC),'-',DisplayName='1-RC model')
plot(t-t(1),abs(vbatt-v_2RC),'-',DisplayName='2-RC model')
plot(t-t(1),abs(vbatt-v_3RC),'-',DisplayName='3-RC model')

exportgraphics(f,'SamplePulseRelaxationFit.png')

function i1 = currentRC(ibatt, t, tau)
% Simulates current through one RC branch (discrete-time filter)
i1    = nan(size(ibatt));                  % Preallocate
Ts    = mean(diff(t));                     % Time step fixed
i1(1) = (1 - exp(-Ts/tau)) * ibatt(1);    % Initial condition

for k = 2:length(ibatt)
    i1(k) = exp(-Ts/tau)*i1(k-1) + (1 - exp(-Ts/tau))*ibatt(k);
end
end