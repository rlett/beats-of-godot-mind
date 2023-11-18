extends Node2D

# The currently selected level
var selectedLevel = ""
# Preloaded song button object
var songbutt = preload("res://Scenes/songButton.tscn")


# Load on start
func _ready():
	_generateSongList()


# Generates the list of songs on the lefthand side.
# Will automatically allow for scroll.
func _generateSongList():
	var dir = DirAccess.get_directories_at(global.commonchart)
	
	# Shows an error message if no songs can be found.
	if dir.size() == 0:
		$SongSelect/ErrorMsg.show()
	else:
		$SongSelect/ErrorMsg.hide()
	
	# For every song, we make a new button
	for song in dir:
		var newSong = songbutt.instantiate()
		$SongSelect/ScrollContainer/VBoxContainer.add_child(newSong)
		newSong.text = song
		newSong.connect("changeSong", _updateSelectedLevel)


# Prepares a level for playing and shows details about it.
func _updateSelectedLevel(lvl):
	# Set songpath and load up details
	global.songpath = lvl
	$SongInfo/InfoTitle.text = lvl
	$SongInfo/PlayButton.disabled = true
	$SongInfo/SongDetails.hide()
	$SongInfo.show()
	$SongInfo/Loading.show()
	
	# Add a little delay to make the viewer feel more like it's loading
	await get_tree().create_timer(0.1).timeout
	
	# Actually load the details
	var chart = JSON.parse_string(FileAccess.get_file_as_string(global.commonchart + global.songpath + "/chart.json"))
	$SongInfo/SongDetails/Notes.text = str(chart.timings.size())
	var duration = int(floor(60 * chart.finishBeat / chart.tempo))
	$SongInfo/SongDetails/Duration.text = (str(floor(duration / 60.0)) + ":" + "%02d") % (duration % 60)
	
		
	# Is there a record? Put that bih on screen.
	if(global.osvers && global.tempsongnames.has(global.songpath)):
		var i = global.tempsongnames.find(global.songpath)
		$SongInfo/SongDetails/Highscore.text = str(global.tempsongscores[i]) + " (" + _findRank(global.tempsongscores[i] / chart.timings.size()) + ")"
	elif(FileAccess.file_exists(global.commonchart + global.songpath + "/records.json")):
		var records = JSON.parse_string(FileAccess.get_file_as_string(global.commonchart + global.songpath + "/records.json"))
		$SongInfo/SongDetails/Highscore.text = str(records.score) + " (" + _findRank(records.score / chart.timings.size()) + ")"
	else:
		$SongInfo/SongDetails/Highscore.add_theme_color_override("font_color", Color.WHITE)
		$SongInfo/SongDetails/Highscore.text = "-"
	
	# Done loading, enable play button and show deets
	$SongInfo/Loading.hide()
	$SongInfo/PlayButton.disabled = false
	$SongInfo/SongDetails.show()


# Close button, sets songpath back to empty and closes visual.
func _closeLevelDetails():
	global.songpath = ""
	$SongInfo.hide()


# Takes an ANS (average note score) and determines a rank based off it.
# Score / Number of notes, done before this func call
func _findRank(ratio):
	# Very simply try to see if we got the best rank, then check the next one
	for i in range(15):
		# If we have a rank, set the correct color and return the right rank
		if(ratio > global.numranks[i]):
			$SongInfo/SongDetails/Highscore.add_theme_color_override("font_color", global.coloranks[i])
			return global.ranks[i]
	$SongInfo/SongDetails/Highscore.add_theme_color_override("font_color", Color.DIM_GRAY)
	return "F"


# if you do not know what these do you are a lost cause :D
func _level():
	get_tree().change_scene_to_file("res://Scenes/PlayGame.tscn")

func _settings():
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")
