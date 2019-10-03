%% loadMUCTCropRGBo3.m
% MUCT data with landmarks, already aligned and croped.
% Samples over 3

loadMUCTCropRGB;

dbName = 'MUCTCropRGBo3';

numOfClasses=max(inputLabel);%276; % total classes
numOfAllSamples=size(inputLabel ,1);
eachClass=zeros(numOfClasses,1);
for ii=1:numOfClasses
    for jj=1:numOfAllSamples
        if(inputLabel(jj)==ii)
            eachClass(ii)=eachClass(ii)+1;
        end
    end %jj    
end %ii
% select classes with 3+ samples in each camera
indexOfSample = 0;
indexOfLabel  = 0;
for ii=1:numOfClasses
    if eachClass(ii)==15 % 3*5
        indexOfLabel=indexOfLabel+1;
        for jj=1:numOfAllSamples
            if(inputLabel(jj)==ii)
                indexOfSample = indexOfSample+1;
                inputDataO3(:,indexOfSample)  =inputData(:,jj);
                inputLabel03(indexOfSample,1) =indexOfLabel;
                %landmarks03(indexOfSample,:)  =landmarks(jj,:);
            end
        end %jj
    end   
end %ii

inputData = inputDataO3;
inputLabel= inputLabel03;
%landmarks = landmarks03;
numOfClasses=max(inputLabel);%199; % total classes
numOfAllSamples=size(inputLabel ,1);

minSamples=15;  % the number of samples per class
mFirstSamples=5;  % The first m images of each class