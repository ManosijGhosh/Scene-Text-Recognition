function [fitness] = BinningGL(chromosome)
global img ExtractionDone BinNumber FCCs FCCs_indexes FCCstats FCCstats_indexes FFeatures FFeatures_indexes;
folderPath='with GT/';
%folderPath = 'E:\ResearchFiles\DATA\Scene-Text-Recognition-GIAN\with GT\'; % Path on Indra's Machine only
idir = dir(strcat(folderPath,'i (*).jpg'));
nfiles = 10;
accuracy = zeros(1,nfiles);

initialiseGT();

loadSavedVariables = true;

if ~ExtractionDone && loadSavedVariables
    load('FCCs.mat');
    load('FCCs_indexes.mat');
    load('FCCstats.mat');
    load('FCCstats_indexes.mat');
    load('FFeatures.mat');
    load('FFeatures_indexes.mat');
    load('ExtractedFileNames.mat');
    load('NumFilesExtracted.mat');
    tFCCs= FCCs ;
    tFCCstats = FCCstats;
    tFFeatures = FFeatures;
    entryCC = numel(FCCs)+1;
    entryCCst = numel(FCCstats)+1;
    entryF = size(FFeatures,1)+1;
else
    if ~ExtractionDone
        NumFilesExtracted = 0;
        ExtractedFileNames = strings(nfiles,1);
        entryCC = 1;
        entryCCst = 1;
        entryF = 1;
        FCCstats_indexes = zeros(nfiles,2);
        FFeatures_indexes = zeros(nfiles,2);
        FCCs_indexes = zeros(nfiles,2);
        
    end
end



if ExtractionDone == false
    index_entry = NumFilesExtracted+1;
    tFCCinitialized = false;
    for img_loop=1:nfiles
        %
        %         try
        fprintf(">>>> Extracting Features for Image : %d\n",img_loop);
        currentfilename = idir(img_loop).name;
        hasBeenDone = (ExtractedFileNames == string(currentfilename));
        if sum(hasBeenDone) ~= 0
            fprintf("File Already Extracted\n");
            continue;
        end
        
        imagePath=strcat(folderPath,currentfilename);
        img = rgb2gray(imread(imagePath));
        image = img;
        BinSizes = [32,50,62,77,95,118];
        
        fprintf(".....Binning Image.....\n");
        [NumBinImages,MAX_DISTANCE] = Binning(image,BinSizes);
        BinNumber = NumBinImages;
        BinMatrix = GetBinAllocations(BinSizes,MAX_DISTANCE,NumBinImages);
        if ~tFCCinitialized
            tFCCs = zeros(nfiles,NumBinImages);
            tFCCstats = zeros(nfiles,4);
            tFCCinitialized = true;
        end
        
        StabilityMatrix = GetStabilityMatrix(BinSizes,BinMatrix,MAX_DISTANCE);
        fprintf("......Extracting Features........\n");
        [CCs,CCstats,Features,~] = GetAllFeatures(BinSizes,MAX_DISTANCE,StabilityMatrix,false);
        %CCs
        tFCCs(entryCC:entryCC+size(CCs,1)-1,:) = CCs;
        FCCs_indexes(index_entry,:) = [entryCC (entryCC+size(CCs,1)-1)];
        entryCC = entryCC + size(CCs,1);
        tFCCstats(entryCCst:entryCCst+size(CCstats,1)-1,:) = CCstats;
        FCCstats_indexes(index_entry,:) = [entryCCst entryCCst+size(CCstats,1)-1];
        entryCCst = entryCCst + size(CCstats,1);
        tFFeatures(entryF:entryF+size(Features,1)-1,:) = Features;
        FFeatures_indexes(index_entry,:) = [entryF entryF+size(Features,1)-1];
        entryF = entryF+size(Features,1);
        
        index_entry = index_entry +1;
        
        NumFilesExtracted = NumFilesExtracted + 1;
        ExtractedFileNames(NumFilesExtracted,1) = string(currentfilename);
        %         catch e
        %             fprintf("Error:: \n %s \n %s ",e.identifier,e.message);
        %             FCCs = tFCCs;
        %             FCCstats = tFCCstats;
        %             FFeatures = tFFeatures;
        %             save('FCCs.mat','FCCs');
        %             save('FCCs_indexes.mat','FCCs_indexes');
        %             save('FCCstats.mat','FCCstats');
        %             save('FCCstats_indexes.mat','FCCstats_indexes');
        %             save('FFeatures.mat','FFeatures');
        %             save('FFeatures_indexes.mat','FFeatures_indexes');
        %             save('ExtractedFileNames.mat','ExtractedFileNames');
        %             save('NumFilesExtracted.mat','NumFilesExtracted');
        %             ExtractionDone = true;
        %             error("THERE HAS BEEN ERROR");
        %         end
    end
    
    try
        FCCs = tFCCs;
        FCCstats = tFCCstats;
        FFeatures = tFFeatures;
    catch e
       fprintf("All Images in this folder already Feature extraction completed\n");
       fprintf("%s %s\n",e.identifier,e.message);
    end
    save('FCCs.mat','FCCs');
    save('FCCs_indexes.mat','FCCs_indexes');
    save('FCCstats.mat','FCCstats');
    save('FCCstats_indexes.mat','FCCstats_indexes');
    save('FFeatures.mat','FFeatures');
    save('FFeatures_indexes.mat','FFeatures_indexes');
    save('ExtractedFileNames.mat','ExtractedFileNames');
    save('NumFilesExtracted.mat','NumFilesExtracted');
    ExtractionDone = true;
