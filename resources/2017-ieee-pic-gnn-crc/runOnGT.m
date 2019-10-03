% runOnGT.m
% GT���ʵ�����

clear all;

% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'GT';
pathPrefix='../datasets/Georgia Tech face database crop/';
firstSample=imread('../datasets/Georgia Tech face database crop/1_1.jpg');
%[size_a size_b size_c]=size(firstSample);
[row col]=size(rgb2gray(firstSample));
numOfSamples=15;
numOfClasses=50;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix int2str(cc) '_' int2str(ss) '.jpg'];
        colored=imread(path);
        %grayed=double(rgb2gray(colored));
        grayed=rgb2gray(colored);
        inputData(cc,ss,:,:)= grayed(:,:);
    end
end
inputData=double(inputData); % all input data

% ���ò���       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % �Ƿ��Ż����
minTrains = 1;  % ѵ��������
maxTrains = 10;  % ѵ��������
numOfStep = 1;  % ѵ��������ѭ������
Gabor_NN_CRC;     % ����ʵ��
disp('Test done!');