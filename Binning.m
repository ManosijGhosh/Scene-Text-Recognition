 function [BinImages,NUM_BIN_IMAGES,MAX_DISTANCE] = Binning( image,BinSizes)
  %reduced = 186;
 
 
 image = histeq(image);
 

 MAX_DISTANCE = 255;

 NUM_BIN_IMAGES = calculateNumBins_2Level(BinSizes,MAX_DISTANCE);

  
 [row,col,~] = size(image);
 

 BinImages = false(row,col,NUM_BIN_IMAGES);
 
 
  
 q_offset = 0;
 DistanceMatrix = zeros(row,col);

 for r = 1:row
     for c = 1:col
        if size(image,3) == 1
            DistanceMatrix(r,c) = image(r,c);   %%ASSUMED GRAY SCALE IMAGE,OTHERWISE VALUE ARE RGB Euclidean distance
        else
            DistanceMatrix(r,c) = image(r,c);
        end
        
     end
 end
 
 for i = 1:numel(BinSizes)
   main_offset = ceil(MAX_DISTANCE/BinSizes(i));
   k = ceil((BinSizes(i)/2)) -1;
   % fprintf("\nMapping Image to Bin Size: %d",BinSizes(i));
   for r = 1:row
        for c = 1:col
     
       value = DistanceMatrix(r,c);

         x = q_offset+floor(value/BinSizes(i))+1;
          BinImages(r,c,x) = 1;

         if value>k && value<(((main_offset-1)*BinSizes(i))+k)        %%CHANGES IN MAX DISTANCE MADE
            y = q_offset+main_offset+ceil((value-k)/BinSizes(i));
            BinImages(r,c,y) = 1;
         end
           
        end   
   end
    
    q_offset = q_offset+2*main_offset-1;
 end
 
 
 end
     
 






   
   