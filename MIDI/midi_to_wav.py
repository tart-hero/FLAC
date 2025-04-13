import subprocess
from pydub import AudioSegment
#sp for system command (call FluidSynth) and pydub for sound processing


def midi_to_wav(midi_file, wav_file, soundfont_path):
    # Use FluidSynth and SoundFont to convert MIDI -> WAV
    command = f'fluidsynth -ni "{soundfont_path}" "{midi_file}" -F "{wav_file}" -r 44100'
    #fluidsynth -ni "FluidR3_GM.sf2" "jazz_melody.mid" -F "jazz_wav.wav" -r 44100 - sample frequency
    subprocess.run(command, shell=True, check=True)

def loop_wav_to_duration(wav_file, target_duration_seconds, output_file):
    original_audio = AudioSegment.from_wav(wav_file) #read file
    num_loops = int(target_duration_seconds * 1000 // len(original_audio)) + 1 #calculate number of loops needed
    extended_audio = original_audio * num_loops
    final_audio = extended_audio[:target_duration_seconds * 1000] #cut to exact time
    final_audio.export(output_file, format="wav")

soundfont = 'FluidR3_GM.sf2'  # Đường dẫn soundfont
midi_file = 'jazz_melody.mid'
wav_file = 'jazz_wav.wav'
looped_wav = 'jazz_loop_4min45s.wav'
 
midi_to_wav(midi_file, wav_file, soundfont)
loop_wav_to_duration(wav_file, 285, looped_wav)
