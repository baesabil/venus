"""
Generator suara swipe "angin" (whoosh) -> Venus/swipe.wav
Jalankan:  python3 Tools/make_whoosh.py
Mau suara lebih panjang / lebih lembut? Ubah DURATION, LOW_HZ, HIGH_HZ, PEAK di bawah.
"""
import numpy as np, wave, os

SR = 44100
DURATION = 0.55          # detik
LOW_HZ, HIGH_HZ = 220.0, 1300.0   # sapuan frekuensi (rendah -> tinggi -> rendah)
Q = 1.6                  # makin kecil = makin "berdesir/airy", makin besar = makin bernada
PEAK = 0.55              # volume puncak (0..1)

rng = np.random.default_rng(7)
n = int(SR * DURATION)
t = np.linspace(0, 1, n)
noise = rng.standard_normal(n)

# Sapuan frekuensi: naik cepat lalu turun pelan (seperti angin lewat)
sweep = np.sin(np.pi * t ** 0.7)
fc = LOW_HZ * (HIGH_HZ / LOW_HZ) ** sweep

# State-variable band-pass filter dengan cutoff berubah-ubah
low = band = 0.0
out = np.zeros(n)
for i in range(n):
    f = 2.0 * np.sin(np.pi * fc[i] / SR)
    low += f * band
    high = noise[i] - low - band / Q
    band += f * high
    out[i] = band

# Amplitudo: fade-in halus, puncak di ~40%, fade-out panjang (tanpa bunyi "klik")
env = np.sin(np.pi * np.clip(t / 0.85, 0, 1)) ** 2
env *= np.minimum(1.0, t / 0.08)
out *= env

# Low-pass lembut (one-pole ~1.6kHz) supaya tidak mendesis / tajam
alpha = 1 - np.exp(-2 * np.pi * 1600.0 / SR)
y = 0.0
for i in range(n):
    y += alpha * (out[i] - y)
    out[i] = y
out = np.tanh(out * 0.4)                 # soft limiter
out *= PEAK / np.max(np.abs(out))

# Fade 5ms di ujung supaya tidak ada pop
fade = int(SR * 0.005)
out[:fade] *= np.linspace(0, 1, fade)
out[-fade:] *= np.linspace(1, 0, fade)

path = os.path.join(os.path.dirname(__file__), "..", "Venus", "swipe.wav")
with wave.open(path, "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((out * 32767).astype(np.int16).tobytes())
print("saved", os.path.abspath(path), f"{DURATION}s, peak={np.max(np.abs(out)):.2f}")
