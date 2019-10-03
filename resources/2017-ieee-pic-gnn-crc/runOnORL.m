% runOnORL.m
% ORL���ʵ����� - Ѱ�����Ż��Ĳ���

clear all;
% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
dbName = 'ORL';
pathPrefix='../datasets/orl/orl';
firstSample=imread('../datasets/orl/orl001.bmp');
[row col]=size(firstSample);
numOfSamples=10;
numOfClasses=40;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix num2str((cc-1)*numOfSamples+ss,'%03d') '.bmp'];
        inputData(cc,ss,:,:)=imread(path);
    end
end
inputData=double(inputData); % ���е���������

% ���ò���       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % �Ƿ��Ż����
minTrains = 1;  % ѵ��������
maxTrains = 8;  % ѵ��������
numOfStep = 1;  % ѵ��������ѭ������
Gabor_NN_CRC;     % ����ʵ��
disp('Test done!');