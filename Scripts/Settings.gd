extends Node2D


# "selected key" is the button you want to assign a key to
# is -1 if no button should be assigned
var selectedKey = -1
var children

func _ready():
	
	# Assign the various buttons their correct text for keybinds
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


# Eventually this can contain more shit but for now just ASCII it out baby
func _formatButtText(bind):
	if(bind == KEY_NONE):
		return "-"
	return char(bind)


# you press key? you want assign key? YOU GOT IT.
func _unhandled_input(event):
	if event is InputEventKey && event.pressed && !event.echo && selectedKey != -1:
		# you press ESC? you want UNassign key? YOU GOT IT.
		if event.keycode == KEY_ESCAPE && selectedKey > 3:
			global.keybinds[selectedKey] = KEY_NONE
			children[selectedKey].text = "-"
		else:
			global.keybinds[selectedKey] = event.keycode
			children[selectedKey].text = char(event.keycode)
		selectedKey = -1

# fucking guess what this do
func _back():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _setKey(key):
	selectedKey = key
