function [fire, transition] = COMMON_PRE(transition)
% Rules for transitions between modules.
% GPenSIM checks these before a port transition fires.
% Rules inside modules are in the MOD_*_PRE files.

global global_info
cfg = global_info.cfg;
wk = week_now();
fire = 1;                                   % default: no extra condition (tRunoff, tSpill, tTurbine)


switch transition.name

    % Store water only if there is free space. Keep its colour.
case 'tStore'   % water enters the dam (the arc from pFree needs free space)
        % Keep the colour of the oldest runoff token.
        % Otherwise the free-space token colour could mix in.
        tok = tokenArrivedEarly('pRunoff', 1);
        transition.selected_tokens = tok(1);
        transition.new_color = get_color('pRunoff', tok(1));
        transition.override  = 1;

    % Set the release amount and record the water colour.
case 'tRelease' % water to the turbines, following the release plan
        % Follow the release plan and keep the minimum water level.
        fire = global_info.n.released(wk) < cfg.plan_release(wk) && ...
               ntokens('pStored') > cfg.MIN_LEVEL;        % keep the minimum level
        if fire
            tok = tokenArrivedEarly('pStored', 1);        % oldest water first
            transition.selected_tokens = tok(1);
            % Record which season the released water came from.
            k = find(ismember(cfg.season_names, get_color('pStored', tok(1))), 1);
            if isempty(k), k = 5; end      % no colour = water already in the dam at start
            global_info.ledger(wk, k)    = global_info.ledger(wk, k) + 1;
            global_info.n.released(wk)   = global_info.n.released(wk) + 1;
        end
end
end
