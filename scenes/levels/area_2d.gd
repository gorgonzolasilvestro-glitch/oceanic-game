extends Area2D

func _ready():
	# assicurati che il segnale sia connesso (se lo connetti in editor, non serve questa riga)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# controllo semplice: identifica il player (adatta il controllo al tuo progetto)
	if body.is_in_group("player") or body.name == "Player":
		# chiama la funzione pubblica del player passandogli la posizione dell'area (o self)
		if body.has_method("apply_hit_from_position"):
			body.apply_hit_from_position(global_position)
