extends Sprite2D

var noteSpeed = 0
var go = false
# Called when the node enters the scene tree for the first time.
func _startUp(speed, pos):
	noteSpeed = speed
	position.x = 660 + 200 * pos
	position.y = 90 + speed*2
	
func _toggleMove():
	go = !go

func _go():
	go = true
	
func _stop():
	go = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if(go):
		position.y -= noteSpeed * delta
		if(position.y < -100):
			self.queue_free()
