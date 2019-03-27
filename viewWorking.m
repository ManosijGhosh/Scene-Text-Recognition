function viewWorking(isImageBinned,isImageCombined,image_no,ShowOutput_dir,file_ext)
global BinImages ShowOutput FCCs FCCs_indexes FCCstats FCCstats_indexes FFeatures FFeatures_indexes ExtractedFileNames
folderPath='with GT/';
%folderPath = 'E:\ResearchFiles\DATA\test_input\'; % Path on Indra's Machine only
idir = dir(strcat(folderPath,'i (*).jpg'));
nfiles = 1;

%load('ExtractedFileNames.mat')
% load('FCCs.mat')
% load('FCCs_indexes.mat')
% load('FCCstats.mat')
% load('FCCstats_indexes.mat')
% load('FFeatures.mat')
% load('FFeatures_indexes.mat')

currentfilename = idir(image_no).name;

imagePath=strcat(folderPath,currentfilename);
img = rgb2gray(imread(imagePath));
image = img;

fprintf(".....Binning...\n");
MAX_DISTANCE = 255;
BinSizes = [32,50,62,77,95,118];
if ~isImageBinned
    [NumBinImages,~] = Binning(image,BinSizes);
    fprintf(".....Saving Binned Images...\n");
    BinImagesSaved = BinImages;
    save(strcat('BinImages',int2str(image_no),'.mat'),'BinImagesSaved');
else
   load(strcat('BinImages',int2str(image_no),'.mat'));
   BinImages = BinImagesSaved;
end



% BinMatrix = GetBinAllocations(BinSizes,MAX_DISTANCE,size(BinImages,3));
% % if ~tFCCinitialized
% %     tFCCs = zeros(nfiles,NumBinImages);
% %     tFCCstats = zeros(nfiles,4);
% %     tFCCinitialized = true;
% % end

% StabilityMatrix = GetStabilityMatrix(BinSizes,BinMatrix,MAX_DISTANCE);
% fprintf("......Extracting Features........\n");
% [row,col,~] = size(image);
% ShowOutput = false(row,col,2*size(BinImages,3));
% [CCs,CCstats,Features,~] = GetAllFeatures(BinSizes,MAX_DISTANCE,StabilityMatrix,false);
% CCs

% save('viewWorkingFeatures.mat','Features')
% save('viewWorkingCCstats.mat','CCstats')
% save('viewWorkingCCs.mat','CCs')
        

% 
% fprintf(".....Combining and removing components....\n");
% 
if ~isImageCombined
    q_offset = 0;
for i = 1:numel(BinSizes)
    main_offset = ceil(MAX_DISTANCE/BinSizes(i));
    for img_no = (q_offset+1):(q_offset+main_offset)
        
        if img_no ~= (q_offset+main_offset)
            ShowOutput(:,:,(2*(img_no-1)+1)) = ReduceToMainCCs(logical(BinImages(:,:,img_no)+BinImages(:,:,(img_no+main_offset))));
        else
            ShowOutput(:,:,(2*(img_no-1)+1)) = ReduceToMainCCs(logical(BinImages(:,:,img_no)));
        end
    end
    
    for img_no = (q_offset+main_offset+1):(q_offset+2*main_offset-1)
        ShowOutput(:,:,(2*(img_no-1)+1)) = ReduceToMainCCs(logical(BinImages(:,:,img_no)+BinImages(:,:,(img_no-main_offset+1))));
    end
    
    q_offset = q_offset + 2*main_offset -1;
end
     ShowOutputSaved = ShowOutput;
    save(strcat('ShowOutputImages',int2str(image_no),'.mat'),'ShowOutputSaved');
else
   load(strcat('ShowOutputImages',int2str(image_no),'.mat'));
   ShowOutput = ShowOutputSaved;
end

load('viewWorkingFeatures.mat','Features')
load('viewWorkingCCstats.mat','CCstats')
load('viewWorkingCCs.mat','CCs') 


% img_no = image_no;
% hasParametersSupplied = true;
% 
% startCC =  FCCs_indexes(img_no,1);
% endCC = FCCs_indexes(img_no,2);
% 
% startCCstats = FCCstats_indexes(img_no,1);
% endCCstats = FCCstats_indexes(img_no,2);
% 
% startFeatures = FFeatures_indexes(img_no,1);
% endFeatures = FFeatures_indexes(img_no,2);
% 
% CCs = FCCs(startCC:endCC,:);
% CCstats = FCCstats(startCCstats:endCCstats,:);
% Features = FFeatures(startFeatures:endFeatures,:);

hasParametersSupplied = true;
parameters = [1 1 1 1 1 1 0 1 1 1 0 1 0 1 0 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 0 1 0 1 0 1 0 1 1];
parameters(1,16:19) = 2;
fprintf("......Get Bounding Boxes...\n");
MapBB(CCs,CCstats,Features,true,hasParametersSupplied,parameters);

fprintf("......Printing......\n");
NumImages = size(ShowOutput,3);
for j=(1:NumImages)
    F_img = ShowOutput(:,:,j);
    name = strrep('i (101).jpg',strcat('.',file_ext),'');
    name3=strcat(name,'_');
    name3 = strcat(name3, int2str(j));
    saveFile3=strcat(ShowOutput_dir,name3,'.jpg');

    imwrite(F_img,saveFile3,'jpg');

end
end

