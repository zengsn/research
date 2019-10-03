%% loadORL.m
% ORL face dataset

dbName = 'FERET';

load 'C:\Users\lenovo\Documents\MATLAB\Lab0_Data\FERET_32x32.mat';
%inputData = fea';
%inputLabel = gnd;
inputData = double(inputData);
row=32;
col=32;
numOfSamples=7;
numOfClasses=200;
%numOfClasses=40; % total classes                    
%numOfSamples=10;  % the number of samples per class
%mFirstSamples=4;  % The first m images of each class