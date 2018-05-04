%% prepareTrainDataDeep.m
% Prepare training data

numOfAllSamples=size(inputLabel ,1);
clear trainData;
clear trainData_0;
clear trainLabel_0;
clear testLabel_0;
clear testData;
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

% load deep data
h5Prefix = dbName;
if strcmp(deepModel,'ResNet_v1_101.logits') % ResNet_v1_101
    layerName='/resnet_v1_101/logits';
elseif strcmp(deepModel,'ResNet_v1_101.global_pool') % ResNet_v1_101
    layerName='/global_pool';
elseif strcmp(deepModel,'ResNet_v2_101')% ResNet_v2_101
    layerName='/resnet_v2_101/logits';
elseif strcmp(deepModel,'Inception_v4') % Inception-v4
    layerName='/Logits';
elseif strcmp(deepModel,'FaceNet') % Inception-v4
    layerName='/dataset';
    h5Prefix = [dbName '_mtcnnpy_160'];
else
    disp(['Unknown model: ' deepModel]);
end
h5File = ['.' lower(deepModel) '.h5'];
path = '../../Lab0_Data/';
%path = '/Volumes/SanDisk128B/datasets-h5/';
% - original
if strcmp(deepModel,'FaceNet')
    h5o = [h5Prefix h5File]; % h5 file for original images
    h5v = [h5Prefix '_v' h5File]; % h5 file for virtual images
elseif ~exist('h5Row','var')
    h5o   = [h5Prefix '_' num2str(row) 'x' num2str(col) h5File];
    h5v   = [h5Prefix '_m_' num2str(row) 'x' num2str(col) h5File];
else % different size of deep features
    h5o   = [h5Prefix '_' num2str(h5Row) 'x' num2str(h5Col) h5File];
    h5v   = [h5Prefix '_m_' num2str(h5Row) 'x' num2str(h5Col) h5File];
end
dbName_o = dbName;
dbName   = [dbName '.' deepModel];
% deep features of original images 
h5Data = h5read([path h5o], layerName);
h5disp([path h5o], layerName);
dim = size(h5Data,1);
dimOfData = size(size(h5Data),2);
% deep features of virtual images 
h5DataV = h5read([path h5v], layerName);
h5disp([path h5v], layerName);
clear inputDataDeep;
clear inputDataDeepV;
% read data
if dimOfData==2
    for ii=1:numOfAllSamples
        inputDataDeep(:,ii)=h5Data(:,ii);
        inputDataDeepV(:,ii)=h5DataV(:,ii);
    end
elseif dimOfData==4
    for ii=1:numOfAllSamples
        inputDataDeep(:,ii)=h5Data(:,1,1,ii);
        inputDataDeepV(:,ii)=h5DataV(:,1,1,ii);
    end
else
    disp('Unknown dim of data.');
end
clear h5Data;
clear h5DataV;

% locate matrix for train and test data
dimDeep = size(inputDataDeep,1);
trainData_0 = zeros(numOfClasses*numOfTrain, dimDeep);
testData    = zeros(numOfAllSamples-numOfClasses*numOfTrain,dimDeep);

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
    trainIndices=idx1st+trainIndices_0; % abosulte indies to all samples
    testIndices=idx1st+testIndices_0;   % abosulte indies to all samples
    
    % original data
    temp1=inputDataDeep(:,trainIndices)';
    temp2=inputDataDeep(:,testIndices)';
    % original training data, may be changed later
    trainData_0(((jClass-1)*numOfTrain+1):((jClass-1)*numOfTrain+numOfTrain),:)=temp1;
    trainLabel_0(((jClass-1)*numOfTrain+1):((jClass-1)*numOfTrain+numOfTrain),1)=jClass;
    % mirror data
    temp1=inputDataDeepV(:,trainIndices)';
    trainDataV_0(((jClass-1)*numOfTrain+1):((jClass-1)*numOfTrain+numOfTrain),:)=temp1;
    % 
    numOfRestSamples=eachClass(jClass,1)-numOfTrain; % 
    % original test data, not changed 
    testData(idx1stTest+1:idx1stTest+numOfRestSamples,:)=temp2;
    testLabel(idx1stTest+1:idx1stTest+numOfRestSamples,1)=jClass;
    idx1stTest=idx1stTest+(eachClass(jClass,1)-numOfTrain);
    idx1st=idx1st+eachClass(jClass);
end % j

%--------------------------------------------------
numOfAllTrain = size(trainData_0,1); % total traning samples
%maxSizeOfDict = numOfAllTrain; % this usually the best size

% generate virtual samples
for iTran=1:numOfAllTrain
    % resulted training data
    trainData(2*iTran-1,:)=trainData_0(iTran,:);
    trainData(2*iTran,:)  =trainDataV_0(iTran,:);
end
 
for iTran=1:numOfAllTrain
    trainLabel(2*iTran-1,1)=trainLabel_0(iTran);
    trainLabel(2*iTran,1)=trainLabel_0(iTran);
end

% prepare for representation
for kk=1:size(trainData_0,1)
    trainData_0(kk,:)=trainData_0(kk,:)/norm(trainData_0(kk,:));
end
for kk=1:size(trainData,1)
    trainData(kk,:)=trainData(kk,:)/norm(trainData(kk,:));
end

trainIndices = trainIndices_0;

%--------------------------------------------------------------------------

for kkk=1:size(testData,1)
    testData(kkk,:)=testData(kkk,:)/norm(testData(kkk,:));
end

numOfClasses; %