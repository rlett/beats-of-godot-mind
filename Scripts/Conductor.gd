extends Node2D

# File Access
var songname
var chart
var path

# Prefab'd objects
var note = preload("res://Scenes/Note.tscn")
var hitmsg = preload("res://Scenes/HitMessage.tscn")
# Prefab'd sprites
var unpressed = preload("res://Assets/brainslot.png")
var pressed = preload("res://Assets/brainslot_pressed.png")

# Related to charting
var speed = 1000
var timer = -1
var numNote = 0
# Related to scoring
var record
var score = 0
var hitcounts = [0, 0, 0, 0]
var keys

# Misc
var scoretimer = 0
var rng = RandomNumberGenerator.new()

# paused = if the song itself is paused
var paused = false
# songstarted = if the song has started yet
var songstarted = false

# Paths to the note holes
var note_holes = [
	"NoteHoles/NoteHole1",
	"NoteHoles/NoteHole2",
	"NoteHoles/NoteHole3",
	"NoteHoles/NoteHole4",
]

# Paths to the hit count messages
var hit_count_msgs = [
	"FinalScore/Miss",
	"FinalScore/Okay",
	"FinalScore/Good",
	"FinalScore/Perfect",
]

# Note sprites as an array
var note_sprites = [
	preload("res://Assets/redbrain.png"),
	preload("res://Assets/bluebrain.png"),
]

