function mni_anat_estwrite( sub, exp )
%MNI_ANAT_ESTWRITE(sub)
%
%   estimate the anat->mni transform for a subject and write the results.
%   this also saves the deformation field for future use without
%   reestimation
%

[ anat_path, anat_ses ] = bids_get_anat_derivs_path( sub, exp, 1 );
if anat_ses
    anat_fname = sprintf('%s/sub-%02d_ses-%02d_T1w_preproc.nii',anat_path,sub,anat_ses);
else
    anat_fname = sprintf('%s/sub-%02d_T1w_preproc.nii',anat_path,sub);
end

clear matlabbatch
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {anat_fname};
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {''};
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {[spm_dir,'/tpm/TPM.nii']};
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
    78 76 85];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'mni_';

end

