function [NUM_BIN_IMAGES,MAX_DISTANCE] = Binning( image,BinSizes)
global BinImages
%% This function Bins the images based on BinSizes and returns a set of Binary Images(:BinSizes) ,the number of such Images(:BUM_BIN_IMAGES)
%  And the maximum value of a pixel(for grey scale it's 255)
%CODE

image = histeq(image);


MAX_DISTANCE = 255;

NUM_BIN_IMAGES = calculateNumBins_2Level(BinSizes,MAX_DISTANCE);


[row,col,~] = size(image);


BinImages = false(row,col,NUM_BIN_IMAGES);

BinMatrix = GetBinAllocations(BinSizes,MAX_DISTANCE,NUM_BIN_IMAGES);

q_offset = 0;
DistanceMatrix = zeros(row,col);

for r = 1:row
    for c = 1:col
        if size(image,3) == 1
            DistanceMatrix(r,c) = double(image(r,c));   %%ASSUMED GRAY SCALE IMAGE,OTHERWISE VALUE ARE RGB Euclidean distance
        else
            DistanceMatrix(r,c) = double(image(r,c));
        end
        
    end
end

for i = 1:size(BinSizes,2)
    main_offset = ceil(MAX_DISTANCE/BinSizes(1,i));
    k = ceil((BinSizes(1,i)/2)) -1;
    % fprintf("\nMapping Image to Bin Size: %d",BinSizes(i));
    for r = 1:row
        for c = 1:col
            
            value = DistanceMatrix(r,c);
            
            x = q_offset+floor(value/BinSizes(1,i))+1;
            BinImages(r,c,x) = 1;
            if BinMatrix(x,3) > value || BinMatrix(x,4) < value
                warning("ERROR:: ");
                fprintf("\nERROR; VALUES ARE NOT MAPPING TO BIN_MATRIX for pixel value= %d , Mapped to Main Bin = %d\n",value,x);
            end
            
            if value>k && value<(((main_offset-1)*BinSizes(1,i))+k)        %%CHANGES IN MAX DISTANCE MADE
                y = q_offset+main_offset+ceil((value-k)/BinSizes(1,i));
                BinImages(r,c,y) = 1;
                if BinMatrix(y,3) > value || BinMatrix(y,4) < value
                    fprintf("\nERROR; VALUES ARE NOT MAPPING TO BIN_MATRIX for pixel value= %d , Mapped to Offset Bin = %d, k = %d Main_offset*BinSizes = %d\n",value,y,k,(((main_offset-1)*BinSizes(i))+k+1));
                end
            end
            
        end
    end
    
    q_offset = q_offset+2*main_offset-1;
end
end