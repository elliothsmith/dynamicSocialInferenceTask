%setup_data_file.m
% set up files, directories

start_path=pwd;

if ~exist('filename','var')
    disp('Subject name not provided, using test as name');
    filename = sprintf('test');
end

%note: fileparts and fullfile would be better, os-independent way to do
%this!

if ispc
    if ~isdir('c:\data\SmithNARSAD')
        mkdir('c:\data\SmithNARSAD')
    end
    %cd C:\data\bartc
    dat_dir=sprintf('%s\\%s','c:\data\SmithNARSAD',filename);
elseif ismac
    if ~isdir('/data/SmithNARSAD')
        mkdir('/data/SmithNARSAD')
    end
    %cd /data/bartc
    dat_dir=sprintf('%s/%s','/data/SmithNARSAD',filename);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    if ~exist(dat_dir,'dir')
        mkdir(dat_dir)
    end
catch q
    Screen('closeall')
end

cd(dat_dir)

% get file names
data_dir=dir(pwd);
dirnames={data_dir.name};

expr=sprintf('(\?<=%s.%s)\\d+',filename,datetime); %regexp to get number of run
runnames_cell=regexp(dirnames,expr,'match');
runnames_cell=runnames_cell(~cellfun(@isempty,runnames_cell)); %get rid of empties
runnames=cellfun(@str2double,runnames_cell);
if ~isempty(runnames)
    lastrun=max(runnames);
else
    lastrun=0;
end

fname_short=sprintf('%s.%d',filename,lastrun+1);
fname=sprintf('%s.bartc.mat',fname_short);
