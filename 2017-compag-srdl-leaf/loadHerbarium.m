%% loadHerbarium.m
% Load Herbarium dataset

dbName = 'Herbarium';

load '../../Lab0_Data/Herbarium49x76';
row=49;%588;%784
col=76;%903;%1204

numOfClasses=6; % total classes
minSamples=9;  % the number of samples per class
mFirstSamples=5;  % The first m images of each class