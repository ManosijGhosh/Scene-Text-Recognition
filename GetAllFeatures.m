function [CCs,CCstats,Features,FinalBinImages] = GetAllFeatures(BinImages,BinSizes,StabilityCheckMatrix,getFinalBinImages) % Make 2nd one false for speed


%% Features Extracted

   % 1. Lower Range Pixel Deviatiion ([0,Inf])
   % 2. Higher Range Pixel Deviation ([0,Inf])
   % 3. Lower Range change of Euler Number([0,Inf))
   % 4. Higher Range change of Euler Number([0,Inf))
   % 5. Lower Range Density Deviation ([0,Inf])
   % 6. Higher Range Density Deviation ([0,Inf])
   % 7. No. of Pixels [0,Inf)
   % 8. Height (1,Inf)
   % 9. Width  (1,Inf)
   % 10. Solidity [0,1]
   % 11. Euler [0,Inf)
   
   % 12  Eccentricity [0,1]
   % 13. Extent [0,1]
   % 14. SVT [0,1]
   % 15. eHOG [0,1]

   Features = zeros(1,15);
 

%% CODE
 show_error = false;  %% CHANGE TO TRUE TO SHOW ERRORS
[row,col,NUM_BIN_IMAGES] = size(BinImages);

cc_no = 1;
 palate = zeros(row,col);
 
 if getFinalBinImages
    FinalBinImages = zeros(size(BinImages));
 else
     FinalBinImages = zeros(1,1); % NA IF FINAL BIN IMAGES NOT WANTED
 end
 
 
 
 
q_offset = 0;  
         for i = 1:numel(BinSizes) %Must change Loop for change in Bin
         
        main_offset = ceil(MAX_DISTANCE/BinSizes(i));
       k = ceil((BinSizes(i)/2)) -1;
   
    %For 1st Level Bins
       for img_no = (q_offset+1):(q_offset+main_offset)
           close all
         %fprintf("\nProcessing Bin No.: %d",img_no);
        
        if img_no ~= (q_offset+main_offset)
          scan_img = logical(BinImages(:,:,img_no)+BinImages(:,:,(img_no+main_offset)));
        else
           scan_img = logical(BinImages(:,:,img_no));
        end
