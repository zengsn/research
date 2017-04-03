% runWithNTrainings.m
% Run experiment with different number of training samples

for numOfTrain=minTrains:maxTrains
    numOfTest = numOfSamples-numOfTrain;
    
    % perform classification without random training samples
    DistinctiveSR_L1;     
    
    result(numOfTrain,1)=accuracy1;
    result(numOfTrain,2)=accuracy2;
    result % print
    
    improve = (accuracy1-accuracy2)*100/accuracy2;
    
    if improve >= 0
        jsonFile = ['=' dbName '_' num2str(numOfTrain) '_+' num2str(improve,2) '%.json'];    
    else
        jsonFile = ['=' dbName '_' num2str(numOfTrain) '_' num2str(improve,2) '%.json'];
    end
    dbJson = savejson('', result(numOfTrain,:), jsonFile);
end
if maxTrains > minTrains % record all results
    jsonFile = ['=' dbName '_' num2str(minTrains) '-' num2str(maxTrains) '.json'];
    dbJson = savejson('', result, jsonFile);
end