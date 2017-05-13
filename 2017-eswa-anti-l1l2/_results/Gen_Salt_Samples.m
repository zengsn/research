
%pathN = 'GT_Salt0.1_Samples/';
%pathN = 'CF_Salt0.3_Samples/';
%pathN = 'AR_Salt0.3_Samples/';
pathN = 'FE_Salt0.1_Samples/';
for cc=3:3
    for tt=1:numOfSamples
        %path=[pathPrefix int2str(cc) '_' int2str(ss) '.jpg'];
        %path=[pathPrefix 'image_' num2str(numOfFirst+ss-1, '%04d') '.jpg'];
        %path=[pathPrefix num2str(cc,'%03d') '-' num2str(ss) '.tif'];
        path=[pathPrefix num2str((cc-1)*numOfSamples+ss,'%d') '.tif'];
        colored=imread(path);
        filename=[num2str(cc), '_' num2str(tt)];
        imwrite(colored, [pathN, filename, '.jpg']);
        %grayed=rgb2gray(colored);
        grayed=colored;
        filename=[num2str(cc), '_' num2str(tt) '_n'];
        saltImg=imnoise(grayed,'salt & pepper',salt);
        imwrite(saltImg, [pathN, filename, '.jpg']);
    end
end