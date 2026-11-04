function R = run_dam(cfg, verbose)
% Build and run the Petri net, then collect the results.
%
% Example: R = run_dam(dam_config('S1'))
% Use false as the second input to hide the summary.
%
% Main steps:
% 1. Set up counters.
% 2. Join the modules and set the starting tokens and times.
% 3. Run GPenSIM.
% 4. Calculate the results.
% 5. Check the balances and capacity.

if nargin < 2
    verbose = true;
end

global global_info PN
global_info = struct();    % forget everything from a previous run
PN = [];

% Step 1
prepare_counters(cfg);

% Step 2
pni = build_petri_net(cfg);

% Step 3
tic;
sim = gpensim(pni);
R.runtime_s = toc;

% Step 4
R = compute_results(R, cfg, sim, global_info);

% Step 5
R.check = run_checks(cfg, sim, global_info, R);

if verbose
    print_summary(R);
end
end


%% =========================================================================
function prepare_counters(cfg)
% Set up counters used by the processor files.
global global_info

W = cfg.WEEKS;
global_info.cfg        = cfg;
global_info.STOP_AT    = W;       % GPenSIM stops after the last week
global_info.DELTA_TIME = 0.05;    % GPenSIM clock step (all firing times are multiples of 0.05)

% Counters for each week
global_info.n.rain     = zeros(1, W);   % water tokens made by tRain
global_info.n.stored   = zeros(1, W);   % tokens taken into the dam
global_info.n.spilled  = zeros(1, W);   % tokens spilled
global_info.n.released = zeros(1, W);   % tokens sent to the turbines
global_info.n.gen      = zeros(1, W);   % energy tokens made

global_info.level  = nan(1, W);     % water in the dam at the end of each week
global_info.ledger = zeros(W, 5);   % released water by colour:
                                    % spring, summer, autumn, winter, no colour
end


%% =========================================================================
function pni = build_petri_net(cfg)
% Join the modules and set the starting tokens and firing times.

% Three modules and their connector
pns = pnstruct({'pdf_Inflow', 'pdf_Dam', 'pdf_PowerStation', 'pdf_IMC'});

% Starting water and free space
dyn.m0 = {'pStored', cfg.START, ...
          'pFree',   cfg.CAPACITY - cfg.START};

% Firing times are in weeks.
dyn.ft = {'tTurbine',  0.1, ...
          'allothers', 0.05};

% No priorities needed: the inhibitor arc means tStore and tSpill are never
% enabled at the same time.

pni = initialdynamics(pns, dyn);
end


%% =========================================================================
function R = compute_results(R, cfg, sim, info)
% Convert token counts into water and energy values.
n   = info.n;
W   = cfg.WEEKS;
MM3 = cfg.MM3_PER_TOKEN;
GWH = cfg.GWH_PER_TOKEN;

% A week with no dam event keeps the level of the week before.
level = info.level;
previous = cfg.START;
for w = 1:W
    if isnan(level(w)), level(w) = previous; end
    previous = level(w);
end

% Demand that the generated energy did not cover.
unmet = max(0, cfg.plan_demand - n.gen);

% Find the winter weeks (season 4).
week_of_year = mod((1:W) - 1, 52) + 1;
is_winter    = cfg.season_of_week(week_of_year) == 4;

% Save the results in R.
R.cfg        = cfg;
R.scenario   = cfg.scenario;
R.sim        = sim;
R.n          = n;
R.level      = level;
R.ledger     = info.ledger;
R.unmet_week = unmet;

R.inflow_mm3       = sum(n.rain) * MM3;
R.spilled_mm3      = sum(n.spilled) * MM3;
R.gen_gwh          = sum(n.gen) * GWH;
R.unmet_gwh        = sum(unmet) * GWH;
R.unmet_winter_gwh = sum(unmet(is_winter)) * GWH;
R.min_level_pct    = 100 * min(level) / cfg.CAPACITY;
R.end_level_pct    = 100 * level(end) / cfg.CAPACITY;
R.weeks_at_min     = sum(level <= cfg.MIN_LEVEL);

% Season of the water released in winter.
% Row 1 is winter 1; row 2 is winter 2.
in_year1 = (1:W) <= 52;
in_year2 = (1:W) > 52;
R.winter_mix = [sum(info.ledger(is_winter & in_year1, :), 1);
                sum(info.ledger(is_winter & in_year2, :), 1)];
winter_total       = max(1, sum(R.winter_mix, 2));
R.summer_share_pct = 100 * R.winter_mix(:, 2) ./ winter_total;
end


%% =========================================================================
function check = run_checks(cfg, sim, info, R)
% Check the results.
n = info.n;

% Check the dam capacity.
check.capacity_ok = all(R.level <= cfg.CAPACITY);

% P-invariant: water + free space = capacity.
check.invariant_ok = tokens_in(sim, 'pStored') + tokens_in(sim, 'pFree') == cfg.CAPACITY;

% Water balance inside the dam.
check.dam_balance = cfg.START + sum(n.stored) - sum(n.released) ...
                    - tokens_in(sim, 'pStored');

% All incoming water must be accounted for.
check.water_balance = sum(n.rain) - sum(n.stored) - sum(n.spilled) ...
                      - tokens_in(sim, 'pCatchment') - tokens_in(sim, 'pRunoff');

% Check water released to the turbines.
check.energy_balance = sum(n.released) - sum(n.gen) - tokens_in(sim, 'pToTurbine');

check.all_ok = check.capacity_ok && check.invariant_ok && ...
               check.dam_balance == 0 && check.water_balance == 0 && ...
               check.energy_balance == 0;
end



%% =========================================================================
function print_summary(R)
c = R.cfg;
fprintf('\n=== %s (%d weeks, %.0f s) ===\n', R.scenario, c.WEEKS, R.runtime_s);
fprintf('Water:  inflow %d Mm3, spilled %d Mm3\n', R.inflow_mm3, R.spilled_mm3);
fprintf('Level:  start %.0f %%, lowest %.0f %%, end %.0f %%, weeks at minimum %d\n', ...
        100 * c.START / c.CAPACITY, R.min_level_pct, R.end_level_pct, R.weeks_at_min);
fprintf('Energy: generated %.0f GWh, unmet %.0f GWh (winter %.0f)\n', ...
        R.gen_gwh, R.unmet_gwh, R.unmet_winter_gwh);
fprintf('Water used in winter 1 / winter 2 [spring summer autumn winter no-colour]:\n');
fprintf('        %s  /  %s   -> summer share in winter 2: %.0f %%\n', ...
        mat2str(R.winter_mix(1, :)), mat2str(R.winter_mix(2, :)), R.summer_share_pct(2));
if R.check.all_ok
    verdict = 'ALL OK';
else
    verdict = 'PROBLEM';
end
fprintf('Checks: capacity %d, invariant %d, balances %d/%d/%d  -> %s\n', ...
        R.check.capacity_ok, R.check.invariant_ok, R.check.dam_balance, ...
        R.check.water_balance, R.check.energy_balance, verdict);
end
