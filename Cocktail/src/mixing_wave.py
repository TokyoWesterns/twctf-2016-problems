import numpy as np

from scipy.io import wavfile
from sklearn.decomposition import FastICA, PCA
import random

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
    files.append('part{0:d}.wav'.format(i + 1))

for fname in files:
    fs, data = wavfile.read(fname)
    data = data / 32768.0
    data = data / max(data) * 0.8
    signals.append(data)

max_len = max(map(len, signals))
for i in xrange(len(signals)):
    signals[i] = np.hstack((signals[i], np.zeros(max_len - len(signals[i]))))

S = np.array(signals).T

# Mix data
t = []
for i in xrange(num_parts):
    t.append(1 - 0.05 * i)

A = []
for i in xrange(num_parts):
    A.append(t[i:]+t[:i])

random.shuffle(A)

# A = np.array([[  1, 0.9, 1, 1, 1],
#               [0.8, 1.8, 1.0, 1.5, 1.2],
#               [1.3, 1.0, 1.8, 0.8, 1.5],
#               [1.8, 1.0, 0.8, 1.5, 1.2],
#               [1.5, 0.8, 1.2, 1.0, 1.8]])  # Mixing matrix
X = np.dot(S, np.array(A))  # Generate observations

# Compute ICA
# ica = FastICA(n_components=4)
# S_ = ica.fit_transform(X)  # Reconstruct signals
# A_ = ica.mixing_  # Get estimated mixing matrix

for i in xrange(len(files)):
    t = X.T[i] / max(np.amax(X.T[i]), abs(np.amin(X.T[i])))
    t = smooth(t)
    wavfile.write('mixed{}.wav'.format(i + 1), fs, (t * 32768.0).astype(np.int16))