%         label_scan_img = bwlabel(scan_img);
        CC_scan_img = bwconncomp(scan_img);
        CCs(cc_no) = CC_scan_img;

        
        lower_overlap_bin_no = img_no + main_offset-1;
        upper_overlap_bin_no = img_no+main_offset;
           if((img_no > NUM_BIN_IMAGES) || ((img_no+main_offset)> NUM_BIN_IMAGES && img_no~=q_offset+main_offset))
               
              fprintf("\nLoop Error,img_value >134;printing loop at Bin Index: %d main_offset = %d ,q_offset = %d\n" ,main_offset,q_offset);
               
           end
        %The Smaller range against which to check stability
      if img_no > q_offset+1 && img_no<(q_offset+main_offset)
         lower_range_check_img = logical(BinImages(:,:,img_no)+BinImages(:,:,lower_overlap_bin_no) + BinImages(:,:,upper_overlap_bin_no));
      else
         if img_no == q_offset+main_offset
           lower_range_check_img = logical(BinImages(:,:,img_no)+ BinImages(:,:,lower_overlap_bin_no)); 
         else
          lower_range_check_img = logical(BinImages(:,:,img_no)+BinImages(:,:,upper_overlap_bin_no));
         end
      end
      lower_range_check_CC = bwconncomp(lower_range_check_img);
      

        upper_range_check_img_no_1= StabilityCheckMatrix(img_no,6);
        upper_range_check_img_no_2= StabilityCheckMatrix(img_no,7);


      upper_range_check_img = logical(BinImages(:,:,upper_range_check_img_no_1)+BinImages(:,:,upper_range_check_img_no_2));
      upper_range_check_CC = bwconncomp(upper_range_check_img);
      
      lower_range_bwimage = bwlabel(lower_range_check_img);
      upper_range_bwimage = bwlabel(upper_range_check_img);
      
       stats = regionprops(CC_scan_img,'EulerNumber','Solidity','BoundingBox', 'Eccentricity', 'Extent');
       CCstats(cc_no) = stats;
        lower_check_stats = regionprops(lower_range_check_img,'EulerNumber','Solidity');
       upper_check_stats = regionprops(upper_range_check_img,'EulerNumber','Solidity');
    for comp = 1:CC_scan_img.NumObjects
            FeatureValues(:,:) = 0;
           lower_range_overlap_comp = findLabels(lower_range_bwimage(CC_scan_img.PixelIdxList{comp}),2); %Make to 1 for speed
           upper_range_overlap_comp = findLabels(upper_range_bwimage(CC_scan_img.PixelIdxList{comp}),2);
      
        if  (lower_range_overlap_comp(1,2) ~= 0 || lower_range_overlap_comp(1,1) == 0) 
            if show_error
             fprintf("\n Wrong Calculation in LOWER Range Check Image");
             figure('Name','ERROR:No Overlap Component !! K-means Component being scanned');
             error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
             imshow(error_figure);
             figure('Name','ERROR:Overlap Component !! The Lower Range Overlap Image');
             error_figure(:,:) = 0;
             imshow(lower_range_check_img);
            end
           continue;
        end
        
        if  (upper_range_overlap_comp(1,2) ~= 0 || upper_range_overlap_comp(1,1) == 0 )  
            if show_error
                fprintf("\n Wrong Calculation in LOWER Range Check Image");
                figure('Name','ERROR:No Overlap Component!! K-means Component being scanned');
                error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
                imshow(error_figure);
                figure('Name','ERROR:No Overlap Component!! The Upper Range Overlap Image');
                error_figure(:,:) = 0;
                imshow(upper_range_check_img);
            end
           continue;
        end
        
        comp_num_of_pixels = numel(CC_scan_img.PixelIdxList{comp});
        
        upper_range_comp_no_pixels = numel(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)});
        lower_range_comp_no_pixels = numel(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)});
        
        if show_error && (comp_num_of_pixels > lower_range_comp_no_pixels)        
           fprintf("\nError in Finding Correct LOWER Range Component: Size of Overlap reduced ");
           figure('Name','ERROR: Size Reduction!! K-means Component being scanned');
           error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
           imshow(error_figure);
           figure('Name','ERROR:Size Reduction!! The Lower Range Overlap Image');
           error_figure(:,:) = 0;
           imshow(lower_range_check_img);
           figure('Name','ERROR:Size Redution!! The Lower Range Overlap Component');
           error_figure(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)}) = 1;
           imshow(error_figure);
           error_figure(:,:) = 0;
           continue;
        end

        if show_error && (comp_num_of_pixels > upper_range_comp_no_pixels)          
          fprintf("\nError in Finding Correct UPPER Range Component: Size of Overlap reduced ");
           figure('Name','ERROR: Size Reduction!! K-means Component being scanned');
           error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
           imshow(error_figure);
           figure('Name','ERROR:Size Reduction!! The Upper Range Overlap Image');
           error_figure(:,:) = 0;
           imshow(upper_range_check_img);
           figure('Name','ERROR:Size Redution!! The Upper Range Overlap Component');
           error_figure(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)}) = 1;
           imshow(error_figure);
           error_figure(:,:) = 0;
           continue;
        end
            

     FeatureValues(1,1) = (abs(numel(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)}) - numel(CC_scan_img.PixelIdxList{comp})))/numel(CC_scan_img.PixelIdxList{comp});        
     FeatureValues(1,2) = (abs(numel(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)}) - numel(CC_scan_img.PixelIdxList{comp})))/numel(CC_scan_img.PixelIdxList{comp});        
     FeatureValues(1,3) = lower_check_stats(lower_range_overlap_comp(1,1)).EulerNumber - stats(comp).EulerNumber;     
     FeatureValues(1,4) = upper_check_stats(upper_range_overlap_comp(1,1)).EulerNumber - stats(comp).EulerNumber; 
     FeatureValues(1,5) = (abs(lower_check_stats(lower_range_overlap_comp(1,1)).Solidity - stats(comp).Solidity))/ stats(comp).Solidity;
     FeatureValues(1,6) = (abs(upper_check_stats(upper_range_overlap_comp(1,1)).Solidity - stats(comp).Solidity))/ stats(comp).Solidity;
     FeatureValues(1,7) = numel(CC_scan_img.PixelIdxList{comp});    
     FeatureValues(1,8) = stats(comp).BoundingBox(4);
     FeatureValues(1,9) = stats(comp).BoundingBox(3);
          
     palate(CC_scan_img.PixelIdxList{comp}) = 1;
                
     FeatureValues(1,10:15) = [ stats(comp).Solidity stats(comp).EulerNumber stats(comp).Eccentricity stats(comp).Extent SWT(palate) eHOG(palate) ];
     palate(:,:) = 0;       
               
         
          
          
      
        Features(cc_no,:) = FeatureValues;
        cc_no = cc_no + 1;
        

        
    end
    
    
        if getFinalBinImages
            FinalBinImages(:,:,img_no) = scan_img;
        end
     
        end
  
   
   % For 2nd Level Bins
     for img_no = (q_offset+main_offset+1):(q_offset+2*main_offset-1) 
         close all
          % fprintf("\nProcessing Bin No.: %d",img_no);
        scan_img = logical(BinImages(:,:,img_no)+BinImages(:,:,(img_no-main_offset+1)));
        
      
