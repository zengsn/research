% runOnCaltechLeaves_Better.m
% Caltech Face���ʵ����� - Ѱ�����Ż��Ĳ���

clear all;
% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
dbName = 'Caltech_Leaves';
pathPrefix='../datasets/caltech_leaves/';
firstSample=imread('../datasets/caltech_leaves/image_0001.jpg');
halfSample =imresize(firstSample,0.5); % ѹ����С
[row col]=size(rgb2gray(halfSample));
numOfSamples=10;
numOfClasses=0; % ��Ҫ�����ݽ��д���

% ��ȡ��ע��¼
labelFile = [pathPrefix 'labels.txt']; % �������
fid = fopen(labelFile);
labelData = textscan(fid, '%d %d', 'delimiter', ',');
fclose(fid);
[numOfLines, two] = size(labelData{1});

for lii=1:numOfLines % ����ÿһ��
    num1=labelData{1}(lii);
    num2=labelData{2}(lii);
    numOfClassSamples = num2-num1+1;
    if numOfClassSamples>numOfSamples % ���㹻������
        numOfClasses = numOfClasses+1; % �ҵ�һ���ϸ����
        classLabels(numOfClasses)=num1;% ��¼��ĵ�һ������λ�� 
    end
end

for cc=1:numOfClasses
    numOfFirst = classLabels(cc);
    for ss=1:numOfSamples        
        path=[pathPrefix 'image_' num2str(numOfFirst+ss-1, '%04d') '.jpg'];
        colored=imread(path);
        halfSample =imresize(colored,0.5); % ѹ����С
        inputData(cc,ss,:,:) = rgb2gray(halfSample);
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