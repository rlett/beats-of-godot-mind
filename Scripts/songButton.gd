extends Button

signal changeSong

# change SONG NOW
func _pressed():
	emit_signal("changeSong", text)
