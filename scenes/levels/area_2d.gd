extends Area2D

var has_triggered := false  # variabile per ricordare se è già stato attivato

func _on_body_entered(body):
	if body.name == "Player" and not has_triggered:
		has_triggered = true  # segna come attivato
		get_node("/root/level1/CanvasLayer/TextureRect").show_banner()
		get_node("/root/level1/CanvasLayer/TextureRect/AnimationPlayer").play("La palude")
