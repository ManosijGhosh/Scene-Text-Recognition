function [BoundingBoxes] = GetBoundingBoxes(CCs,CCstats,Features,NeedToStabilize,hasParametersSupplied,Parameters)

    BoundingBoxes = zeros(1,4);
    Features = abs(Features);
    % NOTE: The Feature Values supplied need to be of already stable
    % componenets if hasParametersSupplied is false. 
    
    %% Features 

   % 1. Lower Range Pixel Deviatiion ([0,1])
   % 2. Higher Range Pixel Deviation ([0,1])
   % 3. Lower Range change of Euler Number/100([0,1))
   % 4. Higher Range change of Euler Number/100([0,1))
   % 5. Lower Range Density Deviation ([0,1])
   % 6. Higher Range Density Deviation ([0,1])
   % 7. No. of Pixels [0,1)
   % 8. Height [0,1)
   % 9. Width  [0,1)
   % 10. Solidity [0,1]
   % 11. Euler/100 [0,1)
   
   % 12  Eccentricity [0,1]
   % 13. Extent [0,1]
   % 14. SVT [0,1]
   % 15. eHOG [0,1]
   
   %% PARAMETERS
    
    % 1.  Max Lower Range No. of Pixels Deviation Allowed ( Value > 0 and Value < 1 )
    % 2.  Max Higher Range No. of Pixels Deviation Allowed ( Value > 0 and Value < 1)
    % 3.  Max Euler Number/100( Value > 1 and Value < Infinite )                  
    % 4.  Max Difference in Euler Number for Lower Range/100( 0 <= Value < 1 )
    % 5.  Max Difference in Euler Number for Higher Range/100( 0 <= Value < 1 )
    % 6.  Max Solidity ( Value > 0 and Value < 1)
    % 7.  Min Solidity ( Value > 0 and Value < 1)
    % 8.  Max Lower Range Density Deviation Allowed ( 0 < Value < 1 )
    % 9.  Max Higher Range Density Deviation Allowed ( 0 < Value < 1 )
    % 10.  Max No. of Pixels Ratio
    % 11. Min No. of Pixels Ratio
    % 12. Max Height Ratio
    % 13. Min Height Ratio
    % 14. Max Width Ratio
    % 15. Min Width Ratio
    
    
    % 16. Baseline Deviation by average height for aligned ( 0 < Value < 1 )
    % 17. Spacing Deviation by average height for aligned (0 < value < 1 )
    % 18. Height Difference by average height for aligned ( 0 < Value < 1 )
    % 19. Maximum negative starting point by average height for aligned (0 < Value < 1)
    
    
    % 20. Max Average Solidity for aligned ( 0 < Value < 1)
    % 21. Min Average Solidity for aligned ( 0 < Value < Max Solidity)
    % 22. Max Average Euler Number for aligned ( 0 < Value < 1)
    % 23. Min Average Euler Number for aligned ( 0 < Value < Max Euler)
    % 24. Max Average Eccentricity for Aligned ( 0 < Value < 1)
    % 25. Min Average Eccentricity for Aligned ( 0 < Value < Max Eccentricity)
    % 26. Max Average Extent for aligned ( 0 < Value < 1)
    % 27. Min Average Extent for aligned ( 0 < Value < Max Extent)
    % 28. Max Average SVT for aligned ( 0 < Value < 1)
    % 29. Max Average eHOG for aligned ( 0 < Value < 1)
    
    % 20. Max Solidity [0,1]
    % 31. Min Solidity [0,Max Solidity]
    % 32. Max Euler Number [0,1)
    % 33. Min Euler Number [0,Max Euler)
    % 34. Max Eccentricity [0,1]
    % 35. Min Eccentricity [0,Max Eccentricity]
    % 36. Max Extent [0,1]
    % 37. Min Extent [0, Max Extent)
    % 38. Max SVT [0,1]
    % 39. Max eHOG [0,1]
    
    % data = [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.25 0.5 0.25 0.5
    % 0.25 0.25 0.25 0.25 0.25 0.8 0.1 0.06 0 0.98 0 0.9 0 0.25 0.3
    % 0.65 0.1 0.06 0 0.99 0 0.9 0.2 0.25 0.3]
    %% Parameter Initialization
         
       if hasParametersSupplied
          GroupingParams = Parameters(1,16:19); % PARAMETER ARRAY DEPENDENT 
          AlignedGroupParams_MAX = [Parameters(1,20:2:26) Parameters(1,28:29)];
          AlignedGroupParams_MIN = [Parameters(1,21:2:27) 0 0];
          NonAlignedGroupParams_MAX = [Parameters(1,30:2:36) Parameters(1,38:39)];
          NonAlignedGroupParams_MIN = [Parameters(1,31:2:37) 0 0];
       else                                     % DEFAULT VALUES
           GroupingParams = [ 0.25 0.25 0.25 0.25 ];
           AlignedGroupParams_MAX = [ 0.8 0.06 0.98 0.9 0.25 0.3];
           AlignedGroupParams_MIN = [0.1 0 0 0.2 0 0];
           NonAlignedGroupParams_MAX = [0.65 0.06 0.99 0.9 0.25 0.3];
           NonAlignedGroupParams_MIN = [ 0.1 0 0 0.2 0 0];
       end
       
    
    %% CODE
  start = 1;
  numBBs = 0;
  component_class = zeros(size(Features,1),1);       % Vector Denoting Class
                                                     % 0 - Undecided
                                                     % 1 - Non Text
                                                     % 2 - Text
                                                     % 3 - Stable Component
  
  for i = 1:size(CCs,2)
      if CCs(1,i) == 0
          continue;
      end
     ends = CCs(1,i); 
      
     for comp = start:ends
         if component_class(comp,1) == 1 || component_class(comp,1) == 2  %If already classified,skip over
             continue
         end
         
         if NeedToStabilize && component_class(comp,1) == 0
             if hasParametersSupplied
                 [isStable] = PredictStabilityFromParameters(Features(comp,1:11),Parameters(1,1:15));
             else
                 error('Need to supply Parameters if Unstable components supplied'); 
             end
             
             if ~isStable
                 component_class(comp,1) = 1;
                 continue
             else
                 component_class(comp,1) = 3;
             end
         end % Stabilization done
         
         
         stats = CCstats(comp,:);
         
         avg_height = stats(1,4);
         avg_baseline = stats(1,2) + stats(1,4);
         max_y = stats(1,1) + stats(1,3);
         max_x = stats(1,2) + stats(1,4);
         aligned_comps = zeros(1,20); % An Array of aligned comp labels, BUFFER OF UPTO 20 ALIGNED COMPONENTS 
         aligned_comps(1,:) = comp;
         aligns = 1;
         sum_features = Features(comp,10:15);
         
         BB = stats(:,:);
         
         for scan_comp = (comp+1):ends
          
           if NeedToStabilize && component_class(scan_comp,1) == 0
             if hasParametersSupplied
                 [isStable] = PredictStabilityFromParameters(Features(scan_comp,1:11),Parameters(1,1:15));
             else
                 error('Need to supply Parameters if Unstable components supplied'); 
             end
             
             if ~isStable
                 component_class(scan_comp,1) = 1;
                 continue
             else
                 component_class(scan_comp,1) = 3;
             end
           end %Stabilization done
         
          
             scan_stats = CCstats(scan_comp,:);
             spacing_dev = abs(scan_stats(1,1) - max_y)/avg_height;
             if spacing_dev > 1.25*GroupingParams(1,2) % CRITICAL ASSUME: Once components reach a certain distance horizontally,it keeps on increasing
                break; 
             end
             baseline_dev = abs(scan_stats(1,2) + scan_stats(1,4) - avg_baseline)/avg_height;
             height_dev =  abs(scan_stats(1,4) - avg_height)/avg_height;
             startPoint_diff = (max_y - scan_stats(1,1))/avg_height;
             
             C_Arr = [baseline_dev spacing_dev height_dev startPoint_diff];
             isAligned = C_Arr <= GroupingParams;
             
             if isAligned == 1
                 
                 avg_height = (avg_height*aligns + scan_stats(1,4))/(aligns+1);
                 avg_baseline = (avg_baseline*aligns + (scan_stats(1,2) + scan_stats(1,4)))/(aligns+1);
                 max_y = max(max_y,scan_stats(1,1)+scan_stats(1,3));
                 max_x = max(max_x,scan_stats(1,2)+scan_stats(1,4));
                 aligns = aligns + 1;
                 aligned_comps(1,aligns) = scan_comp;
                 sum_features = sum_features + Features(scan_comp,10:15);
                 
                 BB(1,1) = min(BB(1,1),scan_stats(1,1));  %%Increasing the Bounding Box
                 BB(1,3) = max_y - BB(1,1);
                 BB(1,2) = min(BB(1,2),scan_stats(1,2));
                 BB(1,4) = max_x - BB(1,2);
             end
             
         end
         
         C_Arr = sum_features./aligns;
         
         if aligns > 1
             isTextGroup = (C_Arr <= AlignedGroupParams_MAX) & (C_Arr >= AlignedGroupParams_MIN);
         else 
             isTextGroup = (C_Arr <= NonAlignedGroupParams_MAX ) & ( C_Arr >= NonAlignedGroupParams_MIN );
         end
         
         if isTextGroup == 1
             numBBs = numBBs + 1;
             BoundingBoxes(numBBs,:) = BB;
             component_class(aligned_comps,1) = 2;
         else
             component_class(aligned_comps,1) = 1;
         end
         
     end
      start = ends + 1;
  end

end