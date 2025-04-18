from pydub import AudioSegment
#process and mix the Audio

def mix_tracks(wav1, wav2, output_file, vol1_dB=0, vol2_dB=-4.0): #adjust the volume
    track1 = AudioSegment.from_wav(wav1) + vol1_dB
    track2 = AudioSegment.from_wav(wav2) + vol2_dB

    mixed = track1.overlay(track2) #overlay track 2 to track 1
    mixed.export(output_file, format="wav")
    print(f"Mixed File: {output_file}")

mix_tracks('jazz_loop_4min45s.wav', 'ghi_am_5_phut_stereo2.wav', 'output.wav')
