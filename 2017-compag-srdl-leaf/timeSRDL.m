% timeSRDL.m
% Evaluate the time of sparse + dictionary learning 

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
deviationsSRC = zeros(numOfAllTest,numOfClasses);
deviationsDL = zeros(numOfAllTest,numOfClasses);
% Sparse representation
errorsSRC=0; errorsDL=0; 
disp('sparse learning ...');
for kk=1:numOfAllTest
    testSample=testData(kk,:);   
    % deviation by DL
    clear deviationDL;
    spcode = gammaOMP(:,kk);
    deviationDL = (Wx * spcode)';
    deviationsDL(kk,:)=deviationDL;
    % SRC by FISTA
    %[solutionSRC, total_iter] = SolveFISTA(trainData',testSample');
    [solutionSRC, total_iter] = SolveOMP(trainData',testSample','isnonnegative',1);
    clear contributionSRC;
    for cc=1:numOfClasses
        contributionSRC(:,cc)=zeros(row*col,1);
        for tt=1:numOfTrain % C(i) = sum(S(i)*T)
            contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    % deviation by SRC
    clear deviationSRC;
    for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
        %deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc))/norm(solutionCRC);
        deviationSRC(cc)=norm(testSample'-contributionSRC(:,cc)); % same
    end
    % save all deviations
    deviationsSRC(kk,:)=deviationSRC;
end
fprintf('\n');

% fusion
lambdas = [-100,-50,-10,-5,-0.5,1,0.5,5,10,50,100];
lambdas = [1];
[one,numOfCases] = size(lambdas);
bestLambda = 0;
bestAccuracy = 0;
for cii=1:numOfCases
    lambda = lambdas(cii); % -10 for LFW
    errorsFusion=0;
    for kk=1:numOfAllTest
        deviationSRC = deviationsSRC(kk,:);
        deviationDL  = deviationsDL(kk,:);
        deviationFusion = deviationSRC+lambda*deviationDL;
        [min_value labelFusion]=min(deviationFusion);
        if labelFusion ~= testLabel(kk,1)
            errorsFusion=errorsFusion+1;
        end
    end    
    accuracyFusion = 1-errorsFusion/numOfAllTest;
    if accuracyFusion>bestAccuracy
        bestLambda = lambda %
        bestAccuracy=accuracyFusion %
    end
end

% best case
lambda = bestLambda; %
accuracyFusion = bestAccuracy; %

% record time
time=toc; % pring
fprintf('\nTests=%d (samples),\ttime=%.3f (s),\tspeed=%.3f(s/sample)\n', numOfAllTest,time,time/numOfAllTest);

% save to json
type = 'time_SRDL';
jsonFile = [dbName '/' type '_' num2str(numOfTrain) '_' num2str(sizeOfDict) '_' ];
jsonFile = [jsonFile num2str(numOfAllTest) ',' num2str(time,'%.3f') '=' num2str(time/numOfAllTest,'%.3f')];
jsonFile = [jsonFile  '.json'];
results = [numOfAllTest, accuracyFusion, time, time/numOfAllTest];
dbJson = savejson('', results, jsonFile);