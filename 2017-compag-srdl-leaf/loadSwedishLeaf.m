%% loadSwedishLeaf.m
% Swedish Leaf dataset

dbName = 'SwedishLeaf';

load '../../Lab0_Data/SwedishLeaf_45x30';
row=45;
col=30;

numOfClasses=max(inputLabel); % total classes
minSamples = 75;