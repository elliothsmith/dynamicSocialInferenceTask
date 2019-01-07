%run_outcome.m

%handle all the drawing, saving, etc. from input

%update screen, display result, and record data
switch result
    case 'yes'
         t_now=GetSecs;
%          WaitSecs(disp_outcome+rand*disp_outcome_jitter);
        keep_waiting=0;
        
    case 'no'
         t_now=GetSecs;
%          WaitSecs(disp_outcome+rand*disp_outcome_jitter);
        keep_waiting=0;
        

    % TODO:: fix timing in the above lines. 
    %  - Also, do I need to save any variables 
end
