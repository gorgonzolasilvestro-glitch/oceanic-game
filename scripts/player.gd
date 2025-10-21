extends CharacterBody2D

# --- PARAMETRI ---
@export var SPEED = 120.0
@export var JUMP_VELOCITY = -300.0
@export var DASH_SPEED = 400.0
@export var DASH_DURATION = 0.30
@export var DASH_COOLDOWN = 1.0
@export var KNOCKBACK_FORCE = 200.0

# --- NODI ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_particles: CPUParticles2D = $CPUParticles2D
@onready var dash_timer := Timer.new()
@onready var cooldown_timer := Timer.new()

# --- AUDIO ---
@onready var audio_walk: AudioStreamPlayer2D = $AudioWalk
@onready var audio_jump: AudioStreamPlayer2D = $AudioJump
@onready var audio_land: AudioStreamPlayer2D = $AudioLand
@onready var audio_dash: AudioStreamPlayer2D = $AudioDash
@onready var audio_hit: AudioStreamPlayer2D = $AudioDamage

# --- STATI ---
var is_dashing = false
var can_dash = true
var dash_direction = 1
var was_on_floor = true
var is_hit = false
var can_move: bool = true



func _ready() -> void:
	# Timer durata dash
	add_child(dash_timer)
	dash_timer.wait_time = DASH_DURATION
	dash_timer.one_shot = true
	dash_timer.connect("timeout", Callable(self, "_on_dash_timeout"))
	add_to_group("player")

	# Timer cooldown dash
	add_child(cooldown_timer)
	cooldown_timer.wait_time = DASH_COOLDOWN
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))

	dash_particles.emitting = false

func _physics_process(delta: float) -> void:
	# --- 1) STATO HIT: blocco controlli e gravità finché non atterra ---
	if is_hit:
		if not is_on_floor():
			velocity += get_gravity() * delta
			move_and_slide()
			return
		else:
			is_hit = false
			can_dash = true
			animated_sprite.play("idle")
			return
	if !can_move:
		animated_sprite.play("idle")
		return

	# --- 2) STATO DASH: movimento dash prioritario ---
	if is_dashing:
		velocity.x = DASH_SPEED * dash_direction
		velocity.y = 0
		move_and_slide()
		was_on_floor = is_on_floor()
		return

	# --- 3) INPUT MOVIMENTO ORIZZONTALE ---
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

	# --- 4) SALTO ---
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")
		audio_jump.play()

	# --- 5) GRAVITÀ ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- 6) APPLICA FISICA ---
	move_and_slide()

	# --- 7) ANIMAZIONI ---
	var grounded = is_on_floor()
	if grounded:
		if velocity.x == 0:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		else:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")

	# --- 8) SUONI PASSI ---
	if grounded and velocity.x != 0 and not is_dashing:
		if not audio_walk.playing:
			audio_walk.play()
	else:
		if audio_walk.playing:
			audio_walk.stop()

	# --- 9) ATERRAGGIO ---
	if not was_on_floor and grounded:
		audio_land.play()
	was_on_floor = grounded

	# --- 10) DASH ---
	if Input.is_action_just_pressed("dash") and not is_dashing and can_dash:
		start_dash()

# --- FUNZIONI DASH ---
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

# --- FUNZIONE HIT + KNOCKBACK ---
func apply_hit_from_position(hit_pos: Vector2) -> void:
	if is_hit:
		return

	is_hit = true
	is_dashing = false
	can_dash = false

	# Animazione e suono hit
	animated_sprite.play("gothit")
	if audio_hit:
		audio_hit.play()

	# Direzione knockback
	var hit_dir = sign(global_position.x - hit_pos.x)
	if hit_dir == 0:
		hit_dir = 1

	# Applica velocity knockback
	velocity.x = hit_dir * KNOCKBACK_FORCE
	velocity.y = JUMP_VELOCITY / 2

	# Stop suoni e particelle attive
	audio_walk.stop()
	dash_particles.emitting = false

	print("Player hit! Direzione:", hit_dir)
