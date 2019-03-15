function result = findLabels(label_matrix,total_labels)

  result = zeros(1,total_labels);
  insert = 0;
for i = 1:numel(label_matrix)
   
    if label_matrix(i)~=0
       
        for check = 1:(insert+1)
           
            if check == (insert+1)
               
                insert = insert+1;
                result(1,insert) = label_matrix(i);
                break;
            end
            
            if result(1,check) == label_matrix(i)
               break; 
            end
            
        end
        
    end
    
    if insert == total_labels
        break;
    end
    
end

end