%% loadFERET.m
% FERET face dataset

dbName = 'FERET';

%load '../../Lab0_Data/FERET_32x32';
load '../../Lab0_Data/FERET_32x32_d';
%inputData = double(inputData);
row=32;
col=32;

numOfClasses=200; % total classes
numOfSamples=7;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class