% Run each scenario.
% Print results and save the table.


clear; clc; close all;
% Scenarios: normal, wet, dry, and winter maintenance.
scenarios = {'S1', 'S2', 'S3', 'S4'};
results = {};

for i = 1:numel(scenarios)
    R = run_dam(dam_config(scenarios{i}));
    R.sim = [];
    results{end+1} = R; %#ok<SAGROW>
end

% ---- Table -------------------------------------------------------------
if ~exist('results', 'dir'), mkdir('results'); end
% Save the comparison table as a CSV file that can be opened in Excel.
fid = fopen(fullfile('results', 'scenario_results.csv'), 'w');
fprintf(fid, 'Scenario,Spilled_Mm3,Lowest_pct,WeeksAtMin,Generated_GWh,Unmet_GWh,UnmetWinter_GWh,SummerShareWinter2_pct,ChecksOK\n');
fprintf('\n%-4s %8s %7s %6s %9s %7s %8s %8s %3s\n', 'Scen', ...
        'Spill', 'Low%', 'Wk@min', 'Gen GWh', 'Unmet', 'UnmetW', 'Summer%', 'OK');
for i = 1:numel(results)
    R = results{i};
    v = [R.spilled_mm3, R.min_level_pct, R.weeks_at_min, R.gen_gwh, R.unmet_gwh, ...
         R.unmet_winter_gwh, R.summer_share_pct(2), R.check.all_ok];
    fprintf('%-4s %8.0f %7.1f %6d %9.0f %7.0f %8.0f %8.0f %3d\n', R.scenario, v);
    fprintf(fid, '%s,%.0f,%.1f,%d,%.0f,%.0f,%.0f,%.0f,%d\n', R.scenario, v);
end
fclose(fid);

plot_compare(results, scenarios);
save(fullfile('results', 'all_results.mat'), 'results');
