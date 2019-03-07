function [output] = GetStabilityMatrix(BinSizes,BinMatrix,MAX_DISTANCE)

   
   
   NUM_BIN_IMAGES = calculateNumBins_2Level(BinSizes,MAX_DISTANCE);
   output_size = NUM_BIN_IMAGES;  %Must be changed if BinSizes Changes
   output = zeros(output_size,10);

   


   q_offset = 0;
   insert = 1;
 
   for i = 1:numel(BinSizes)                        %%LOOP TO CHANGE FOR DIFFERENT BIN SIZES    
       main_offset = ceil(MAX_DISTANCE/BinSizes(i)); 
       for img_no = (q_offset+1):(q_offset+main_offset)
           
        lower_bin_limit = (img_no-q_offset-1)*BinSizes(1,i);
        k = ceil((BinSizes(1,i)/2)) -1;
        upper_bin_limit = min(440,k+(img_no-q_offset)*BinSizes(1,i));
        [upper_range_check_img_no_1,upper_range_check_img_no_2,j] = GetUpperRangeImage(lower_bin_limit,upper_bin_limit,i,q_offset,BinSizes,MAX_DISTANCE);
        
        
        if upper_range_check_img_no_1 ==0 || upper_range_check_img_no_1 == 0
           fprintf("\n GetUpperRangeImage() function gives 0,0 as an output"); 
            
        end
        
       if upper_range_check_img_no_1 >NUM_BIN_IMAGES || upper_range_check_img_no_2 >NUM_BIN_IMAGES
           fprintf("\n GetUpperRangeImage() function gives image numbers unreachable>134:: Bin index %d and img_no: %d,ret1: %d and ret2: %d",i,img_no,upper_range_check_img_no_1,upper_range_check_img_no_2);          
        end 
        
       
       
        upper_1_binSize = BinMatrix(upper_range_check_img_no_1,2);
        upper_2_binSize = BinMatrix(upper_range_check_img_no_2,2);
        
        if((i~=numel(BinSizes)) && (upper_1_binSize ~= BinSizes(1,j) || upper_2_binSize ~= BinSizes(1,j)))
            fprintf("\n Bins Do not belong to the exact next higher set: for Bin index %d and img_no: %d",i,img_no);
        end
        
        if lower_bin_limit < BinMatrix(upper_range_check_img_no_1,3) || upper_bin_limit > BinMatrix(upper_range_check_img_no_2,4)       
           fprintf("\n Incorrect Upper range Images found for Bin index: %d and img_no: %d ",i,img_no); 
        end
%         
        
        if img_no ~= (q_offset+main_offset)
         offset_img_no = img_no+main_offset;
        else
          offset_img_no = img_no;
        end 
        
      if img_no ~= q_offset+1 && img_no~=q_offset+main_offset
         output(insert,8:10) = [img_no (img_no+main_offset) (img_no+main_offset-1)];
         if lower_bin_limit < min(BinMatrix(img_no+main_offset-1,3)) || upper_bin_limit > BinMatrix(img_no+main_offset,4)       
           fprintf("\n Incorrect Lower range Images found for Bin index: %d and img_no: %d ",i,img_no); 
        end
      
      else
         if img_no == q_offset+main_offset
            output(insert,8:10) = [img_no (img_no+main_offset-1) (img_no+main_offset-1)];
         if lower_bin_limit < min(BinMatrix(img_no+main_offset-1,3)) || upper_bin_limit > BinMatrix(img_no,4)       
           fprintf("\n Incorrect Lower range Images found for Bin index: %d and img_no: %d ",i,img_no); 
        end
      
         else
          output(insert,8:10) = [img_no (img_no+main_offset) (img_no+main_offset)];
           if lower_bin_limit < min(BinMatrix(img_no,3)) || upper_bin_limit > BinMatrix(img_no+main_offset,4)       
              fprintf("\n Incorrect Lower range Images found for Bin index: %d and img_no: %d ",i,img_no); 
           end
      
         end
      end
      
 
        output(insert,1:7) = [BinSizes(i) img_no offset_img_no lower_bin_limit upper_bin_limit upper_range_check_img_no_1 upper_range_check_img_no_2 ];
        insert = insert+1;
       end
       
       
       for img_no = (q_offset+main_offset+1):(q_offset+2*main_offset-1)
            k = ceil((BinSizes(i)/2)) -1;
            lower_bin_limit = k+(img_no-q_offset-main_offset-1)*BinSizes(1,i);     
            upper_bin_limit = min(440,(img_no-q_offset-main_offset+1)*BinSizes(1,i));
            [upper_range_check_img_no_1,upper_range_check_img_no_2,j] = GetUpperRangeImage(lower_bin_limit,upper_bin_limit,i,q_offset,BinSizes,MAX_DISTANCE);
      

            main_img_no = img_no-main_offset+1;
         
      
         output(insert,8:10) = [img_no (img_no-main_offset) (img_no-main_offset+1)];
       if upper_range_check_img_no_1 ==0 || upper_range_check_img_no_1 == 0
           fprintf("\n GetUpperRangeImage() function gives 0,0 as an output"); 
            
        end
        
       if upper_range_check_img_no_1 >NUM_BIN_IMAGES || upper_range_check_img_no_2 >NUM_BIN_IMAGES
           fprintf("\n GetUpperRangeImage() function gives image numbers unreachable>134:: Bin index %d and img_no: %d,ret1: %d and ret2: %d",i,img_no,upper_range_check_img_no_1,upper_range_check_img_no_2);          
       end 
        
        if((i~=numel(BinSizes)) && (upper_1_binSize ~= BinSizes(1,j) || upper_2_binSize ~= BinSizes(1,j)))
            fprintf("\n Bins Do not belong to the exact next higher set: for Bin index %d and img_no: %d",i,img_no);
%         else
%             if((i==size(BinSizes,2) && (upper_1_binSize ~= BinSizes(i) || upper_2_binSize ~= BinSizes(i))))
%                fprintf("\n Bins Do not belong to the same bin size for the last Bin Size: For Bin index: %d and img_no: %d",i,img_no);  
%             end
        end
        
        if lower_bin_limit < BinMatrix(upper_range_check_img_no_1,3) || upper_bin_limit > BinMatrix(upper_range_check_img_no_2,4)       
           fprintf("\n Incorrect Upper range Images found for Bin index: %d and img_no: %d ",i,img_no); 
        end
%         
        
   
      
            output(insert,1:7) = [BinSizes(i) img_no main_img_no lower_bin_limit upper_bin_limit upper_range_check_img_no_1 upper_range_check_img_no_2 ];
            insert = insert+1;
           
       end
       
       q_offset = q_offset+2*main_offset-1;
   end

end