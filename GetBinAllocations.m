function [X] = GetBinAllocations(BinSizes,MAX_DISTANCE,NumBinImages)

   X = zeros(NumBinImages,4);
   %[ imageNo Size start end ]
   q_offset = 0;
   for i = 1:numel(BinSizes)
      main_offset = ceil(MAX_DISTANCE/BinSizes(i));
      k = ceil((BinSizes(i)/2)) -1;
      start = 0;
      for img_no = (q_offset+1):(q_offset+main_offset)
          X(img_no,:) = [img_no BinSizes(i) start (start+BinSizes(i)-1)];
          start = start + BinSizes(i);
      end
       start = k+1;
      for img_no = (q_offset+main_offset+1):(q_offset+2*main_offset-1)
           X(img_no,:) = [img_no BinSizes(i) start (start+BinSizes(i))];
          start = start + BinSizes(i);          
      end    
       
      q_offset = q_offset + 2*main_offset-1; 
   end


end