function [population,rank]=crossover(population,rank,id1,id2,probC,probM)
rng('shuffle');
[r,c]=size(population);

%uniform crossover
population2(1,1:c)=population(id1,:);
population2(2,1:c)=population(id2,:);

for i=1:c
    if(rand(1)<=probC)
        temp=population2(1,i);
        population2(1,i)=population2(2,i);
        population2(2,i)=temp;
    end
end
clear arr1 arr2;
%mutation --
for i=1:c
    point=i;
    if(rand(1)<=probM)
        population2(1,point)=1-population2(1,point);
    end
    if(rand(1)<=probM)
        population2(2,point)=1-population2(2,point);
    end
end
%mutation ends

[rch1]=classify(population2(1,:));
[rch2]=classify(population2(2,:));
for i = r:-1:1
    if(rank(i)<rch1)
        fprintf('Replaced chromosome at %d in crossover with first\n',i);
        population(i,1:c)=population2(1,1:c);%substituition of chromose can be better
        rank(i)=rch1;
        break;
    end
end
for i = r:-1:1
    if(rank(i)<rch2)
        fprintf('Replaced chromosome at %d in crossover with second\n',i);
        population(i,1:c)=population2(2,1:c);
        rank(i)=rch2;
        break;
    end
end
end