extends Area2D

@export var fade_path: NodePath = "/root/level1/CanvasLayer/ColorRect"
@export var message_path: NodePath = "/root/level1/CanvasLayer/Label"
@export var anim_player_path: NodePath = "/root/level1/CanvasLayer/AnimationPlayer"

@export var fade_in_time: float = 4  # durata fade in

var triggered: bool = false  # evita retrigger

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

	# inizializza visibilità
	var fade_rect: ColorRect = get_node(fade_path)
	var label: Label = get_node(message_path)
	if fade_rect:
		fade_rect.modulate.a = 0.0
	if label:
		label.modulate.a = 0.0

func _on_body_entered(body):
	if triggered:
		return
	if body.name != "Player":
		return

	triggered = true

	var fade_rect: ColorRect = get_node(fade_path)
	var label: Label = get_node(message_path)
	var anim_player: AnimationPlayer = get_node(anim_player_path)

	if fade_rect:
		# fade in del ColorRect (invisibile -> visibile)
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, fade_in_time)

	if label:
		# rendi visibile il Label (alpha 0 -> 1) usando tween
		var tween2 = create_tween()
		tween2.tween_property(label, "modulate:a", 1.0, fade_in_time)

	if anim_player:
		anim_player.play("Testo")  # nome animazione
