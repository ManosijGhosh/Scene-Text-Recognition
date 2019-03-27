function [isStable] = PredictStabilityFromParameters(Features,Parameters)
  global CheckisStable
  
   %% PARAMETERS
    % 1.  Max Lower Range No. of Pixels Deviation Allowed ( Value > 0 and Value < 1 )
    % 2.  Max Higher Range No. of Pixels Deviation Allowed ( Value > 0 and Value < 1)
    % 3.  Max Euler Number( Value > 1 and Value < Infinite )                  
    % 4.  Max Difference in Euler Number for Lower Range( 0 <= Value < 1 )
    % 5.  Max Difference in Euler Number for Higher Range( 0 <= Value < 1 )
    % 6.  Max Solidity ( Value > 0 and Value < 1)
    % 7.  Min Solidity ( Value > 0 and Value < 1)
    % 8.  Max Lower Range Density Deviation Allowed ( 0 < Value < 1 )
    % 9.  Max Higher Range Density Deviation Allowed ( 0 < Value < 1 )
    % 10.  Max No. of Pixels
    % 11. Min No. of Pixels
    % 12. Max Height
    % 13. Min Height
    % 14. Max Width
    % 15. Min Width
    
    %% Features 

   % 1. Lower Range Pixel Deviatiion ([0,1])
   % 2. Higher Range Pixel Deviation ([0,1])
   % 3. Lower Range change of Euler Number([0,1))
   % 4. Higher Range change of Euler Number([0,1))
   % 5. Lower Range Density Deviation ([0,1])
   % 6. Higher Range Density Deviation ([0,1])
   % 7. No. of Pixels [0,1)
   % 8. Height (1,1)
   % 9. Width  (1,1)
   % 10. Solidity [0,1]
   % 11. Euler [0,1)
   
   %% CODE
 
  MIN_Params = [0 0 0 0 0 0 Parameters(1,[11 13 15 7]) 0];
   MAX_Params = Parameters(1,[1 2 4 5 8 9 10 12 14 6 3]) + MIN_Params;
%    Features(1,[3,4,11]) =  0;
  IsStable = (Features <= MAX_Params) & (Features>= MIN_Params);
  CheckisStable = CheckisStable + IsStable;
     if IsStable(1,[1 2 3 4 5 6 8 9 10]) == 1
         isStable = true;
     else
         isStable = false;
     end

end