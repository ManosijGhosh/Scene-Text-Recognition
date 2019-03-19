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
    
    data(1,:) = [0.2 0.2 0.5 0.5 0.5 0.5 0.1 0.2 0.2 0.2 0 0.25 0 0.25 0 0.25 0.25 0.25 0.25 0.8 0.1 0.6 0 0.98 0 0.9 0.2 0.25 0.3 0.65 0.1 0.6 0 0.99 0 0.9 0.2 0.25 0.3];

end