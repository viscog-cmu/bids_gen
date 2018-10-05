
function bids_dir = get_bids_dir(experiment)

if ismac
    bids_dir =['/Volumes/external/fMRI/bids/',experiment];
elseif isunix
    bids_dir = ['/mnt/hgfs/F/nblauch/bids/',experiment];
    try
        ls(bids_dir)
    catch
        bids_dir=['/home/nick/external/fMRI/bids/',experiment];
        try
            ls(bids_dir)
        catch
            bids_dir = ['/home/nicholasblauch/MEG/',experiment];
        end
    end
elseif ispc
    bids_dir = ['D:/fMRI/bids/',experiment];
else
    disp('Platform not supported')
end

end