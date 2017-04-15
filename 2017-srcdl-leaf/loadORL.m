%% loadORL.m
% ORL face dataset

dbName = 'ORL';

load '../../Lab0_Data/ORL_56x46';
load '../../Lab0_Data/ORL_56x46_int8';
%inputData = double(inputData);
row=56;
col=46;

numOfClasses=40; % total classes
numOfSamples=10;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class