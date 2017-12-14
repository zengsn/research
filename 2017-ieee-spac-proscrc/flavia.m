y1 = [0.2741,0.3429,0.3650,0.4328,0.4511,0.4700,0.4474];
y2 = [0.2805,0.3413,0.3766,0.4463,0.4917,0.4927,0.5015];
y3 = [0.2875,0.3581,0.3854,0.4536,0.4923,0.5079,0.5152];
y4 = [0.2859,0.3321,0.3539,0.3929,0.4293,0.4257,0.4284];
y5 = [0.2832,0.3239,0.3490,0.3845,0.4316,0.4397,0.4379];
%y6 = [0.3013,0.3500,0.3827,0.4497,0.5072,0.5055,0.5140];
y7 = [0.2768,0.3375,0.3755,0.4356,0.4963,0.4910,0.4795];
y = [y1',y2',y3',y4',y5',y7'];
X1 = [1:1:7];
figure1 = figure;
YMatrix1 = y;
% ???? axes
figure1 = figure('PaperUnits','centimeters','PaperType','A4',...
    'PaperSize',[20.99999864 29.69999902]);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create multiple lines using matrix input to plot
plot1 = plot(X1,YMatrix1);
set(plot1(1),'DisplayName','SRC','Color',[0 0 1]);
set(plot1(2),'DisplayName','ProCRC','Color',[0 0.5 0]);
set(plot1(3),'DisplayName','ProSCRC','Marker','*','Color',[1 0 0]);
set(plot1(4),'DisplayName','CRC','Color',[0 0.75 0.75]);
set(plot1(5),'DisplayName','L1LS','Color',[0.75 0 0.75]);
%set(plot1(6),'DisplayName','OMP','Color',[0.75 0.75 0]);
set(plot1(6),'DisplayName','KNN','Color',[0.25 0.25 0.25]);

% Create xlabel
xlabel({'The number of training samples on Flavia database'},'FontSize',15);

% Create ylabel
ylabel('The accuracy of image classification','FontSize',15);

box(axes1,'on');
% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.169345238095235 0.586904761904762 0.203571428571429 0.322222222222222],...
    'EdgeColor',[0 0 0]);