% runOnCOIL.m
% COIL���ʵ����� - Ѱ�����Ż��Ĳ���

clear all;
% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
dbName = 'COIL';
pathPrefix='../datasets/coil-20-proc/';
firstSample=imread('../datasets/coil-20-proc/obj1__0.png');
[row col]=size(firstSample);
numOfSamples=30;%72;
numOfClasses=20;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix 'obj' num2str(cc, '%d') '__' num2str(ss-1, '%d') '.png'];
        inputData(cc,ss,:,:)=imread(path);
    end
end
inputData=double(inputData); % ���е���������

% ���ò���       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % �Ƿ��Ż����
minTrains = 1;  % ѵ��������
maxTrains = 8;  % ѵ��������
numOfStep = 1;  % ѵ��������ѭ������
Gabor_NN_CRC; % ����ʵ��
disp('Test done!');