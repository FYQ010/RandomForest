%%  ��ջ�������
warning off             % �رձ�����Ϣ
close all               % �رտ�����ͼ��
clear                   % ��ձ���
clc                     % ���������


%% ����Ԥ����
[attrib1, attrib2, attrib3, attrib4, class] = textread('iris.data', '%f%f%f%f%s', 'delimiter', ',');
class1 = zeros(150, 1); 
class1(strcmp(class, 'Iris-setosa')) = 1; 
class1(strcmp(class, 'Iris-versicolor')) = 2; 
class1(strcmp(class, 'Iris-virginica')) = 3; 

num1 = [attrib1, attrib2, attrib3, attrib4];
%%  ����ѵ�����Ͳ��Լ�
temp=randperm(150);

P_train = num1(temp(1:120), 1:4)';
T_train = class1(temp(1:120), 1)';
M = size(P_train, 2);                  %size���ؾ����С

P_test = num1(temp(121: end), 1:4)';
T_test = class1(temp(121: end), 1)';
N = size(P_test, 2);

%%  ���ݹ�һ��
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input );
t_train = T_train;
t_test  = T_test ;

%%  ת������Ӧģ��
p_train = p_train'; p_test = p_test';
t_train = t_train'; t_test = t_test';

%%  ѵ��ģ��
trees = 50;                                       % ��������Ŀ
leaf  = 1;                                        % ��СҶ����
OOBPrediction = 'on';                             % �����ͼ
OOBPredictorImportance = 'on';                    % ����������Ҫ��
Method = 'classification';                        % ���໹�ǻع�
net = TreeBagger(trees, p_train, t_train, 'OOBPredictorImportance', OOBPredictorImportance, ...
      'Method', Method, 'OOBPrediction', OOBPrediction, 'minleaf', leaf);
importance = net.OOBPermutedPredictorDeltaError;  % ��Ҫ��

%%  �������
t_sim1 = predict(net, p_train);
t_sim2 = predict(net, p_test );

%%  ��ʽת��
T_sim1 = str2num(cell2mat(t_sim1));
T_sim2 = str2num(cell2mat(t_sim2));

%%  ��������
error1 = sum((T_sim1' == T_train)) / M * 100 ;
error2 = sum((T_sim2' == T_test )) / N * 100 ;

%%  �����������
figure
plot(1 : trees, oobError(net), 'b-', 'LineWidth', 1)
legend('�������')
xlabel('��������Ŀ')
ylabel('���')
xlim([1, trees])
grid

%%  ����������Ҫ��
figure
bar(importance)
legend('��Ҫ��')
xlabel('����')
ylabel('��Ҫ��')

%%  ��������
[T_train, index_1] = sort(T_train);
[T_test , index_2] = sort(T_test );

T_sim1 = T_sim1(index_1);
T_sim2 = T_sim2(index_2);

%%  ��ͼ
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('��ʵֵ', 'Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string = {'ѵ����Ԥ�����Ա�'; ['׼ȷ��=' num2str(error1) '%']};
title(string)
grid

figure
plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('��ʵֵ', 'Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string = {'���Լ�Ԥ�����Ա�'; ['׼ȷ��=' num2str(error2) '%']};
title(string)
grid

%%  ��������
figure
cm = confusionchart(T_train, T_sim1);
cm.Title = 'Confusion Matrix for Train Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
    
figure
cm = confusionchart(T_test, T_sim2);
cm.Title = 'Confusion Matrix for Test Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
