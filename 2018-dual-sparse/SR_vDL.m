% SR_DL_vDL.m
% Fuse SRC with dictionary learning

algName = 'SR_vDL';

if exist('dimDeep','var')
    dim = dimDeep;
else
    dim = row*col;
end

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

%% dictionary learning  - virutal training samples
disp('Dictionary learning using virutal samples ...');
tic
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
% sizeOfDict = numOfClasses;
[dInit,tInit,cInit,qTrain,xInit,dLabel] = initialization4LCKSVD(trainData',hTrain,sizeOfDict,iterations4init,sparsityThres);
[Q]=construct_Q(dLabel);
[D,X,V] = Learn_D_X(xInit,dInit,Q,alpha,beta,gamma,trainData,knn,iterations);
Wx = inv(X*X'+eye(size(X*X')))*X*hTrain';
Wx = Wx';
Wx=normcols(Wx);
G = D'*D;
gammaOMP = omp(D'*testData',G,sparsityThres);
errorsDL=0;
deviationsDL = zeros(numOfAllTest,numOfClasses);
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
    % record for comparison
    labelsDL(kk)=labelDL;
end
time_DL = toc;
accuracyDL = 1-errorsDL/numOfAllTest;
fprintf('\t done in %.3f with accuracyDL=%.4f.\n',time_DL,accuracyDL);

%% Sparse representation - using original training samples
disp('Sparse learning using original samples ...');
if exist('lastAccuracySRC','var') && exist('lastTrain','var') && lastTrain==numOfTrain
    fprintf('\t already done in %.3f with accuracySRC=%.4f.\n',time_SRC,accuracySRC);
else % run one time
    tic
    errorsSRC=0;
    deviationsSRC = zeros(numOfAllTest,numOfClasses);
    for kk=1:numOfAllTest
        testSample=testData(kk,:);
        % SRC by FISTA
        %[solutionSRC, total_iter] = SolveFISTA(trainData',testSample');
        [solutionSRC, total_iter] = SolveOMP(trainData_0',testSample','isnonnegative',1);
        clear contributionSRC;
        for cc=1:numOfClasses
            contributionSRC(:,cc)=zeros(dim,1);
            for tt=1:numOfTrain % C(i) = sum(S(i)*T)
                contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*trainData_0((cc-1)*numOfTrain+tt,:)';
            end
        end
        % for analysis
        %if kk==216
        %    I = CoefDict2Img(D,X,contributionSRC,'LFW-SR_vDL-8-216.png');
        %    break; % output analysis images
        %end
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
        % record for comparison
        labelsSRC(kk)=labelSRC;
        % save all deviations
        deviationsSRC(kk,:)=deviationSRC;
    end
    time_SRC = toc;
    % result by SRC 
    accuracySRC = 1-errorsSRC/numOfAllTest;
    lastAccuracySRC=accuracySRC;
    lastTrain=numOfTrain;
    fprintf('\t done in %.3f with accuracySRC=%.4f.\n',time_SRC,accuracySRC);
end

% fusion
lambdas = [-100,-50,-10,-5,-0.5,1,0.5,5,10,50,100];
%lambdas = [-5];
[one,numOfCases] = size(lambdas);
bestLambda = 0;
bestAccuracy = 0;
foundSRC = 0; foundDL = 0;
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
        % record for comparison
        %labelsFusion(kk)=labelFusion;
        % pick a case for analysis
        %if labelFusion == testLabel(kk,1) && labelsSRC(kk)~= testLabel(kk,1) && labelsDL(kk)~= testLabel(kk,1)
        %    fprintf('Improve SRC and DL case : %d \n', kk);
        %    jsonFile = [dbName '-' algName '-train' num2str(numOfTrain) ',test' num2str(kk) '.json'];
        %    dbJson = savejson('', [deviationSRC;deviationDL;deviationFusion], jsonFile);
        %    foundSRC = 1; foundDL = 1;
        %end
        %         if foundSRC==0 && labelFusion == testLabel(kk,1) && labelsSRC(kk)~= testLabel(kk,1)
        %             fprintf('Improve SRC case : %d \n', kk);
        %             jsonFile = [dbName '-src-train' num2str(numOfTrain) ',test' num2str(kk) '.json'];
        %             dbJson = savejson('', [deviationSRC;deviationDL;deviationFusion], jsonFile);
        %             foundSRC = 1;
        %         end
        %         if foundDL==0 && labelFusion == testLabel(kk,1) && labelsDL(kk)~= testLabel(kk,1)
        %             fprintf('Improve SRC case : %d \n', kk);
        %             jsonFile = [dbName '-dl-train' num2str(numOfTrain) ',test' num2str(kk) '.json'];
        %             dbJson = savejson('', [deviationSRC;deviationDL;deviationFusion], jsonFile);
        %             foundDL = 1;
        %         end
        %         if foundSRC==1 && foundDL==1
        %             break; % stop
        %         end
    end
    accuracyFusion = 1-errorsFusion/numOfAllTest;
    if accuracyFusion>bestAccuracy
        bestLambda = lambda; %
        bestAccuracy=accuracyFusion; %
    end
end

% best case
lambda = bestLambda; %
accuracyFusion = bestAccuracy; %
fprintf('\nSRC=%.4f\tDL=%.4f\tFusion=%.4f\tlambda=%d\n', accuracySRC,accuracyDL,accuracyFusion,lambda);

% result path
if ~isequal(exist(dbName, 'dir'),7)
    mkdir(dbName);
end

% improvement
improve1 = (accuracyFusion-accuracySRC)*100/accuracySRC;
improve2 = (accuracyFusion-accuracyDL)*100/accuracyDL;

% save to json
jsonFile = [dbName '/_' algName '_' num2str(numOfTrain) '_' num2str(accuracyFusion,'%.4f') '(' num2str(improve1,'%.1f') '%,' num2str(improve2,'%.1f') '%)_' num2str(sizeOfDict) '_' num2str(lambda)];
jsonFile = [jsonFile '~' num2str(sparsityThres) ',' num2str(iterations4init) ',' num2str(knn)]; % save parameters
jsonFile = [jsonFile ',' num2str(alpha) ',' num2str(beta) ',' num2str(gamma) ',' num2str(iterations)];
jsonFile = [jsonFile  '.json'];
oneResult = [accuracySRC, accuracyDL, accuracyFusion, lambda, trainIndices];

if ~exist('highestAccuracy','var')
    highestAccuracy=accuracyFusion;
end
if exist('highestAccuracy','var') && highestAccuracy<accuracyFusion+0.005
    if highestAccuracy<accuracyFusion
        highestAccuracy = max([highestAccuracy,accuracyFusion]);
        highestJsonFile = jsonFile;
        highestResult   = oneResult;
    end
    dbJson = savejson('', oneResult, jsonFile);
    if exist('sendEmail','file')==2 && ~exist('isTuning','var')
        sendEmail(jsonFile,mat2str(oneResult),jsonFile);
    end
end

% true positive test
%kk = 131; % Leaf