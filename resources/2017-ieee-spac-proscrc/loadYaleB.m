%% loadORL.m
% ORL face dataset

dbName = 'YaleB';

load 'C:\Users\lenovo\Documents\MATLAB\datasets\YaleB_58x51.mat';
%inputData = fea';
%inputLabel = gnd;
inputData = double(inputData);
row=58;
col=51;
numOfSamples=57;
numOfClasses=38;
%numOfClasses=40; % total classes                    
%numOfSamples=10;  % the number of samples per class
%mFirstSamples=4;  % The first m images of each class