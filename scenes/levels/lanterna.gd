extends PointLight2D

@export var player_path: NodePath = "/root/level1/Player"  # percorso al Player
@export var fade_time: float = 0.5
@export var max_energy: float = 1.7
@export var vertical_offset: float = -5.0

var player: Node2D
var tween: Tween

func _ready():
	player = get_node(player_path)
	energy = 0.0
	visible = true

	tween = create_tween()
	tween.kill()

func _process(delta):
	if energy > 0.0 and player:
		global_position = player.global_position + Vector2(0, vertical_offset)

func activate_light():
	tween.kill()
	tween = create_tween()
	print("SSSSSSS")
	tween.tween_property(self, "energy", max_energy, fade_time)

func deactivate_light():
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "energy", 0.0, fade_time)
