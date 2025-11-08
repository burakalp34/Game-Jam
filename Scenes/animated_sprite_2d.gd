extends AnimatedSprite2D

func _ready() -> void:
	var anim_name := "explosion"
	var frames := sprite_frames
	if frames and frames.has_animation(anim_name):
		frames.set_animation_loop(anim_name, false)  # ⬅️ empêche la boucle
		play(anim_name)
		await animation_finished
	queue_free()
