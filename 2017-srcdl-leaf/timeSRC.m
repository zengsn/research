% timeSRC.m
% Evaluate the time of SRC only

addpath(genpath('../../Lab4_Benchmark/FISTA'));
addpath(genpath('../../Lab4_Benchmark/OMP'));

[numOfAllTrain,at]=size(trainLabel);
[numOfAllTest,bt]=size(testLabel);

% calculate deviations
deviationsSRC = zeros(numOfAllTest,numOfClasses);
% Sparse representation
errorsSRC=0; errorsDL=0;
disp('sparse learning ...');

% start time
tic

for kk=1:numOfAllTest
    testSample=testData(kk,:);
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
end
fprintf('\n');
% result by SRC and DL
accuracySRC = 1-errorsSRC/numOfAllTest;

% record time
time=toc; % print
fprintf('\nTests=%d (samples),\ttime=%.3f (s),\tspeed=%.3f(s/sample)\n', numOfAllTest,time,time/numOfAllTest);

% save to json
type = 'time_SRC';
jsonFile = [dbName '/' type '_' num2str(numOfTrain) '_' num2str(numOfAllTest) ',' num2str(time,'%.3f') '=' num2str(time/numOfAllTest,'%.3f')];
jsonFile = [jsonFile  '.json'];
results = [numOfAllTest, accuracySRC, time, time/numOfAllTest];
dbJson = savejson('', results, jsonFile);