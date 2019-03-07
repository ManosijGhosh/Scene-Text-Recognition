function ehog = eHOG(matrix)


   w1 = 0;
   w2 = 0;
   w3 = 0;
   w4 = 0;
   
   
   x = bwboundaries(matrix,'noholes');
   
   
   list = x{:};
   
   for i = 2:(numel(list)/2)
       
      x1 =  list(i,1);
      y1 = list(i,2);
      
      x2 = list((i-1),1);
      y2 = list((i-1),2);
      

     if ((x1 == x2+1) && (y1 == y2)) || ((x1 == x2+1) && (y1 == y2-1))   
         w1 = w1+1;  
     end
      
    if ((x1 == x2) && (y1 == y2-1)) || ((x1 == x2-1) && (y1 == y2-1))
        w2 = w2 + 1;  
    end
    
    if ((x1 == x2-1) && (y1 == y2)) || ((x1 == x2-1) && (y1 == y2+1))  
        w3 = w3 + 1; 
    end
      
    
    if ((x1 == x2) && (y1 == y2+1)) || ((x1 == x2+1) && (y1 == y2+1)) 
        w4 = w4 + 1;  
    end
       
   end
   
   ehog = (sqrt((w1-w3)^2 + (w2-w4)^2))/((numel(list)/2) - 1);


end