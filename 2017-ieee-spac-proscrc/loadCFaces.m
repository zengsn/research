%% loadORL.m
% ORL face dataset

dbName = 'CFaces';

load 'C:\Users\lenovo\Documents\MATLAB\Lab0_Data\CFaces_30x45.mat';
%inputData = fea';
%inputLabel = gnd;
inputData = double(inputData);
row=30;
col=45;
numOfSamples=10;
numOfClasses=19;
%numOfClasses=40; % total classes                    
%numOfSamples=10;  % the number of samples per class
%mFirstSamples=4;  % The first m images of each class