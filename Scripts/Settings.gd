extends Node2D

var selectedKey = -1
var children

# Called when the node enters the scene tree for the first time.
func _ready():
	children = [
		$NoteKeybinds/Note1/Primary1,
		$NoteKeybinds/Note2/Primary1,
		$NoteKeybinds/Note3/Primary1,
		$NoteKeybinds/Note4/Primary1,
		$NoteKeybinds/Note1/Secondary1,
		$NoteKeybinds/Note2/Secondary1,
		$NoteKeybinds/Note3/Secondary1,
		$NoteKeybinds/Note4/Secondary1,
	]
	
	for i in range(8):
		children[i].text = _formatButtText(global.keybinds[i])

func _formatButtText(bind):
	if(bind == KEY_NONE):
		return "-"
	return char(bind)

func _unhandled_input(event):
	if event is InputEventKey && event.pressed && !event.echo && selectedKey != -1:
		if event.keycode == KEY_ESCAPE && selectedKey > 3:
			global.keybinds[selectedKey] = KEY_NONE
			children[selectedKey].text = "-"
		else:
			global.keybinds[selectedKey] = event.keycode
			children[selectedKey].text = char(event.keycode)
		selectedKey = -1

func _back():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _setKey(key):
	selectedKey = key
