%% loadORL.m
% ORL face dataset

dbName = 'COIL20';

load 'C:\Users\lenovo\Documents\MATLAB\Lab0_Data\COIL20_32x32.mat';
%inputData = fea';
%inputLabel = gnd;
inputData = double(inputData);
row=32;
col=32;
numOfSamples=30;
numOfClasses=20;
%numOfClasses=40; % total classes                    
%numOfSamples=10;  % the number of samples per class
%mFirstSamples=4;  % The first m images of each class