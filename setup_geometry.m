%setup_geometry
%get screen resolution and define useful locations (origin, text locations,
%etc.) with respect to it

%get screen resolution
res_info=Screen('Resolution',which_screen);
horz=res_info.width;
vert=res_info.height;
screen_size = [horz vert];

%set various convenient screen locations (0,0) is upper-left monitor corner
% basic rectangles
origin = [horz/2 vert/2];
text_origin = origin - [45 25];
origin2=[origin origin];
%baserect=minrad*[-1 -1 1 1]; %rectangle of cue
opt_loc_L=origin+[-250 200];
opt_loc_R=origin+[250 200];

state.txtpos=text_origin;
state.Lpos=opt_loc_L;
state.Rpos=opt_loc_R;

% %progress bar
% pbar_hoffset=100;
% pbar_voffset=100;
% pbar_thick=50;
% pbar_UL=[0 vert]+[pbar_hoffset -pbar_voffset-pbar_thick]; %lower left corner of pbar
% pbar_LR=[horz vert]+[-pbar_hoffset -pbar_voffset];
% state.pbar=[pbar_UL pbar_LR];

    % set up movie rectangle
    destrect_ext = [0 + 10*screenRect(3)/100, 0 + 10*screenRect(4)/100,  screenRect(3) - 10*screenRect(3)/100,  screenRect(4) - 10*screenRect(4)/100];


min_vpos=origin(2)-100;
max_vpos=0+30;
