%% loadHerbariumI.m
% Load Herbarium Isoluted dataset

dbName = 'HerbariumI';

load '../../Lab0_Data/HerbariumI32x32';
row=32;%512;%
col=32;%512;%

numOfClasses=6; % total classes
minSamples=38;  % the number of samples per class
mFirstSamples=5;  % The first m images of each class