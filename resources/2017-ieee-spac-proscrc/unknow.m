numOfCases = 1;
%flavia case = 7
for cii=1:numOfCases
    lambda = 99;%lambdas(cii); % -10 for LFW
    errorsFusion=0;
    for kk=1:numOfAllTests
        deviationProCRC = deviationsProCRC(kk,:);
        deviationSRC = deviationsSRC(kk,:);
        deviationFusion = deviationProCRC+deviationSRC*lambda;
        [min_value labelFusion]=min(deviationFusion);
        if labelFusion ~= testLabel(kk,1)
            errorsFusion=errorsFusion+1;
        end
    end    
    accuracyFusion = 1-errorsFusion/numOfAllTests
    %fprintf('numOfCase=%d\tlambdas=%d\taccuracyFusion=%d\n', numOfCases,lambda,accuracyFusion);
    %if accuracyFusion>bestAccuracy
    %    bestLambda = lambda;
    %    bestAccuracy=accuracyFusion;
    %end
end