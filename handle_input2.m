%handle_input2.m
%use joystick input only to start and stop input

KbName('UnifyKeyNames')
stopkey=KbName('escape');
%         pausekey=KbName('space');
%         unpausekey = KbName('u');
%         selkey=KbName('return');
Rkey=KbName('rightarrow');
Lkey=KbName('leftarrow');
JTrig=1;

%get keyboard input
[keyIsDown,secs,keyCode] = KbCheck;
pushed=find(keyCode,1);

while keyIsDown %wait for subject to release key
    [keyIsDown,foo,foo2] = KbCheck;
end

% if joy_present
%     [jx,jy,jz,buttons]=WinJoystickMex(0);
%     jclicked=find(buttons);
% else
%     jclicked=[];
% end
%
% while joy_present&&any(buttons)
%     [jx,jy,jz,buttons]=WinJoystickMex(0);
% end

% %break 'ties' by randomly sorting keypresses and choosing first
% all_in=[pushed(:) ; jclicked(:)];
% all_in=all_in(randperm(numel(all_in)));
% %this_key=all_in(1);
% this_key=all_in;
%
% yes_key=any(ismember(this_key,[Lkey]));
% no_key=any(ismember(this_key,[Rkey]));
% stopnow=ismember(stopkey,this_key);

if pushed==Lkey
    % [20180531] this section should be all I need.
    mark_event('yes response',11);
    rt=GetSecs-question_onset;
    response_time=GetSecs;
    last_response_time=response_time;
    result='yes';
    Screen('Flip', window);
elseif pushed==Rkey
    mark_event('no response',10);
    rt=GetSecs-question_onset;
    response_time=GetSecs;
    last_response_time=response_time;
    result='no';
    Screen('Flip', window);
end

if pushed==stopkey
    if continue_running
        disp('esc pressed while waiting for selection')
    end
    result='aborted';
    keep_waiting=0;
    continue_running=0;
end

