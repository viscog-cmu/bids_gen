function [ output_args ] = spm_gii_and_dat_2_gii( file_path, delete_original )
%SPM_GII_AND_DAT_2_GII 
%
%   Transform paired .gii and .dat files to single .gii file 
%   containing the data. Option to delete original files.
%   Input a file  path with NO EXTENSION. We assume that the .gii and .dat file
%   have the same name with different extensions only.
%
%   update to take in an entire folder??   
%   
%   Author: Nicholas Blauch
%   last updated: 1/3/2018

gii = gifti([file_path,'.gii']);
gii.cdata = gii.cdata();

save(gii,[file_path,'.gii']);

if exist('delete_original')
    if delete_original == 1
        delete([file_path,'.dat'])
    end
end

end

