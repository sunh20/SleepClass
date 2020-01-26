import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
from mayavi import mlab

import mne
from mne.viz import plot_alignment, snapshot_brain_montage
mlab.process_ui_events()
print(__doc__)

def plot_ecog(trodes, ch_names):
    montage = mne.channels.make_dig_montage(ch_pos=dict(zip(ch_names, trodes)),
                                        coord_frame='head')
    print('Created %s channel positions' % len(ch_names))
    
    info = mne.create_info(ch_names, 1000., 'ecog', montage=montage)
    
    # launches mayavi scene + sets orientation
    subjects_dir = mne.datasets.sample.data_path() + '/subjects'
    fig = plot_alignment(info, subject='sample', subjects_dir=subjects_dir,
                         surfaces=['pial'])
    mne.viz.set_3d_view(fig, 200, 70)

    xy, im = snapshot_brain_montage(fig, montage)

    # Convert from a dictionary to array to plot
    xy_pts = np.vstack([xy[ch] for ch in info['ch_names']])

    # Define an arbitrary "activity" pattern for viz
    activity = np.linspace(100, 200, xy_pts.shape[0])

    # This allows us to use matplotlib to create arbitrary 2d scatterplots
    _, ax = plt.subplots(figsize=(10, 10))
    ax.imshow(im)
    ax.scatter(*xy_pts.T, c=activity, s=200, cmap='coolwarm')
    ax.annotate('1',xy_pts[0])
    ax.set_axis_off()

    # add labels to electrodes
    for num in np.arange(0,64):
        ax.annotate(str(num+1),xy_pts[num])

    plt.show()
    
    