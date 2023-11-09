extends Node

var unpressed = preload("res://Assets/brainslot.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$noteholesprite.texture = unpressed;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
