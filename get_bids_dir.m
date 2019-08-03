
function bids_dir = get_bids_dir(experiment)

% this function expects you to have an environment variable $bids set to your bids super-directory, in which experiment folders are found

bids_dir = [getenv('BIDS'),'/',experiment];

% if ismac
%     bids_dir =['/Volumes/external/fMRI/bids/',experiment];
% elseif isunix
%     bids_dir = ['/mnt/hgfs/F/nblauch/bids/',experiment]; % cmap server
%     try
%         ls(bids_dir)
%     catch
%         bids_dir=['/home/nick/external/fMRI/bids/',experiment]; %external drive on ubuntu laptop
%         try
%             ls(bids_dir)
%         catch
%             bids_dir=['/home/nblauch/bids/',experiment]; % psycho server
%         end
%     end
% elseif ispc
%     bids_dir = ['D:/fMRI/bids/',experiment];
% else
%     disp('No existing bids directory found. Add desired location to get_bids_dir.m')
% end

end
