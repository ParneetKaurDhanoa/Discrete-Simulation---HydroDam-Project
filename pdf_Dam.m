function [png] = pdf_Dam()
% Dam module: the reservoir.
%
% These places show the water and empty space:
% pStored = water in the dam
% pFree = free space in the dam
% Storing water uses a free slot; releasing water frees a slot.
% This should always stay true:
% pStored + pFree = CAPACITY (P-invariant)
%
% Main transitions:
% tStore: move water into the dam
% tSpill: spill water when the dam is full
% tRelease: send water to the turbine
%
% An inhibitor arc links pFree to tSpill.
% Spilling is blocked while there is free space, so it only happens
% when the dam is full (pFree = 0).
%
% The shared-place arcs are defined in pdf_IMC,
% because those places connect different modules.

% GPenSIM uses this name to find MOD_Dam_POST.m.
png.PN_name = 'Dam';

% Places in this module
png.set_of_Ps = {'pStored', 'pFree'};

% Transitions in this module
png.set_of_Ts = {'tStore', 'tSpill', 'tRelease'};

% Arcs: {from, to, weight}
png.set_of_As = { ...
    'pFree',    'tStore',   1, ...   % storing water uses one free slot ...
    'tStore',   'pStored',  1, ...   % ... and adds one token of stored water
    'pStored',  'tRelease', 1, ...   % releasing takes one token of stored water ...
    'tRelease', 'pFree',    1};      % ... and gives the free slot back

% Inhibitor arc: {place, transition, weight}
% tSpill can fire only when pFree is empty.
png.set_of_Is = {'pFree', 'tSpill', 1};

% Ports connect this module to the others.
png.set_of_Ports = {'tStore', 'tSpill', 'tRelease'};
end
