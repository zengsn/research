%% prepareTrainData
% Prepare training data
%inputLabel = gnd;
numOfAllSamples=size(inputLabel ,1);

% locate matrix for train and test data
trainData_0 = zeros(numOfClasses*numOfTrain, row*col);
testData    = zeros(numOfAllSamples-numOfClasses*numOfTrain,row*col);
clear trainLabel_0;
clear testLabel_0;
clear testLabel;

% record the number of samples belonging to each class
% in case of different samples in each class
eachClass=zeros(numOfClasses,1);
for ii=1:numOfClasses
    for jj=1:numOfAllSamples
        if(inputLabel(jj)==ii)
            eachClass(ii)=eachClass(ii)+1;
        end
    end %jj
end %ii

numOfSamples = min(eachClass);

idx1st=0; % index of 1st (training) sample of each class
idx1stTest=0; % index of 1st test sample of each class
% select training samples randomly
for jClass=1:numOfClasses
    % Random permutation the last n samples of each class
    %if numOfTrain>mFirstSamples % add random
    %    randIdx=randperm(eachClass(jClass)-mFirstSamples)+mFirstSamples;
    %    trainIndices_0 = [1:mFirstSamples,randIdx(1:numOfTrain-mFirstSamples)]; % relative indies
    %    testIndices_0  = [randIdx(numOfTrain-mFirstSamples+1:eachClass(jClass)-mFirstSamples)];
    %else % do not add random
    trainIndices_0 = [1:numOfTrain]; % no random
    testIndices_0  = [numOfTrain+1:eachClass(jClass)]; % no random
    %end
    %idx1st
    trainIndices=idx1st+trainIndices_0; % abosulte indies to all samples
    testIndices=idx1st+testIndices_0;   % abosulte indies to all samples
    
    temp1=inputData(:,trainIndices)';
    temp2=inputData(:,testIndices)';
    % original training data, may be changed later
    trainData_0(((jClass-1)*numOfTrain+1):((jClass-1)*numOfTrain+numOfTrain),:)=temp1;
    trainLabel_0(((jClass-1)*numOfTrain+1):((jClass-1)*numOfTrain+numOfTrain),1)=jClass;
    numOfRestSamples=eachClass(jClass,1)-numOfTrain; % 
    % original test data, not changed 
    testData(idx1stTest+1:idx1stTest+numOfRestSamples,:)=temp2;
    testLabel(idx1stTest+1:idx1stTest+numOfRestSamples,1)=jClass;
    idx1stTest=idx1stTest+(eachClass(jClass,1)-numOfTrain);
    idx1st=idx1st+eachClass(jClass);
end % j

%--------------------------------------------------
numOfAllTrain = size(trainData_0,1); % total traning samples
maxSizeOfDict = numOfAllTrain; % this usually the best size

% for iTran=1:numOfAllTrain
%     % resulted training data
%     trainData(2*iTran-1,:)=trainData_0(iTran,:);
%     tempory=trainData_0(iTran,:);
%     tempory1=reshape(tempory,row,col);
%     for iCol=1:col % revert the image
%         tempory2(:,col-iCol+1)=tempory1(:,iCol);
%     end
%     tempory3=reshape(tempory2,row*col,1);
%     trainData(2*iTran,:)=tempory3(:);
% end
% 
% for iTran=1:numOfAllTrain
%     trainLabel(2*iTran-1)=trainLabel_0(iTran);
%     trainLabel(2*iTran)=trainLabel_0(iTran);
% end

% prepare for representation
for kk=1:size(trainData_0,1)
    trainData_0(kk,:)=trainData_0(kk,:)/norm(trainData_0(kk,:));
end
% for kk=1:size(trainData,1)
%     trainData(kk,:)=trainData(kk,:)/norm(trainData(kk,:));
% end

trainData = trainData_0;
trainLabel = trainLabel_0;
trainIndices = trainIndices_0;

%--------------------------------------------------------------------------

for kkk=1:size(testData,1)
    testData(kkk,:)=testData(kkk,:)/norm(testData(kkk,:));
end

numOfClasses; %