%         label_scan_img = bwlabel(scan_img);
        CC_scan_img = bwconncomp(scan_img);
       
        
        %The Smaller range against which to check stability
  
            lower_overlap_bin_no = img_no -main_offset;
        upper_overlap_bin_no = img_no-main_offset+1;
         if((img_no > NUM_BIN_IMAGES) || (lower_overlap_bin_no> NUM_BIN_IMAGES))              
              fprintf("\nLoop Error,img_value >134;printing loop at Bin Index: %d main_offset = %d ,q_offset = %d\n" ,main_offset,q_offset);            
         end
        lower_range_check_img = logical(BinImages(:,:,img_no)+BinImages(:,:,lower_overlap_bin_no) + BinImages(:,:,upper_overlap_bin_no));

      lower_range_check_CC = bwconncomp(lower_range_check_img);

        upper_range_check_img_no_1= StabilityCheckMatrix(img_no,6);
        upper_range_check_img_no_2= StabilityCheckMatrix(img_no,7);


      upper_range_check_img = logical(BinImages(:,:,upper_range_check_img_no_1)+BinImages(:,:,upper_range_check_img_no_2));
      upper_range_check_CC = bwconncomp(upper_range_check_img);
      
      lower_range_bwimage = bwlabel(lower_range_check_img);
      upper_range_bwimage = bwlabel(upper_range_check_img);
      
       stats = regionprops(CC_scan_img,'EulerNumber','Solidity');
        lower_check_stats = regionprops(lower_range_check_img,'EulerNumber','Solidity');
       upper_check_stats = regionprops(upper_range_check_img,'EulerNumber','Solidity');
    for comp = 1:CC_scan_img.NumObjects

           lower_range_overlap_comp = findLabels(lower_range_bwimage(CC_scan_img.PixelIdxList{comp}),2); %Make to 1 for speed
           upper_range_overlap_comp = findLabels(upper_range_bwimage(CC_scan_img.PixelIdxList{comp}),2);
      
         if  (lower_range_overlap_comp(1,2) ~= 0 || lower_range_overlap_comp(1,1) == 0 )  
             if show_error
                fprintf("\n Wrong Calculation in LOWER Range Check Image");
                figure('Name','ERROR:No Overlap Component !! K-means Component being scanned');
                error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
                imshow(error_figure);
                figure('Name','ERROR:Overlap Component !! The Lower Range Overlap Image');
                error_figure(:,:) = 0;
                imshow(lower_range_check_img);
             end
           continue;
        end
        
        if  (upper_range_overlap_comp(1,2) ~= 0 || upper_range_overlap_comp(1,1) == 0 ) 
            if show_error
           fprintf("\n Wrong Calculation in LOWER Range Check Image");
           figure('Name','ERROR:No Overlap Component!! K-means Component being scanned');
           error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
           imshow(error_figure);
           figure('Name','ERROR:No Overlap Component!! The Upper Range Overlap Image');
           error_figure(:,:) = 0;
           imshow(upper_range_check_img);
            end
           continue;
        end
        
        comp_num_of_pixels = numel(CC_scan_img.PixelIdxList{comp});
        
        upper_range_comp_no_pixels = numel(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)});
        lower_range_comp_no_pixels = numel(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)});
        
        if show_error && (comp_num_of_pixels > lower_range_comp_no_pixels)         
           fprintf("\nError in Finding Correct LOWER Range Component: Size of Overlap reduced ");
           figure('Name','ERROR: Size Reduction!! K-means Component being scanned');
           error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
           imshow(error_figure);
           figure('Name','ERROR:Size Reduction!! The Lower Range Overlap Image');
           error_figure(:,:) = 0;
           imshow(lower_range_check_img);
           figure('Name','ERROR:Size Redution!! The Lower Range Overlap Component');
           error_figure(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)}) = 1;
           imshow(error_figure);
           error_figure(:,:) = 0;
           continue;
        end

        if show_error && (comp_num_of_pixels > upper_range_comp_no_pixels)         
          fprintf("\nError in Finding Correct UPPER Range Component: Size of Overlap reduced ");
           figure('Name','ERROR: Size Reduction!! K-means Component being scanned');
           error_figure(CC_scan_img.PixelIdxList{comp}) = 1;
           imshow(error_figure);
           figure('Name','ERROR:Size Reduction!! The Upper Range Overlap Image');
           error_figure(:,:) = 0;
           imshow(upper_range_check_img);
           figure('Name','ERROR:Size Redution!! The Upper Range Overlap Component');
           error_figure(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)}) = 1;
           imshow(error_figure);
           error_figure(:,:) = 0;
           continue;
        end
        
     FeatureValues(1,1) = (abs(numel(lower_range_check_CC.PixelIdxList{lower_range_overlap_comp(1,1)}) - numel(CC_scan_img.PixelIdxList{comp})))/numel(CC_scan_img.PixelIdxList{comp});        
     FeatureValues(1,2) = (abs(numel(upper_range_check_CC.PixelIdxList{upper_range_overlap_comp(1,1)}) - numel(CC_scan_img.PixelIdxList{comp})))/numel(CC_scan_img.PixelIdxList{comp});        
     FeatureValues(1,3) = lower_check_stats(lower_range_overlap_comp(1,1)).EulerNumber - stats(comp).EulerNumber;     
     FeatureValues(1,4) = upper_check_stats(upper_range_overlap_comp(1,1)).EulerNumber - stats(comp).EulerNumber; 
     FeatureValues(1,5) = (abs(lower_check_stats(lower_range_overlap_comp(1,1)).Solidity - stats(comp).Solidity))/ stats(comp).Solidity;
     FeatureValues(1,6) = (abs(upper_check_stats(upper_range_overlap_comp(1,1)).Solidity - stats(comp).Solidity))/ stats(comp).Solidity;
     FeatureValues(1,7) = numel(CC_scan_img.PixelIdxList{comp});    
     FeatureValues(1,8) = stats(comp).BoundingBox(4);
     FeatureValues(1,9) = stats(comp).BoundingBox(3);
          
     palate(CC_scan_img.PixelIdxList{comp}) = 1;
                
     FeatureValues(1,10:15) = [ stats(comp).Solidity stats(comp).EulerNumber stats(comp).Eccentricity stats(comp).Extent SWT(palate) eHOG(palate) ];
     palate(:,:) = 0;       
               
         
     Features(cc_no,:) = FeatureValues;
     cc_no = cc_no + 1;
                   
    end
        
    FinalBinImages(:,:,img_no) = scan_img;
    end
   
   q_offset = q_offset+2*main_offset-1;
        end  
   
   


end