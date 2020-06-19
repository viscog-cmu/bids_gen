
# use for standalone freesurfer roi labels or ROI masks in volumetric space
# using freesurfer roi labels generally allows for easier drawing, since the mask will be binaryself.
# with volumetric masks, pycortex sampling results in a non-binary mask, which must be outlined by hand.

import cortex
import cortex.polyutils
import numpy as np
np.random.seed(1234)
import os
import numpy as np
import mne
import nibabel as nib
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--subnum', type=int)
parser.add_argument('--experiment-id', type=str, help='name of bids experiment')
parser.add_argument('--experiment-short', type=str, default='', help='shorthand name of experiment prepending subject id in pycortex subject identifier')
parser.add_argument('--xfm', type=str, default='standard')
parser.add_argument('--compute-boundary', action='store_true')
parser.add_argument('--roi-format', default='vol', choices=['vol', 'surf', 'label', 'fake'])
parser.add_argument('--rois', nargs='*', type=str, default=['FFA', 'VWFA'])
args = parser.parse_args()

subject = f'sub-{args.subnum:02d}'
if args.experiment_short is not None and len(args.experiment_short) > 0:
    pyc_subject = f'{args.experiment_short}-{subject}'
else:
    pyc_subject = f'{subject}'
    
surfs = [cortex.polyutils.Surface(*d) for d in cortex.db.get_surf(pyc_subject, "fiducial")]
num_verts = np.array([surfs[0].pts.shape[0], surfs[1].pts.shape[0]])
bids_dir = os.path.join(os.environ['BIDS'], args.experiment_id)

for roi in args.rois:
    if args.roi_format == 'label':
        verts = {}
        verts['lh'] = mne.read_label(f"{bids_dir}/derivatives/freesurfer/{subject}/label/lh.{roi}.label").vertices
        verts['rh'] = mne.read_label(f"{bids_dir}/derivatives/freesurfer/{subject}/label/rh.{roi}.label").vertices
        dat = np.zeros((num_verts.sum(),), dtype=bool)
        for hemi_i, (hemi, vertices) in enumerate(verts.items()):
            m = np.zeros((num_verts[hemi_i],), dtype=bool)
            m[vertices] = 1
            if args.compute_boundary:
                subsurf = surfs[hemi_i].create_subsurface(m)
                m = subsurf.lift_subsurface_data(subsurf.boundary_vertices)
            if hemi == 'rh':
                dat[num_verts[0]:] = m
            else:
                dat[:num_verts[0]] = m
        V = cortex.dataset.Vertex(dat, pyc_subject)
    elif args.roi_format == 'surf':
        label_lh = nib.load(f"{bids_dir}/derivatives/freesurfer/{subject}/label/lh.{roi}.gii").darrays[0].data.copy()
        label_rh = nib.load(f"{bids_dir}/derivatives/freesurfer/{subject}/label/rh.{roi}.gii").darrays[0].data.copy()
        overlay_dat = np.concatenate((label_lh, label_rh), axis=0)
        V = cortex.dataset.Vertex(overlay_dat, pyc_subject)
    elif args.roi_format == 'vol':
        label_rh =  nib.load(f"{bids_dir}/derivatives/freesurfer/{subject}/mri/{roi}_RH_aligned.nii")
        label_lh = nib.load(f"{bids_dir}/derivatives/freesurfer/{subject}/mri/{roi}_LH_aligned.nii")
        overlay_dat = label_rh.get_data().copy() + label_lh.get_data().copy()
        overlay_dat = overlay_dat.swapaxes(0,2)
        V = cortex.Volume(overlay_dat, pyc_subject, args.xfm, sampler='lanczos') #, cmap='tab20')
    elif args.roi_format == 'fake':
        dat = np.zeros((num_verts.sum(),), dtype=bool)
        V = cortex.dataset.Vertex(dat, pyc_subject)

    cortex.add_roi(V, name=roi, open_inkscape=True, add_path=True, with_colorbar=False)
