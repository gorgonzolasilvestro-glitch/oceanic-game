extends AnimatedSprite2D

@export var start_animation: String = "default"

func _ready() -> void:
	var sprite_frames: SpriteFrames = get_sprite_frames()
	if sprite_frames and sprite_frames.has_animation(start_animation):
		play(start_animation)
	else:
		push_warning("⚠️ Animazione '%s' non trovata o nessun SpriteFrames assegnato!" % start_animation)
