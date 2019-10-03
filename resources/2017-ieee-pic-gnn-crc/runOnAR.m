% runOnAR.m

clear all;

% Loading data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
dbName = 'AR';
pathPrefix='../datasets/AR_gray_50by/AR';
firstSample=imread('../datasets/AR_gray_50by/AR001-1.tif');
[row col]=size(firstSample);
numOfSamples=26;
numOfClasses=120;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        path=[pathPrefix num2str(cc,'%03d') '-' num2str(ss) '.tif'];
        temp00=imread(path);
        temp0=reshape(temp00,row*col,1);
        inputData(cc,ss,:,:)=temp0;
    end
end
inputData=double(inputData); % all input data

% Setting Parameters   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % �Ƿ��Ż����
minTrains = 1;  % ѵ��������
maxTrains = 15;  % ѵ��������
numOfStep = 1;  % ѵ��������ѭ������
Gabor_NN_CRC;     % ����ʵ��
disp('Test done!');