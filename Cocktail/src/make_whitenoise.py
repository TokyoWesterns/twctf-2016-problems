import numpy as np
from numpy import random
from scipy.io import wavfile

def white_noize(length, sample_rate=44100):
    sample = length * sample_rate
    time_step = 1. / sample_rate
    time_arr = np.arange(sample) * time_step
    noize = random.randn(time_arr.size)
    return noize

fs = 22050
noize = white_noize(6.5, fs)
wavfile.write('part10.wav', fs, (noize * 32768.0).astype(np.int16))
