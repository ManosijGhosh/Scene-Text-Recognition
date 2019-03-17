function [images] = ReduceToMainCCs(images)


[row,col,numImages] = size(images);

parfor img_no = 1:numImages
    img = images(:,:,img_no);
    CCimg = bwconncomp(img);
    
    temp_img = zeros(row,col);

    
    stat = regionprops(CCimg,'BoundingBox');
    
    for comp_no = 1:CCimg.NumObjects
        width = stat(comp_no).BoundingBox(3);
        height = stat(comp_no).BoundingBox(4);
        pixel_count = numel(CCimg.PixelIdxList{comp_no});
        if width > 0.04*min(row,col) && height > 0.04*min(row,col) && pixel_count > 0.000064*(row*col)
            temp_img(CCimg.PixelIdxList{comp_no}) = 1;
        end
        
    end
    
    images(:,:,img_no) = temp_img;
end

end