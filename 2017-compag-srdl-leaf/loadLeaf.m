%% loadLeaf.m
% Leaf dataset

dbName = 'Leaf';

load '../../Lab0_Data/Leaf_36x48';
row=36;
col=48;

numOfClasses=36; % total classes
minSamples=10;  % the number of samples per class
numOfSamples=10;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class