function merge_fs_hemi_labels( exp, subname, labname)
%MERGE_FS_HEMI_LABELS( exp, subname, labname)
%
%   merge freesurfer labels across hemispheres
%   requires freesurfer
%
%   inputs:
%   
%   exp: experiment name under bids/ directory
%   subname: subject name
%   labname: base label name, e.g., 'OFA'. hemis will be preprended to this
%       using standard format, e.g. 'lh.OFA', 'rh.OFA', 'mh.OFA'
%
%

x_shift = 90;

bids_dir = get_bids_dir(exp);
setenv('SUBJECTS_DIR',[bids_dir,'/derivatives/freesurfer'])
fs_sub_dir = [bids_dir,'/derivatives/freesurfer/',subname];

surf_L = read_surf([fs_sub_dir,'/surf/lh.white']);
n_nodes_L = length(surf_L);

try
    lab_L = read_label(subname, ['lh.',labname]);
    use_L = 1;
catch
    use_L = 0;
end
try
    lab_R = read_label(subname, ['rh.',labname]);
    use_R = 1;
catch
    use_R = 0;
end

% determine how to create lab_M and do it
if use_L && use_R
    lab_R(:,1) = lab_R(:,1) + n_nodes_L;
    lab_R(:,2) = lab_R(:,2) + x_shift;
    lab_M = [lab_L;lab_R];
elseif use_L && ~use_R
    lab_M = lab_L;
elseif ~use_L && use_R
    lab_M = lab_R;
    lab_M(:,1) = lab_R(:,1) + n_nodes_L;
    lab_M(:,2) = lab_R(:,2) + x_shift;
end

%first two lines standard for FS label files
line_1 = ['#!ascii label  , from subject ',subname,' vox2ras=TkReg coords=white'];
line_2 = num2str(length(lab_M));

%create file, write first two lines
fname_M = [fs_sub_dir,'/label/mh.',labname,'.label'];
if exist(fname_M)
    delete(fname_M)
end
fid = fopen(fname_M,'w');
fprintf(fid,'%s\n%s\n', line_1, line_2);
fclose(fid);

%write the tab delimited data
dlmwrite(fname_M,lab_M,'-append','delimiter','\t','precision','%10.5f','newline','unix');

end

