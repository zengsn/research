%% loadYaleBNew.m
% YaleB face dataset

dbName = 'NEW';

load './Lab0_Data/YaleB_32x32_New';
inputLabel=gnd;
inputData =fea';
row=32;
col=32;

numOfClasses=max(inputLabel); % total classes
minSamples=64;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class