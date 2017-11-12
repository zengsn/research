%% loadAR.m
% AR face dataset

dbName = 'AR';

load '../../Lab0_Data/AR_40x32';
%inputData = double(inputData);
row=40;%50;
col=32;%40;

numOfClasses=120; % total classes
numOfSamples=26;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class