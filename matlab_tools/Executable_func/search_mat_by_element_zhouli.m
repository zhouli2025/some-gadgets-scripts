function rows=search_mat_by_element_zhouli(M,string)
%在一个矩阵中查找某一行，返回找到的行数（可能不止一行满足条件）
    rows=[];
    [size_row,size_col] = size(M);
    
%     display(size_row);
%     display(size_col);
    
    for i=1:size_col
        %display(M{i,1});
        if (isequal(M{1,i},string))%==size_col
            rows=[rows i];
        end
        
    end

