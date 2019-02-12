function [fitness] = BinningGL(chromosome)
global img;
folderPath='with GT/';
idir = dir(strcat(folderPath,'i (*).jpg'));
nfiles = uint16(length(idir)*(1.0/10.0));    % Number of files found


accuracy = zeros(1,nfiles);

initialiseGT();

for img_loop=1:nfiles
    currentfilename = idir(img_loop).name;
    imagePath=strcat(folderPath,currentfilename);
    img = rgb2gray(imread(imagePath));
    
    textBoxes = boundingBoxes(chromosome);
    
    accuracy(img_loop) = overlapAccuracy(textBoxes, currentfilename);
    fprintf('Accuracy ratio - %f\n',accuracy(img_loop));
end
disp(accuracy);
fitness = mean(accuracy);
end


function [textBoxes] = boundingBoxes(chromosome)
% returns a list of tex boxes for all bin sizes
textBoxes = [];

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