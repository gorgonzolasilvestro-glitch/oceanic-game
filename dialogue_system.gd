extends Node2D

const DialogueButtomPreload = preload("res://dialogue_button.tscn")

@onready var DialogueLabel: RichTextLabel = $HBoxCOntainer/VBoxContainer/RichTextLabel
@onready var SpeakerSprite: Sprite2D = $HBoxCOntainer/SpeakerParent/Sprite2D

var dialogue: Array[DE]
var current_dialogue_item: int = 0
var next_item: bool = true

var player_node :CharacterBody2D

func _ready() -> void:
	visible = false
	$HBoxContainer/VBoxContainer/button_container.visible = false
	
	for i in get_tree() .get_nodes_in_group("player"):
		player_node = i

func _process(_delta: float) -> void:
	if current_dialogue_item == dialogue.size():
		if !player_node:
			for i in get_tree() .get_nodes_in_group("player"):
				player_node = i
			return
		player_node.can_move = true
		queue_free()
		return
	if next_item:
		next_item = false
		var i = dialogue[current_dialogue_item]
		
		
		if i is DialogueFunction:
			if i.hide_dialogue_box:
				visible = false
			else:
				visible = true
			_function_resource(i)
		
		elif i is DialogueChoice:
			visible = true
			_choice_resource(i)
		
		elif i is DialogueText:
			visible = true
			_text_resource(i)
		
		else:
			printerr("you accidentally added a DE recource")
			current_dialogue_item += 1
			next_item = true 

func _function_resource(i: DialogueFunction) -> void:
	var target_node = get_node(i.target_path)
	if target_node.has_method(i.function_name):
		if i.function_arguments.size() == 0:
			target_node.call(i.function_name)
		else:
			target_node.callv(i.function_name, i.function_arguments)
	
		if i.wait_for_signal_to_continue:
			var signal_name = i.wait_for_signal_to_continue
			if target_node.has_signal(signal_name):
				var signal_state = { "done": false }
				var callable = func(_args): signal_state.done = true
				target_node.connect(signal_name, callable, CONNECT_ONE_SHOT)
				while not signal_state.done:
					await get_tree().process_frame

	current_dialogue_item += 1
	next_item = true

func _choice_resource(i: DialogueChoice) -> void:
	DialogueLabel.text = i.text
	DialogueLabel.visible_characters = -1
	if i.speaker_img:
		$HBoxContainer/SpeakerParent.visible = true 
		SpeakerSprite.texture = i.speaker_img
		SpeakerSprite.hframes = i.speaker_img_Hframes
		SpeakerSprite.frame = min(i.speaker_img_select_frame, i.speaker_img_hframes-1)
	else:
		$HBoxContainer/speakerPArent.visible = false
	$HBoxContainer/VBoxContainer/buttom_container.visible = true

	for item in i.choice_text.size():
		var DialogueButtomVar = DialogueButtomPreload.instantiate()
		DialogueButtomVar.text = i.choice_text[item]
		
		var function_resource: DialogueFunction = i.choice_function_call[item]
		if function_resource:
			DialogueButtomVar.connect("pressed",
			Callable(get_node(function_resource.target_path), function_resource.function_name).bindv(function_resource.function_arguments), CONNECT_ONE_SHOT)
			if function_resource.hide_dialogue_box:
				DialogueButtomVar.connect("pressed", hide, CONNECT_ONE_SHOT)
			DialogueButtomVar.connect("pressed",
			_choice_button_pressed.bind(get_node(function_resource.target_path), function_resource.wait_for_signal_to_continue), CONNECT_ONE_SHOT)
		else:
			DialogueButtomVar.connect("pressed", _choice_button_pressed.bind(null, ""), CONNECT_ONE_SHOT)
		
		$HBoxContainer/VBoxContainer/buttom_container.add_child(DialogueButtomVar)
	$HBoxContainer/VBoxContainer/buttom_container.get_child(0).grab_focus()


func _choice_button_pressed(target_node: Node, wait_for_signal_to_continue: String):
	$HBoxContainer/VBoxContainer/buttom_container.visible = false 
	for i in $HBoxContainer/VBoxContainer/buttom_container.get_children():
		i.queue_free()
	
	if wait_for_signal_to_continue:
		var signal_name = wait_for_signal_to_continue
		if target_node.has_signal(signal_name):
			var signal_state={"done":false}
			var callable = func(_args): signal_state.done =true
			target_node.connect(signal_name, callable, CONNECT_ONE_SHOT)
			while not signal_state.done:
				await get_tree().process_frame

	current_dialogue_item+=1
	next_item=true

func _text_resource(i: DialogueText) -> void:
	$AudioStreamPlayer.stream=i.text_cound
	$AudioStreamPlayer.volume_db=i.text_volumedb
	var camera: Camera2D=get_viewport().get_camera_2d()
	if camera and i.camera_position != Vector2(999.999, 999.999):
		var camera_tween: Tween =create_tween().set_trans(Tween.TRANS_SINE)
		camera_tween.property(camera, "global_position", i.camera_position, i.camera_transition_time)
	if !i.speaker_img:
		$HBoxContainer/speakerPArent.visible = false
	else:
		$HBoxContainer/speakerPArent.visible=true
		SpeakerSprite.texture =i.speaker_img
		SpeakerSprite.hframes =i.speaker_img_Hframes
		SpeakerSprite.frame = 0
		
	DialogueLabel.visible_characters=0
	DialogueLabel.text=i.text
	var text_without_square_brackets: String = _text_without_square_brackets(i.text)
	var total_characters: int = text_without_square_brackets.length()
	var character_timer: float =0.0
	while DialogueLabel.visible_characters < total_characters:
		if Input.is_action_just_pressed("vi_cncel"):
			DialogueLabel.visible_characters = total_characters
		break
	
		character_timer += get_process_delta_time()
		if character_timer >= (1.0 / i.texted_speed) or text_without_square_brackets[DialogueLabel.visible_characters]== " ":
			var character: String=text_without_square_brackets[DialogueLabel.visible_characters]
			DialogueLabel.visible_characters += 1
			if character != " ":
				$AudioStreamPlayer.pitch_scale=randf_range(i.text_volume_pitch_min, i.text_volume_pitch_max)
				$AudioStreamPlayer.play()
				if i.speaker_img_Hframes!= 1:
					if SpeakerSprite.frame < i.speaker_img_Hframes -1:
						SpeakerSprite.frame +=1
					else:
						SpeakerSprite.frame = 0
			character_timer =0.0
			
		await get_tree().process_frame
	SpeakerSprite.frame=min(i.speaker_img_rest_frame, i.speaker_img_Hframes-1)
	
	while true:
		await get_tree().process.frame
		if DialogueLabel.visible_characters == total_characters:
			if Input.is_action_just_pressed("vi.accept"):
				current_dialogue_item +=1
				next_item= true

func _text_without_square_brackets(text: String) -> String:
	var result: String = ""
	var inside_bracket: bool=false

	for i in text:
		if i == "[":
			inside_bracket=true
			continue
			
		if i=="]":
			inside_bracket=false
			continue
		
		if !inside_bracket:
			result += i
	return result
