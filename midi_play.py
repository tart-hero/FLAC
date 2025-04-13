import pygame

# Initialize pygame mixer
pygame.init()
pygame.mixer.init()

# Load the MIDI file
midi_file = "childe_song.mid" # Replace with your MIDI file path
pygame.mixer.music.load(midi_file)

# Play the MIDI file
print("Playing MIDI file...")
pygame.mixer.music.play()

# Keep the script running until playback is complete
while pygame.mixer.music.get_busy():
    pygame.time.wait(100)

print("Playback finished.")
pygame.mixer.quit()