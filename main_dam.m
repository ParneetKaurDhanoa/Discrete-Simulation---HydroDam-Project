% Run the dam simulation.
% Pick a scenario below.
% run_dam runs the Petri net.


clear; clc; close all;


%% Choose the scenario
scenario = 'S1';   % 'S1' normal, 'S2' wet, 'S3' dry,
                   % 'S4' winter maintenance


%% Run the model
settings = dam_config(scenario);
R = run_dam(settings);


%% Token colours: which season's water made the electricity?
% Each released token is counted by its colour (the ledger in COMMON_PRE).
% The turbine keeps the colour, so this is also the colour of the energy tokens.
names = [R.cfg.season_names, {'no colour (already in dam at start)'}];
used  = sum(R.ledger, 1);
fprintf('\nWater tokens released, by colour:\n');
for k = 1:numel(names)
    fprintf('  %-36s %3d\n', names{k}, used(k));
end


%% Draw the graphs
plot_run(R);
