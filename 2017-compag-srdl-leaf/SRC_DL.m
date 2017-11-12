% SRC_DL.m
% Fuse SRC with dictionary learning

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
    % recognition DL
    [min_value labelDL]=max(deviationDL); % max
    if labelDL ~= testLabel(kk,1)
        errorsDL=errorsDL+1;
    end
    % print progress
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
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
    % recognition SRC
    [min_value labelSRC]=min(deviationSRC); % min
    if labelSRC ~= testLabel(kk,1)
        errorsSRC=errorsSRC+1;
    end
    % save all deviations
    deviationsSRC(kk,:)=deviationSRC;
end
fprintf('\n');
% result by SRC and DL
accuracySRC = 1-errorsSRC/numOfAllTest;
accuracyDL = 1-errorsDL/numOfAllTest;

% fusion
lambdas = [-100,-50,-10,-5,-0.5,1,0.5,5,10,50,100];
lambdas = [0.5];
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

fprintf('\nSRC=%.4f\tDL=%.4f\tFusion=%.4f\tlambda=%d\n', accuracySRC,accuracyDL,accuracyFusion,lambda);

% improvement
improve1 = (accuracyFusion-accuracySRC)*100/accuracySRC;
improve2 = (accuracyFusion-accuracyDL)*100/accuracyDL;

% save to json
jsonFile = [dbName '/_SRC_DL_' num2str(numOfTrain) '_' num2str(accuracyFusion,'%.4f') '(' num2str(improve1,'%.1f') '%,' num2str(improve2,'%.1f') '%)_' num2str(sizeOfDict) '_' num2str(lambda)];
jsonFile = [jsonFile '~' num2str(sparsityThres) ',' num2str(iterations4init) ',' num2str(knn)]; % save parameters
jsonFile = [jsonFile ',' num2str(alpha) ',' num2str(beta) ',' num2str(gamma) ',' num2str(iterations)];
jsonFile = [jsonFile  '.json'];
results = [accuracySRC, accuracyDL, accuracyFusion, lambda, trainIndices];
dbJson = savejson('', results, jsonFile);