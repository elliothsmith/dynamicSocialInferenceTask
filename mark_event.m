function mark_event(eventname,channel)
global data dio

% task codes are in a text file called task_codes.txt

%send digital trigger
putvalue(dio,[dec2binvec(channel,8) 1]);
WaitSecs(.005);
putvalue(dio,[dec2binvec(0,8) 0]);

%stuff for saving in the data matrix
eventtime=GetSecs-data(end).trial_start_time;

if isfield(data(end),'ev')
    data(end).ev{end+1}=eventname;
    data(end).evt(end+1)=eventtime*1000;
else
    data(end).ev{1}=eventname;
    data(end).evt(1)=eventtime*1000;
end
end % end function

