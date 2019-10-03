function createfigure(X1, YMatrix1)
%CREATEFIGURE(X1, YMATRIX1)
%  X1:  x ??????????
%  YMATRIX1:  y ??????????

%  ?? MATLAB ?? 31-Jul-2017 16:03:45 ????????

% ???? figure
figure1 = figure;

% ???? axes
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');

% ???? plot ??????????????????
plot1 = plot(X1,YMatrix1,'Parent',axes1);
set(plot1(1),'DisplayName','SRC');
set(plot1(2),'DisplayName','ProCRC');
set(plot1(3),'Marker','*','DisplayName','ProSCRC');
set(plot1(4),'DisplayName','CRC');
set(plot1(5),'DisplayName','L1LS');
set(plot1(6),'DisplayName','OMP');
set(plot1(7),'DisplayName','KNN');

% ???? xlabel
xlabel('The number of training samples on Yale database B');

% ???? ylabel
ylabel('The accuracy of image classification');
%xlim([1 15]);
% ???? legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.683630952380951 0.348809523809524 0.203571428571429 0.322222222222222]);

