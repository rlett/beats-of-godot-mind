extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# TODO: have an animation for developer
	global.prevScene = get_tree().current_scene.scene_file_path
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _storyMode():
	pass
	
func _freePlay():
	SceneTransitions.change_scene("res://Scenes/LevelSelect.tscn")
	
func _chartEditor():
	pass

func _settings():
	SceneTransitions.change_scene("res://Scenes/Settings.tscn")


	



