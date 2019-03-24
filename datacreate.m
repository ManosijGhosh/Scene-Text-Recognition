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
    
    ideal = [1 1 1 1 1 1 0 1 1 1 0 1 0 1 0 0.25 0.25 0.25 0.25 1 0 1 0 1 0 1 0 1 1 1 0 1 0 1 0 1 0 1 1];
    %data(1,:) = ideal;
    for i=1:n
        data(i,:) = ((~ideal*0.25).*data(i,:)) + ((ideal).*data(i,:));
    end
    data(1,:) = ideal;
     data = max(data,0);
     data = min(data,0);
     
end