extends Node2D

var timer = 0
var chart
var record
var path
var score = -1
var selectedLevel = ""

var songbutt = preload("res://Scenes/songButton.tscn")

func _ready():

	# Loading the record for the song. -1 means unplayed.
	#if(FileAccess.file_exists(path + "/records.json")):
	#	record = JSON.parse_string(FileAccess.get_file_as_string(path + "/records.json"))
	#else:
	#	record = {"score": -1}
		
	#_songEnd()
	_generateSongList()

func _songEnd():
	# Overwriting the record iff the record is beaten
	if(score > record.score):
		record.score = score
		var recordsfile = FileAccess.open(path + "/records.json", FileAccess.WRITE_READ)
		recordsfile.store_string(JSON.stringify(record, "\t"))
		recordsfile.close()

func _generateSongList():
	var dir = DirAccess.get_directories_at(global.commonchart)
	
	if dir.size() == 0:
		$SongSelect/ErrorMsg.show()
	else:
		$SongSelect/ErrorMsg.hide()
		
	for song in dir:
		var newSong = songbutt.instantiate()
		$SongSelect/ScrollContainer/VBoxContainer.add_child(newSong)
		newSong.text = song
		newSong.connect("changeSong", _updateSelectedLevel)


func _updateSelectedLevel(lvl):
	global.songpath = lvl
	$SongInfo/InfoTitle.text = lvl
	$SongInfo/PlayButton.disabled = true
	$SongInfo/SongDetails.hide()
	$SongInfo.show()
	$SongInfo/Loading.show()
	
	# Add a little delay to make the viewer feel more like it's loading
	await get_tree().create_timer(0.2).timeout
	# Actually load the details
	chart = JSON.parse_string(FileAccess.get_file_as_string(global.commonchart + global.songpath + "/chart.json"))
	$SongInfo/SongDetails/Notes.text = str(chart.timings.size())
	var duration = int(floor(60 * chart.finishBeat / chart.tempo))
	$SongInfo/SongDetails/Duration.text = (str(duration / 60) + ":" + "%02d") % (duration % 60)
	
	var records
	if(FileAccess.file_exists(global.commonchart + global.songpath + "/records.json")):
		records = JSON.parse_string(FileAccess.get_file_as_string(global.commonchart + global.songpath + "/records.json"))
		$SongInfo/SongDetails/Highscore.text = str(records.score) + " (" + _findRank(records.score / chart.timings.size()) + ")"
	else:
		$SongInfo/SongDetails/Highscore.text = "-"
	
	$SongInfo/Loading.hide()
	$SongInfo/PlayButton.disabled = false
	$SongInfo/SongDetails.show()
	

func _closeLevelDetails():
	global.songpath = ""
	$SongInfo.hide()

# This is gonna be ugly.
func _findRank(ratio):
	for i in range(14):
		if(ratio > global.numranks[i]):
			return global.ranks[i]
	return "F"

func _level():
	get_tree().change_scene_to_file("res://Scenes/PlayGame.tscn")

func _settings():
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")
