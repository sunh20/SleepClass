# ## Filtering tools for neural data

import scipy.signal as sps

def flex_filter(signal, fs, f_cut, f_cut2=None, btype='lowpass', order=4):
    '''
    flexible filter able to low/band/highpass filter  
      
    *signal*: MxN matrix, assuming that there are N independent vectors of length M  
    *fs*: sampling frequency  
    *f_cut*: frequency cutoff value
    *f_cut2*: high frequency cutoff value (0 if none)  
    *btype*: filter type, can be: 'highpass','lowpass','bandpass'  
    *order*: butterworth order (default is 4)
    '''
    
    assert((btype == 'bandpass' and f_cut2 != None) or (btype != 'bandpass'))
    
    nyq = 0.5 * fs;
    
    if f_cut2 != None:
        b, a = sps.butter(order / 2, [f_cut / nyq, f_cut2 / nyq], btype)
    else:
        b, a = sps.butter(order / 2, f_cut / nyq, btype)

    return sps.filtfilt(b, a, signal, axis=0)

def notch(signal, fs, f_cut=[60,120,180], err=0.1):
    '''
    applies a notch filter to signal at frequencies at f_cut  
    default values @ 60, 120, 180 Hz  
    err indicates the notch bandwidth (in Hz)  
    '''
    nyq = 0.5 * fs;
    temp = signal;
    
    for f in f_cut:
        # set quality factor - determines notch bandwidth
        Q = f / nyq / err 
        
        b, a = sps.iirnotch(f / nyq, Q)
        temp = sps.filtfilt(b, a, temp, axis=0)
    
    return temp

def ecog_clean(signal, fs):
    '''
    applies a standardized set of filtering parameters to clean ECoG data  
    bandpass 0.1 Hz - 200 Hz  
    notch @ 60, 120, 180 Hz  
    '''
    # bandpass 0.1 Hz - 200 Hz
    temp = flex_filter(signal, fs, 0.1, 200, btype='bandpass')
    
    # notch @ 60, 120, 180 Hz
    temp = notch(temp, fs)
    
    return temp




