extends Node2D





func _on_restartbutton_pressed() -> void:
	get_tree().reload_current_scene()