end

for img_loop=1:nfiles
    currentfilename = idir(img_loop).name;
    imagePath=strcat(folderPath,currentfilename);
    img = rgb2gray(imread(imagePath));
    
    textBoxes = boundingBoxes(chromosome,img_loop);
    %disp(textBoxes);
    accuracy(img_loop) = overlapAccuracy(textBoxes, currentfilename);
    %fprintf('Accuracy ratio - %f\n',accuracy(img_loop));
end
%disp(accuracy);
fitness = mean(accuracy);
end


function [BoundingBoxes] = boundingBoxes(parameters,img_no)
% returns a list of tex boxes for all bin sizes
global FCCs FCCs_indexes FCCstats FCCstats_indexes FFeatures FFeatures_indexes CheckTextGroup CheckisStable;
hasParametersSupplied = true;

startCC =  FCCs_indexes(img_no,1);
endCC = FCCs_indexes(img_no,2);

startCCstats = FCCstats_indexes(img_no,1);
endCCstats = FCCstats_indexes(img_no,2);

startFeatures = FFeatures_indexes(img_no,1);
endFeatures = FFeatures_indexes(img_no,2);

% FFeatures = normalize(FFeatures,1,'range');
% FFeatures(:,7) = FFeatures(:,7)*10;
 %FFeatures(:,15) = FFeatures(:,11).*10;

CCs = FCCs(startCC:endCC,:);
CCstats = FCCstats(startCCstats:endCCstats,:);
Features = FFeatures(startFeatures:endFeatures,:);

 Features(:,[3 4 11]) = Features(:,[3 4 11])./1000;
% Features(:,[8 9]) = Features(:,[8,9])*10; 
CheckTextGroup = zeros(1,6);
CheckisStable = zeros(1,11);
BoundingBoxes = GetBoundingBoxes(CCs,CCstats,Features,true,hasParametersSupplied,parameters);
%disp(CheckisStable);
%disp(CheckTextGroup);

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
% disp(size(img));
mask = zeros(row,col);
mask2 = zeros(row,col);
% size(mask2)
textBoxes = uint16(textBoxes);
% mark the GT in mask
for i = 1:size(gtBoundingbox,2)
    if strcmp(gtBoundingbox{i},currentfilename)
        mask(list(i,2):list(i,2)+list(i,4)-1,list(i,1):list(i,1)+list(i,3)-1) = 1;
    end
end
% mark output in mask
% may have put x ad y wrong, check it
% fprintf('groud truth only - %d\n',sum(mask(:)==1));
for i =1:size(textBoxes,1)
    xmin = max(textBoxes(i,1),1);
    xmax = min(textBoxes(i,1)+textBoxes(i,3)-1,col);
    ymin = max(textBoxes(i,2),1);
    ymax = min(textBoxes(i,2)+textBoxes(i,4)-1,row);
    
    %INDRA's modification
    mask2(ymin:ymax, xmin:xmax) = mask2(ymin:ymax, xmin:xmax)+2;
    % fprintf('text box at - (%d, %d) to (%d, %d)\n',xmin,ymin,xmax,ymax);
    % disp(size(mask2));
end
% disp(size(mask));
% disp(size(mask2));



mask = mask + mask2;
textBoxOnly = sum(sum(mask(mask ~= 0 & mod(mask,2) ~= 1)./2));
intersection = sum(sum((mask(mod(mask,2) == 1)-1)./2));
union = textBoxOnly + intersection + sum(sum(mask == 1));
%fprintf('textBox only - %d : intersection - %d : union - %d\n',textBoxOnly,intersection,union);
%fprintf('textBox only - %d : intersection - %d : union - %d\n',sum(mask(:)==2),sum(mask(:)==3),sum(mask(:)~=0));
%accuracy = sum(mask(:)==3)/(sum(mask(:)~=0));
accuracy = intersection/union;
end
