%setup_pars.m

% pre-configure task parameters; save all relevant parameters to the pars
% structure for saving to disk

%%%%%%%%%%%%%%%%% trial parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialnum=0;
trialnumdp=0;
numtrials=100;
continue_running=1; %loop parameter

%%%%%%%%%%%%%%%% sound parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setup_audio

%%%%%%%%%%%%%%%%% response parameters, points, etc. %%%%%%%%%%%%%%%
input_mode=2;
max_rt=15; %maximum reaction time
iti=1; %inter-trial interval (not currently used)
iti_jitter=0.25; %jitter for iti
post_movie_delay=2;
post_movie_delay_jitter=0.5; % re-read experimental design to decide whether to use this. 

disp_resp=0.5; %interval for displaying response
disp_resp_jitter=0.25;

rt=0;
result='first_trial';
this_run=0;


%things that don't really change trial-to-trial
pars.input_mode=input_mode;
pars.max_rt=max_rt;
pars.iti=iti;
pars.iti_jitter=iti_jitter;
pars.disp_resp=disp_resp;
pars.disp_resp_jitter=disp_resp_jitter;




