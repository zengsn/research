%% loadOneHundredLeaf.m
% 100 leaves dataset

dbName = 'OneHundredLeaf';

% use classes with 30+ samples
%load '../../Lab0_Data/LeafSnap1200_30.mat';
% use classes with 50+ samples
load '../../Lab0_Data/OneHundredLeaf_30x40.mat';
row=30; 
col=40; 

numOfClasses=max(inputLabel); % total classes
minSamples = 16;