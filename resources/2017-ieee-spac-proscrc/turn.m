open('YaleB.fig');
lh = findall(gca, 'type', 'line');% ���ͼ���ж������ߣ�lhΪһ������
xc = get(lh, 'xdata');            % ȡ��x�����ݣ�xc��һ��Ԫ������
yc = get(lh, 'ydata');            % ȡ��y�����ݣ�yc��һ��Ԫ������
%�����ȡ�õ�2�����ߵ�x��y����
x=xc{2};
y2=yc{2};
y3=yc{3};
y4=yc{4};
y5=yc{5};
y6=yc{6};
y7=yc{7};
y1=yc{1};