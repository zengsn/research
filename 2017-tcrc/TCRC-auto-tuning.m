% TCRC.m

algName = 'TCRC';

%% parameters
% numOfTrain
% trainData
% trainLabel
% testData
% testLabel

[numOfAllTrains,~]=size(trainLabel);
[numOfAllTests,~]=size(testLabel);
fprintf('训练样本=%d；\t测试样本=%d；\t共 %d 组对象。\n', numOfAllTrains, numOfAllTests, numOfClasses);

%% fusion cases
aCases = [1,5,10,20,30,40,50,60,70,80];
%aCases = [0.5,0.1,0.05,0.03,0.025,0.02,0.01,0.001];
%aCases = [0.001,0.01,0.05,0.1,0.5];
%aCases = [5];
[~,numOfCases]=size(aCases);
%thCases=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8];
%thCases=[0.1,0.2,0.3,0.4];
%thCases=[0.5,0.6,0.7,0.8];
%thCases=[0.1];
[~,numOfThresh]=size(thCases);
trainLabelFile=[dbName '/' num2str(numOfTrain) '_'];

% (T*T'+aU)-1 * T
clear preserved;
preserved=inv(trainData*trainData'+0.01*eye(numOfAllTrains))*trainData;

%
errorsCRC = 0;
errorsTTLS = zeros(1,numOfThresh); % errors
errorsFusion = zeros(numOfCases,numOfThresh); % accuracy

clear testSample;
clear solutionCRC;
for kk=1:numOfAllTests
    testSample=testData(kk,:);
    
    % CRC 解：(T*T'+aU)^-1 * T * D(i)'
    solutionCRC=preserved*testSample';
    % print progress
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    clear contributionCRC;
    for cc=1:numOfClasses
        contributionCRC(:,cc)=zeros(row*col,1);
        for tt=1:numOfTrain % C(i) = sum(S(i)*T)
            contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    clear deviationCRC;
    for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
        %deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc))/norm(solutionCRC);
        deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc)); % same
    end
    % recognition
    [min_value labelCRC]=min(deviationCRC);
    if labelCRC ~= testLabel(kk,1)
        errorsCRC=errorsCRC+1;
    end
    
    % TTLS with different threshold
    clear solutionTTLS;
    for kii=1:numOfThresh
        % use different thresh
        k = thCases(1,kii);
        % SRC by T-TLS
        solutionTTLS = TTLS(trainData', testSample', k);
        clear contributionTTLS;
        for cc=1:numOfClasses
            contributionTTLS(:,cc)=zeros(row*col,1);
            for tt=1:numOfTrain % C(i) = sum(S(i)*T)
                contributionTTLS(:,cc)=contributionTTLS(:,cc)+solutionTTLS((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
            end
        end
        clear deviationTTLS;
        for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
            %deviationTTLS(cc)=norm(testSample'-contributionTTLS(:,cc))/norm(solutionTTLS);
            deviationTTLS(cc)=norm(testSample'-contributionTTLS(:,cc)); % same
        end
        % recognition
        [min_value labelTTLS]=min(deviationTTLS);
        if labelTTLS ~= testLabel(kk,1)
            errorsTTLS(1,kii)=errorsTTLS(1,kii)+1;
        end
        
        % fusion
        for aii=1:numOfCases
            a = aCases(1,aii);
            b = 1;
            %fprintf('a=%d \t b=%f \t k=%f \n', a, b, k);
            clear contributionFusion;
            solutionFusion = zeros(numOfAllTrains,1);
            for cc=1:numOfClasses
                contributionFusion(:,cc)=zeros(row*col,1); % Fusion
                for tt=1:numOfTrain % C(i) = sum(S(i)*T) % fusion
                    solutionFusion((cc-1)*numOfTrain+tt) = a*solutionCRC((cc-1)*numOfTrain+tt)+b*solutionTTLS((cc-1)*numOfTrain+tt);
                    contributionFusion(:,cc)=contributionFusion(:,cc)+solutionFusion((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
                end
            end
            clear deviationFusion;
            for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
                %deviationFusion(cc)=norm(testSample'-contributionFusion(:,cc)/norm(solutionFusion)/(a+b));
                deviationFusion(cc)=norm(testSample'-contributionFusion(:,cc)/(a+b)); % same
            end
            % recognition
            [min_value labelFusion]=min(deviationFusion);
            if labelFusion ~= testLabel(kk,1)
                errorsFusion(aii,kii)=errorsFusion(aii,kii)+1;
            end
        end
    end
end
% accuracy
accuracyCRC = 1-errorsCRC/numOfAllTests;
highestCase = 0;
highestThresh = 0;
highestAccuracy = 0;
isBetter = '-';
result = zeros(numOfCases*numOfThresh,6);
for kii=1:numOfThresh
    accuracyTTLS = 1-errorsTTLS(1,kii)/numOfAllTests;
    for aii=1:numOfCases
        accuracyFusion = 1-errorsFusion(aii,kii)/numOfAllTests;
        if (highestAccuracy<accuracyFusion)
            highestCase = aCases(1,aii);
            highestThresh = thCases(1,kii);
            highestAccuracy = accuracyFusion;
            if accuracyFusion>accuracyTTLS && accuracyFusion>accuracyCRC
                isBetter = '+';
            else
                isBetter = '-';
            end
        end
        % save accuracy
        count = (kii-1)*numOfCases+aii;
        result(count,1)=aCases(1,aii);
        result(count,2)=1;
        result(count,3)=thCases(1,kii);
        result(count,4)=accuracyCRC;
        result(count,5)=accuracyTTLS;
        result(count,6)=accuracyFusion;
    end
end
a = highestCase;
b = 1;
k = highestThresh;
accuracyFusion=highestAccuracy;
improveCRC = (accuracyFusion-accuracyCRC)*100/accuracyCRC;
improveTTLS= (accuracyFusion-accuracyTTLS)*100/accuracyTTLS;

% save result to file
jsonFile = [dbName '/' algName '_' num2str(numOfTrain) '_' num2str(accuracyFusion,'%.4f') ];
jsonFile = [jsonFile '(' num2str(improveCRC,'%.2f') '%,' num2str(improveTTLS,'%.2f') '%)' ];
jsonFile = [jsonFile '_' num2str(a) ',' num2str(b) ',' num2str(k)];
dbJson = savejson('', result, [jsonFile '.json']);
result % print
%sendEmail(jsonFile,mat2str(resultInCase),jsonFile);

% save training labels
dbJson = savejson('', trainIndices, [jsonFile '_index.json']);