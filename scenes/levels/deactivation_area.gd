extends Area2D

@export var light_node_path: NodePath = "/root/level1/Lanterna"  # percorso relativo alla Lanterna

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		var light = get_node_or_null(light_node_path)
		if light:
			light.deactivate_light()
