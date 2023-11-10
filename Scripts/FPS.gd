extends Label

# Is fups. need more? fuck you
func _process(_delta):
	text = str(floor(Engine.get_frames_per_second())) + " fps"
