

% combination_by_multiplication_on_GT.m

clear all;

addpath 'src_solution';

% miu=1.0e-3;

path='Georgia Tech face database crop/';

test1=imread('Georgia Tech face database crop/1_1.jpg');
[size_a size_b size_c]=size(test1);
[row col]=size(rgb2gray(test1));

clear test1;

number=15; mei=number;
persons=50; c=persons
m=mei

new_path0='Georgia Tech face database crop/'


train_number=2 ;
train_number=3 ;
train_number=5 ;
train_num= train_number;trainnum= train_number;
testnum=number-trainnum;  test= testnum;
test_number=number-train_number;

defined_number=50;      %% The largest dimensionality of the features obtained using the proposed method.

M=c; N=train_num;

for gg=1:persons
    path20=[path  int2str(gg)];
    
    for hhh=1:number
        path2=[path20 '_' int2str(hhh) '.jpg'];
        
        test0=imread(path2);
        
        test1=double(rgb2gray(test0));
        
        input0(gg,hhh,:,:)= test1(:,:);
    end
end
input0=double(input0);

% 取出相应原始训练集和测试集
for j=1:c
    for k=1:train_num
        zanshi(1,:)=input0(j,k,:);
        ex_data((j-1)*train_num+k,:)=zanshi/norm(zanshi);
    end
end
for j=1:c
    for k=1:test
        zanshi(1,:)=input0(j,k+train_num,:);
        data((j-1)*test+k,:)=zanshi/norm(zanshi);
    end
end

n_number=c*train_num

useful_train=ex_data;
preserved=inv(useful_train*useful_train'+0.01*eye(n_number))*useful_train;

for j=1:test*c
    shiliang=data(j,:);
    solution2=preserved*shiliang';
    
    %%%%%%%%%%%%%如下不同的SRC解法可任选一种
    %           [solution, total_iter] =    SolveL1LS(useful_train',shiliang');
    [solution, total_iter] =    SolveFISTA(useful_train',shiliang');
    %            [solution, total_iter] =    SolveDALM(useful_train',shiliang');
    %            [solution, total_iter] =    SolveDALM_fast(useful_train',shiliang');
    disp(['Solution of test sample ' num2str(j) ' by FISTA.']);
    
    for kk=1:c
        contribution(:,kk)=zeros(row*col,1);
        sparse_contribution(:,kk)=zeros(row*col,1);
        collaborative_contribution(:,kk)=zeros(row*col,1);
        
        for hh=1:train_num
            sparse_contribution(:,kk)=sparse_contribution(:,kk)+solution((kk-1)*train_num+hh)*useful_train((kk-1)*train_num+hh,:)';
            collaborative_contribution(:,kk)=collaborative_contribution(:,kk)+solution2((kk-1)*train_num+hh)*useful_train((kk-1)*train_num+hh,:)';
            contribution(:,kk)=contribution(:,kk)+(solution((kk-1)*train_num+hh)*solution2((kk-1)*train_num+hh))*useful_train((kk-1)*train_num+hh,:)';
        end
    end
    
    for kk=1:c
        wucha(kk)=norm(shiliang'-contribution(:,kk));
        collaborative_wucha(kk)=norm(shiliang'-collaborative_contribution(:,kk));
        sparse_wucha(kk)=norm(shiliang'-sparse_contribution(:,kk));
    end
    [min_value xx]=min(wucha);
    fen_label(j)=xx;
    
    [min_value yy]=min(sparse_wucha);
    sparse_fen_label(j)=yy;
    [min_value zz]=min(collaborative_wucha);
    collaborative_fen_label(j)=zz;
end

errors=0; collaborative_errors=0; sparse_errors=0;
for i=1:test*c
    inte=floor((i-1)/test+1);
    label2(i)=inte;
    if fen_label(i)~=label2(i)
        errors=errors+1;
    end
    if collaborative_fen_label(i)~=label2(i)
        collaborative_errors=collaborative_errors+1;
    end
    if sparse_fen_label(i)~=label2(i)
        sparse_errors=sparse_errors+1;
    end
end

errors_ratio=errors/c/test;
collaborative_errors_ratio=collaborative_errors/c/test;
sparse_errors_ratio=sparse_errors/c/test;

