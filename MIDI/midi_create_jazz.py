import mido
from mido import MidiFile, MidiTrack, Message, MetaMessage

# Create empty MIDI file
midi = MidiFile()
# Create 2 track for melody and chord
track_melody = MidiTrack()
track_chords = MidiTrack()
midi.tracks.append(track_melody)
midi.tracks.append(track_chords)

# Set the tempo
track_melody.append(MetaMessage('set_tempo', tempo=mido.bpm2tempo(120)))

# Set the instrusmental Saxophone for melody and Piano for chords
track_melody.append(Message('program_change', program=65, channel=0, time=0))  # Alto Sax
track_chords.append(Message('program_change', program=0, channel=1, time=0))   # Acoustic Grand Piano

# Notes list and length of each note
# Each tuple contains (note name, note type (just for annotation), length (in ticks))
# Duration of 1 khung = 1920 tick = circle
notes = [
    ("D#4", "hoa mỹ", 60), ("E4", "móc đơn", 240), ("G4", "trắng", 1620), #1.5

    ("D#4", "hoa mỹ", 60), ("E4", "móc đơn", 240), ("G3", "trắng", 1620), #2.1

    ("D#4", "hoa mỹ", 60), ("E4", "móc đơn", 240), ("G4", "trắng", 1140), 
    ("G4", "liên ba", 160), ("A4", "liên ba", 160), ("G4", "liên ba", 160), #2.2

    ("A#4", "đen", 480), ("A#4", "đen", 480), ("A#4", "hoa mỹ", 60), ("A4", "móc đơn", 240),
    ("G4", "đen", 480), ("lặng", "", 180), #2.3

    ("A#4", "hoa mỹ", 60), ("A4", "móc đơn", 240), ("C5", "trắng", 1620), #2.4

    ("A#4", "hoa mỹ", 60), ("A4", "móc đơn", 240), ("C4", "trắng", 1140),
    ("C4", "liên ba", 160), ("D4", "liên ba", 160), ("C4", "liên ba", 160), #3.1

    ("D#4", "liên ba", 160), ("D4", "liên ba", 160), ("C4", "liên ba", 160), #3.2
    ("D#4", "liên ba", 160), ("D4", "liên ba", 160), ("C4", "liên ba", 160),
    ("D#4", "liên ba", 160), ("D4", "liên ba", 160), ("C4", "liên ba", 160),

    ("F#4", "hoa mỹ", 60), ("G4", "móc đơn", 240), ("G4", "trắng", 1140), #3.3
    ("G4", "liên ba", 160), ("A4", "liên ba", 160), ("G4", "liên ba", 160),

    ("A#4", "đen", 480), ("A#4", "đen", 480), ("A#4", "hoa mỹ", 60), ("A4", "móc đơn", 240),
    ("G4", "đen", 480), ("lặng", "", 180), #3.4

    ("A4", "móc đơn", 240), ("C5", "móc đơn", 240), ("A4", "móc đơn", 240), ("C4", "đen", 480), 
    ("C4", "móc đơn", 240), ("D4", "móc đơn", 240), ("C4", "móc đơn", 240), #4.1

    ("D#4", "liên ba", 160), ("D4", "liên ba", 160), ("C4", "liên ba", 160), 
    ("D#4", "liên ba", 160), ("D4", "liên ba", 160), ("C4", "liên ba", 160),
    ("D#4", "liên ba", 160), ("D4", "liên ba", 160), ("C4", "liên ba", 160), #4.2

    ("D#4", "hoa mỹ", 60), ("E4", "móc đơn", 240), ("C4", "móc đơn", 240), ("A3", "móc đơn", 240), 
    ("C4", "móc đơn", 240), ("lặng", "", 900), #4.3

]

# Danh sách hợp âm và thời điểm bắt đầu (ticks)
chords = [
    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240),
    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240), #1.1

    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240),
    ("lặng", "", 960), #2.1

    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240),
    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240), #2.2

    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240),
    ("lặng", "", 960), #2.3

    (['F3','C4'], "móc đơn", 240), (['F3','C4'], "móc đơn", 240), ("G#3", "móc đơn", 240), ("A3", "móc đơn", 240), 
    (['F3','C4'], "móc đơn", 240), (['F3','C4'], "móc đơn", 240), ("G#3", "móc đơn", 240), ("A3", "móc đơn", 240), #2/4

    (['F3','C4'], "móc đơn", 240), (['F3','C4'], "móc đơn", 240), ("G#3", "móc đơn", 240), ("A3", "móc đơn", 240), 
    ("lặng", "", 960), #3.1

    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240),
    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240), #3.2

    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240),
    ("lặng", "", 960), #3.3

    (['G3','D4'], "móc đơn", 240), (['G3','D4'], "móc đơn", 240), ("A#3", "móc đơn", 240), ("B3", "móc đơn", 240), 
    (['G3','D4'], "móc đơn", 240), (['G3','D4'], "móc đơn", 240), ("A#3", "móc đơn", 240), ("B3", "móc đơn", 240), #3.4

    (['F3','C4'], "móc đơn", 240), (['F3','C4'], "móc đơn", 240), ("G#3", "móc đơn", 240), ("A3", "móc đơn", 240), 
    (['F3','C4'], "móc đơn", 240), (['F3','C4'], "móc đơn", 240), ("G#3", "móc đơn", 240), ("A3", "móc đơn", 240), #4.1

    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240),
    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240), #4.2

    (['C4','G4'], "móc đơn", 240), (['C4','G4'], "móc đơn", 240), ("D#4","móc đơn", 240), ("E4","móc đơn", 240),
    ("lặng", "", 960), #4.3


]


# Mapping from note name to MIDI
note_to_midi = {
    "F3": 53, "G3": 55, "G#3": 56, "A3": 57, "A#3": 58, "B3":59,
    "C4": 60, "D4": 62, "D#4": 63, "E4": 64, "F#4": 66, "G4": 67,
    "A4": 69, "A#4": 70, "B4": 71, "C5": 72,
    "A5": 81, "A#5": 82, "B5": 83
}

# Channel 0 - Melody
current_time = 0
for note, _, duration in notes:
    if note != "lặng":
        midi_note = note_to_midi[note] #mapping
        track_melody.append(Message('note_on', note=midi_note, velocity=80, time=0, channel=0))
        track_melody.append(Message('note_off', note=midi_note, velocity=0, time=duration, channel=0))
    else:
        # Rest note
        track_melody.append(Message('note_on', note=0, velocity=0, time=duration, channel=0))
    current_time += duration

# Channel 1 - Chords
current_chord_time = 0
for chord_data in chords:
    if chord_data[0] == "lặng" or chord_data[0] == "rest":
        # Nghỉ
        track_chords.append(Message('note_on', note=0, velocity=0, time=chord_data[2], channel=1))
        current_chord_time += chord_data[2]
    else:
        notes, _, duration = chord_data
        for note in notes if isinstance(notes, list) else [notes]:
            midi_note = note_to_midi[note] - 12  # Lùi 1 octave
            track_chords.append(Message('note_on', note=midi_note, velocity=64, time=0, channel=1))
        for i, note in enumerate(notes if isinstance(notes, list) else [notes]):
            midi_note = note_to_midi[note] - 12
            track_chords.append(Message('note_off', note=midi_note, velocity=0, time=duration if i == 0 else 0, channel=1))
        current_chord_time += duration


# Save MIDI file 
midi.save('jazz_melody.mid')

print("Suscess")
