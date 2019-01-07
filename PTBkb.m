function [] = PTBkb()
% this is just a way to keyboard psych toolbox

Screen('CloseAll') %close screen
ListenChar(0) %keyboard input goes back to matlab window
keyboard %pause for user input

end