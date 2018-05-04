%% loadCMUFaces.m
% CMUFaces face dataset

dbName = 'CMUFaces';

%load '../../Lab0_Data/CMUFaces_30x32';
load '/Volumes/SanDisk128B/datasets-mat/CMUFaces_30x32';
%inputData = double(inputData);
row=30;
col=32;

numOfClasses=max(inputLabel); % total classes
minSamples=54;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class

minTrain=1;
maxTrain=40;
trainStep=1;