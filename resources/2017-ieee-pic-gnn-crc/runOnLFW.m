% runOnLFW.m
% LFW���ʵ����� - Ѱ�����Ż��Ĳ���

clear all;
% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'LFW';
scale = 0.3;
pathPrefix='../datasets/lfw-deepfunneled/';
firstSample=imread('../datasets/lfw-deepfunneled/Aaron_Eckhart/Aaron_Eckhart_0001.jpg');
halfSample =imresize(firstSample,scale); % ѹ����С
[row col]=size(rgb2gray(halfSample));
numOfSamples=10; % ȡ��5�������Ķ���
numOfClasses=0; % ���������Ҫͳ��
indiesOfClasses = []; % ��¼����λ��
% ������5������������
fileID = fopen('../datasets/lfw-names.txt');
namesAndImages = textscan(fileID,'%s %d');
fclose(fileID);
names = namesAndImages{1,1};
nums = namesAndImages{1,2};
[nRow, nCol] = size(names);
for jj=1:nRow % ������������
    numOfImages = nums(jj);
    if numOfImages >= numOfSamples  % ���������㹻
        numOfClasses = numOfClasses + 1;
        indiesOfClasses(numOfClasses)=jj;
    end
end

for cc=1:numOfClasses
    for ss=1:numOfSamples
        indexOfClass = indiesOfClasses(cc); %disp(indexOfClass);
        %path=[pathPrefix names(indexOfClass) '/' names(indexOfClass) '_' num2str(ss, '%04d') '.jpg'];
        path=strcat(pathPrefix,names(indexOfClass),'/',names(indexOfClass),'_',num2str(ss, '%04d'),'.jpg');
        colored=imread(path{1});
        grayed=double(rgb2gray(colored));
        inputData(cc,ss,:,:)= imresize(grayed(:,:),scale); % ѹ����С
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