    
function smooth_masked_vols(fnames, sm_fnames, FWHM, vox_mm, mask)
%
% fnames -> cell struct of file names to be smoothed
% sm_fnames -> output smoothed file names
% FWHM -> smoothing FWHM
% vox_mm -> voxel size in mm
% mask -> optional explicit mask to use. otherwise, a nan mask is built
%   code written by Christian Graser to do smoothing on a masked volume
%   see: https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind06&L=SPM&D=0&P=6709614

for ii = 1:length(fnames)
    
    if exist(sm_fnames{ii},'file')
        continue
    end
        
    vol_nii = load_untouch_nii(fnames{ii});
    vol_all = vol_nii.img;
    
    dim = size(vol_all);
    if length(dim) > 3
        ntp = dim(4);
    else
        ntp = 1;
    end
    
    svol_all = zeros(size(vol_all));
    for tp = 1:ntp
        vol = squeeze(vol_all(:,:,:,tp));
        if exist('mask','var')
            Q = find(squeeze(mask(:,:,:,tp)) > 0);
        else
            Q = find(~isnan(vol));
        end
        svol   = zeros(dim(1:3));
        smask    = zeros(dim(1:3));
        tmpvol    = zeros(dim(1:3));
        tmpvol(Q) = ones(size(Q));
        spm_smooth(tmpvol,smask,FWHM./vox_mm);
        tmpvol(Q) = vol(Q);
        spm_smooth(tmpvol,svol,FWHM./vox_mm);
        vol(Q)  = svol(Q)./smask(Q);
        svol = vol;
        svol_all(:,:,:,tp) = svol;
    end
    svol_nii = vol_nii;
    svol_nii.img = svol_all;
    save_untouch_nii(svol_nii, sm_fnames{ii});
    
end