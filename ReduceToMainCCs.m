function ReduceToMainCCs()
global BinImages

BImages =  BinImages;
[row,col,numImages] = size(BinImages);
parfor img_no = 1:numImages
    img = BImages(:,:,img_no);
    CCimg = bwconncomp(img);
    
    temp_img = false(row,col);

    
    stat = regionprops(CCimg,'BoundingBox');
    
    for comp_no = 1:CCimg.NumObjects
        width = stat(comp_no).BoundingBox(3);
        height = stat(comp_no).BoundingBox(4);
        pixel_count = numel(CCimg.PixelIdxList{comp_no});
        if width > 0.04*min(row,col) && row > 0.04*min(row,col) && pixel_count > 0.000064*(row*col) && width < 0.25*col && height < 0.25*row && pixel_count < 0.0625*(row*col)
            temp_img(CCimg.PixelIdxList{comp_no}) = 1;
        end
        
    end
    
    BImages(:,:,img_no) = temp_img;
end

BinImages = BImages;
end