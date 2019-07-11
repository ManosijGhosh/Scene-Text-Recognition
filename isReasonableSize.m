function [truth] = isReasonableSize(width,height,pixel_count,row,col)

 %TODO
 
 if width > 0.04*min(row,col) && row > 0.04*min(row,col) && pixel_count > 0.000064*(row*col) && width < 0.25*col && height < 0.25*row && pixel_count < 0.0625*(row*col)
     truth = true;
 else
     truth = false;
 end

end