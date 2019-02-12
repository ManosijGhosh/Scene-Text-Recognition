% GA runs to find the bins
function [st_ga]=GA()
%     clear all
%     clc
mkdir('output');
tic
rng('shuffle');

global lowerBound upperBound;

upperBound = 60;
lowerBound = 10;

c=upperBound - lowerBound + 1;
%n=int16(input('Enter the number of chromosomes to work on :'));
n=5;   % To change population Size
iter = 5;

population=datacreate(n,c);   % Feature Length
fprintf('data created\n');
%[r,c]=size(population);
rank=zeros(1,n);
rankcs=zeros(1,n);

[population,rank]=chromosomeRank(population,rank,0);
fprintf('Chromosomes ranked\n');

count = 1;
while (count<=iter)    % To Change if reqd..count - number of iterations
    
    %crossover starts
    fprintf('\nCrossover done for %d th time\n',count);
    for i=1:uint16(n/2)
        %cumulative sum for crossover
        rankcs(1:n)=rank(1:n);%copying the values of rank to rankcs
        for j= 2:n% size of weights = no. of features in popaulation=c
            rankcs(j)=rankcs(j)+rankcs(j-1);
        end
        maxcs=rankcs(n);
        for j= 1:n
            rankcs(j)=rankcs(j)/maxcs;
        end
        a=find(rankcs>rand(1),1,'first');
        b=find(rankcs>rand(1),1,'first');
        %roulette wheel ends
        
        [population,rank]=crossover(population,rank,a,b,0.5,0.001);
        %[population,rank]=crossover(x,t,population,randi(n,1),randi(n,1),rand(1),rank);
        clear a b j rankcs;
    end
    %crossover ends
    
    count=count+1;
    [population,rank]=chromosomeRank(population,rank,1);
    
    fprintf('Accuracy of population - ');
    disp(rank);
    disp('Results saved');
    save('output/result.mat','population','rank');
    %end
end
fprintf('The number of bins is : %d\n',sum(population(1,:)));
fprintf('The best accuracy is : %d\n',rank(1));
save('output/result.mat','population','rank');
disp('Final results stored');
st_ga=[sum(population(1,:)==1) rank(1)];
toc
end