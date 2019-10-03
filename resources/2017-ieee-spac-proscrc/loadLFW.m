% runOnLFW_Better.m
% LFW???????????? - ????????????????


% ????????       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbName = 'LFW';
scale = 0.5;
pathPrefix='./datasets/lfw-deepfunneled/';
firstSample=imread('./datasets/lfw-deepfunneled/Aaron_Eckhart/Aaron_Eckhart_0001.jpg');
halfSample =imresize(firstSample,scale); % ????????
[row col]=size(rgb2gray(halfSample));
numOfSamples=30; % ????5????????????
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
    end
end

for cc=1:numOfClasses
    for ss=1:numOfSamples
        indexOfClass = indiesOfClasses(cc); %disp(indexOfClass);
        %path=[pathPrefix names(indexOfClass) '/' names(indexOfClass) '_' num2str(ss, '%04d') '.jpg'];
        path=strcat(pathPrefix,names(indexOfClass),'/',names(indexOfClass),'_',num2str(ss, '%04d'),'.jpg');
        colored=imread(path{1});
      %  grayed=double(rgb2gray(colored));
        
%         inputData(cc,ss,:,:)= imresize(grayed(:,:),scale); % ????????
%         index = (cc-1)*numOfSamples + ss;
%        
%         inputLabel(index,1) = cc;
         grayed=rgb2gray(colored);
         grayed=imresize(grayed,scale);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % all input data

disp('data done!');