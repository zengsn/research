function [J] = Random_Pixel_Crop(I,ratio)

[h,w] = size(I);
num_c = floor(ratio*h*w);
tem_index = (ceil(h*w.*rand(20*num_c,1)));

i =1;index_c = tem_index(1);j=1;
while i<=num_c && j<size(tem_index,1)
      if sum(index_c==tem_index(j+1))==0
         index_c(i+1)=tem_index(j+1);
         i = i+1;
      end
      j = j+1;
end

[hc,wc] = ind2sub(size(I),index_c);
value_c = ceil(256.*rand(num_c,1))-1;
J = I;
for i = 1:num_c
    J(hc(i),wc(i))=value_c(i);
end