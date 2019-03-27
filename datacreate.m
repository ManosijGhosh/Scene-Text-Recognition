%creates a feature list & value of acuuracy of list out of 1(0-1)
function [data] = datacreate(n,dimension,lb,ub)
    %n is the number of chromosomes we are working on
   
    rng('shuffle');
    data=zeros(n,dimension);
    for i=1:n
        temp=rand(1,dimension);
        temp=temp*(ub-lb)+lb;
        data(i,:)=temp;  
    end
    clear max min count;
    
    
     ideal = [1 1 1 1 1 1 0 1 1 1 0 1 0 1 0 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 0 1 0 1 0 1 0 1 1];
%     
% %     data(:,~ideal) = max(0.25,data(:,~ideal));
% %     data(1,:) = ideal;
%     for i=1:n
%         data(i,:) = abs(ideal - (0.2*rand(1,dimension)-0.1));
%     end
% % %     data(1,:) = ideal;
% % data(:,16:19) = 0.25;
     data = max(data,lb);
     data = min(data,ub);
     
end