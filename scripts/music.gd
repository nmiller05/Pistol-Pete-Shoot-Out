extends AudioStreamPlayer
@onready var looped_song: AudioStreamPlayer = $LoopedSong


func _on_finished() -> void:
	looped_song.play()
