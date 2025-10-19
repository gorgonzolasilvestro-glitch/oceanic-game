extends TextureRect

@export var display_time := 5.0
@export var fade_time1 := 1.5
@export var fade_time2 := 3.0
@export var slide_distance := 20.0  # pixel di movimento verso il basso

var tween: Tween

func _ready():
	modulate.a = 0.0  # invisibile all'avvio

func show_banner():
	if tween:
		tween.kill()
	modulate.a = 0.0

	var start_y = position.y - slide_distance
	position.y = start_y

	tween = create_tween()
	# Fade in + slide verso il basso in parallelo
	tween.parallel().tween_property(self, "modulate:a", 1.0, fade_time1)
	tween.parallel().tween_property(self, "position:y", start_y + slide_distance, fade_time1)
	# Mantiene visibile
	tween.tween_interval(display_time)
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, fade_time2)
