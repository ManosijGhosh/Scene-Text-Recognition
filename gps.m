function [timeexc,gbest_rank]=gps()

%% Indra's Code
global ExtractionDone 
ExtractionDone = false;

%%
%mutation off
tic
%clc
rng('shuffle');
functionNum = 1;
scale = 1;
% these need variables to be changed for each function, refer to the tables in the paper
ubArray=ones(1,1);
lbArray=zeros(1,1);
dimArray=39;
ub=3;
lb=0;
dimension=dimArray(functionNum);

% variables requiring change ends
n=50;   %number of points being considered
iter=1000;

label=zeros(1,iter);
valuesBest=zeros(1,iter);
valuesAvg=zeros(1,iter);
%{
    population=vpa(datacreate(n,dimension,lb,ub));
    rank=vpa(zeros(1,n));
    velocities=vpa(zeros(n,dimension));
%}
population = datacreate(n,dimension,scale,lb,ub);
rank=(zeros(1,n));
velocities_gsa=(zeros(n,dimension));
velocities_pso=zeros(n,dimension);
pbest=rank;
pbest_particle=population;

[population,rank,velocities_gsa,velocities_pso,~,pbest_particle]=chromosomeRank(population,rank,velocities_gsa,velocities_pso,pbest,pbest_particle,scale,1,1);
gbest_rank=rank(1);
gbest_particle=population(1,:);
pbest=rank;

change=0;


for count=1:iter
    %fprintf('Iteration - %d with gbest as - %f and current best %f change  - %f\n',count,double(gbest_rank),double(rank(1)),change);
    
    valuesBest(1,count)=rank(1);
    valuesAvg(1,count)=sum(rank)/n;
    label(1,count)=count;
    
    mass=massCalculation(rank);
    [velocities_gsa]=updateVelocities_gsa(mass,velocities_gsa,population,count,iter);
    
    [velocities_pso]=updateVelocity_pso(velocities_pso,population,pbest_particle,gbest_particle);
    
    [population]=updatePosition(population,velocities_pso,velocities_gsa);
    
    population=min(population,ub);
    population=max(population,lb);
    [population,rank,velocities_gsa,velocities_pso,pbest,pbest_particle]=chromosomeRank(population,rank,velocities_gsa,velocities_pso,pbest,pbest_particle,scale,1,1);
    
    if (gbest_rank<=rank(1))
        gbest_rank=rank(1);
        gbest_particle=population(1,:);
    end
    for i=1:n
        if rank(i)<=pbest(i)
            pbest_particle(i,:)=population(i,:);
            pbest(i)=rank(i);
        end
    end
    %disp([population rank']);
    %disp([pbest_particle pbest']);
    %if (abs(gbest-rank(1))<.01*gbest)
    if (abs(gbest_rank-rank(1))<.01*gbest_rank)% || abs(gbest_rank-rank(1))>gbest_rank)
        change=change+1;
        change=mod(change,50);
    else
        change=0;
    end
    disp(population);
    %{
    [population]=mutation(population,rank,count,iter,change,(ub-lb));
    [population,rank,velocities_gsa,velocities_pso,pbest,pbest_particle]=chromosomeRank(population,rank,velocities_gsa,velocities_pso,pbest,pbest_particle,scale,1,0);
    if (gbest_rank>=rank(1))
        gbest_rank=rank(1);
        gbest_particle=population(1,:);
    end
    for i=1:n
        if rank(i)<=pbest(i)
            pbest_particle(i,:)=population(i,:);
            pbest(i)=rank(i);
        end
    end
    %}
    %population
end
fprintf('The gbest is - %f and best accuracy is %f\n',double(gbest_rank),double(rank(1,1)));
%disp(gbest-(418.9829*dimension));
disp(gbest_rank);
disp(gbest_particle);
disp(population(1,:));
%%{
figure;
plot(label,valuesBest,label,valuesAvg);
%}
timeexc=toc;
end
%% gsa part of functions
function [dist]=distance(vec1,vec2)
dist=0;
for i=1:size(vec1,2)
    dist=dist+((vec1(i)-vec2(i))^2);
end
dist=sqrt(dist);
end
function [mass]=massCalculation(rank)
rank=100./((rank)+1);
worst=min(rank);
best=max(rank);
mass=rank;
mass=mass-worst;
mass=mass/((best-worst)+.00005);
total=sum(mass(1,:));
mass=mass/(total+.00005);
end
function [velocities_gsa]=updateVelocities_gsa(mass,velocities_gsa,population,count,iter)
rng('shuffle');
[r,c]=size(velocities_gsa);
force=zeros(r,c);
k=int16(r+((1-r)*(count-1))/(iter-1));  %linear relation
g=exp(-20*(count/iter));    %20 should change - decrease over time
for i=1:r
    for l=1:c
        for j=1:k
            if i~=j
                temp=g*((mass(i)*mass(j))/(distance(population(i,:),population(j,:))+.00005))*(population(j,l)-population(i,l));
                force(i,l)=force(i,l)+(rand*temp);
            end
        end
    end
end
for i=1:r
    force(i,:)=force(i,:)/(mass(i)+.00005);
end
c1=(-2*(count^3/iter^3))+2;
c2=(2*(count^3/iter^3));
for i=1:r
    for j=1:c
        velocities_gsa(i,j)=(rand*velocities_gsa(i,j))+c1*force(i,j)+c2*(population(1,j)-population(i,j));
    end
end
end
%% pso part functions
function [velocity_pso]=updateVelocity_pso(velocity_pso,currentPoints,bestPoints,globalBest)
rng('shuffle');
[n,c]=size(velocity_pso);
c1=2;c2=2;l=0.2;
w=((rand/2)+.4);
for i=1:n
    for j=1:c
        velocity_pso(i,j)=(w*velocity_pso(i,j))+(c1*rand(1)*(bestPoints(i,j)-currentPoints(i,j)))+(c2*rand(1)*(globalBest(1,j)-currentPoints(i,j)));
    end
end
x_max=max(bestPoints(:));
x_min=min(bestPoints(:));
velocity_pso=max(velocity_pso,l*x_min);
velocity_pso=min(velocity_pso,l*x_max);
end

%% gps part
function [population]=updatePosition(population,velocities_pso,velocities_gsa)
[r,c]=size(population);
c3=1;c4=1;
for i=1:r
    temp=rand;
    for j=1:c
        population(i,j)=population(i,j)+(c3*temp*velocities_pso(i,j))+(c4*(1-temp)*velocities_gsa(i,j));
    end
end
end
%% mutation part
function [population]=mutation(population,rank,count,iter,change,range)
mass=massCalculation(rank);
mass=mass+.00005;

centroid=zeros(1,size(population,2));
for i=1:size(population,2)
    centroid(1,i)=(mass*population(:,i))/sum(mass);
end

for i=1:size(population,1)
    dist=distance(centroid,population(i,:));
    pm=1/(dist+1);
    pc=.5+.5*(tanh((change/4)-5));
    pm=min(pc,pm);
    for j=1:size(population,2)
        if ((rand < pm))% || (pc > .98))
            %fprintf('l');
            if abs(population(i,j)) <= 0.00001
                delta=.5*range*((1-(count/iter))^2);
            else
                delta=min(.5*range*((1-(count/iter))^2),abs(population(i,j)));
            end
            
            %delta=max(delta,population(i,j)/10); %bad results
            %delta=.5*range*((1-(count/iter))^2);
            if rand <.5
                population(i,j)=population(i,j)-delta;
            else
                population(i,j)=population(i,j)+delta;
            end
        end
    end
end
end