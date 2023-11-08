extends Button

signal changeSong

func _pressed():
	emit_signal("changeSong", text)
