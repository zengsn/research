%% loadCMUFaces.m
% CMUFaces face dataset

dbName = 'CMUFaces';

load '../../Lab0_Data/CMUFaces_30x32';
%load '../../Lab0_Data/CMUFaces_30x32_int8';
%inputData = double(inputData);
row=30;
col=32;

numOfClasses=max(inputLabel); % total classes
numOfSamples=54;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class