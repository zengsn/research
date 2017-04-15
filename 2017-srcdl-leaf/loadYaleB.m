%% loadYaleB.m
% YaleB face dataset

dbName = 'YaleB';

load '../../Lab0_Data/YaleB_29x26';
%load '../../Lab0_Data/YaleB_29x26_int8';
%inputData = double(inputData);
row=29;
col=26;

numOfClasses=max(inputLabel); % total classes
numOfSamples=57;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class