%% loadFlavia.m
% Flavia leaves dataset

dbName = 'Flavia';

load '../../Lab0_Data/Flavia_30x40';
%load Flavia_120x160;
%load Flavia_240x320;
row=30; %120; % 240
col=40; %160; % 320

numOfClasses=32; % total classes
minSamples=50;  % the number of samples per class
mFirstSamples=5;  % The first m images of each class