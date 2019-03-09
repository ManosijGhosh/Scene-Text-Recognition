function [upper_bin_1,upper_bin_2,upper_bin_i] = GetUpperRangeImage(lower_bin_limit,upper_bin_limit,i,q_offset,BinSizes,MAX_DISTANCE)

upper_bin_1=0;
upper_bin_2 = 0;
upper_bin_i = 0;
% if i == numel(BinSizes)
%     upper_bin_i = 0;
%     return
% else
    upper_q_offset = q_offset;
    for j = i:numel(BinSizes)                    %%LOOP TO CHANGE FOR DIFFERENT BIN SIZES
        main_offset = ceil(MAX_DISTANCE/BinSizes(j));
        if BinSizes(j) >= (1.5*BinSizes(i))
            upper_bin_i = j;
            break;
        end
        upper_q_offset = upper_q_offset+2*main_offset-1;
        
        
    end
    
    if upper_bin_i == 0
        return
    end
    
    upper_bin_limit = min(MAX_DISTANCE,upper_bin_limit);
    % end
    
    upper_k = ceil((BinSizes(upper_bin_i)/2)) -1;
    upper_main_offset = ceil(MAX_DISTANCE/BinSizes(upper_bin_i));
    
    %MAX_DISTANCE = upper_main_offset*BinSizes(upper_bin_i) - 1;
    
    %BIN where lower bin limit lies
    main_bin = floor(lower_bin_limit/BinSizes(upper_bin_i))+1;
    if lower_bin_limit > upper_k && lower_bin_limit<(((main_offset-1)*BinSizes(upper_bin_i))+upper_k)
        offset_bin = ceil((lower_bin_limit-upper_k)/BinSizes(upper_bin_i));
        if main_bin == offset_bin+1
            upper_bin_1 = upper_q_offset+main_bin;
        else
            if main_bin == offset_bin
                upper_bin_1 = upper_q_offset+upper_main_offset+offset_bin;
            else
                fprintf('/nError in Bin Value Calculation,Main and Offset Bins dont overlap');
            end
        end
    else
        upper_bin_1=upper_q_offset+main_bin;
    end
    
    
    %BIN where upper bin limit lies
    main_bin = floor(upper_bin_limit/BinSizes(upper_bin_i))+1;
    if upper_bin_limit > upper_k && upper_bin_limit<(((main_offset-1)*BinSizes(upper_bin_i))+upper_k)
        offset_bin = ceil((upper_bin_limit-upper_k)/BinSizes(upper_bin_i));
        if main_bin == offset_bin+1
            upper_bin_2 = upper_q_offset+upper_main_offset+offset_bin;
        else
            if main_bin == offset_bin
                upper_bin_2 = upper_q_offset+main_bin;
            else
                fprintf('\n Error in Bin Value Calculation,Main and Offset Bins dont overlap');
            end
        end
    else
        upper_bin_2=upper_q_offset+main_bin;
    end
    
    
    if upper_bin_1 == 0
        upper_bin_1 = upper_bin_2;
    else
        if upper_bin_2 == 0
            upper_bin_2 = upper_bin_1;
        end
    end
    
    %[BinSizes(i) BinSizes(upper_bin_i) upper_q_offset upper_main_offset lower_bin_limit upper_bin_limit upper_bin_1 upper_bin_2]
    
    if abs(upper_bin_1 - upper_bin_2) ~= 0 && abs(upper_bin_1 - upper_bin_2) ~= upper_main_offset && abs(upper_bin_1 - upper_bin_2) ~= (upper_main_offset-1)
        
        fprintf('\nWrong Calculation of Upper range bins,Bins Do not overlap');
    end
    
    
end