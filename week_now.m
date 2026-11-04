function [wk, season] = week_now()
% Find the current week and season.
% One time unit is one week.
% Seasons: 1 spring, 2 summer, 3 autumn, 4 winter.

global global_info

cfg = global_info.cfg;
% Convert simulation time to a week number.
wk = min(floor(current_time() + 1e-6) + 1, cfg.WEEKS);
% Get the season for that week.
season = cfg.season_of_week(mod(wk - 1, 52) + 1);
end
