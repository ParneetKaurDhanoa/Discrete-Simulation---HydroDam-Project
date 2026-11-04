function [png] = pdf_Inflow()
% Inflow module: rain and melting snow.
%
%      tRain  ---->  pCatchment  ---->  tRunoff  ---->  (pRunoff, in pdf_IMC)
%    makes one      water flowing      hands the water
%    water token    down the valley    to the dam
%
% tRain adds water. MOD_Inflow_PRE sets the amount
% and gives each token a season colour.
% pCatchment holds water in the catchment.
% tRunoff sends water to the dam.

% GPenSIM uses this name to find MOD_Inflow_PRE.m.
png.PN_name = 'Inflow';

% Places in this module
png.set_of_Ps = {'pCatchment'};

% Transitions in this module
png.set_of_Ts = {'tRain', 'tRunoff'};

% Arcs: {from, to, weight}
png.set_of_As = {'tRain',      'pCatchment', 1, ...   % rain fills the catchment
                 'pCatchment', 'tRunoff',    1};      % runoff takes it away

% Ports connect this module to the others.
png.set_of_Ports = {'tRunoff'};
end
