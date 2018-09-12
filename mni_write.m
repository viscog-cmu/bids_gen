function mni_write(sub, exp, fnames, vx_sizes)
%MNI_WRITE 
%
%   write native space files to mni using a predefined deformation field.
%   if it does not exist, first run mni_anat_estwrite(sub)
%   it takes a set of filenames and prefixes mni_ for mni files
%
%   sub: sub number
%   fnames: cell array of filenames to be deformed to mni
%   vx_sizes: 3D matrix of voxel sizes (e.g. [2 2 2])
%

[ anat_path, anat_ses ] = bids_get_anat_derivs_path( sub, exp, 1 );
if anat_ses
    def_fname = sprintf('%s/y_sub-%02d_ses-%02d_T1w_preproc.nii',anat_path,sub,anat_ses);
else
    def_fname = sprintf('%s/y_sub-%02d_T1w_preproc.nii',anat_path,sub);
end

clear matlabbatch
matlabbatch{1}.spm.spatial.normalise.write.subj.def = {def_fname};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = fnames;
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
    78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = vx_sizes;
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 0;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'mni_';
spm_jobman('run',matlabbatch)

end

