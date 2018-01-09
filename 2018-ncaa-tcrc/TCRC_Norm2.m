% TCRC_Norm2.m

algName='TCRC_Norm2';

%% parameters
% numOfTrain
% trainData
% trainLabel
% testData
% testLabel

[numOfAllTrain,~]=size(trainLabel);
[numOfAllTest,~]=size(testLabel);
%fprintf('????????=%d??\t????????=%d??\t?? %d ????????\n', numOfAllTrains, numOfAllTests, numOfClasses);

%% fusion cases
%aCases = [1,5,10,20,30,40,50,60,70,80];
%aCases = [0.5,0.1,0.05,0.03,0.025,0.02,0.01,0.001];
%aCases = [0.001,0.01,0.05,0.1,0.5];
%aCases = [1];
%[~,numOfCases]=size(aCases);
%thCases=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8];
%thCases=[0.1,0.2,0.3,0.4];
%thCases=[0.5,0.6,0.7,0.8];
%thCases=[0.3];
%[~,numOfThresh]=size(thCases);
%trainLabelFile=[dbName '/' num2str(numOfTrain) '_'];
tic
% (T*T'+aU)-1 * T
clear preserved;
preserved=inv(trainData*trainData'+0.01*eye(numOfAllTrain))*trainData;

%
errorsCRC = 0;
errorsTTLS = 0; % errors
errorsFusion = 0; % accuracy
fprintf('CRC with TTLS at %d ... ', times);
clear testSample;
for kk=1:numOfAllTest
    testSample=testData(kk,:);   
    % print progress
    %fprintf('%d ', kk);
    %if mod(kk,20)==0
    %    fprintf('\n');
    %end 
    % CRC ????(T*T'+aU)^-1 * T * D(i)'
    clear solutionCRC;
    solutionCRC=preserved*testSample';
    clear contributionCRC;
    for cc=1:numOfClasses
        contributionCRC(:,cc)=zeros(row*col,1);
        for tt=1:numOfTrain % C(i) = sum(S(i)*T)
            contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    clear deviationCRC;
    for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
        deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc))/norm(contributionCRC(:,cc));
        %deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc)); % same
    end
    % recognition
    [min_value labelCRC]=min(deviationCRC);
    if labelCRC ~= testLabel(kk,1)
        errorsCRC=errorsCRC+1;
    end
    
    % TTLS with different threshold
    clear solutionTTLS;
    % SRC by T-TLS
    solutionTTLS = TTLS(trainData', testSample', th);
    clear contributionTTLS;
    for cc=1:numOfClasses
        contributionTTLS(:,cc)=zeros(row*col,1);
        for tt=1:numOfTrain % C(i) = sum(S(i)*T)
            contributionTTLS(:,cc)=contributionTTLS(:,cc)+solutionTTLS((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    clear deviationTTLS;
    for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
        deviationTTLS(cc)=norm(testSample'-contributionTTLS(:,cc))/norm(contributionTTLS(:,cc));
        %deviationTTLS(cc)=norm(testSample'-contributionTTLS(:,cc)); % same
    end
    % recognition
    [min_value labelTTLS]=min(deviationTTLS);
    if labelTTLS ~= testLabel(kk,1)
        errorsTTLS=errorsTTLS+1;
    end
    
    % Fusion
    clear contributionFusion;
    solutionFusion = zeros(numOfAllTrain,1);
    for cc=1:numOfClasses
        contributionFusion(:,cc)=zeros(row*col,1); % Fusion
        for tt=1:numOfTrain % C(i) = sum(S(i)*T) % fusion
            solutionFusion((cc-1)*numOfTrain+tt) = a*solutionCRC((cc-1)*numOfTrain+tt)+b*solutionTTLS((cc-1)*numOfTrain+tt);
            contributionFusion(:,cc)=contributionFusion(:,cc)+solutionFusion((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    clear deviationFusion;
    for cc=1:numOfClasses % r(i) = |D(i)-C(i)|/|C(i)|
        deviationFusion(cc)=norm(testSample'-contributionFusion(:,cc)/norm(contributionFusion(:,cc))/(a+b));
        %deviationFusion(cc)=norm(testSample'-contributionFusion(:,cc)/(a+b)); % same
    end
    % recognition
    [min_value labelFusion]=min(deviationFusion);
    if labelFusion ~= testLabel(kk,1)
        errorsFusion=errorsFusion+1;
    end
end
% accuracy
accuracyCRC = 1-errorsCRC/numOfAllTest;
accuracyTTLS = 1-errorsTTLS/numOfAllTest;
accuracyFusion = 1-errorsFusion/numOfAllTest;

time_tcrc = toc;
fprintf('in %.1f (s). accuracy=%.4f \n', time_tcrc, accuracyFusion);

improveCRC = (accuracyFusion-accuracyCRC)*100/accuracyCRC;
improveTTLS= (accuracyFusion-accuracyTTLS)*100/accuracyTTLS;

% result path
if ~isequal(exist(dbName, 'dir'),7)
    mkdir(dbName);
end

% save result to file
%jsonFile = [dbName '/' algName '_' num2str(numOfTrain) '_' num2str(highestAccuracy,'%.4f') isBetter '(' num2str(a) ',' num2str(b) ',' num2str(th) ').json'];
%dbJson = savejson('', result, jsonFile);
%result % print
jsonFile = [dbName '/' algName '_' num2str(numOfTrain) '_' num2str(accuracyFusion,'%.4f') ];
jsonFile = [jsonFile '(' num2str(improveCRC,'%.2f') '%,' num2str(improveTTLS,'%.2f') '%)' ];
jsonFile = [jsonFile '_' num2str(a) ',' num2str(b) ',' num2str(th) '_' num2str(times) '.json'];
result   = [numOfTrain,a,b,th,accuracyCRC,accuracyTTLS,accuracyFusion,trainIndices];
%result % print
dbJson = savejson('', result, jsonFile);
if exist('sendEmail')
    sendEmail(jsonFile,mat2str(resultInCase),jsonFile);
end

% save training labels
%trainLabelFile = [trainLabelFile num2str(highestAccuracy,'%.4f') '.json'];
%dbJson = savejson('', trainIndices, trainLabelFile);