% runWithNCrossValidation.m
% Run experiment with different number of training samples
% Cross Validation: https://en.wikipedia.org/wiki/Cross-validation_(statistics)

% number of parts to divide
% numOfParts = 3;

% record original data
numOfTest  = floor(numOfSamples / numOfParts);
numOfTrain = numOfSamples - numOfTest;

% randomly divide the samples 
randomIndies = randperm(numOfSamples);

errorsRatioSRCAvg = 0;
errorsRatioCRCAvg = 0;
errorsRatioFusionAvg = 0;

for pp=1:numOfParts
    % select random samples for test
    %fprintf('Tests: ');
    testIndies = randomIndies(1,(pp-1)*numOfTest+1:pp*numOfTest);
    for cc=1:numOfClasses
        clear Ai;
        for tt=1:numOfTest
            index = testIndies(1,tt);
            %fprintf('%d ', index);
            Xi(1,:)=inputData(cc,index,:); % X(i)
            testData((cc-1)*numOfTest+tt,:)=Xi/norm(Xi);
        end
    end
    %fprintf('\n');
    % prepare samples for training
    %fprintf('Trains: ');
    for cc=1:numOfClasses
        clear Xi;
        index = 0;
        for tt=1:numOfSamples 
            if isempty(find(testIndies==tt)) % not test sample
                %fprintf('%d ', tt);
                Ai(1,:)=inputData(cc,tt,:); % A(i)
                index = index + 1; % found one
                trainData((cc-1)*numOfTrain+index,:)=Ai/norm(Ai);
            end
        end
        %fprintf('\n');
    end

    % perform classification
    Multiplication2;

    % process results
    result(pp,1)=errorsRatioSRC;
    result(pp,2)=errorsRatioCRC;
    result(pp,3)=errorsRatioFusion;
    result % print

    % sum results
    errorsRatioSRCAvg = errorsRatioSRCAvg+errorsRatioSRC;
    errorsRatioCRCAvg = errorsRatioCRCAvg+errorsRatioCRC;
    errorsRatioFusionAvg = errorsRatioFusionAvg+errorsRatioFusion;

end

errorsRatioSRCAvg = errorsRatioSRCAvg/numOfParts;
errorsRatioCRCAvg = errorsRatioCRCAvg/numOfParts;
errorsRatioFusionAvg = errorsRatioFusionAvg/numOfParts;
result(numOfParts+1,1)=errorsRatioSRCAvg;
result(numOfParts+1,2)=errorsRatioCRCAvg;
result(numOfParts+1,3)=errorsRatioFusionAvg;
result % print
    
improveSRC = (errorsRatioSRCAvg-errorsRatioFusionAvg)*100/errorsRatioSRCAvg;
improveCRC = (errorsRatioCRCAvg-errorsRatioFusionAvg)*100/errorsRatioCRCAvg;
    
if errorsRatioFusionAvg<errorsRatioSRCAvg && errorsRatioFusionAvg<errorsRatioCRCAvg
    jsonFile = ['=' dbName '_' num2str(numOfParts) 'Fold_s+' num2str(improveSRC,2) '%_c+' num2str(improveCRC,2) '%'];
elseif errorsRatioFusionAvg<errorsRatioSRCAvg
    jsonFile = ['=' dbName '_' num2str(numOfParts) 'Fold_s+' num2str(improveSRC,2) '%_c' num2str(improveCRC,2) '%'];
elseif errorsRatioFusionAvg<errorsRatioCRCAvg
    jsonFile = ['=' dbName '_' num2str(numOfParts) 'Fold_s' num2str(improveSRC,2) '%_c+' num2str(improveCRC,2) '%'];
else
    jsonFile = ['=' dbName '_' num2str(numOfParts) 'Fold_s' num2str(improveSRC,2) '%_c' num2str(improveCRC,2) '%'];
end

% save result to json file !!! need json toolbox
dbJson = savejson('', result, [jsonFile '.json']);
% save sample order for reference
dbJson = savejson('', randomIndies, [jsonFile '_samples.json']);
