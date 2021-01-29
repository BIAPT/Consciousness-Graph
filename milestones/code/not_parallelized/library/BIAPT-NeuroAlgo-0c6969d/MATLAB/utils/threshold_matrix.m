function [t_matrix] = threshold_matrix(matrix,t_level, mode)
%THRESHOLD_MATRIX Threshold a matrix to have element below a significant
%amount to 0
%   Matrix: N*N matrix with value within any range
%   t_level: value from 0 to 1 which set the ratio of highest value
%   to keep. i.e. t_level = 0.05 -> keep only top 5% value
    
    %% Flatten the matrix into an array
    [num_row, num_col] = size(matrix);
    num_element = num_row*num_col;
    array = reshape(matrix, [1 num_element]);
    
    %% Find the value to threshold on (the one at the limit of top t_level%
    sorted_array = sort(array);
    t_index = floor(num_element*(1 - t_level)) + 1;
    if strcmp(mode, 'dpli')
        middle = floor(num_element/2);
        t_index = middle + floor(middle*(1 - t_level)) + 1;
    end
    
    t_element = sorted_array(t_index);
    
    if strcmp(mode, 'dpli')
        if t_element < 0.5
           t_element_lower = t_element;
           t_element= abs(1- t_element_lower);
        else
            t_element_lower = abs (1 - t_element);
        end
        
    end
    
    
    %% Threshold the matrix
    t_matrix = matrix;
    %%{
    if strcmp(mode, 'dpli')
        for i=1:num_row
            for j=1:num_col
                current = t_matrix(i,j);
                test = current < t_element && current > t_element_lower;
                item = current;
                if (current < t_element && current > t_element_lower)
                    t_matrix(i,j) = 0;
                    item = t_matrix(i,j);
                end
            end
        end
    else
        t_matrix(t_matrix < t_element) = 0;
    end
   %%}
    
    
    %t_matrix(t_matrix < t_element) = 0;
    %% Remove the diagonal elements
    t_matrix = t_matrix - diag(diag(t_matrix));
end

