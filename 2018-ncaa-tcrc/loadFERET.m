%% loadFERET.m
% FERET face dataset

dbName = 'FERET';

%load '../../Lab0_Data/FERET_40x40';
%load '../../Lab0_Data/FERET_32x32';
load '/Volumes/SanDisk128B/datasets-mat/FERET_40x40';
inputData = double(inputData);
row=40;
col=40;

numOfClasses=200; % total classes
minSamples=7;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class