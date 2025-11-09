extends AudioStreamPlayer2D  

@export var restart_offset := 0.0 

func _ready() -> void:
	if stream and "loop" in stream:
		stream.loop = false  
	finished.connect(_on_finished)
	play()                  

func _on_finished() -> void:
	play(restart_offset)  
