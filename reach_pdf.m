% Small Petri net for the reachability check.
function [png] = reach_pdf()

% This model uses small fixed values so the number of states stays
% small enough to check.
%
%   pRain --tStore--> pStored --tStart--> pBusy --tGen--> pEnergy
%     |  (needs pFree)          (gives pFree back)  (gives pIdle back)
%     +--tSpill--> pSpilled   (inhibitor arc: only when pFree is empty)

png.PN_name   = 'Dam reachability model';
png.set_of_Ps = {'pRain', 'pFree', 'pStored', 'pSpilled', 'pIdle', 'pBusy', 'pEnergy'};
png.set_of_Ts = {'tStore', 'tSpill', 'tStart', 'tGen'};
png.set_of_As = {'pRain', 'tStore', 1,  'pFree', 'tStore', 1,  'tStore', 'pStored', 1, ...
                 'pRain', 'tSpill', 1,  'tSpill', 'pSpilled', 1, ...
                 'pStored', 'tStart', 1, 'pIdle', 'tStart', 1, ...
                 'tStart', 'pBusy', 1,  'tStart', 'pFree', 1, ...
                 'pBusy', 'tGen', 1,    'tGen', 'pEnergy', 1,  'tGen', 'pIdle', 1};
png.set_of_Is = {'pFree', 'tSpill', 1};
end
