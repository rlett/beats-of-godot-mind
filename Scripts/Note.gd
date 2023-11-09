extends Node

var noteSpeed = 0
var go = false

func _startUp(speed, pos):
	noteSpeed = speed
	position.x = 660 + 200 * pos
	# 90 is destination. ALWAYS TAKE 2 SECONDS FROM SPAWN TO HIT
	position.y = 90 + speed*2

# Is no go? GO! Is go? NO GO!
func _toggleMove():
	go = !go

# move
func _process(delta):
	if(go):
		position.y -= noteSpeed * delta
		# save da world
		# my final message.
		if(position.y < -100):
			# goodb ye
			self.queue_free()
			
func _set_texture(tex):
	$noteSprite.texture = tex
