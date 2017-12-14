% LFW-a

clear all;

dbName = 'LFWA';
scale = 0.2;
pathPrefix='./datasets/lfw-a/';
firstSample=imread('./datasets/lfw-a/Aaron_Eckhart/Aaron_Eckhart_0001.jpg');
halfSample =imresize(firstSample,scale); % ????????
%[row col]=size(rgb2gray(halfSample));
[row col]=size(halfSample);
numOfSamples=11; % ????5????????????
numOfClasses=0; % ????????????????
indiesOfClasses = []; % ????????????
% ??????5????????????
fileID = fopen('./datasets/lfw-names.txt');
namesAndImages = textscan(fileID,'%s %d');
fclose(fileID);
names = namesAndImages{1,1};
nums = namesAndImages{1,2};
[nRow, nCol] = size(names);
for jj=1:nRow % ????????????
    numOfImages = nums(jj);
    if numOfImages >= numOfSamples  % ????????????
        numOfClasses = numOfClasses + 1;
        indiesOfClasses(numOfClasses)=jj;
        eachClass(numOfClasses)=numOfImages;
    end
end

index = 0;
for cc=1:numOfClasses
    for ss=1:eachClass(cc) %numOfSamples
        index=index+1;
        indexOfClass = indiesOfClasses(cc); %disp(indexOfClass);
        %path=[pathPrefix names(indexOfClass) '/' names(indexOfClass) '_' num2str(ss, '%04d') '.jpg'];
        path=strcat(pathPrefix,names(indexOfClass),'/',names(indexOfClass),'_',num2str(ss, '%04d'),'.jpg');
        colored=imread(path{1});
        %grayed=double(rgb2gray(colored));
        %grayed=double(colored);
        grayed=colored;
        oneSample= imresize(grayed(:,:),scale); % ????????
        columniation = reshape(oneSample, row*col, 1);
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % all input data

disp('Data is ready!');