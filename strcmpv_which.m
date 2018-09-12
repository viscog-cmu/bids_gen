function which = strcmpv_which( list, str_bank )
%STRCMPV 
%   strcmp for two cell arrays of strings

which = zeros(length(list),1);
for ii = 1:length(list)
    which(ii) = find(strcmp(list(ii),str_bank));
end


end
