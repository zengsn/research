%% loadMUCT.m
% MUCT face dataset

dbName = 'MUCT';

load '../../Lab0_Data/MUCT_with_Landmarks_32x32';
%inputData = double(inputData);
row=32;
col=32;

numOfClasses=max(inputLabel); % total classes
numOfSamples=15;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class