# Vectors for noteholes
var smol = Vector2(.9, .95)
var normal = Vector2(1.0, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	keys = global.keybinds
	speed = 1000 * global.settings.noteSpeed
	
	# Loads the general path this chart will take
	# IF THE SONGNO IS SET, IT WILL REFERENCE THE SONG LIST ARRAY IN GLOBAL.
	# This is a FOLDER. Chart is path + /chart.json, audio is path + audio.mp3, etc.
	songname = global.songpath if global.songno == -1 else global.songs[global.songno][1]
	path = global.commonchart + songname
	
	# Loads the chart JSON object
	chart = JSON.parse_string(FileAccess.get_file_as_string(path + "/chart.json"))
	
	# Load up the highscore details. If no record exists load default -1.
	if(global.osvers && global.tempsongnames.has(songname)):
		var i = global.tempsongnames.find(songname)
		record = {"score": global.tempsongscores[i]}
		$Highscore.text = "Highscore: " + str(record.score)
		$Highscore.show()
	elif(FileAccess.file_exists(path + "/records.json")):
		record = JSON.parse_string(FileAccess.get_file_as_string(path + "/records.json"))
		$Highscore.text = "Highscore: " + str(record.score)
		$Highscore.show()
	else:
		record = {"score": -1}
	
	# Load up the music
	$Music.stream = load(path + "/audio.mp3")
	
	# Wait the appropriate delay.
	# 2 seconds (time it takes from spawn to note)
	# 1 beat (the negative 1 for consistent delay)
	# Start delay as given on the chart
	await get_tree().create_timer(2 + (60 / chart.tempo) + chart.startDelay).timeout
	$Music.play()
	songstarted = true


func _process(delta):
	# This happens every frame, oh well. This is for the final score tally
	scoretimer += delta
	
	# Increase the timer when unpaused
	if(!paused):
		# Convert this time into beats. TIMER CONTAINS BEAT
		timer += delta * chart.tempo / 60
		
		# If not done && ready to spawn note, spawn note
		while numNote < chart.timings.size() && timer > chart.timings[numNote].beat:
			#instantiate the new note and spawn it at a given xy position
			var newNote = note.instantiate()
			$Notes.add_child(newNote)
			
			# Set the texture of the note.
			newNote._set_texture(note_sprites[int(chart.timings[numNote].noteID) % 2])
			
			# Initialize everything and send that bih
			newNote._startUp(speed, chart.timings[numNote].noteID)
			newNote.connect("missed", _missNote)
			newNote._toggleMove()
			
			# Move to the next note
			numNote += 1
		# Update score
		$Score.text = "Score: " + str(score)
		
	# If the game is finished, "pause" so nothing can be changed
	if(timer > chart.finishBeat && !paused):
		paused = true
		_songEnd()


func _songEnd():
	# Overwriting the record iff the record is beaten.
	# This is done right away so that if the player hits continue immediately the score still gets saved.
	var newrecord = false
	if(score > record.score):
		record.score = score
		if(global.osvers):
			var i = global.tempsongnames.find(songname)
			if(i != -1):
				global.tempsongscores[i] = record.score
			else:
				global.tempsongnames.push_back(songname)
				global.tempsongscores.push_back(record.score)
		else:
			var recordsfile = FileAccess.open(path + "/records.json", FileAccess.WRITE_READ)
			recordsfile.store_string(JSON.stringify(record, "\t"))
			recordsfile.close()
		newrecord = true
	
	# Show the vignette and this entire dude
	$Vignette.show()
	$FinalScore.show()
	$FinalScore/SongName.text = chart.name
	
	# Hide background elements
	$NoteHoles.hide()
	$Score.hide()
	$Highscore.hide()
	$"FPS Counter".hide()
	
	# Should this part be a loop? Yea. Tomorrow thing tbh.
	# I did it :3
	for i in range(4):
		get_node(hit_count_msgs[i] + "/Value").text = str(hitcounts[3 - i])
		var hittext = get_node(hit_count_msgs[i] + "/Text")
		hittext.set("theme_override_colors/font_color", global.hitregcolors[3 - i])
		hittext.set("theme_override_colors/font_shadow_color", global.hitregcolors[7 - i])
		hittext.set("theme_override_colors/font_outline_color", global.hitregcolors[7 - i])
		get_node(hit_count_msgs[i]).show()
		await get_tree().create_timer(0.75).timeout
	
	# Show text that says "Final Score:" and prepare your nuts for the grand finale
	$FinalScore/FinalScore.show()
	$FinalScore/FinalScoreText.show()
	
	# Start at 0 and over the course of 1 second, total up to the actual score
	$FinalScore/FinalScore.text = str(0)
	scoretimer = 0
	while(scoretimer < 1):
		$FinalScore/FinalScore.text = str(floor(score * scoretimer))
		await get_tree().create_timer(0.05).timeout
	$FinalScore/FinalScore.text = str(score)
	await get_tree().create_timer(0.5).timeout
	
	# Finding the rank the player got
	var rank = _findRank(score / chart.timings.size())
	
	# If there is a next rank, show how close the player was to that
	var nextind = global.ranks.find(rank) - 1
	if nextind >= 0:
		$FinalScore/NextRank.text = str((global.numranks[nextind] * chart.timings.size()) - score) + " pts\nuntil " + global.ranks[nextind]
		$FinalScore/NextRank.show()
	
	# Show the rank
	$FinalScore/LetterGrade.text = rank
	$FinalScore/LetterGrade.show()
	
	if(newrecord):
		$FinalScore/HighScore.show()


# rankle
func _findRank(ratio):
	# Very simply try to see if we got the best rank, then check the next one
	for i in range(15):
		# If we have a rank, set the correct color and return the right rank
		# This could've been a global method tbh.
		if(ratio > global.numranks[i]):
			$FinalScore/LetterGrade.add_theme_color_override("font_color", global.coloranks[i])
			return global.ranks[i]
	$FinalScore/LetterGrade.add_theme_color_override("font_color", Color.DIM_GRAY)
	return "F"


# guess what this fucking does
func _quit():
	SceneTransitions.change_scene(global.prevScene)


# -------------------------
# Input handling functions
# -------------------------
func _unhandled_input(event):
	if event is InputEventKey && event.pressed && !event.echo:
		_checkPlayerInput(event.keycode)
		
	if event is InputEventKey && !paused:
		_changeNoteHoleSprite(event)

func _missNote(x):
	var regmsg = hitmsg.instantiate()
	$HitMessages.add_child(regmsg)
	regmsg._prepMove(x, 3, rng.randf_range(-100, 100), -500)
	score = max(score - 500, 0)
	hitcounts[3] += 1


# buton is push. handel
func _checkPlayerInput(key):
	var areas
	var slot = -1
	
	# im pause?
	if(key == keys[8] && songstarted):
		_pause()
	
	if(!paused):
		# Loop thru all the keys, and if one is pressed, check if notes are overlapping over it.
		# THIS PUTS PRIORITY ON THE PRIMARY KEYS
		for i in range(8):
			if(key == keys[i]):
				areas = get_node(note_holes[i % 4] + "/Area2D").get_overlapping_areas()
				slot = i % 4
				if areas:
					_processNotes(areas, slot)
				#break
		
		# If there are actual notes in the range, see what to do
		#if areas:
		#	_processNotes(areas, slot)


# Updates the sprite of the note hole when it pressed :) or depressed :(
func _changeNoteHoleSprite(keyEvent):
	# Only one key is pressed at a time. Find it.
	var key = keyEvent.keycode
	if keyEvent.pressed && !keyEvent.echo:
		# Loop thru all keys, if one is pressed, put that one down.
		for i in range(8):
			if(key == keys[i]):
				var sprite = get_node(note_holes[i % 4] + "/noteholesprite")
				sprite.texture = pressed
				sprite.scale = smol
				#break
	elif keyEvent.pressed == false:
		# Loop thru all keys, if that one is no longer pressed, put that one up.
		for i in range(8):
			if(key == keys[i]):
				var sprite = get_node(note_holes[i % 4] + "/noteholesprite")
				sprite.texture = unpressed
				sprite.scale = normal
				#break


# Processes an input on a given slot, adds points, spawns a hitreg, and removes a note
func _processNotes(areas, slot):
	# play click :3
	$SoundEffects.play()
	
	# Setting baselines for minimums
	var mindist = 9001 # it's over NINE THOUSA-
	var mindex = -1
	
	# Finding the closest note
	for noteint in range(areas.size()):
		var dist = abs(areas[noteint].get_parent().position.y - 90)
		if dist < mindist:
			mindist = dist
			mindex = noteint
	
	# At this point in time, the closest note will be counted only.
	var regmsg = hitmsg.instantiate()
	$HitMessages.add_child(regmsg)
	
	# Modify the distance based off of note speed, to functionally make it identical
	mindist /= global.settings.noteSpeed
	
	# Do I want to make this better? Yes. Is there a way? Probably.
	# Will I do it? Not tonight.
	if(mindist < 40):
		regmsg._prepMove(slot, 0, rng.randf_range(-100, 100), 1200 - floor(mindist))
		score += 1000
		hitcounts[0] += 1
	elif(mindist < 100):
		regmsg._prepMove(slot, 1, rng.randf_range(-100, 100), 1000 - floor(mindist))
		score += 800
		hitcounts[1] += 1
	elif(mindist < 160):
		regmsg._prepMove(slot, 2, rng.randf_range(-100, 100), 700 - floor(mindist))
		score += 500
		hitcounts[2] += 1
	else:
		regmsg._prepMove(slot, 2, rng.randf_range(-100, 100), 400 - floor(mindist))
		score += 200
		hitcounts[2] += 1
	
	# Add an extra bit of points based on distance
	score += (200 - floor(mindist))
	
	# Kill the note.
	areas[mindex].get_parent().queue_free()


# im pause?
func _pause():
	
	# Okay this part is as readable as a kids book
	if !paused:
		$Vignette.show()
		$Pause.show()
		paused = true
	else:
		$Pause.hide()
		$Countdown.show()
		$Countdown.text = "3"
		await get_tree().create_timer(1).timeout
		$Countdown.text = "2"
		await get_tree().create_timer(1).timeout
		$Countdown.text = "1"
		await get_tree().create_timer(1).timeout
		$Countdown.hide()
		$Vignette.hide()
		paused = false
	
	# Go thru every note and either tell them to stop moving or start again
	var notes = $Notes.get_children()
	for noteitem in notes:
		noteitem._toggleMove()
		
	# Either pause or unpause the music
	$Music.set_stream_paused(paused)
