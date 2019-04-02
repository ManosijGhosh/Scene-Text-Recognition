%creates a feature list & value of acuuracy of list out of 1(0-1)
function [data] = datacreate(n,dimension,scale,lb,ub)
%n is the number of chromosomes we are working on

rng('shuffle');
data=zeros(n,dimension);
ub = ub/scale;
for i=1:n
    temp=rand(1,dimension);
    temp=temp*(ub-lb)+lb;
    data(i,:)=double(uint8(temp*20))*0.05;
end
clear max min count;


%Finish this

min_dev = 0.2;
max_k =2;

ideal = [0.25 0.25 1 0.25 0.25 1 0.1 0.25 0.25 0.15 0.0015 0.4 0.01 0.85 0.05 0.25 0.25 0.25 0.25 0.9 0.2 1 0 0.98 0 0.9 0.2 0.4 0.1 0.65 0.1 1 0 0.99 0 0.9 0.2 0.4 0.1 ];
catch_all = [ 1 1 1 1 1 1 0 1 1 1 0 1 0 1 0 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 0 1 0 1 0 1 0 1 1];
% %     data(:,~ideal) = max(0.25,data(:,~ideal));
data(1,:) = catch_all;
for i=2:n
    data(i,:) = (max_k*data(i,:) + min_dev).*ideal;
end
% % %     data(1,:) = ideal;
% % data(:,16:19) = 0.25;
data = max(data,lb);
data = min(data,ub);
data=data*scale;
end