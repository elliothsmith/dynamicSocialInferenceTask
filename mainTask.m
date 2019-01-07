% function mainTask()
% runs the [emotion and semantic decision making] task

%developed from jmp's bartc.m script.
%[EHS::20180531]
AssertOpenGL;
sca, clear, close all, clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% SET EYE TRACKER %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
updateFrequencyInHz = 300;
disp('Initializing tetio...');
tetio_init(); %initilize library
% Set to tracker ID to the product ID of the tracker you want to connect to.
trackerId = 'TX300-010105642665';%find in the network settings
% FUNCTION "SEARCH FOR TRACKERS" IF NOTSET
if (strcmp(trackerId, 'NOTSET'))
    warning('tetio_matlab:EyeTracking', 'Variable trackerId has not been set.');
    disp('Browsing for trackers...');
    trackerinfo = tetio_getTrackers();
    for i = 1:size(trackerinfo,2)
        disp(trackerinfo(i).ProductId);
    end
    tetio_cleanUp();
    error('Error: the variable trackerId has not been set. Edit the EyeTrackingSample.m script and replace "NOTSET" with your tracker id (should be in the list above) before running this script again.');
end

% ET params
tetio_connectTracker(trackerId)
currentFrameRate = tetio_getFrameRate;
fprintf('Frame rate: %d Hz.\n', currentFrameRate);

% calibration
wanttocalibrate = inputdlg('Want to calibrate: y or n?');
if strcmp(wanttocalibrate, 'y')
    calibration;
end

