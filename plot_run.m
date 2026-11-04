% Plot one simulation run.
function plot_run(R)
% Two simple graphs, saved in results/run_<scenario>.png
%   1. How full the dam is each week.
%   2. Which season's water was used in each winter (token colours).

if ~exist('results', 'dir'), mkdir('results'); end
c = R.cfg;

f = figure('Name', R.scenario, 'Color', 'w', 'Position', [100 100 800 600]);

% 1. Dam level
subplot(2, 1, 1);  hold on;
plot(0:c.WEEKS, 100 * [c.START R.level] / c.CAPACITY, 'b', 'LineWidth', 2);
plot([0 c.WEEKS], 100 * c.MIN_LEVEL / c.CAPACITY * [1 1], 'r--');
ylim([0 100]); grid on;
xlim([0 c.WEEKS]);
xlabel('Week');  ylabel('% full');
legend({'dam level', 'minimum level'}, 'Location', 'best');
title(sprintf('Scenario %s: dam level', R.scenario));

% 2. Token colours
subplot(2, 1, 2);
h = bar(R.winter_mix, 0.5, 'stacked');
cols = [0.1 0.7 0.5; 0.9 0.4 0.2; 0.9 0.6 0; 0.2 0.5 0.9; 0.7 0.7 0.7];
for k = 1:5, set(h(k), 'FaceColor', cols(k, :)); end
set(gca, 'XTickLabel', {'Winter 1', 'Winter 2'});
ylabel('Water tokens used');
legend({'spring', 'summer', 'autumn', 'winter', 'old water'}, 'Location', 'eastoutside');
title('Which season''s water was used in winter?');

saveas(f, fullfile('results', sprintf('run_%s.png', R.scenario)));
end