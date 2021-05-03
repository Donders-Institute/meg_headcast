[f, p] = fileparts(mfilename('fullpath'));

codepath = fullfile(fileparts(f), 'code');
modelpath = fullfile(fileparts(f), 'models');

warning('adding %s to your path', codepath);
warning('adding %s to your path', modelpath);

addpath(codepath)
addpath(modelpath)

