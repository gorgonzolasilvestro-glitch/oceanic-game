extends CharacterBody2D

@export var SPEED = 120.0
@export var JUMP_VELOCITY = -300.0
@export var DASH_SPEED = 400.0
@export var DASH_DURATION = 0.30
@export var DASH_COOLDOWN = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_particles: CPUParticles2D = $CPUParticles2D
@onready var dash_timer := Timer.new()
@onready var cooldown_timer := Timer.new()

# --- Audio ---
@onready var audio_walk: AudioStreamPlayer2D = $AudioWalk
@onready var audio_jump: AudioStreamPlayer2D = $AudioJump
@onready var audio_land: AudioStreamPlayer2D = $AudioLand
@onready var audio_dash: AudioStreamPlayer2D = $AudioDash

var is_dashing = false
var can_dash = true
var dash_direction = 1
var was_on_floor = true  # per rilevare l'atterraggio

func _ready() -> void:
	# Timer durata dash
	add_child(dash_timer)
	dash_timer.wait_time = DASH_DURATION
	dash_timer.one_shot = true
	dash_timer.connect("timeout", Callable(self, "_on_dash_timeout"))

	# Timer cooldown dash
	add_child(cooldown_timer)
	cooldown_timer.wait_time = DASH_COOLDOWN
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))

	# inizialmente particelle spente
	dash_particles.emitting = false

func _physics_process(delta: float) -> void:
	# Se stiamo facendo il dash, gestiamo solo il dash (muove e ritorna)
	if is_dashing:
		velocity.x = DASH_SPEED * dash_direction
		velocity.y = 0
		move_and_slide()
		# aggiorniamo was_on_floor per non sparare land su entrata/uscita
		was_on_floor = is_on_floor()
		return

	# --- 1) Input orizzontale: impostiamo velocity.x basandoci sugli input ---
	var input_dir = 0
	if Input.is_action_pressed("move_left"):
		input_dir = -1
		dash_direction = -1
		animated_sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		input_dir = 1
		dash_direction = 1
		animated_sprite.flip_h = false

	velocity.x = input_dir * SPEED

	# --- 2) Salto: impostiamo la velocità verticale solo quando si preme il jump a terra ---
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")
		audio_jump.play()

	# --- 3) Gravità ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- 4) Applichiamo la fisica (qui is_on_floor() viene aggiornato correttamente) ---
	move_and_slide()

	# --- 5) Ora aggiorniamo animazioni e suoni in base allo stato attuale ---
	var grounded = is_on_floor()

	# Animazioni: idle/run (grounded) o jump (air)
	if grounded:
		if velocity.x == 0:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		else:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")
	else:
		# in aria non riavviamo continuamente l'animazione di jump (assumiamo sia stata settata al momento del jump)
		pass

	# Suono passi: solo se grounded e stai effettivamente camminando e non dashing
	if grounded and velocity.x != 0 and not is_dashing:
		if not audio_walk.playing:
			audio_walk.play()
	else:
		if audio_walk.playing:
			audio_walk.stop()

	# Rilevamento atterraggio (play land sound una sola volta quando si torna a terra)
	if not was_on_floor and grounded:
		audio_land.play()

	was_on_floor = grounded

	# DASH (tasto destro)
	if Input.is_action_just_pressed("dash") and not is_dashing and can_dash:
		start_dash()

func start_dash() -> void:
	is_dashing = true
	can_dash = false
	animated_sprite.play("dash")

	dash_particles.emitting = true
	audio_dash.play()

	dash_timer.start()
	cooldown_timer.start()

func _on_dash_timeout() -> void:
	is_dashing = false
	dash_particles.emitting = false

func _on_cooldown_timeout() -> void:
	can_dash = true