% Specifying default variables in a loop
try   
    % add current directory to path
    addpath(pwd) %make sure to grab local copies of scripts
     
    %% generate movie lists, clip identities, and
    start_path = pwd;
    movie_list = dir('./clips');
    movie_list(1:2) = [];
    num_movies = length(movie_list);
    fid = fopen('./questions.csv');
    q_array = textscan(fid,'%s','Delimiter',',');
    questions = reshape(q_array{:},2,size(q_array{:},1)/2);

    % first row is emotional question and second row is the corresponding
    % semantic quetion.
    % TODO:: assert these have the same lengths.
    
    % setup joystick - if using gamepad. NUm pad is probably better for this one. 
    %     setup_joystick
    
    % PTB settings (it tends to complain on PCs)
    warning('off','MATLAB:dispatcher:InexactMatch');
    Screen('Preference', 'SkipSyncTests',2); %disables all testing -- use only if ms timing is not at all an issue
    Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('CloseAll')
    HideCursor; % turn off mouse cursor
    % InitializeMatlabOpenGL([],[],1);
    ListenChar(2); %keeps keyboard input from going to Matlab window
    
    % set random number seed
    seed=sum(100*clock);
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',seed));
    
    % pre-configure task parameters; save all relevant parameters to the pars
    % structure for saving to disk

    %%%%%%%%%%%%%%%%% trial parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    trialnum=0;
    trialnumdp=0;
    numtrials=200;
    continue_running=1; %loop parameter

    %%%%%%%%%%%%%%%% sound parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    setup_audio

    %%%%%%%%%%% response parameters, points, etc. %%%%%%%%%%%%%%%%%%
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

    %%%%%%%%%%%%%%%% stimulus parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % generate a pseudorandom list of video identities. 
    movie_queue = repmat(ceil(num_movies*rand(1,num_movies)),1,floor(numtrials/num_movies));
    question_queue = repmat(ceil(2*rand(1,num_movies)),1,floor(numtrials/num_movies);
    % setup_pars  % [20180531::EHS:TODO::fix the saving structure. Rename vars, and could be more efficient.]
    
    % [20180604] prebuffering stuff
    benchmark=0;
    async=0;
    
    %which screen do we display to?
    which_screen=2;
    
    % open window
    [window, screenRect] = Screen('OpenWindow',which_screen,[0 0 0],[],32);
    
    % setup geometry
    setup_geometry % [20180531::EHS: cleared]
    
    % bind keys
    KbName('UnifyKeyNames')
    stopkey=KbName('escape');
    Rkey=KbName('rightarrow');
    Lkey=KbName('leftarrow');
    JTrig=1;
    % bind_keys % [20180531::EHS: cleared]
    
    % setup data file
    setup_data_file % [20180531::EHS: cleared]
    
    % initialize data structure for recording
    global data;
    data=[];
    
    % initialize data io object for national intrusments setup
    global dio
    dio = digitalio('nidaq','Dev1');
    hline = addline(dio, 0:7, 0, 'Out');
    hline2 = addline(dio, 1, 1, 'Out');
    putvalue(dio,[dec2binvec(0,8) 0]); % Set port values to zero.
    ET_time = []; %initiate the ET_time markers log mattrix with trigger value and remote (i.e. eye tracker time stamp)
    SDK_time = []; %initiate the SDK_time markers log mattrix with trigger value and local (i.e. SDK/MATLAB time stamp)

    % marking the beginning of the task
    mark_event('start of task',254)

    % set font parameters
    Screen(window,'TextFont','Helvetica');
    Screen(window,'TextSize',50);
    
    WaitSecs(1); %for some reason, PTB screws up Screen redraw the first time we use pause, so do it here
    trialnum=0;
    
    tetio_startTracking;
    WaitSecs(0.5)
    
%% While Loop Info::
%% continue_running : main task loop for each trial
%% keep_waiting : response loop for the response to each question.

    %% main task loop
    %     KbEventFlush
    while continue_running
        
        % set up the current trial. [20180531::EHS:cleared]
        % perform basic bookkeeping before trial starts
        if ~strcmp(result, 'no response') %increment trial number
            trialnumdp=trialnumdp+1;
        end
        trialnum=trialnum+1;
        result='';

        % current trial movie params. 
        which_movie = movie_queue(trialnum);
        which_question = question_queue(trialnum);
        
        % end of task screen.
        if trialnumdp>numtrials
            Screen('FillRect',window)
            DrawFormattedText(window,'Thank you.','center','center',[255 255 255]); %point value in balloon
            Screen('Flip',window);
            WaitSecs(5);
            mark_event('end of task',255)
            break
        end
                      
        trial_start_time=GetSecs;
        data(trialnum).trial_start_time=trial_start_time;

        % fixation cross?
        mark_event('fixation cross',200)
        DrawFormattedText(window,'+','center','center',[255 255 255])
        Screen('Flip',window)
        WaitSecs(0.5)

        %% play video HERE!
        try
            % Open movie file:
            [movie, movie_duration, frame_rate] = Screen('OpenMovie', window,...
                fullfile(start_path,'clips',movie_list(which_movie).name));
            
            % Start playback engine:
            [droppedframes] = Screen('PlayMovie', movie,1);
            [ET_time, SDK_time] = add_ET_marker([movie_list(which_movie).name],ET_time, SDK_time);
            mark_event('movie',which_movie)
            tic

            % movie loop
            movie_loops = 1;
            while (~KbCheck)
                movie_loops=movie_loops+1;
                % Wait for next movie frame, retrieve texture handle to it
                tex = Screen('GetMovieImage', window, movie);
                % Valid texture returned? A negative value means end of movie reached:
                if tex<=0
                    % We're done, break out of loop:
                    break;
                end
                % Draw the new texture immediately to screen:
                Screen('DrawTexture', window, tex,[],destrect_ext);
                % Update display:
                Screen('Flip', window);
                % Release texture:
                Screen('Close', tex);
            end % end of video loop
            % Stop playback and close movie
            Screen('PlayMovie', movie, 0);
            Screen('CloseMovie', movie);
            [ET_time, SDK_time] = add_ET_marker([movie_list(which_movie).name],ET_time, SDK_time);
            mark_event('end movie',190)
            tmp = toc;           
        catch 
            sca
            psychrethrow(psychlasterror);
        end 
        
        %         numGazeData = size(leftEye, 2);
        %         LeftEyeAll = vertcat(LeftEyeAll, leftEye(:, 1:numGazeData));
        %         RightEyeAll = vertcat(RightEyeAll, rightEye(:, 1:numGazeData));
        %         TimeStampAll = vertcat(TimeStampAll, timeStamp(:,1));
        
        %% show black screen during delay period. delay period
        Screen('Flip', window);
        WaitSecs(post_movie_delay+rand*post_movie_delay_jitter);
        mark_event('end delay',195)

        %% draw question 1: semantic or emotional content.
        DrawFormattedText(window,questions{which_question,which_movie},'center','center',[255 255 255])
        Screen('Flip', window);
        mark_event('question 1',198)
        question_onset = GetSecs;
        
        keep_waiting=1;
        % trap keyboard input for response
        while keep_waiting

             %get keyboard input
             [keyIsDown,secs,keyCode] = KbCheck;
             pushed=find(keyCode,1);
             while keyIsDown %wait for subject to release key
                 [keyIsDown,foo,foo2] = KbCheck;
             end

             % in case of esc
             if pushed==stopkey
                if continue_running
                    disp('esc pressed while waiting for selection')
                end
                result='aborted';
                keep_waiting=0;
                continue_running=0;
             end

             % regisetring binary responses (yes or no) using the left and righ arrow keys, respectively.  
             if pushed==Lkey
                 % [20180531] this section should be all I need.
                 mark_event('yes response',11);
                 rt=GetSecs-question_onset;
                 response_time=GetSecs;
                 last_response_time=response_time;
                 result='yes';
                 keep_waiting=0;
                 Screen('Flip', window);
              elseif pushed==Rkey
                 mark_event('no response',10);
                 rt=GetSecs-question_onset;
                 response_time=GetSecs;
                 last_response_time=response_time;
                 result='no';
                 keep_waiting=0;
                 Screen('Flip', window);
              end
                                     
             % did subject make a response in time?
             if (GetSecs-question_onset)>max_rt
                 keep_waiting=0;
                 line=sprintf('SUBJECT FAILED TO CHOOSE TARGET WITHIN %d SECONDS',max_rt);
                 disp(line);
                 result = 'no response';
                 mark_event('max rt exceeded',222)
                
                 Screen(window,'flip');
                 WaitSecs(1);
             end
        end % end of response loop
        
        %save trial data and print result here
        out_line=sprintf('Trial %d: %s',trialnumdp,movie_list(which_movie).name);
        disp(out_line)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% end of trial bookkeeping %%%%%%%%%%
%%%%%%%%%%%%%%% saving data %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        curtime=GetSecs;

        %for now, no iti, since outcome period pauses action
        %if we use an iti, blank screen
        mark_event('iti begin',210);
        while (GetSecs-curtime < (iti+rand*iti_jitter))
            esc_check();
        end;

        % pause for ~.33 ms and read gaze data from eyetracker
        pause(1/updateFrequencyInHz);
        [leftEye, rightEye, timeStamp, trigSignal] = tetio_readGazeData;
        pause(1/updateFrequencyInHz);

        % saving eyetracker data
        eye_mov.leftEye = leftEye;
        eye_mov.rightEye = rightEye;
        eye_mov.timeStamp = timeStamp;
        eye_mov.setup.currentFrameRate = currentFrameRate;
        eye_mov.setup.screen_size = screen_size;
        eye_mov.setup.destrect_ext = destrect_ext;
        eye_mov.timing.movie_loops = movie_loops;
        eye_mov.timing.movie_duration = movie_duration;
        eye_mov.timing.toc_time = tmp;
        eye_mov.timing.ET_time = ET_time;
        eye_mov.timing.SDK_time = SDK_time;

        %record other data
        data(trialnum).ETdata=eye_mov;
        data(trialnum).which_movie=which_movie;
        data(trialnum).which_question=which_question;
        data(trialnum).this_run=this_run;
        data(trialnum).result = result;
        data(trialnum).rt=rt;
        data(trialnum).movie_duration = movie_duration;
        data(trialnum).frame_rate=frame_rate;

        % saving.
        save(fname,'data','pars');
            
        % close_trial %save variables, increment trial number
        mark_event('iti end',211);

        esc_check %did we try to exit?
        
    end %of keep_waiting response loop    
    
    %% TODO [if necessary]::  draw question 2: familiarity.

    mark_event('end of task',255)
    Screen('CloseAll') %close screen
    cd(start_path) %return to start directory
    ListenChar(0); %give keyboard input back to Matlab
    
    tetio_stopTracking;
    tetio_disconnectTracker;
    tetio_cleanUp;
catch q
    Screen('CloseAll') %close screen
    if exist('start_path','var')
        cd(start_path) %return to start directory
    end
    ListenChar(0) %keyboard input goes back to matlab window
    keyboard %pause for user input
end


% end % eof
