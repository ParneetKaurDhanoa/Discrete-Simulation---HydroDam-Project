function [png] = pdf_PowerStation()
% PowerStation module with one turbine.
%
%   (pToTurbine)  ---->  tTurbine  ---->  pEnergy
%
% The turbine uses one water token from pToTurbine
% and makes one energy token in pEnergy.
% One energy token = 50.2 GWh.
%
% GPenSIM keeps the input token colour on the output token,
% so energy from summer water is marked summer.
%
% The weekly turbine limit and maintenance are in the release plan (dam_config.m).
% MOD_PowerStation_POST counts each finished run.

% GPenSIM uses this name to find MOD_PowerStation_POST.m.
png.PN_name = 'PowerStation';

% Places in this module
png.set_of_Ps = {'pEnergy'};

% Transitions in this module
png.set_of_Ts = {'tTurbine'};

% Arcs: {from, to, weight}
png.set_of_As = {'tTurbine', 'pEnergy', 1};   % the turbine makes one energy token

% The turbine takes water from outside this module.
png.set_of_Ports = {'tTurbine'};
end
