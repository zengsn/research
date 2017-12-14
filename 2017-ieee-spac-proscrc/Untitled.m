tic;
Lk=50;
t0=10;
tf=0.1;
a=0.5;
I=imread('3.jpg');
I=INT(I);
TT1=RANDI(1,1,[min(min(I)) max(max(I))]);
while t0>tf
    for m=1:Lk
        TT2=RANDI(1,1,[min(min(I)) max(max(I))]);
        if f(I,TT2)-f(I,TT1)<0
            TT1=TT2;
        elseif exp((f(I,TT2)-f(I,TT1))/t0)>rand
            TT1=TT2
        end  
        
    end
    t0=t0*a;
end
toc;
disp(strcat('大律法计算出的阈值: ',num2str(TT1)));
Iotsu=im2bw(I,double(TT1)/255);
subplot(2,2,2);
imshow(Iotsu,[]);
xlabel('b,大律法');
