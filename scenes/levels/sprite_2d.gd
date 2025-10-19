extends Sprite2D

@export var display_time := 2.0  # quanto resta visibile
@export var fade_time := 0.5     # durata del fade in/out

var tween: Tween

func _ready():
	modulate.a = 1  # inizia trasparente

func show_banner():
	# Se c'è già un tween in corso, lo fermiamo
	if tween:
		tween.kill()

	# Riavvia il fade completo
	modulate.a = 0.0
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)   # fade in
	tween.tween_interval(display_time)
	tween.tween_property(self, "modulate:a", 0.0, fade_time)   # fade out
