extends Label

var moving = false
var timer = 0
var max_life = 1.5
var xmove

var xcrazy
var ycrazy

func _prepMove(slot, type, rngnum, pts):
	position.x = 360 + slot*200
	position.y = -60
	
	text = global.hitregtext[type] if !global.funsettings.hitregshowpts else "+" + str(pts) if pts > 0 else str(pts)
	set("theme_override_colors/font_color", global.hitregcolors[type])
	set("theme_override_colors/font_shadow_color", global.hitregcolors[type + 4])
	set("theme_override_colors/font_outline_color", global.hitregcolors[type + 4])
	
	if(pts == 1200):
		if(!global.funsettings.hitregshowpts):
			text = "Synaptic!"
		set("theme_override_colors/font_color", Color.MAGENTA)
	
	# For gits and shiggles, see global.funsettings
	ycrazy = 2 * global.funsettings.hitregcrazyfactor
	xcrazy = pow(global.funsettings.hitregcrazyfactor, 2)
	xmove = rngnum * xcrazy
	max_life = global.funsettings.hitreglifespan
	
	moving = true


func _process(delta):
	if(moving):
		timer += delta
		position.y = -60 + ((pow((timer - 1), 2) - 1) * (60 + ycrazy))
		position.x += xmove * delta
		modulate.a = min(1.5 - (1.5 * (timer / max_life)), 1)
	if(timer > max_life):
		self.queue_free()
