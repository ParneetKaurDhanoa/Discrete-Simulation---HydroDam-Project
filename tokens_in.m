function k = tokens_in(sim, place_name)
% Count the tokens left in a place at the end of a run.
names = {sim.global_places.name};
k = sim.X(strcmp(names, place_name));
end
