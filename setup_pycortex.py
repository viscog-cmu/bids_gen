
from cortex.options import config
from cortex.xfm import Transform
from cortex.freesurfer import import_flat, import_subj
# from cortex.fmriprep import import_subj
import os
import shutil

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--subnum', type=int)
parser.add_argument('--experiment-id', type=str)
parser.add_argument('--experiment-short', type=str, default='', help='shorthand experiment name to prepend to pycortex subject id')
parser.add_argument('--import-flat', action='store_true')
args = parser.parse_args()

subject='sub-{:02d}'.format(args.subnum)
if args.experiment_short is not None and len(args.experiment_short) > 0:
    pyc_subject = f'{args.experiment_short}-{subject}'
else:
    pyc_subject = f'{subject}'
bids_dir = os.path.join(os.environ['BIDS'], args.experiment_id)

# first import most everything from fmriprep
import_subj(f'sub-{args.subnum:02d}', pyc_subject, freesurfer_subject_dir=bids_dir+'/derivatives/freesurfer')

# # then import flattened surfaces from freesurfer
if args.import_flat:
    try:
        import_flat(subject, 'full', cx_subject=pyc_subject)
    except Exception as e:
        print(e)

# copy over the first session mask (since it will be used for everything)
shutil.copyfile(bids_dir+'/derivatives/freesurfer/{}/mri/T1w.cortex.nii'.format(subject),
    '{}/{}/anatomicals/T1w.cortex.nii'.format(config.get('basic', 'filestore'), pyc_subject))

# # create the xfm transformation
sub_dir = bids_dir+'/derivatives/freesurfer/{}'.format(subject)
os.system('tcsh fsreg2xfm {}/mri/register.dat {}/mri/T1w.cortex.nii {} {} standard'.format(sub_dir, sub_dir, pyc_subject, subject))
