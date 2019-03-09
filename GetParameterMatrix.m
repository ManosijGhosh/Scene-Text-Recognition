function [BoundMatrix] = GetParameterMatrix()

    % 1.  Max Lower Range No. of Pixels Deviation Allowed ( Value > 0 and Value < 1 )
    % 2.  Max Higher Range No. of Pixels Deviation Allowed ( Value > 0 and Value < 1)
    % 3.  Max Euler Number( Value > 1 and Value < Infinite )                  
    % 4.  Max Difference in Euler Number for Lower Range( 0 <= Value < Inf )
    % 5.  Max Difference in Euler Number for Higher Range( 0 <= Value < Inf )
    % 6.  Max Solidity ( Value > 0 and Value < 1)
    % 7.  Min Solidity ( Value > 0 and Value < 1)
    % 8.  Max Lower Range Density Deviation Allowed ( 0 < Value < Inf )
    % 9.  Max Higher Range Density Deviation Allowed ( 0 < Value < Inf )
    % 10.  Max No. of Pixels/TotalPixels
    % 11. Min No. of Pixels/TotalPixels
    % 12. Max Height/ImageHeight
    % 13. Min Height/ImageHeight
    % 14. Max Width/ImageWidth
    % 15. Min Width/ImageWidth
    
    
    % 16. Baseline Deviation by average height for aligned ( 0 < Value < Inf )
    % 17. Spacing Deviation by average height for aligned (0 < value < Inf )
    % 18. Height Difference by average height for aligned ( 0 < Value < 1 )
    % 19. Maximum negative starting point by average height for aligned (0 < Value < 1)
    
    
    % 20. Max Average Solidity for aligned ( 0 < Value < 1)
    % 21. Min Average Solidity for aligned ( 0 < Value < Max Solidity)
    % 22. Max Average Euler Number for aligned ( 0 < Value < Inf)
    % 23. Min Average Euler Number for aligned ( 0 < Value < Max Euler)
    % 24. Max Average Eccentricity for Aligned ( 0 < Value < 1)
    % 25. Min Average Eccentricity for Aligned ( 0 < Value < Max Eccentricity)
    % 26. Max Average Extent for aligned ( 0 < Value < 1)
    % 27. Min Average Extent for aligned ( 0 < Value < Max Extent)
    % 28. Max Average SVT for aligned ( 0 < Value < 1)
    % 29. Max Average eHOG for aligned ( 0 < Value < 1)
    
    % 20. Max Solidity [0,1]
    % 31. Min Solidity [0,Max Solidity]
    % 32. Max Euler Number [0,Inf)
    % 33. Min Euler Number [0,Max Euler)
    % 34. Max Eccentricity [0,1]
    % 35. Min Eccentricity [0,Max Eccentricity]
    % 36. Max Extent [0,1]
    % 37. Min Extent [0, Max Extent)
    % 38. Max SVT [0,1]
    % 39. Max eHOG [0,1]
    
    BoundMatrix = [zeros(1,39);1 1 100 100 100 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 100 100 1 1 1 1 1 1 1 1 100 100 1 1 1 1 1 1];   
    

end