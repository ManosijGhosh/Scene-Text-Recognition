function [BoundingBoxes] = fitness(image,BinSizes,hasParametersSupplied,Parameters,StabilityPredictor)


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
    % 17. Height Difference by average height for aligned ( 0 < Value < 1 )
    % 18. Maximum negative starting point by average height for aligned (0 < Value < 1)
    
    
    % 19. Max Average Solidity for aligned ( 0 < Value < 1)
    % 20. Min Average Solidity for aligned ( 0 < Value < Max Solidity)
    % 21. Max Average Euler Number for aligned ( 0 < Value < Inf)
    % 22. Min Average Euler Number for aligned ( 0 < Value < Max Euler)
    % 23. Max Average Eccentricity for Aligned ( 0 < Value < 1)
    % 24. Min Average Eccentricity for Aligned ( 0 < Value < Max Eccentricity)
    % 25. Max Average Extent for aligned ( 0 < Value < 1)
    % 26. Min Average Extent for aligned ( 0 < Value < Max Extent)
    % 27. Max Average SVT for aligned ( 0 < Value < 1)
    % 28. Max Average eHOG for aligned ( 0 < Value < 1)
    
    % 29. Max Solidity [0,1]
    % 30. Min Solidity [0,Max Solidity]
    % 31. Max Euler Number [0,Inf)
    % 32. Min Euler Number [0,Max Euler)
    % 33. Max Eccentricity [0,1]
    % 34. Min Eccentricity [0,Max Eccentricity]
    % 35. Max Extent [0,1]
    % 36. Min Extent [0, Max Extent)
    % 37. Max SVT [0,1]
    % 38. Max eHOG [0,1]
    
    %FEATURE VECTOR = [ SOLIDITY EULER ECCENTRICITY EXTENT SVT eHOG]
  
   
    %% BINNING 
       [BinImages,NumBinImages,MAX_DISTANCE] = Binning(image,BinSizes);
    
    %% Stabilizing Bins
        BinMatrix = GetBinAllocations(BinSizes,MAX_DISTANCE,NumBinImages);
        StabilityMatrix = GetStabilityMatrix(BinSizes,BinMatrix,MAX_DISTANCE);
        StableBinImages = removeUnstableComponents(BinImages,BinSizes,StabilityMatrix,BinMatrix,hasParametersSupplied,Parameters,StabilityPredictor);

    %% Splitting into Aligned and Non-Aligned
        [CCs,CCstats,Features] = GetTextGroupFeatures(StableBinImages,BinSizes);
        BoundingBoxes = GetBoundingBoxes(CCs,CCstats,Features,hasParametersSupplied,Parameters);


end