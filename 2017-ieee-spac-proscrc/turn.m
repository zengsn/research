open('YaleB.fig');
lh = findall(gca, 'type', 'line');% 如果图中有多条曲线，lh为一个数组
xc = get(lh, 'xdata');            % 取出x轴数据，xc是一个元胞数组
yc = get(lh, 'ydata');            % 取出y轴数据，yc是一个元胞数组
%如果想取得第2条曲线的x，y坐标
x=xc{2};
y2=yc{2};
y3=yc{3};
y4=yc{4};
y5=yc{5};
y6=yc{6};
y7=yc{7};
y1=yc{1};