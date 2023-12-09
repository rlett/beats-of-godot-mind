extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# TODO: have an animation for developer
	global.prevScene = get_tree().current_scene.scene_file_path
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _settings():
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")

func _freePlay():
	get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")
	
func _storyMode():
	pass

func _chartEditor():
	pass
