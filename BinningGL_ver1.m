function [fitness] = BinningGL_ver2(chromosome)
global idx cn img;
folderPath='with GT/';
idir = dir(strcat(folderPath,'i (*).jpg'));
nfiles = uint16(length(idir)*(1.0/10.0));    % Number of files found


accuracy = zeros(1,nfiles);
idx = chromosome;
cn = sum(chromosome(:));
idx(1) = 1;
for loop = 2:size(chromosome)
    idx(1,loop) = idx(1,loop-1) + idx(1,loop);
end

initialiseGT();

for img_loop=1:nfiles
    currentfilename = idir(img_loop).name;
    imagePath=strcat(folderPath,currentfilename);
    img = rgb2gray(imread(imagePath));
    
    textBoxes = boundingBoxes();
    
    accuracy(img_loop) = overlapAccuracy(textBoxes, currentfilename);
    fprintf('Accuracy ratio - %f\n',accuracy(img_loop));
end
disp(accuracy);
fitness = mean(accuracy);
end

function [textBBoxes] = boundingBoxes()
global idx cn img;
[width,height]=size(img);

for i=1:cn % FOR EACH CLUSTER, A BIN OR A BINARY MASK WILL BE GENERATED
    bw=zeros(width,height);
    %PLACE THE CORRESPONDING CLUSTER NO. AGAINST THE GRAY LEVEL VALUE AT THE PIXEL POSITION OF THE GRAY IMAGE
    for rw=1:width
        for cl=1:height
            if idx(int8(img(rw,cl))+1)==i
                bw(rw,cl)=1;
            end
        end
    end
    
    %figure, imshow(bw);
    
    bwcc=bwconncomp(bw);
    %     cbx=vertcat(bwcc.PixelIdxList);
    % BOUNDING BOX IS GENERATED FOR ALL THE WHITE COMPONENTS IN THE BIN
    bwStats = regionprops(bwcc, 'BoundingBox', 'Eccentricity', ...
        'Area', 'Solidity', 'Extent', 'Euler', 'Image');
    %     bwcount=bwcount+1;
    
    %  BINARY CC PROPERTY ANALYSIS
    
    filterIdx =  [bwStats.Eccentricity] > .995 ;
    filterIdx = filterIdx | [bwStats.Solidity] > .5;
    % filterIdx = filterIdx | [bwStats.Extent] < 0.2 | [bwStats.Extent] > 0.9;
    % filterIdx = filterIdx | [bwStats.EulerNumber] < -4;
    bwStats(filterIdx) = [];
    bboxes = vertcat(bwStats.BoundingBox);
    %     [bwLbl, bwNum]=bwlabel(bw,4);
    if i==1
        bb1=bboxes;
        continue;
    end
    
    bb1=[bb1;bboxes];
end

% FILTERING OUT UNNECESSARY BOUNDING BOXES
bb1=unique(bb1,'rows');


textBBoxes=[bb1];
end

function [] = initialiseGT()
global list gtBoundingbox;
[list, temp] = xlsread('with GT/MISTI bboxes.xlsx','bboxes');
list = uint16(list);
gtBoundingbox = cell(1,size(temp,1)-1);
for i=1:size(list,1)
    gtBoundingbox{1,i} = temp{i+1,1};
end
end

function [accuracy] = overlapAccuracy(textBoxes, currentfilename)
global img list gtBoundingbox;
[row,col] = size(img);

mask = zeros(row,col);
textBoxes = uint16(textBoxes);
% mark the GT in mask
for i = 1:size(gtBoundingbox,2)
    if strcmp(gtBoundingbox{i},currentfilename)
        mask(list(i,1):list(i,1)+list(i,3)-1,list(i,2):list(i,2)+list(i,4)-1) = 1;
    end
end
% mark output in mask
for i =1:size(textBoxes,1)
    xmin = max(textBoxes(i,1),1);
    xmax = min(textBoxes(i,1)+textBoxes(i,3)-1,row);
    ymin = max(textBoxes(i,2),1);
    ymax = min(textBoxes(i,2)+textBoxes(i,4)-1,col);
    mask(xmin:xmax,ymin:ymax) = mask(xmin:xmax,ymin:ymax) + 2;
end
fprintf('textBox only - %d : intersection - %d : union - %d\n',sum(mask(:)==2),sum(mask(:)==3),sum(mask(:)~=0));
accuracy = sum(mask(:)==3)/(sum(mask(:)~=0));
end