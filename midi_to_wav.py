import os
import subprocess
from pydub import AudioSegment

def midi_to_wav(midi_file, wav_file, soundfont_path):
    # Dùng FluidSynth để convert MIDI -> WAV
    command = f'fluidsynth -ni "{soundfont_path}" "{midi_file}" -F "{wav_file}" -r 44100'
    subprocess.run(command, shell=True, check=True)

def loop_wav_to_duration(wav_file, target_duration_seconds, output_file):
    base = AudioSegment.from_wav(wav_file)
    loops = int(target_duration_seconds * 1000 // len(base)) + 1
    full = base * loops
    trimmed = full[:target_duration_seconds * 1000]
    trimmed.export(output_file, format="wav")

soundfont = 'FluidR3_GM.sf2'  # Đường dẫn soundfont
midi_file = 'jazz_melody.mid'
wav_file = 'jazz_wav.wav'
looped_wav = 'jazz_loop_4min45s.wav'
 
midi_to_wav(midi_file, wav_file, soundfont)
loop_wav_to_duration(wav_file, 285, looped_wav)
