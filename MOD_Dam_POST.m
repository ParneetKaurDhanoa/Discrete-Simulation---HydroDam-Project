function [] = MOD_Dam_POST(transition)
% Runs after a Dam transition finishes.
% Count the action and save the dam level for this week.
% The last value saved in a week is the level at the end of that week.

global global_info
wk = week_now();

switch transition.name
    case 'tStore', global_info.n.stored(wk)  = global_info.n.stored(wk) + 1;
    case 'tSpill', global_info.n.spilled(wk) = global_info.n.spilled(wk) + 1;
end
global_info.level(wk) = ntokens('pStored');
end
