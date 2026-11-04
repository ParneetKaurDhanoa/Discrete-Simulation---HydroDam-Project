% Check the states the small Petri net can reach.
% Build the coverability tree for reach_pdf.m.
% Use cotreei because the net has an inhibitor arc.
% Check capacity and invariants.
% Show the P-invariants for both models.
% Draw the coverability tree as a figure (plot_cotree.m).

clear; clc;
global global_info
global_info = struct();

% Build the small Petri net.
pns = pnstruct('reach_pdf');
dyn.m0 = {'pRain', 3, 'pFree', 2, 'pIdle', 1};
dyn.ft = {'allothers', 1};          % times are not used by the tree, but GPenSIM asks
pni = initialdynamics(pns, dyn);

fprintf('===== 1. Coverability tree =====\n');
% Run the reachability check.
COTREE = cotreei(pni, 500);         % prints every state

fprintf('\n===== 2. Check every state in the tree =====\n');
% Get place names for the columns in the tree.
P = {pns.global_places.name};
S = COTREE(:, 1:numel(P));          % one row per state, one column per place
col = @(name) S(:, strcmp(P, name));
fprintf('States in the tree:                         %d\n', size(S, 1));
fprintf('Dam never above capacity (pStored <= 2):    %d\n', all(col('pStored') <= 2));
fprintf('Capacity invariant pStored + pFree = 2:     %d\n', all(col('pStored') + col('pFree') == 2));
fprintf('Water invariant (all water places) = 3:     %d\n', ...
        all(col('pRain') + col('pStored') + col('pBusy') + col('pSpilled') + col('pEnergy') == 3));
fprintf('Turbine invariant pIdle + pBusy = 1:        %d\n', all(col('pIdle') + col('pBusy') == 1));
% Dead (terminal) states are marked with T in the last column of COTREE.
% Check that none of them leaves water waiting in the system.
dead = S(COTREE(:, end) == double('T'), :);
fprintf('Dead states with water still in the dam:    %d  (0 = no deadlock)\n', ...
        sum(dead(:, strcmp(P, 'pRain')) + dead(:, strcmp(P, 'pStored')) + dead(:, strcmp(P, 'pBusy')) > 0));

fprintf('\n===== 3. P-invariants =====\n');
fprintf('Small model:\n');      pinvariant(pns);
fprintf('\nFull Blasjo model:\n');
pinvariant(pnstruct({'pdf_Inflow', 'pdf_Dam', 'pdf_PowerStation', 'pdf_IMC'}));


% ----- Coverability tree diagram -----
% GPenSIM's cotree can draw the tree, but it does not accept nets with
% inhibitor arcs. This net has one (pFree -> tSpill), so cotreei is used
% above: it builds and prints the tree, but cannot draw it.
% The diagram of this tree is in diagrams/03_coverability_tree.png.
% It uses the same state numbers as the cotreei printout:
%   25 nodes, 20 different states
%   D = marking already in the tree (not expanded again)
%   T = dead state (no transition can fire): states 23 and 25
% Both dead states have all the water used up, so there is no deadlock.
