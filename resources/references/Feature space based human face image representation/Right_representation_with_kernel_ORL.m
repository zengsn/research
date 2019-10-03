
% Right_representation_with_kernel_orl



clear all;


miu=1.0e-3;


m=10

c=40
train_num=5;
test=m-train_num;

N=c*train_num;
N1=N;
cha_jieguo=zeros(N,N);
K=zeros(N);

sigma_2=1.0e7;


folder='ORL\orl';

linshi0=imread('ORL\orl001.bmp');
[row col]=size(linshi0);

folder='ORL\orl';

linshi0=imread('ORL\orl001.bmp');
[row col]=size(linshi0);


for i=1:c
    for k=1:m
        filename=[folder num2str((i-1)*m+k,'%03d')  '.bmp'];
        input0(i,k,:,:)=imread(filename);
    end
end
input0=double(input0);


for j=1:c
    for k=1:train_num
        ex_data((j-1)*train_num+k,:)=input0(j,k,:);
    end
end


for j=1:c
    for k=1:test
        data((j-1)*test+k,:)=input0(j,train_num+k,:);
    end
end


useful_train=ex_data;


for i=1:N
    k11=useful_train(i,:);
    for j=1:N
        k12=ex_data(j,:);
        kernel=exp(-(norm(k11-k12))^2/2/sigma_2);
        New_K1(i,j)=kernel;
    end
end

errors=0;

% 先计算测试样本与训练样本间的核函数
for i=1:test*c
    k11=data(i,:);
    for j=1:N
        k12=useful_train(j,:);
        kernel=exp(-(norm(k11-k12))^2/2/sigma_2);
        test_kernel(i,j)=kernel;
    end
end


for j=1:test*c
    shiliang=test_kernel(j,:);
    
    %         if cond(New_K1)<1.0e6
    if cond(New_K1)<1.0e8
        solution=inv(New_K1)*shiliang';
    else
        solution=inv(New_K1+0.01*eye(N))*shiliang';
    end
    
    if j==1
        solution0=solution;
    end
    
    contribution=zeros(N1,N);
    for kk=1:c
        for hh=1:train_num
            contribution(:,kk)=contribution(:,kk)+solution((kk-1)*train_num+hh)*New_K1(:,(kk-1)*train_num+hh);
        end
    end
    
    for kk=1:c
        wucha(kk)=norm(shiliang'-contribution(:,kk));
    end
    
    [min_value xx]=min(wucha);
    fen_label(j)=xx;
    
end


for i=1:test*c
    
    inte=floor((i-1)/test+1);
    label2(i)=inte;
    if fen_label(i)~=label2(i)
        errors=errors+1;
    end
end

errors_ratio=errors/c/test


save  solution_ORL solution -ascii;