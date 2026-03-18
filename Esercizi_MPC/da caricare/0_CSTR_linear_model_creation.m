clear all
clc

A = [ -5 -0.3427;
     47.68 2.785];
B = [ 0 1
     0.3 0];
C = flipud(eye(2));
D = zeros(2);
CSTR = ss(A,B,C,D);
CSTR.InputName = {'T_c', 'C_A_f'}; % set names of input signals
CSTR.OutputName = {'T', 'C_A'}; % set names of output signals
CSTR.StateName = {'C_A', 'T'}; % set names of state variables
CSTR.InputUnit = {'K', 'kmol/m3'}; % set units of input signals
CSTR.OutputUnit = {'K', 'kmol/m3'}; % set units of output signals
CSTR.StateUnit = {'kmol/m3', 'K'}; % set units of state variables

app=0;
if app==1
% assign input and output signals to different MPC categories
CSTR=setmpcsignals(CSTR,'MV',1,'UD',2,'MO',1,'UO',2);

save CSTRlinearmodel_label.mat CSTR
else
save CSTRlinearmodel_nolabel.mat CSTR
end

clear all
clc

% codice da utilizzare ad esempio per dichiarare una variabile disturbo in ingresso misurata (MD)
% CSTR=setmpcsignals(CSTR,'MV',1,'MD',2,'MO',1,'UO',2);