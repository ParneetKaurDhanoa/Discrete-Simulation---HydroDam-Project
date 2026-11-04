BLASJO PROJECT
=====================

The key concepts:
modular Petri nets, places, transitions, tokens, inhibitor arcs, token colours,
timed transitions, verification, P-invariants, reachability
analysis, and scenario comparison.


START HERE
----------
1. This is our project folder.
2. Open MATLAB with this folder as the Current Folder.
3. Make sure GPenSIM v11 is on the MATLAB path.
4. Run:
       run_tests
       reachability_analysis
       main_dam
       run_all_scenarios

Run one command at a time and wait for it to finish before running the next.

MAIN FILES
----------
main_dam.m             Starts one scenario.
dam_config.m           Model settings, scenarios and the weekly release plan.
run_dam.m              Builds/runs the net and calculates results.
pdf_Inflow.m           Defines incoming water.
pdf_Dam.m              Defines storage and overflow.
pdf_PowerStation.m     Defines the turbine.
pdf_IMC.m              Connects the modules.
COMMON_PRE.m           Rules for module connections.
MOD_*                  Module-specific rules and event logging.
run_tests.m            Five verification tests.
reach_pdf.m            Small Petri net for reachability analysis.
reachability_analysis.m Reachability tree and invariants.
plot_cotree.m          Draws the coverability tree as a figure (results/).
run_all_scenarios.m    Compares the four scenarios.
plot_run.m             Plots one run.
plot_compare.m         Compares scenarios in graphs.
week_now.m             Converts simulation time into week and season.
tokens_in.m            Counts the tokens left in a place after a run.
diagrams/              Figures for the report (net, coverability tree, invariants, colours).

MODEL ASSUMPTIONS
-----------------
1 simulation time unit = 1 week
1 water token = 20 Mm3
1 water token through a turbine = 50.2 GWh
Normal dam capacity = 155 tokens
The full simulation covers 104 weeks.


