%% loadORL.m
% ORL face dataset

dbName = 'CMU';

load './Lab0_Data/CMUFaces_30x32.mat';
%inputData = fea';
%inputLabel = gnd;
inputData = double(inputData);
row=30;
col=32;
numOfSamples=54;
numOfClasses=20;
%numOfClasses=40; % total classes                    
%numOfSamples=10;  % the number of samples per class
%mFirstSamples=4;  % The first m images of each class