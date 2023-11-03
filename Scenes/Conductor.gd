extends Node2D

var timer = 0
var nextSpawn = 0
var note = preload("res://Scenes/Note.tscn")
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# increase the timer
	timer += delta
	# check that a second has passed
	if timer > nextSpawn:
		nextSpawn = timer + 1
		
		#instantiate the new note and spawn it at a given xy position
		var newNote = note.instantiate()
		$notes.add_child(newNote)
		
		var r = rng.randi_range(0, 3)
		match r:
			0:
				newNote.position.x = 513
				newNote.position.y = 1090
			1:
				newNote.position.x = 823
				newNote.position.y = 1090
			2:
				newNote.position.x = 1133
				newNote.position.y = 1090
			3:
				newNote.position.x = 1443
				newNote.position.y = 1090
		
		
		
		
