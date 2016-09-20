import numpy as np

from scipy.io import wavfile
from sklearn.decomposition import FastICA, PCA

def smooth(x):
    window_len = 4
    s = np.r_[x[window_len - 1:0:-1], x, x[-1:-window_len:-1]]
    w = np.hanning(window_len)
    y = np.convolve(w / w.sum(), s, mode='valid')
    return y

num_parts = 10
signals = []
files = []
for i in xrange(num_parts):
    files.append('mixed{0:d}.wav'.format(i + 1))

for fname in files:
    fs, data = wavfile.read(fname)
    signals.append(data / 32768.0)

max_len = max(map(len, signals))
for i in xrange(len(signals)):
    signals[i] = np.hstack((signals[i], np.zeros(max_len - len(signals[i]))))

S = np.array(signals).T

# Compute ICA
ica = FastICA(n_components=len(files))
S_ = ica.fit_transform(S)  # Reconstruct signals
A_ = ica.mixing_  # Get estimated mixing matrix

for i in xrange(num_parts):
    t = S_.T[i] / max(np.amax(S_.T[i]), abs(np.amin(S_.T[i])))
    t = smooth(t)
    wavfile.write('reconstructed_part{}.wav'.format(i + 1), fs, (t * 32768.0).astype(np.int16))
