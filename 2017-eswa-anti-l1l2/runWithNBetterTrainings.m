% runWithNTrainings.m
% Run experiment with different number of training samples

G=[1e-2,1e-1,1e-3];
S=[1, 0.1];
[one, numG] = size(G);
[one, numS] = size(S);
%gama=1e-4;
%iterations=50;

clear resultOne;
for numOfTrain=minTrains:trainStep:maxTrains
    numOfTest = numOfSamples-numOfTrain;
    
    % perform classification without random training samples
    highest1 = 0;
    highest2 = 0;
    bestGamma = 0;
    bestSigma = 0;
    numOfCases = 0;
    for gii=1:numG
        gamma = G(1,gii);
        for sii=1:numS
            sigma=S(1,sii);
            % run classification
            numOfCases = numOfCases+1;
            DistinctiveSR_L1_100;
            resultOne(numOfCases,1)=gamma;
            resultOne(numOfCases,2)=sigma;
            resultOne(numOfCases,3)=accuracy1;
            resultOne(numOfCases,4)=accuracy2;
            % save results
            jsonFile = ['=' dbName '_' num2str(numOfTrain) '_g' num2str(gamma) ',s' num2str(sigma) ',salt' num2str(salt) '_' num2str(accuracy1) '.json'];
            dbJson = savejson('', [gamma,sigma,accuracy1,accuracy2], jsonFile);
            % save best results
            if highest1<accuracy1
                highest1=accuracy1;
                highest2=accuracy2;
                bestGamma = gii;
                bestSigma = sii;
            end
            % stop when improved
            if highest1>highest2
                break;
            end
        end
        % stop when improved
        if highest1>highest2
            break;
        end
    end
    % record results of all cases for one
    jsonFile = ['=' dbName '_' num2str(numOfTrain) '_salt' num2str(salt) '.json'];
    dbJson = savejson('', resultOne, jsonFile);
    % record best results
    accuracy1 = highest1;
    accuracy2 = highest2;
    result(numOfTrain,1)=G(1,bestGamma);
    result(numOfTrain,2)=S(1,bestSigma);
    result(numOfTrain,3)=accuracy1;
    result(numOfTrain,4)=accuracy2;
    result % print
    
    gamma = G(1,bestGamma);
    sigma = S(1,bestSigma);
    improve = (accuracy1-accuracy2)*100/accuracy2;
    
    if improve >= 0
        jsonFile = ['=' dbName '_' num2str(numOfTrain) '_g' num2str(gamma) ',s' num2str(sigma) '_+' num2str(improve,2) '%.json'];
    else
        jsonFile = ['=' dbName '_' num2str(numOfTrain) '_g' num2str(gamma) ',s' num2str(sigma) '_' num2str(improve,2) '%.json'];
    end
    dbJson = savejson('', result(numOfTrain,:), jsonFile);
end
if maxTrains > minTrains % record all results
    jsonFile = ['=' dbName '_' num2str(minTrains) '-' num2str(maxTrains) '-salt' num2str(salt) '.json'];
    dbJson = savejson('', result, jsonFile);
end