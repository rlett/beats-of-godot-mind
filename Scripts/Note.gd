extends Node

var noteSpeed = 0
var go = false

# load textures for different notes

# Called when the node enters the scene tree for the first time.
func _startUp(speed, pos):
	noteSpeed = speed
	self.position.x = 660 + 200 * pos
	self.position.y = 90 + speed*2
	
func _toggleMove():
	go = !go

func _go():
	go = true
	
func _stop():
	go = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if(go):
		self.position.y -= noteSpeed * delta
		if(self.position.y < -100):
			self.queue_free()
			
func _set_texture(tex):
	$noteSprite.texture = tex
