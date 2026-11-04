% Tests for the dam model.
% Each test has a purpose, expected result and check.
% The table at the end shows the expected and actual results.

clear; clc;
results = {};    % one row per test: {name, expected, got, pass}


%% T1  Overflow ---------------------------------------------------------
% Check that water spills only when the dam is full.
% Expected: 4 tokens arrive, but the dam can hold only 3.
% The first 3 are stored and the last one spills.
% Expected result: stored 3, spilled 1, free 0.
R = run_dam(dam_config('T_OVERFLOW'), false);

stored  = tokens_in(R.sim, 'pStored');
spilled = tokens_in(R.sim, 'pSpilled');
free    = tokens_in(R.sim, 'pFree');

pass = stored == 3 && spilled == 1 && free == 0 && R.check.all_ok;
got  = sprintf('stored %d, spilled %d, free %d', stored, spilled, free);
results(end+1, :) = {'T1 overflow', 'stored 3, spilled 1, free 0', got, pass};


%% T2  Colours, oldest water first ---------------------------------------
% Check the season colours and release order.

% Two spring tokens arrive in week 1 and two summer tokens in week 10.
% Three tokens are released in week 12, oldest first.
% Two spring tokens and one summer token leave; one summer token stays.
% Expected release count: [2 1 0 0 0].
R = run_dam(dam_config('T_COLOUR'), false);

released = sum(R.ledger, 1);
left     = R.sim.global_places(strcmp({R.sim.global_places.name}, 'pStored')).token_bank;
left_colour = '';
if numel(left) == 1
    left_colour = strjoin(left(1).color, ',');
end

pass = isequal(released, [2 1 0 0 0]) && numel(left) == 1 && strcmp(left_colour, 'summer');
got  = sprintf('released %s, %d left: %s', mat2str(released), numel(left), left_colour);
results(end+1, :) = {'T2 colours, oldest first', 'released [2 1 0 0 0], 1 left: summer', got, pass};


%% T3  Normal two years: nothing lost or created -------------------------
% Check the balances in a normal run (S1).
% Expected: all balances are zero.
R = run_dam(dam_config('S1'), false);
c = R.check;

pass = c.all_ok;
got  = sprintf('dam/water/energy = %d/%d/%d', c.dam_balance, c.water_balance, c.energy_balance);
results(end+1, :) = {'T3 normal: balances', 'dam/water/energy = 0/0/0', got, pass};


%% T4  Wet years: spill, but never above capacity ------------------------
% Check capacity in a wet year (S2).
% Expected: some water spills when the dam fills,
% but the dam never goes above 155 tokens.
R = run_dam(dam_config('S2'), false);

highest = max(R.level);

pass = R.spilled_mm3 > 0 && highest <= R.cfg.CAPACITY && R.check.all_ok;
got  = sprintf('spilled %d Mm3, highest level %d', R.spilled_mm3, highest);
results(end+1, :) = {'T4 wet: spill, capacity kept', 'spilled > 0, highest level <= 155', got, pass};


%% T5  Dry years: minimum level is kept ----------------------------------
% Check the minimum level in a dry year (S3).
% Expected: the level reaches 16 tokens at least once,
% but does not fall below 16 at the end of a week.
R = run_dam(dam_config('S3'), false);

lowest = min(R.level);

pass = R.weeks_at_min > 0 && lowest >= R.cfg.MIN_LEVEL && R.check.all_ok;
got  = sprintf('weeks at minimum %d, lowest level %d', R.weeks_at_min, lowest);
results(end+1, :) = {'T5 dry: minimum level kept', 'weeks at minimum > 0, lowest level >= 16', got, pass};


%% Print the table --------------------------------------------------------
fprintf('\n%-6s %-30s %-42s %s\n', 'Result', 'Test', 'Expected', 'Got');
for i = 1:size(results, 1)
    if results{i, 4}
        verdict = 'PASS';
    else
        verdict = 'FAIL';
    end
    fprintf('%-6s %-30s %-42s %s\n', verdict, results{i, 1}, results{i, 2}, results{i, 3});
end
fprintf('\n%d of %d tests passed\n', sum([results{:, 4}]), size(results, 1));
