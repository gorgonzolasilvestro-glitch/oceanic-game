extends Area2D

# Coordinate di destinazione (modificale come vuoi)
@export var teleport_position: Vector2 = Vector2(2225.0, -1796.0)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		print("Teletrasporto attivato!")
		body.global_position = teleport_position
