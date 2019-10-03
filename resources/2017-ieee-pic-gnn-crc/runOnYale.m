% runOnYale.m
% Yale���ʵ����� - Ѱ�����Ż��Ĳ���

clear all;
% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'Yale';
pathPrefix='../datasets/yalefaces/';
firstSample=imread('../datasets/yalefaces/subject01.centerlight');
[row col]=size(firstSample);
numOfSamples=11;
numOfClasses=15;

for cc=1:numOfClasses
    for ss=1:numOfSamples
        types=cell(11,1);
        types{1}='centerlight';     types{2}='glasses';     types{3}='happy';
        types{4}='leftlight';       types{5}='noglasses';   types{6}='normal';
        types{7}='rightlight';      types{8}='sad';         types{9}='sleepy';
        types{10}='surprised';      types{11}='wink';
        path=[pathPrefix 'subject' num2str(cc, '%02d') '.' types{ss}];
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