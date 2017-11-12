% timeDL.m
% Evaluate the time of dictionary learning only

addpath(genpath('../../Lab4_Benchmark/FISTA'));
addpath(genpath('../../Lab4_Benchmark/OMP'));
addpath(genpath('../lcle-dl/ksvdbox'));  % add K-SVD box
addpath(genpath('../lcle-dl/OMPbox')); % add sparse coding algorithem OMP
%sparsityThres = 40; % sparsity prior
%iterations = 10; % iteration number
%iterations4init =1; % iteration number for initialization
%numOfClasses=143;
%knn=2;
%alpha=1e-1;
%beta=1e-1;
%gamma=1e-1;

% Prepare for LCKSVD
[numOfAllTrain,at]=size(trainLabel);
[numOfAllTest,bt]=size(testLabel);
hTest=zeros(numOfClasses,numOfAllTest);   % sparse matrix ?
hTrain=zeros(numOfClasses,numOfAllTrain); % sparse matrix ?
for jTran=1:numOfAllTrain
    a=trainLabel(jTran);
    hTrain(a,jTran)=1;
end
for jTest=1:numOfAllTest
    b=testLabel(jTest);
    hTest(b,jTest)=1;
end

% dictionary learning 
% sizeOfDict = numOfClasses;
disp('dictionary learning ...');

% start time
tic

[dInit,tInit,cInit,qTrain,xInit,dLabel] = initialization4LCKSVD(trainData',hTrain,sizeOfDict,iterations4init,sparsityThres);
[Q]=construct_Q(dLabel);
[D,X,V] = Learn_D_X(xInit,dInit,Q,alpha,beta,gamma,trainData,knn,iterations);
Wx = inv(X*X'+eye(size(X*X')))*X*hTrain';
Wx = Wx';
Wx=normcols(Wx);
G = D'*D;
gammaOMP = omp(D'*testData',G,sparsityThres);

% calculate deviations
deviationsDL = zeros(numOfAllTest,numOfClasses);
% Sparse representation
errorsSRC=0; errorsDL=0; 
for kk=1:numOfAllTest
    testSample=testData(kk,:);   
    % deviation by DL
    clear deviationDL;
    spcode = gammaOMP(:,kk);
    deviationDL = (Wx * spcode)';
    deviationsDL(kk,:)=deviationDL;
    % recognition DL
    [min_value labelDL]=max(deviationDL); % max
    if labelDL ~= testLabel(kk,1)
        errorsDL=errorsDL+1;
    end
end
fprintf('\n');
% result by SRC and DL
accuracyDL = 1-errorsDL/numOfAllTest;

% record time
time=toc; % pring
fprintf('\nTests=%d (samples),\ttime=%.3f (s),\tspeed=%.3f(s/sample)\n', numOfAllTest,time,time/numOfAllTest);

% save to json
type = 'time_DL';
jsonFile = [dbName '/' type '_' num2str(numOfTrain) '_' num2str(sizeOfDict) '_' ];
jsonFile = [jsonFile num2str(numOfAllTest) ',' num2str(time,'%.3f') '=' num2str(time/numOfAllTest,'%.3f')];
jsonFile = [jsonFile  '.json'];
results = [numOfAllTest, accuracyDL, time, time/numOfAllTest];
dbJson = savejson('', results, jsonFile);