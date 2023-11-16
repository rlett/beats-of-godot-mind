extends Node

signal missed
var noteSpeed = 0
var x
var go = false

func _startUp(speed, pos):
	noteSpeed = speed
	self.position.x = 660 + 200 * pos
	x = pos
	# 90 is destination. ALWAYS TAKE 2 SECONDS FROM SPAWN TO HIT
	self.position.y = 90 + speed*2

# Is no go? GO! Is go? NO GO!
func _toggleMove():
	go = !go

# move
func _process(delta):
	if(go):
		self.position.y -= noteSpeed * delta
		# save da world
		# my final message.
		if(self.position.y < -100):
			# goodb ye
			self.queue_free()
			emit_signal("missed", x)
			
func _set_texture(tex):
	$noteSprite.texture = tex
