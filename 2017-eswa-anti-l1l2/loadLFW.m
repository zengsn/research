%% loadLFW.m
% Load original data

dbName = 'LFW';

load gray_lsw
row=32;
col=32;

inputData = gray_lsw;
inputLabel = gnd;
numOfClasses=86;
mFirstSamples=5; % The first m images of each class
numOfSamples=11;