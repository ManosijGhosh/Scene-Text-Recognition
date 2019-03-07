function [NUM_BIN_IMAGES] = calculateNumBins_2Level(BinSizes,MAX_DISTANCE)

   NUM_BIN_IMAGES = 0;
 for i = 1:numel(BinSizes)
   main_offset = ceil(MAX_DISTANCE/BinSizes(1,i));
    NUM_BIN_IMAGES = NUM_BIN_IMAGES+2*main_offset-1;
 end
  


end