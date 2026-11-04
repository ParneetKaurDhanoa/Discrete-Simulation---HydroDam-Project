function [fire, transition] = MOD_Inflow_PRE(transition)
% Rules for water coming into the model.
% Add rain tokens until the weekly target is reached.
% Give each token the current season colour.

global global_info
cfg = global_info.cfg;

% Stop when this week's inflow target is reached.
if strcmp(transition.name, 'tRain')
    [wk, season] = week_now();

fire = global_info.n.rain(wk) < cfg.plan_inflow(wk);
    if fire
        % Keep the season colour on each token.
transition.new_color = cfg.season_names{season};   % e.g. 'summer'
        transition.override  = 1;
        global_info.n.rain(wk) = global_info.n.rain(wk) + 1;
    end
else
    fire = 1;       % tRunoff: its interface rule is in COMMON_PRE
end
end
