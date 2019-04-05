function [PageEndings,statsBoxes,Features,FinalBinImages] = GetAllFeatures(BinSizes,MAX_DISTANCE,StabilityCheckMatrix,getFinalBinImages) % Make 2nd one false for speed

global BinImages ShowOutput
%% Features Extracted

% 1. Lower Range Pixel Deviatiion ([0,Inf])
% 2. Higher Range Pixel Deviation ([0,Inf])
% 3. Lower Range change of Euler Number/100([0,Inf))
% 4. Higher Range change of Euler Number/100([0,Inf))
% 5. Lower Range Density Deviation ([0,Inf])
% 6. Higher Range Density Deviation ([0,Inf])
% 7. No. of Pixels/MaxPixels [0,Inf)
% 8. Height/MaxHeight (1,Inf)
% 9. Width/MaxWidth (1,Inf)
% 10. Solidity [0,1]
% 11. Euler/100 [0,Inf)

% 12  Eccentricity [0,1]
% 13. Extent [0,1]
% 14. SVT [0,1]
% 15. eHOG [0,1]




%% CODE
show_error = true;  %% CHANGE TO TRUE TO SHOW ERRORS
[row,col,NUM_BIN_IMAGES] = size(BinImages);

Features = zeros(1,15);
PageEndings = zeros(1,NUM_BIN_IMAGES);
prev=0;
statsBoxes = zeros(1,4);

cc_no = 1;



if getFinalBinImages
    FinalBinImages = zeros(size(BinImages));
else
    FinalBinImages = zeros(1,1); % NA IF FINAL BIN IMAGES NOT WANTED
end


