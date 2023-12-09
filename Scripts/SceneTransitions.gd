extends CanvasLayer

func change_scene(newScene: String):
	$AnimationPlayer.play("disolve")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(newScene)
	$AnimationPlayer.play_backwards("disolve")
