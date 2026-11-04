function cfg = dam_config(scenario)
% DAM_CONFIG  All settings and numbers used by the Blasjo dam model.
%
% Example:  cfg = dam_config('S1')
%
% This file does not run the Petri net. It only fills the struct "cfg".
% Every other file (run_dam, COMMON_PRE, MOD_* files, plots) reads its
% numbers from cfg, so all assumptions of the model are in one place.
%
% Scenarios:
%   S1  normal year (the reference case)
%   S2  wet year: 40 % more water, dam starts 75 % full
%   S3  dry year: 40 % less water, dam starts 30 % full
%   S4  turbine maintenance in winter: half capacity in weeks 38-45
%   'T_OVERFLOW', 'T_COLOUR'  tiny test cases used by run_tests.m
%
% Units used everywhere in the model:
%   1 time unit     = 1 week
%   1 water token   = 20 million m3 (Mm3) of water
%   1 water token through the turbine = 50.2 GWh of electricity
%
% The order of the steps below matters:
%   steps 1-6  normal settings
%   step 7     the scenario changes some of them
%   step 8     the weekly plans are made from the (changed) settings
%   step 9     test cases overwrite the plans with tiny numbers
%   step 10    the release plan is made last, from the final settings
 
cfg.scenario = scenario;    % saved so results and plots can show the scenario
 
 
%% 1. The dam -------------------------------------------------------------
% CAPACITY: 155 tokens x 20 Mm3 = 3,100 Mm3, about the real Blasjo
% reservoir (about 3,105 Mm3). In the Petri net, the dam has one token in
% pFree for every empty slot, so this number also gives the P-invariant
%     pStored + pFree = CAPACITY
% which is why the dam can never hold more than 155 tokens.
cfg.CAPACITY  = 155;
 
% MIN_LEVEL: 16 / 155 = about 10 % full. At or below this level no water
% is sent to the turbine (checked in COMMON_PRE for tRelease), like the
% lowest level a real reservoir is allowed to reach.
cfg.MIN_LEVEL = 16;
 
% START: water in the dam at the start of week 1 (early April).
% 70 / 155 = 45 % full, a normal level before the snow melts.
% This water has no colour, because we do not know which season it came from.
cfg.START     = 70;
 
% WEEKS: two years. In year 1 the turbine mostly uses the old water with no
% colour. By year 2 that water is used up, so the winter of year 2 shows
% which season's water really makes the winter electricity
% (winter_mix in run_dam compares winter 1 and winter 2).
cfg.WEEKS     = 104;
 
 
%% 2. Units ---------------------------------------------------------------
% Used only to turn token counts back into real numbers in the results.
% GWH_PER_TOKEN: the real plant makes about 7.8 TWh from about 3,105 Mm3,
%   7,800 GWh / 3,105 Mm3 x 20 Mm3 = about 50.2 GWh per token.
cfg.MM3_PER_TOKEN = 20;
cfg.GWH_PER_TOKEN = 50.2;
 
 
%% 3. Seasons -------------------------------------------------------------
% Week 1 is early April, so the year starts just before the snow melts.
% Season number for each week of the year:
%   weeks  1-9   spring (Apr-May)   -> 1    ( 9 weeks)
%   weeks 10-22  summer (Jun-Aug)   -> 2    (13 weeks)
%   weeks 23-35  autumn (Sep-Nov)   -> 3    (13 weeks)
%   weeks 36-52  winter (Dec-Mar)   -> 4    (17 weeks)
% Winter is the longest because December to March is the cold period
% with little inflow and high demand. 9 + 13 + 13 + 17 = 52 weeks.
%
% season_names are also the token colours: tRain (MOD_Inflow_PRE) gives
% each new water token the name of the current season as its colour.
cfg.season_names = {'spring', 'summer', 'autumn', 'winter'};
 
spring = 1 * ones(1, 9);
summer = 2 * ones(1, 13);
autumn = 3 * ones(1, 13);
winter = 4 * ones(1, 17);
cfg.season_of_week = [spring, summer, autumn, winter];   % 52 values, one per week
 
 
%% 4. Water arriving each week in a normal year (tokens) -----------------
% One value per week, in the same order as the seasons above.
% Most water comes from melting snow in May and June (3 tokens a week).
% There is almost no inflow in winter, because the water is frozen as snow.
% Total for one year: 52 tokens = 1,040 Mm3.
inflow_one_year = [0 1 0 1 1 2 1 2 1 ...                  % spring
                   3 3 3 3 2 2 2 2 1 1 1 1 1 ...          % summer
                   1 2 1 2 1 1 1 2 0 1 1 0 1 ...          % autumn
                   0 0 1 0 0 0 0 1 0 0 0 0 0 1 0 1 0];    % winter
 
 
%% 5. Electricity needed each week (energy tokens) -----------------------
% One value per week. This is the opposite pattern to the inflow:
% low demand in summer, high demand in winter (heating).
% Weeks 41-43 are a cold snap with the highest demand (3, 4, 3 tokens).
%
% Total for one year: 52 tokens, exactly the same as the inflow.
% This is on purpose: in a normal year (S1) the water in equals the water
% out, so the dam neither fills up nor runs empty. Any problem in S2-S4 is
% then caused by the scenario change, not by the data.
% 31 of the 52 tokens are needed in winter.
demand_one_year = [1 0 1 1 0 0 0 1 0 ...                  % spring
                   1 0 0 1 1 0 0 0 2 0 0 0 2 ...          % summer
                   0 1 0 1 1 0 1 1 1 1 1 1 1 ...          % autumn
                   1 2 1 2 1 3 4 3 1 2 2 1 2 1 2 1 2];    % winter
 
 
