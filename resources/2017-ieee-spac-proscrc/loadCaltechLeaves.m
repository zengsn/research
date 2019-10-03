% runOnCaltechLeaves_Better.m
% Caltech Face?????? - ????????

clear all;
% ????       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
dbName = 'Caltech_Leaves';
pathPrefix='./datasets/caltech_leaves/';
firstSample=imread('./datasets/caltech_leaves/image_0001.jpg');
halfSample =imresize(firstSample,0.5); % ????
[row col]=size(rgb2gray(halfSample));
numOfSamples=10;
numOfClasses=0; % ?????????

% ??????
labelFile = [pathPrefix 'labels.txt']; % ????
fid = fopen(labelFile);
labelData = textscan(fid, '%d %d', 'delimiter', ',');
fclose(fid);
[numOfLines, two] = size(labelData{1});

for lii=1:numOfLines % ?????
    num1=labelData{1}(lii);
    num2=labelData{2}(lii);
    numOfClassSamples = num2-num1+1;
    if numOfClassSamples>numOfSamples % ??????
        numOfClasses = numOfClasses+1; % ????????
        classLabels(numOfClasses)=num1;% ??????????? 
    end
end

for cc=1:numOfClasses
    numOfFirst = classLabels(cc);
    for ss=1:numOfSamples        
        path=[pathPrefix 'image_' num2str(numOfFirst+ss-1, '%04d') '.jpg'];
        colored=imread(path);
        halfSample =imresize(colored,0.5); % ????
        inputData(cc,ss,:,:) = rgb2gray(halfSample);
        index = (cc-1)*numOfSamples + ss;
        inputLabel(index,1) = cc;
    end
end
inputData=double(inputData); % ???????

% ????       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redoDeviation = 1; % ??????
minTrains = 1;  % ?????
maxTrains = 8;  % ?????
%abs_crc_lambda; % ????
disp('Test done!');