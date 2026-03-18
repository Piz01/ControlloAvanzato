load('CSTR_mpc8_scenario3.mat');

%% create MPC controller object with sample time
CSTR_mpc8 = mpc(CSTR_C, 0.5);
%% specify prediction horizon
CSTR_mpc8.PredictionHorizon = 15;
%% specify control horizon
CSTR_mpc8.ControlHorizon = 15;
%% specify nominal values for inputs and outputs
CSTR_mpc8.Model.Nominal.U = [0;0];
CSTR_mpc8.Model.Nominal.Y = [0;0];
%% specify constraints for MV and MV Rate
CSTR_mpc8.MV(1).Min = -10;
CSTR_mpc8.MV(1).Max = 10;
CSTR_mpc8.MV(1).RateMin = -1;
CSTR_mpc8.MV(1).RateMax = 1;
%% specify overall adjustment factor applied to weights
beta = 4.0552;
%% specify weights
CSTR_mpc8.Weights.MV = 0*beta;
CSTR_mpc8.Weights.MVRate = 0.3/beta;
CSTR_mpc8.Weights.OV = [1 0]*beta;
CSTR_mpc8.Weights.ECR = 100000;
%% specify simulation options
options = mpcsimopt();
options.RefLookAhead = 'on';
options.MDLookAhead = 'off';
options.Constraints = 'on';
options.OpenLoop = 'off';
%% run simulation
sim(CSTR_mpc8, 41, CSTR_mpc8_RefSignal, CSTR_mpc8_MDSignal, options);
