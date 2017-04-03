% DistinctiveSR_L1.m
% Distinctive sparse representation with L1

%% Parameters
% numOfSamples=10;
% numOfClasses=40;
% inputData
% numOfTrain
% numOfTest
gama=1e-3
sample_num=numOfSamples;
class_num=numOfClasses;
train_num=numOfTrain;
test_num=sample_num-train_num;
input0=inputData;
errors=0;


%% print summary of experiment
fprintf('numOfTrain=%d\tnumOfTest=%d\tnumOfClasses= %d\n', numOfTrain, numOfTest, numOfClasses);

%% divide the training samples and test samples
for jj=1:class_num
    for k=1:train_num
        tempt0(1,:)=double(input0(jj,k,:));
        ex_data((jj-1)*train_num+k,:)=tempt0/norm(tempt0);
        Label_train((jj-1)*train_num+k)=jj;
    end
end
for jj=1:class_num
    for k=1:test_num
        tmp =input0(jj,k+train_num,:);
        tmp=imnoise(tmp,'salt & pepper',.3);% 原始图像增加30%的椒盐噪声
        tmp = double(tmp);
        data((jj-1)*test_num+k,:)=tmp(:)/norm(tmp(:));
        Label_test((jj-1)*test_num+k)=jj;
    end
end
X=ex_data';
data1=data';

%% solve the equation (11)
[size1 size2]=size(X);
M=eye(train_num*class_num);
XtX=zeros(train_num*class_num);
for i=1:class_num
    xi=X(:,(i-1)*train_num+1:i*train_num);
    M((i-1)*train_num+1:i*train_num,(i-1)*train_num+1:i*train_num)=xi'*xi;
end
XtX=ex_data*ex_data';
Xt = ex_data;
X = ex_data';
%     T=inv((1+2*gama)*XtX+2*gama*class_num*M);
T0=inv(XtX+2*gama*(XtX+class_num*M));
sigma = 1;
tau = 1/norm(XtX)/sigma;
T=inv(eye(size(XtX))/sigma+2*gama*(XtX+class_num*M));

%% test all test samples
for i=1:class_num*test_num
    y(:,1)=data1(:,i);
    solution=T0*(ex_data*y); % L2拟合项算法的解
    %% new method
    %         solution(:) = 0; % 零初始化
    z = zeros(size(y));
    z_bar = z;
    for iter = 1:100
        z_old = z;
        solution=T*(solution+sigma*Xt*z_bar); % L1拟合项算法的解
        z = z + tau*(y - X*solution);
        z = z ./ max(1,abs(z));
        z_bar = 2*z - z_old;
    end
    %%
    contribution0=zeros(size1,class_num);
    
    for kk=1:class_num
        for hh=1:train_num
            contribution0(:,kk)=solution((kk-1)*train_num+hh)*X(:,(kk-1)*train_num+hh)+contribution0(:,kk);
        end
    end
    for kk=1:class_num
        wucha0(kk)=norm(y-contribution0(:,kk));
    end
    [recorded_value record00]=min(wucha0);
    record0_class(i)=record00;
    
    inte=floor((i-1)/test_num)+1;
    label2(i)=inte;
    if record0_class(i)~=label2(i)
        errors=errors+1;
    end
end
errors_ratio=errors/test_num/class_num;
accuracy(train_num)=1-errors_ratio