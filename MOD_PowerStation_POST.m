function [] = MOD_PowerStation_POST(transition) %#ok<INUSD>
% Runs when the turbine finishes.

global global_info
wk = week_now();
% Count the energy made this week.
global_info.n.gen(wk) = global_info.n.gen(wk) + 1;
end
