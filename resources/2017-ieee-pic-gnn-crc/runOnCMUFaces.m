% runOnCMUFaces.m
% CMU Faces���ʵ����� - Ѱ�����Ż��Ĳ���

clear all;
% ��������       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
dbName = 'CMUFaces';
pathPrefix='../datasets/cmufaces/';
firstSample=imread('../datasets/cmufaces/an2i/an2i_left_angry_open_2.pgm');
[row col]=size(firstSample);
numOfSamples=0; % 54
numOfClasses=0; % ��Ҫ�����ݽ��д���

% ��ȡĿ¼
subjects=dir(pathPrefix);
[numOfFiles, one] = size(subjects);
%sampleNames = struct; % ��¼���г��ֵ���������
subjectNames = cell(20,1);
allSampleNames = cell(100,1);
numOfAllNames = 0; % ���ҵ�������
for fii=1:numOfFiles % �����ļ�
    filename = subjects(fii).name;
    if isvarname(filename) % ��������ĸ��ͷ���ַ���
        numOfClasses = numOfClasses+1; % ��һ����
        subjectNames{numOfClasses}=filename;
        samples=dir([pathPrefix '/' filename]);
        [numOfClassSamples, one] = size(samples);        
        % ����ȫ�������е�����������
        for sii=1:numOfClassSamples % ��������
            imageName = samples(sii).name;
            imageName = strrep(imageName, '.pgm', '');
            if isvarname(imageName)
                sampleName = strrep(imageName, filename, '');
                if numOfAllNames==0
                    numOfAllNames = 1;
                    allSampleNames{numOfAllNames} = sampleName;
                else % �����������
                    hasSame = 0;
                    for snii=1:numOfAllNames  % ��������������
                        name = allSampleNames{snii};
                        if strcmp(sampleName, name) == 1 
                            hasSame = 1;
                            break; % ����
                        end
                    end
                    if hasSame == 0 % �ҵ�������
                        numOfAllNames = numOfAllNames+1;
                        allSampleNames{numOfAllNames} = sampleName;
                    end
                end
            end
        end
    end
end

% �ҵ�ȫ���඼�е���������
sampleNames = cell(50,1); % ʵ�ʲ�ֹ50��
for snii=1:numOfAllNames % �����������
    sampleName = allSampleNames{snii};
    allHave = 1; % ȫ������
    for cc=1:numOfClasses % ����������
        subjectName = subjectNames{cc};
        imageFile = [pathPrefix '/' subjectName '/' subjectName sampleName '.pgm'];
        if exist(imageFile, 'file') ~= 2
            allHave = 0; % û���������
            break;
        end
    end
    if allHave == 1 % ȫ������
        numOfSamples = numOfSamples+1;
        sampleNames{numOfSamples} = sampleName;
    end
end

% ��������
for cc=1:numOfClasses
    subjectName = subjectNames{cc};
    for ss=1:numOfSamples   
        sampleName = sampleNames{ss};
        imageFile = [pathPrefix subjectName '/' subjectName sampleName '.pgm'];
        sampleData=imread(imageFile);
        halfSample =imresize(sampleData,[60 64]); % ѹ����С
        inputData(cc,ss,:,:) = halfSample;
    end
end
inputData=double(inputData); % ���е���������


% ���ò���       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % �Ƿ��Ż����
minTrains = 1;  % ѵ��������
maxTrains = 8;  % ѵ��������
numOfStep = 1;  % ѵ��������ѭ������
Gabor_NN_CRC;   % ����ʵ��
disp('Test done!');