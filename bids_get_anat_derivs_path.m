function [ anat_path, anat_ses, anat_fullfile ] = bids_get_anat_derivs_path( sub, experiment, sessions )
%bids_get_anat_path 
%   return path containing anatomical derivatives
%   necessary when there is only one anatomical image or one session in an
%   experiment which is generally dual-session
%   returns the multi-session anatomical path, or the first existing anatomical 
%   path in sessions order.
%
%   Updated 4/30/18 to detect server automatically

%   added compatibility for sub to be input as int/double/char
%   5/14: changed from folder detection to file detection since new
%   fmriprep stores anatomical derivatives above session, while still
%   creating a session-level anatomical folder containing a transformation
%   file

if ~ischar(sub)
    sub = sprintf('%02d',sub);
end

if isunix
    sub_path = ['/mnt/hgfs/F/nblauch/bids/',experiment,'/derivatives/fmriprep/sub-',sub];
else
    sub_path = ['D:/fMRI/bids/',experiment,'/derivatives/fmriprep/sub-',sub];
end

if exist([sub_path,'/anat/sub-',sub,'_T1w_preproc.nii'],'file') || exist([sub_path,'/anat/sub-',sub,'_T1w_preproc.nii.gz'],'file')
    anat_ses = 0;
    anat_dir = dir([sub_path,'/anat/sub-',sub,'_T1w_preproc.*']);
    anat_path = anat_dir(1).folder;
    anat_fullfile = fullfile(anat_path,anat_dir.name);
    return
else
    for ses = 1:sessions
        if exist(sprintf('%s/ses-%02d/anat/sub-%s_ses-%02d_T1w_preproc.nii',sub_path,ses,sub,ses),'file') || ...
                exist(sprintf('%s/ses-%02d/anat/sub-%s_ses-%02d_T1w_preproc.nii.gz',sub_path,ses,sub,ses),'file') 
            anat_ses = ses;
            anat_dir = dir(sprintf('%s/ses-%02d/anat/sub-%s_ses-%02d_T1w_preproc.*',sub_path,ses,sub,ses));
            anat_path = anat_dir.folder;
            anat_fullfile = sprintf('%s/sub-%s_ses-%02d_T1w_preproc.nii',anat_path,sub,ses);
            return
        end
    end
    error('No anatomical path found')
end

