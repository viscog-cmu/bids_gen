function bids_prepare_volumes( experiment, sub, ses, ref_task, masks )
%BIDS_PREPARE_VOLUMES( experiment, sub, ses, ref_task, masks )
%   Gunzip anat and func folders and reslice cortical masks to functional
%   dimensions. Uses the first run of ref_task for reference. 

%default value for masks: do all of them
if ~exist('masks','var')
    masks = {'GM','WM','CSF'};
end

bids_dir = get_bids_dir(experiment);
[ anat_path, anat_ses ] = bids_get_anat_derivs_path( sub, experiment, 2 );

%try to gunzip but catch error if already done
try
    gunzip(sprintf('%s/derivatives/fmriprep/sub-%02d/ses-%02d/func/*.gz',bids_dir,sub,ses))
catch
end
try
    gunzip(sprintf('%s/*.gz',anat_path))
catch
end

for mask = masks
    
    %check if mask already exists to save time
    if exist(sprintf('%s/derivatives/fmriprep/sub-%02d/ses-%02d/func/sub-%02d_ses-%02d_T1w_class-%s_probtissue.nii',bids_dir,sub,ses,sub,ses,mask{1}),'file')
        continue
    end
    
    if anat_ses > 0
        spm_reslice({sprintf('%s/derivatives/fmriprep/sub-%02d/ses-%02d/func/sub-%02d_ses-%02d_task-%s_run-01_bold_space-T1w_preproc.nii',bids_dir,sub,ses,sub,ses,ref_task), ...
            sprintf('%s/sub-%02d_ses-%02d_T1w_class-%s_probtissue.nii',anat_path,sub,ses,mask{1})},struct('prefix','r_'));
        movefile(sprintf('%s/r_sub-%02d_ses-%02d_T1w_class-%s_probtissue.nii',anat_path,sub,ses,mask{1}), ...
            sprintf('%s/derivatives/fmriprep/sub-%02d/ses-%02d/func/sub-%02d_ses-%02d_T1w_class-%s_probtissue.nii',bids_dir,sub,ses,sub,ses,mask{1}));
    else
        spm_reslice({sprintf('%s/derivatives/fmriprep/sub-%02d/ses-%02d/func/sub-%02d_ses-%02d_task-%s_run-01_bold_space-T1w_preproc.nii',bids_dir,sub,ses,sub,ses,ref_task), ...
            sprintf('%s/sub-%02d_T1w_class-%s_probtissue.nii',anat_path,sub,mask{1})},struct('prefix','r_'));
        movefile(sprintf('%s/r_sub-%02d_T1w_class-%s_probtissue.nii',anat_path,sub,mask{1}), ...
            sprintf('%s/derivatives/fmriprep/sub-%02d/ses-%02d/func/sub-%02d_ses-%02d_T1w_class-%s_probtissue.nii',bids_dir,sub,ses,sub,ses,mask{1}));
    end
    
end

end

