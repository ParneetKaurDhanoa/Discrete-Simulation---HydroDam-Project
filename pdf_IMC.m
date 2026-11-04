function [png] = pdf_IMC()
% Connector between the modules. It contains shared places and arcs.


% pRunoff: water from Inflow to Dam
% pSpilled: water spilled from the dam
% pToTurbine: water sent to the turbine


png.PN_name   = 'IMC';

png.set_of_Ps = {'pRunoff', 'pSpilled', 'pToTurbine'};
png.set_of_Ts = {};

png.set_of_As = {'tRunoff', 'pRunoff', 1, ...
                 'pRunoff', 'tStore', 1,  'pRunoff', 'tSpill', 1, ...
                 'tSpill', 'pSpilled', 1, ...
                 'tRelease', 'pToTurbine', 1, ...
                 'pToTurbine', 'tTurbine', 1};
end
