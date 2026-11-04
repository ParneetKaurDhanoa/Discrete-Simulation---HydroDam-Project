% Compare the scenarios.
function plot_compare(results, scenarios)
% Two simple bar charts, one bar per scenario, value written on each bar.
% Saved in results/compare_scenarios.png

missing = zeros(1, numel(scenarios));
spilled = zeros(1, numel(scenarios));
for i = 1:numel(scenarios)
    missing(i) = results{i}.unmet_gwh;
    spilled(i) = results{i}.spilled_mm3;
end

f = figure('Name', 'Scenarios', 'Color', 'w', 'Position', [100 100 900 400]);

subplot(1, 2, 1);
simple_bar(missing, scenarios);
title('Electricity missing (GWh)');

subplot(1, 2, 2);
simple_bar(spilled, scenarios);
title('Water spilled (Mm3)');

saveas(f, fullfile('results', 'compare_scenarios.png'));
end


function simple_bar(v, scenarios)
% Bar chart with the number written on top of each bar.
bar(v, 0.6);
ylim([0 1.2 * max([v 1])]);
text(1:numel(v), v, string(round(v)), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
set(gca, 'XTickLabel', scenarios);
grid on;
end