%% 6. Turbine -------------------------------------------------------------
% TURBINE_CAP: the most water tokens the turbine can use in one week.
% The highest weekly demand is 4 (the cold snap), so with 4 the turbine can
% always meet the demand when it works normally.
cfg.TURBINE_CAP = 4;
 
% MAINT_WEEKS: weeks with maintenance, when the turbine works at half
% capacity (2 tokens a week). Empty = no maintenance. Only S4 sets this.
cfg.MAINT_WEEKS = [];
 
 
%% 7. Change the settings for the chosen scenario -------------------------
% Each scenario changes only one or two settings compared with S1.
% So any difference in the results comes from that change alone.
 
weather = 1.0;       % multiplies the inflow: wet > 1, dry < 1
 
if strcmp(scenario, 'S1')
    % Normal year: nothing changes. All other scenarios are compared to this.
 
elseif strcmp(scenario, 'S2')
    % Wet year: tests that the dam spills when full and never goes above
    % CAPACITY (test T4 in run_tests.m).
    weather   = 1.4;       % 40 % more water
    cfg.START = 116;       % 116 / 155 = 75 % full at the start
 
elseif strcmp(scenario, 'S3')
    % Dry year: tests that the minimum level is kept (test T5).
    weather   = 0.6;       % 40 % less water
    cfg.START = 47;        % 47 / 155 = 30 % full at the start
 
elseif strcmp(scenario, 'S4')
    % Maintenance in December-January, which covers the cold snap.
    % In weeks 38-45 the turbine can only use 2 tokens a week. Demand above 2
    % in those weeks is 1 + 2 + 1 = 4 tokens, so 4 x 50.2 = about 201 GWh
    % cannot be delivered. Weeks 38-45 are only in year 1 (weeks 1-104).
    cfg.MAINT_WEEKS = 38:45;
 
elseif strcmp(scenario, 'T_OVERFLOW') || strcmp(scenario, 'T_COLOUR')
    % Tiny test cases: allowed here, but set up later in step 9,
    % because they must overwrite the plans made in step 8.
 
else
    % Stop with a clear message if the scenario name is misspelled,
    % instead of quietly running the normal year.
    error('Unknown scenario %s', scenario);
end
 
 
%% 8. Make the week-by-week plans for the two years ------------------------
% The same one-year pattern is used for both years, multiplied by weather.
inflow_two_years = [inflow_one_year, inflow_one_year] * weather;
 
% With weather 1.4 or 0.6 the weekly values become fractions (e.g. 0.6),
% but tokens must be whole numbers.
% Rounding each week on its own would be wrong: 0.6 rounds up to 1, so the
% dry year would hardly be dry (78 tokens instead of 62).
% Instead we round the running total and take the weekly differences.
% Then each week is a whole number, and the total stays correct.
cfg.plan_inflow  = diff([0, round(cumsum(inflow_two_years))]);
 
% Demand does not depend on the weather: both years are the same.
cfg.plan_demand = [demand_one_year, demand_one_year];
 
 
%% 9. Tiny test cases (numbers small enough to check by hand) -----------
% These come after step 8 on purpose: they overwrite the normal plans.
% MIN_LEVEL = 0 so that even 1-3 tokens can be released.
 
if strcmp(scenario, 'T_OVERFLOW')
    % Test T1: capacity 3, but 4 tokens arrive and none are released.
    % Expected by hand: 3 stored, 1 spilled, 0 free space.
    % This shows that the inhibitor arc lets tSpill fire only when pFree = 0.
    cfg.WEEKS       = 2;
    cfg.CAPACITY    = 3;
    cfg.START       = 0;
    cfg.MIN_LEVEL   = 0;
    cfg.plan_inflow = [4 0];
    cfg.plan_demand = [0 0];
end
 
if strcmp(scenario, 'T_COLOUR')
    % Test T2: two spring tokens arrive in week 1 and two summer tokens in
    % week 10. Three tokens are released in week 12.
    % If the oldest water goes first (tokenArrivedEarly in COMMON_PRE),
    % 2 spring + 1 summer tokens are released and 1 summer token stays.
    % This shows that colours are kept and the order is oldest first.
    cfg.WEEKS       = 12;
    cfg.CAPACITY    = 10;
    cfg.START       = 0;
    cfg.MIN_LEVEL   = 0;
    cfg.plan_inflow = zeros(1, 12);
    cfg.plan_inflow(1)  = 2;
    cfg.plan_inflow(10) = 2;
    cfg.plan_demand = zeros(1, 12);
    cfg.plan_demand(12) = 3;
end
 
 
%% 10. Release plan: release the demand, up to what the turbine can use -----
% This is the whole release rule of the model:
%   release this week's demand,
%   but not more than the turbine can use (half during maintenance).
% It is made last because it uses the final WEEKS, plan_demand and
% MAINT_WEEKS, which the test cases in step 9 may have changed.
%
% COMMON_PRE fires tRelease until plan_release(week) tokens have gone out
% that week, or until the dam reaches MIN_LEVEL.
cap = cfg.TURBINE_CAP * ones(1, cfg.WEEKS);                          % normal: 4 a week
cap(ismember(1:cfg.WEEKS, cfg.MAINT_WEEKS)) = cfg.TURBINE_CAP / 2;   % maintenance: 2
cfg.plan_release = min(cfg.plan_demand, cap);
end