extends AnimatableBody2D

@export var onewayplatform := false
@export var amplitude: float = 120.0   # distanza massima in pixel (su/giù)
@export var speed: float = 0.2        # cicli al secondo (maggiore = più veloce)
@export var vertical: bool = true      # true = su/giu, false = sinistra/destra

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _start_pos: Vector2
var _time: float = 0.0

func _ready() -> void:
	_start_pos = global_position

func _physics_process(delta: float) -> void:
	# aggiorna one-way collision
	collision_shape.one_way_collision = onewayplatform

	# calcola offset sinusoidale (-amplitude .. +amplitude)
	_time += delta * speed
	var offset := amplitude * sin(_time * TAU) # TAU = 2*PI
	if vertical:
		global_position = _start_pos + Vector2(0, offset)
	else:
		global_position = _start_pos + Vector2(offset, 0)
