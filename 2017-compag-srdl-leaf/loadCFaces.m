%% loadCFaces.m
% CFaces face dataset

dbName = 'CFaces';

load '../../Lab0_Data/CFaces_30x45';
%load '../../Lab0_Data/CMUFaces_30x32_int8';
%inputData = double(inputData);
row=30;
col=45;

numOfClasses=max(inputLabel); % total classes
numOfSamples=10;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class