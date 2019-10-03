% loadLFWH5.m

%% load original data
loadLFW;

%% load deep learning features
path = '/Volumes/SanDisk128/datasets/';
% ResNet_v1_101
dbName = 'LFW.h5.RN1101';
h5 = 'LFW_32x32.h5.resnet_v1_101';
data = h5read([path h5],'/resnet_v1_101/logits');
h5disp([path h5],'/resnet_v1_101/logits');
% ResNet_v2_101
%dbName = 'CLeaves.h5.RN2101';
%h5 = 'LFW_32x32.h5.resnet_v2_101';
%data = h5read([path h5],'/resnet_v2_101/logits');
%h5disp([path h5],'/resnet_v2_101/logits');
% load features
[dim,a,b,numOfAllSimples]=size(data);
for ii=1:numOfAllSimples
    inputDataH5(:,ii)=data(:,1,1,ii);
end
% Inception-v4
%dbName = 'CLeaves.h5.INv4';
%h5 = 'LFW_32x32.h5.inception_v4';
%data = h5read([path h5],'/Logits');
%h5disp([path h5],'/Logits');
% load features
%[dim,numOfAllSimples]=size(data);
%for ii=1:numOfAllSimples
%    inputDataH5(:,ii)=data(:,ii);
%end
clear inputData;
inputData = inputDataH5;
clear inputDataH5;
