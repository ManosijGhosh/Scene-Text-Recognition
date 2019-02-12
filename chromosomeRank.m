function [population,rank]=chromosomeRank(population,rank,flag)
    rng('shuffle');
    [r,c]=size(population);
    
    if flag==0
        for i=1:r
            [rank(i)]=classify(population(i,:));
        end
    end
    [rank,index] = sort(rank,'descend');
    population=population(index,:);
    
    fprintf('\nPopulation now - \n');
    for i=1:r
        fprintf('R - %f\tbin num- %d\n',rank(i),sum(population(i,1:c)));
    end
    fprintf('\n');
end
            