%% loadORL.m
% ORL face dataset

dbName = 'flavia';

load './datasets/ORL_56x46.mat';
%inputData = fea';
%inputLabel = gnd;
inputData = double(inputData);
row=56;
col=46;
%numOfSamples=70;
%numOfClasses=32;
numOfClasses=40; % total classes                    
numOfSamples=10;  % the number of samples per class
%mFirstSamples=4;  % The first m images of each class