%% loadLeafsnap.m
% Leafsnap dataset

dbName = 'Leafsnap';

% use classes with 30+ samples
load '../../Lab0_Data/LeafSnap1200_30.mat';
% use classes with 50+ samples
%load '../../Lab0_Data/LeafSnap1200_50.mat';
row=40; % or 30
col=30; % or 40

numOfClasses=max(inputLabel); % total classes
minSamples = 28;
%minSamples = 48;