%% PREPROCESSING
scan_imgs = false(row,col,NUM_BIN_IMAGES);
lower_range_check_imgs = false(row,col,NUM_BIN_IMAGES);
upper_range_check_imgs = false(row,col,NUM_BIN_IMAGES);
lower_range_bwimages = zeros(row,col,NUM_BIN_IMAGES);
upper_range_bwimages = zeros(row,col,NUM_BIN_IMAGES);
fprintf(".......preprocessing.........\n");
q_offset = 0;
for i = 1:numel(BinSizes)
    main_offset = ceil(MAX_DISTANCE/BinSizes(i));
    parfor img_no = (q_offset+1):(q_offset+main_offset)
        
        if img_no ~= (q_offset+main_offset)
            scan_imgs(:,:,img_no) = ReduceToMainCCs(logical(BinImages(:,:,img_no)+BinImages(:,:,(img_no+main_offset))));
        else
            scan_imgs(:,:,img_no) = ReduceToMainCCs(logical(BinImages(:,:,img_no)));
        end
        
        if StabilityCheckMatrix(img_no,1) == 0
            continue;
        end
        if StabilityCheckMatrix(img_no,1) ~= 0 && StabilityCheckMatrix(max(q_offset+1,img_no-1),1) == 0
            StabilityCheckMatrix
            error('ALL IMAGES UNDER same I not equal');
        end
        
        lower_overlap_bin_no = img_no + main_offset-1;
        upper_overlap_bin_no = img_no+main_offset;
        if((img_no > NUM_BIN_IMAGES) || ((img_no+main_offset)> NUM_BIN_IMAGES && img_no~=q_offset+main_offset))
            fprintf('\nLoop Error,img_value >134;printing loop at Bin Index: %d main_offset = %d ,q_offset = %d\n' ,main_offset,q_offset);
        end
        
        %The Smaller range against which to check stability
        if img_no > q_offset+1 && img_no<(q_offset+main_offset)
            lower_range_check_imgs(:,:,img_no) = logical(BinImages(:,:,img_no)+BinImages(:,:,lower_overlap_bin_no) + BinImages(:,:,upper_overlap_bin_no));
        else
            if img_no == q_offset+main_offset
                lower_range_check_imgs(:,:,img_no) = logical(BinImages(:,:,img_no)+ BinImages(:,:,lower_overlap_bin_no));
            else
                lower_range_check_imgs(:,:,img_no) = logical(BinImages(:,:,img_no)+BinImages(:,:,upper_overlap_bin_no));
            end
        end
        lower_range_check_imgs(:,:,img_no) = ReduceToMainCCs(lower_range_check_imgs(:,:,img_no));
        
        upper_range_check_img_no_1= StabilityCheckMatrix(img_no,6);
        upper_range_check_img_no_2= StabilityCheckMatrix(img_no,7);
        
        
        
        upper_range_check_imgs(:,:,img_no) = logical(BinImages(:,:,upper_range_check_img_no_1)+BinImages(:,:,upper_range_check_img_no_2));
        upper_range_check_imgs(:,:,img_no) = ReduceToMainCCs(upper_range_check_imgs(:,:,img_no));
        
        lower_range_bwimages(:,:,img_no) = bwlabel(lower_range_check_imgs(:,:,img_no));
        upper_range_bwimages(:,:,img_no) = bwlabel(upper_range_check_imgs(:,:,img_no));
    end
    
    parfor img_no = (q_offset+main_offset+1):(q_offset+2*main_offset-1)
        
        scan_imgs(:,:,img_no) = ReduceToMainCCs(logical(BinImages(:,:,img_no)+BinImages(:,:,(img_no-main_offset+1))));
        
        
        if StabilityCheckMatrix(img_no,1) == 0
            continue;
        end
        
        if StabilityCheckMatrix(img_no,1) ~= 0 && StabilityCheckMatrix(max(q_offset+main_offset+1,img_no-1),1) == 0
            fprintf('ALL IMAGES UNDER same I not equal');
            continue;
        end
        
        %The Smaller range against which to check stability
        
        lower_overlap_bin_no = img_no -main_offset;
        upper_overlap_bin_no = img_no-main_offset+1;
        if((img_no > NUM_BIN_IMAGES) || (lower_overlap_bin_no> NUM_BIN_IMAGES))
            fprintf('\nLoop Error,img_value >134;printing loop at Bin Index: %d main_offset = %d ,q_offset = %d\n' ,main_offset,q_offset);
        end
        lower_range_check_imgs(:,:,img_no) = ReduceToMainCCs(logical(BinImages(:,:,img_no)+BinImages(:,:,lower_overlap_bin_no) + BinImages(:,:,upper_overlap_bin_no)));
        
        
        upper_range_check_img_no_1= StabilityCheckMatrix(img_no,6);
        upper_range_check_img_no_2= StabilityCheckMatrix(img_no,7);
        
        
        upper_range_check_imgs(:,:,img_no) = ReduceToMainCCs(logical(BinImages(:,:,upper_range_check_img_no_1)+BinImages(:,:,upper_range_check_img_no_2)));
        
        lower_range_bwimages(:,:,img_no) = bwlabel(lower_range_check_imgs(:,:,img_no));
        upper_range_bwimages(:,:,img_no) = bwlabel(upper_range_check_imgs(:,:,img_no));
        
    end
    
    q_offset = q_offset + 2*main_offset - 1;
end

%% EXTRACTING
q_offset = 0;
fprintf("....extracting..........\n\n");




