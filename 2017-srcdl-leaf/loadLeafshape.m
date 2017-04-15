%% loadLeafshape.m
% Leaf dataset

dbName = 'LeafShape';

load '../../Lab0_Data/LeafShape_64x32';
row=64;
col=32;

numOfClasses=max(inputLabel); % total classes
minSamples=10;  % the number of samples per class
mFirstSamples=4;  % The first m images of each class