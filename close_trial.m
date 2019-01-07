%close_trial.m
%end of trial bookkeeping; save data

curtime=GetSecs;

%for now, no iti, since outcome period pauses action
%if we use an iti, blank screen
mark_event('iti begin',210);
while (GetSecs-curtime < (iti+rand*iti_jitter))
    esc_check();
end;
mark_event('iti end',211);

% pause for ~.33 ms and read gaze data from eyetracker
pause(1/updateFrequencyInHz);
[leftEye, rightEye, timeStamp, trigSignal] = tetio_readGazeData;
pause(1/updateFrequencyInHz);

% saving eyetracker data
eye_mov.leftEye = leftEye;
eye_mov.rightEye = rightEye;
eye_mov.timeStamp = timeStamp;
% Eye_movie.repetition = repeatNo;
% Eye_movie.current_movie = movieNo;
% Eye_movie.moviefile = moviefile;
% Eye_movie.fr = fr;
% Eye_movie.vbl_aggr = vbl_aggr;
% Eye_movie.setup.rate = rate;
eye_mov.setup.currentFrameRate = currentFrameRate;
eye_mov.setup.screen_size = screen_size;
eye_mov.setup.destrect_ext = destrect_ext;
% Eye_movie.setup.timeindex_aggr = timeindex_aggr;
% Eye_movie.setup.toc_time = toc_time;
% Eye_movie.setup = image_idx;
eye_mov.timing.ET_time= ET_time;
eye_mov.timing.SDK_time = SDK_time;

%record data
data(trialnum).ETdata=eye_mov;
data(trialnum).which_movie=which_movie;
data(trialnum).which_question=which_question;

data(trialnum).this_run=this_run;
data(trialnum).result = result;
data(trialnum).rt=rt;

data(trialnum).movie_duration = movie_duration;
data(trialnum).frame_rate=frame_rate;

save(fname,'data','pars');
