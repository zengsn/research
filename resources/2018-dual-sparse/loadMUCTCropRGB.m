%% loadMUCTCropRGB.m
% MUCT data with landmarks, already aligned and croped.

load '/Volumes/SanDisk128B/datasets-mat/MUCTCropRGB_32x24.mat';
dbName = 'MUCTCropRGB';
dbNameD= dbName;
%row=64;
%col=48;
%numOfClasses=276; % total classes
minSamples=10;  % the number of samples per class
mFirstSamples=5;  % The first m images of each class