function [BoundingBoxes] = fitness(BinSizes,hasParametersSupplied,Parameters,StabilityPredictor)


   %% PARAMETES NEEDED
    % 1.  Max Lower Range No. of Pixels Deviation Allowed ( Value > 0 and Value < 1 )
    % 2.  Max Higher Range No. of Pixels Deviation Allowed ( Value > 0 and Value < 1)
    % 3.  Max Euler Number( Value > 1 and Value < Infinite )                  
    % 4.  Max Difference in Euler Number for Lower Range( 0 <= Value < Inf )
    % 5.  Max Difference in Euler Number for Higher Range( 0 <= Value < Inf )
    % 6.  Min Solidity ( Value > 0 and Value < 1)
    % 7.  Max Solidity ( Value > 0 and Value < 1)
    % 7.  Max Lower Range Density Deviation Allowed ( 0 < Value < Inf )
    % 8.  Max Higher Range Density Deviation Allowed ( 0 < Value < Inf )
    % 9.  Min No. of Pixels
    % 10. Max No. of Pixels
    % 11. Min Height
    % 12. Max Height
    % 13. Min Width
    % 14. Max Width
    
    % 15. Baseline Deviation by average height for aligned ( 0 < Value < Inf )
    % 16. Spacing Deviation by average height for aligned (0 < value < Inf )
    % 16. Height Difference by avera0ge height for aligned ( 0 < Value < 1 )
    
    
   
   
    %% BINNING 
       [BinImages,NumBinImages] = Binning(image,BinSizes);
    
    %% Stabilizing Bins
        BinMatrix = GetBinAllocations(BinSizes,MAX_DISTANCE,NUM_BIN_IMAGES);
        StabilityMatrix = GetStabilityMatrix(BinSizes,BinMatrix,MAX_DISTANCE);
        StableBinImages = removeUnstableComponents(BinImages,BinSizes,StabilityMatrix,BinMatrix,hasParametersSupplied,Parameters,StabilityPredictor);

    %% Splitting into Aligned and Non-Aligned
        
     


end