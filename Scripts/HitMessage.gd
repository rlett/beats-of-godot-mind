extends Sprite2D

var moving = false
var timer = 0
var max_life = 1.5
var xmove

var xcrazy
var ycrazy

func _prepMove(slot, type, rngnum):
	position.x = 660 + slot*200
	position.y = 90
	texture = global.hitsprites[type]
	
	# For gits and shiggles, see global.funsettings
	ycrazy = 2 * global.funsettings.hitregcrazyfactor
	xcrazy = pow(global.funsettings.hitregcrazyfactor, 2)
	xmove = rngnum * xcrazy
	max_life = global.funsettings.hitreglifespan
	
	moving = true


func _process(delta):
	if(moving):
		timer += delta
		position.y = 90 + ((pow((timer - 1), 2) - 1) * (60 + ycrazy))
		position.x += xmove * delta
	if(timer > max_life):
		self.queue_free()
