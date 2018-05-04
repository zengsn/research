%% loadMUCT.m
% MUCT data with landmarks, already aligned and croped.

dbName = 'MUCT';

load '../../Lab0_Data/MUCT_with_Landmarks_32x32.mat';
row=32;
col=32;

numOfClasses=276; % total classes
minSamples=10;  % the number of samples per class
mFirstSamples=5;  % The first m images of each class

minTrain=1;
maxTrain=8;
trainStep=1;