for i = 1:numel(BinSizes) %Must change Loop for change in Bin
    
    if i~=1 && StabilityCheckMatrix(q_offset+1,1) ~= 0 && StabilityCheckMatrix(max(1,q_offset-2*main_offset+1),1) == 0
        StabilityCheckMatrix
        error('GAP:: i = %d has a checking bin but before that does not',i);
    end
    main_offset = ceil(MAX_DISTANCE/BinSizes(i));
    k = ceil((BinSizes(i)/2)) -1;
    
    if StabilityCheckMatrix(q_offset+1,1) ~= 0 && StabilityCheckMatrix(max(1,q_offset-2*main_offset),1) == 0
        StabilityCheckMatrix
        error('ALL IMAGES UNDER same I not equal');
    end
    
    %For 1st Level Bins
    for img_no = (q_offset+1):(q_offset+main_offset)
        
        scan_img = scan_imgs(:,:,img_no);
        CC_scan_img = bwconncomp(scan_img);
        
        
        if StabilityCheckMatrix(img_no,1) == 0
            continue;
        end
        if StabilityCheckMatrix(img_no,1) ~= 0 && StabilityCheckMatrix(max(q_offset+1,img_no-1),1) == 0
            StabilityCheckMatrix
            error('ALL IMAGES UNDER same I not equal');
        end
        
        PageEndings(1,img_no) = prev + CC_scan_img.NumObjects;
        prev = PageEndings(1,img_no);
        
        if CC_scan_img.NumObjects == 0
            continue;
        end
        

        
        
        if((img_no > NUM_BIN_IMAGES) || ((img_no+main_offset)> NUM_BIN_IMAGES && img_no~=q_offset+main_offset))
            fprintf('\nLoop Error,img_value >134;printing loop at Bin Index: %d main_offset = %d ,q_offset = %d\n' ,main_offset,q_offset);
        end
        %The Smaller range against which to check stability
        
        lower_range_check_img =  lower_range_check_imgs(:,:,img_no);
        
        lower_range_check_CC = bwconncomp(lower_range_check_img);
        
        
        upper_range_check_img = upper_range_check_imgs(:,:,img_no);
        upper_range_check_CC = bwconncomp(upper_range_check_img);
        
        lower_range_bwimage = lower_range_bwimages(:,:,img_no);
        upper_range_bwimage = upper_range_bwimages(:,:,img_no);
        
        stats = regionprops(CC_scan_img,'EulerNumber','Solidity','BoundingBox', 'Eccentricity', 'Extent');
        
        
        lower_check_stats = regionprops(lower_range_check_img,'EulerNumber','Solidity');
        upper_check_stats = regionprops(upper_range_check_img,'EulerNumber','Solidity');
        CompFeatureValues = zeros(CC_scan_img.NumObjects,15);
        CompstatsBoxes = zeros(CC_scan_img.NumObjects,4);
        parfor comp = 1:CC_scan_img.NumObjects
            
            FeatureValues = zeros(1,15);
            
            
            region = CC_scan_img.PixelIdxList{comp};
            lower_range_overlap_comp = lower_range_bwimage(region(1)); %Make to 1 for speed
            upper_range_overlap_comp = upper_range_bwimage(region(1));
            
            %                         if  (lower_range_overlap_comp(1,2) ~= 0 || lower_range_overlap_comp(1,1) == 0)
            %                             if show_error
            %                                 fprintf('\n Wrong Calculation in LOWER Range Check Image in MAIN Loop for img_no = %d, i = %d',img_no,i);
            %             %                     figure('Name','ERROR:No Overlap Component !! K-means Component being scanned');
            %             %                     error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
            %             %                     imshow(error_figure);
            %             %                     figure('Name','ERROR:Overlap Component !! The Lower Range Overlap Image');
            %             %                     error_figure(:,:) = 0;
            %             %                     imshow(lower_range_check_img);
            %                             end
            %                             %count_errors = count_errors +1;
            %                             continue;
            %                         end
            %
            %                         if  (upper_range_overlap_comp(1,2) ~= 0 || upper_range_overlap_comp(1,1) == 0 )
            %                             if show_error
            %                                 fprintf('\n Wrong Calculation in UPPER Range Check Image in MAIN LOOP for img_no = %d, i = %d',img_no,i);
            %             %                     figure('Name','ERROR:No Overlap Component!!Component being scanned');
            %             %                     error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
            %             %                     imshow(error_figure);
            %             %                     figure('Name','ERROR:No Overlap Component!! The Upper Range Overlap Image');
            %             %                     error_figure(:,:) = 0;
            %             %                     imshow(upper_range_check_img);
            %                             end
            %                            % count_errors = count_errors +1;
            %                             continue;
            %                         end
            
            comp_num_of_pixels = numel(CC_scan_img.PixelIdxList{comp});
            
            upper_range_comp_no_pixels = numel(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)});
            lower_range_comp_no_pixels = numel(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)});
            
            if show_error && (comp_num_of_pixels > lower_range_comp_no_pixels)
                fprintf('\nError in Finding Correct LOWER Range Component: Size of Overlap reduced ');
                %                 figure('Name','ERROR: Size Reduction!! K-means Component being scanned');
                %                 error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
                %                 imshow(error_figure);
                %                 figure('Name','ERROR:Size Reduction!! The Lower Range Overlap Image');
                %                 error_figure(:,:) = 0;
                %                 imshow(lower_range_check_img);
                %                 figure('Name','ERROR:Size Redution!! The Lower Range Overlap Component');
                %                 error_figure(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)}) = 1;
                %                 imshow(error_figure);
                %                 error_figure(:,:) = 0;
                continue;
            end
            
            if show_error && (comp_num_of_pixels > upper_range_comp_no_pixels)
                fprintf('\nError in Finding Correct UPPER Range Component: Size of Overlap reduced ');
                %                 figure('Name','ERROR: Size Reduction!! K-means Component being scanned');
                %                 error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
                %                 imshow(error_figure);
                %                 figure('Name','ERROR:Size Reduction!! The Upper Range Overlap Image');
                %                 error_figure(:,:) = 0;
                %                 imshow(upper_range_check_img);
                %                 figure('Name','ERROR:Size Redution!! The Upper Range Overlap Component');
                %                 error_figure(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)}) = 1;
                %                 imshow(error_figure);
                %                 error_figure(:,:) = 0;
                continue;
            end
            
            
            FeatureValues(1,1) = (abs(lower_range_comp_no_pixels - comp_num_of_pixels))/comp_num_of_pixels;
            FeatureValues(1,2) = (abs(upper_range_comp_no_pixels - comp_num_of_pixels))/comp_num_of_pixels;
            FeatureValues(1,3) = (lower_check_stats(lower_range_overlap_comp(1,1)).EulerNumber - stats(comp).EulerNumber)/100;
            FeatureValues(1,4) = (upper_check_stats(upper_range_overlap_comp(1,1)).EulerNumber - stats(comp).EulerNumber)/100;
            FeatureValues(1,5) = (abs(lower_check_stats(lower_range_overlap_comp(1,1)).Solidity - stats(comp).Solidity))/ stats(comp).Solidity;
            FeatureValues(1,6) = (abs(upper_check_stats(upper_range_overlap_comp(1,1)).Solidity - stats(comp).Solidity))/ stats(comp).Solidity;
            FeatureValues(1,7) = comp_num_of_pixels/(row*col);
            FeatureValues(1,8) = stats(comp).BoundingBox(4)/row;
            FeatureValues(1,9) = stats(comp).BoundingBox(3)/col;
            
            palate = zeros(row,col);
            palate(CC_scan_img.PixelIdxList{comp}) = 1;
            
            FeatureValues(1,10:15) = [ stats(comp).Solidity (stats(comp).EulerNumber)/100 stats(comp).Eccentricity stats(comp).Extent SWT(palate) eHOG(palate) ];
            
            
            CompFeatureValues(comp,:) = FeatureValues;
            CompstatsBoxes(comp,:) = stats(comp).BoundingBox;
            
        end
        Features(cc_no:cc_no+size(CompFeatureValues,1)-1,:) = CompFeatureValues;
        statsBoxes(cc_no:cc_no+size(CompFeatureValues,1)-1,:) = CompstatsBoxes;
        cc_no = cc_no+size(CompFeatureValues,1);
        
        if getFinalBinImages
            FinalBinImages(:,:,img_no) = scan_img;
        end
        
    end
    
    
    % For 2nd Level Bins
    for img_no = (q_offset+main_offset+1):(q_offset+2*main_offset-1)
        
        scan_img = scan_imgs(:,:,img_no);
        CC_scan_img = bwconncomp(scan_img);
        
        
        if StabilityCheckMatrix(img_no,1) == 0
            continue;
        end
        if StabilityCheckMatrix(img_no,1) ~= 0 && StabilityCheckMatrix(max(q_offset+1,img_no-1),1) == 0
            StabilityCheckMatrix
            error('ALL IMAGES UNDER same I not equal');
        end
        
        PageEndings(1,img_no) = prev + CC_scan_img.NumObjects;
        prev = PageEndings(1,img_no);
        
        if CC_scan_img.NumObjects == 0
            continue;
        end
        

        
        
        if((img_no > NUM_BIN_IMAGES) || ((img_no+main_offset)> NUM_BIN_IMAGES && img_no~=q_offset+main_offset))
            fprintf('\nLoop Error,img_value >134;printing loop at Bin Index: %d main_offset = %d ,q_offset = %d\n' ,main_offset,q_offset);
        end
        %The Smaller range against which to check stability
        
        lower_range_check_img =  lower_range_check_imgs(:,:,img_no);
        
        lower_range_check_CC = bwconncomp(lower_range_check_img);
        
        
        upper_range_check_img = upper_range_check_imgs(:,:,img_no);
        upper_range_check_CC = bwconncomp(upper_range_check_img);
        
        lower_range_bwimage = lower_range_bwimages(:,:,img_no);
        upper_range_bwimage = upper_range_bwimages(:,:,img_no);
        
        stats = regionprops(CC_scan_img,'EulerNumber','Solidity','BoundingBox', 'Eccentricity', 'Extent');
        
        
        lower_check_stats = regionprops(lower_range_check_img,'EulerNumber','Solidity');
        upper_check_stats = regionprops(upper_range_check_img,'EulerNumber','Solidity');
        CompFeatureValues = zeros(CC_scan_img.NumObjects,15);
        CompstatsBoxes = zeros(CC_scan_img.NumObjects,4);
        
        parfor comp = 1:CC_scan_img.NumObjects
            FeatureValues = zeros(1,15);
            
            
            region = CC_scan_img.PixelIdxList{comp};
            lower_range_overlap_comp = lower_range_bwimage(region(1)); %Make to 1 for speed
            upper_range_overlap_comp = upper_range_bwimage(region(1));
            
            %                         if  (lower_range_overlap_comp(1,2) ~= 0 || lower_range_overlap_comp(1,1) == 0)
            %                             if show_error
            %                                 fprintf('\n Wrong Calculation in LOWER Range Check Image in MAIN Loop for img_no = %d, i = %d',img_no,i);
            %             %                     figure('Name','ERROR:No Overlap Component !! K-means Component being scanned');
            %             %                     error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
            %             %                     imshow(error_figure);
            %             %                     figure('Name','ERROR:Overlap Component !! The Lower Range Overlap Image');
            %             %                     error_figure(:,:) = 0;
            %             %                     imshow(lower_range_check_img);
            %                             end
            %                             %count_errors = count_errors +1;
            %                             continue;
            %                         end
            %
            %                         if  (upper_range_overlap_comp(1,2) ~= 0 || upper_range_overlap_comp(1,1) == 0 )
            %                             if show_error
            %                                 fprintf('\n Wrong Calculation in UPPER Range Check Image in MAIN LOOP for img_no = %d, i = %d',img_no,i);
            %             %                     figure('Name','ERROR:No Overlap Component!!Component being scanned');
            %             %                     error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
            %             %                     imshow(error_figure);
            %             %                     figure('Name','ERROR:No Overlap Component!! The Upper Range Overlap Image');
            %             %                     error_figure(:,:) = 0;
            %             %                     imshow(upper_range_check_img);
            %                             end
            %                            % count_errors = count_errors +1;
            %                             continue;
            %                         end
            
            comp_num_of_pixels = numel(CC_scan_img.PixelIdxList{comp});
            
            upper_range_comp_no_pixels = numel(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)});
            lower_range_comp_no_pixels = numel(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)});
            
            if show_error && (comp_num_of_pixels > lower_range_comp_no_pixels)
                fprintf('\nError in Finding Correct LOWER Range Component: Size of Overlap reduced ');
                %                 figure('Name','ERROR: Size Reduction!! K-means Component being scanned');
                %                 error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
                %                 imshow(error_figure);
                %                 figure('Name','ERROR:Size Reduction!! The Lower Range Overlap Image');
                %                 error_figure(:,:) = 0;
                %                 imshow(lower_range_check_img);
                %                 figure('Name','ERROR:Size Redution!! The Lower Range Overlap Component');
                %                 error_figure(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)}) = 1;
                %                 imshow(error_figure);
                %                 error_figure(:,:) = 0;
                continue;
            end
            
            if show_error && (comp_num_of_pixels > upper_range_comp_no_pixels)
                fprintf('\nError in Finding Correct UPPER Range Component: Size of Overlap reduced ');
                %                 figure('Name','ERROR: Size Reduction!! K-means Component being scanned');
                %                 error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
                %                 imshow(error_figure);
                %                 figure('Name','ERROR:Size Reduction!! The Upper Range Overlap Image');
                %                 error_figure(:,:) = 0;
                %                 imshow(upper_range_check_img);
                %                 figure('Name','ERROR:Size Redution!! The Upper Range Overlap Component');
                %                 error_figure(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)}) = 1;
                %                 imshow(error_figure);
                %                 error_figure(:,:) = 0;
                continue;
            end
            
            
            FeatureValues(1,1) = (abs(lower_range_comp_no_pixels - comp_num_of_pixels))/comp_num_of_pixels;
            FeatureValues(1,2) = (abs(upper_range_comp_no_pixels - comp_num_of_pixels))/comp_num_of_pixels;
            FeatureValues(1,3) = (lower_check_stats(lower_range_overlap_comp(1,1)).EulerNumber - stats(comp).EulerNumber)/100;
            FeatureValues(1,4) = (upper_check_stats(upper_range_overlap_comp(1,1)).EulerNumber - stats(comp).EulerNumber)/100;
            FeatureValues(1,5) = (abs(lower_check_stats(lower_range_overlap_comp(1,1)).Solidity - stats(comp).Solidity))/ stats(comp).Solidity;
            FeatureValues(1,6) = (abs(upper_check_stats(upper_range_overlap_comp(1,1)).Solidity - stats(comp).Solidity))/ stats(comp).Solidity;
            FeatureValues(1,7) = comp_num_of_pixels/(row*col);
            FeatureValues(1,8) = stats(comp).BoundingBox(4)/row;
            FeatureValues(1,9) = stats(comp).BoundingBox(3)/col;
            
            palate = zeros(row,col);
            palate(CC_scan_img.PixelIdxList{comp}) = 1;
            
            FeatureValues(1,10:15) = [ stats(comp).Solidity (stats(comp).EulerNumber)/100 stats(comp).Eccentricity stats(comp).Extent SWT(palate) eHOG(palate) ];
            
            
            CompFeatureValues(comp,:) = FeatureValues;
            CompstatsBoxes(comp,:) = stats(comp).BoundingBox;
            
        end
        Features(cc_no:cc_no+size(CompFeatureValues,1)-1,:) = CompFeatureValues;
        statsBoxes(cc_no:cc_no+size(CompFeatureValues,1)-1,:) = CompstatsBoxes;
        cc_no = cc_no+size(CompFeatureValues,1);
        
        if getFinalBinImages
            FinalBinImages(:,:,img_no) = scan_img;
        end
        
    end
    
    q_offset = q_offset+2*main_offset-1;
end
fprintf("..To be removed...\n");
PageEndings

ShowOutput(:,:,1:2:end) = scan_imgs;
end