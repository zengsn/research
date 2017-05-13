% runWithNTrainings.m
% Run experiment with different number of training samples

for numOfTrain=minTrains:maxTrains
    numOfTest = numOfSamples-numOfTrain;
    %kernelRepresentation; % classification
    kernelCoarseToFine; % classification
    
    result(numOfTrain,1)=bestKernelCandidate;
    result(numOfTrain,2)=errorsRatio1;
    result(numOfTrain,3)=errorsRatio2;
    result % print
    
    if errorsRatio1>=errorsRatio2
        candidate = result(numOfTrain,1);
        improveRate = (errorsRatio1-errorsRatio2)*100/errorsRatio1;
        jsonFile = ['+' dbName '_t' num2str(numOfTrain) '_s' num2str(candidate) '_' num2str(improveRate,2) '%.json'];
        dbJson = savejson('', result(numOfTrain,:), jsonFile);
        % record all cases
        jsonFile = ['+' dbName '_t' num2str(numOfTrain) '_' num2str(errorsRatio1) '.json'];
        dbJson = savejson('', errorsRatioKernelCF, jsonFile);
        errorsRatioKernelCF
    end
end

jsonFile = ['~' dbName '.json'];
dbJson = savejson('', result, jsonFile);