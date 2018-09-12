function comparisons = strcmpv( list, str_bank )
%STRCMPV 
%   strcmp for two cell arrays of strings

comparisons = false(length(list),1);
for ii = 1:length(list)
    comparisons(ii) = any(strcmp(list(ii),str_bank));
end


end

