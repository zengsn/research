%% loadGT.m
% GT face dataset

dbName = 'GT';

load '../../Lab0_Data/GT_40x30';
%inputData = double(inputData);
row=40;
col=30;

numOfClasses=50; % total classes
numOfSamples=15;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class