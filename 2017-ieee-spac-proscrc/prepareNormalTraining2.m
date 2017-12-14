% prepareNormalTraining.m
%

clear trainData;
clear testData;

%% determine the size of data
%tempSample = double(inputData(:,1))';
%tempData = tempSample/norm(tempSample);
%[one, dataCols] = size(tempData);
%trainData = zeros(numOfClass*numOfTrain,dataCols);
%testData = zeros(numOfAllSamples-numOfClasses*numOfTrain,dataCols);
%clear tempSample; clear tempData;
fprintf('numOfAllTrainingSamples=%d,\tnumOfAllTestSamples=%d\n', numOfClasses*numOfTrain,numOfAllSamples-numOfClasses*numOfTrain);

%% prepare samples for training and testing
lastIndex = 0;
testIndex = 0;
trainIndex = 0;
for cc=1:numOfClasses
    clear Ai;
    numOfClassSamples = eachClass(cc);
    for tt=lastIndex+1:lastIndex+numOfTrain
        if inputLabel(tt,1)==cc % read training data
            lastIndex = lastIndex+1;
            trainIndex = trainIndex+1;
            Ai = double(inputData(:,tt))';
            trainData(trainIndex,:)=Ai/norm(Ai);
            trainLabels(trainIndex)=cc;
        else % not enough training samples
            disp 'Error: Not enough samples.';
        end
    end
    clear Xi;
    for tt=lastIndex+1:lastIndex+numOfClassSamples-numOfTrain
        if inputLabel(tt,1)==cc % use rest samples as test samples
            lastIndex = lastIndex+1;
            testIndex = testIndex+1;
            Xi = inputData(:,tt)'; % X(i)
            if salt > 0 % 原始图像增加30%的椒盐噪声
                Xi = imnoise(Xi,'salt & pepper',salt);
            end
            Xi = double(Xi);
            testData(testIndex,:)=Xi(:)/norm(Xi(:));
            testLabels(testIndex)=cc;
        end
    end
end

