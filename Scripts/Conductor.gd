extends Node2D

var timer = -3
var nextSpawn = 0
var note = preload("res://Scenes/Note.tscn")
var hitmsg = preload("res://Scenes/HitMessage.tscn")
var rng = RandomNumberGenerator.new()
var paused = false
var songstarted = false
var numNote = 0
var keys
var score = 0
var record
var chart
var path
var hitcounts = [0, 0, 0, 0]
var scoretimer = 0

var unpressed = preload("res://Assets/brainslot.png")
var pressed = preload("res://Assets/brainslot_pressed.png")

var note_sprite_1 = preload("res://Assets/redbrain.png")
var note_sprite_2 = preload("res://Assets/bluebrain.png")

var speed = 1000
# Called when the node enters the scene tree for the first time.
func _ready():
	keys = global.keybinds
	
	# Loads the general path this chart will take
	path = global.commonchart + global.songpath if global.songno == -1 else global.songs[global.songno][1]
	# Loads the chart JSON object
	chart = JSON.parse_string(FileAccess.get_file_as_string(path + "/chart.json"))
	
	# Load up the highscore details.
	if(FileAccess.file_exists(path + "/records.json")):
		record = JSON.parse_string(FileAccess.get_file_as_string(path + "/records.json"))
		$Highscore.text = "Highscore: " + str(record.score)
		$Highscore.show()
	else:
		record = {"score": -1}
	
	# Load up the music
	$Music.stream = load(path + "/audio.mp3")
	# Wait the appropriate delay.
	# 2 seconds (time it takes from spawn to note)
	# 3 beats (the negative 3 for consistent delay
	# Start delay as given on the chart
	await get_tree().create_timer(2 + (180 / chart.tempo) + chart.startDelay).timeout
	$Music.play()
	songstarted = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scoretimer += delta
	# increase the timer
	if(!paused):
		timer += delta * chart.tempo / 60
	# check that a second has passed
		while numNote < chart.timings.size() && timer > chart.timings[numNote].beat:
			#instantiate the new note and spawn it at a given xy position
			var newNote = note.instantiate()
			$Notes.add_child(newNote)
			# give child correct texture
			if chart.timings[numNote].noteID == 0:
				newNote._set_texture(note_sprite_1)
			if chart.timings[numNote].noteID == 1:
				newNote._set_texture(note_sprite_2)
			if chart.timings[numNote].noteID == 2:
				newNote._set_texture(note_sprite_1)
			if chart.timings[numNote].noteID == 3:
				newNote._set_texture(note_sprite_2)
			newNote._startUp(speed, chart.timings[numNote].noteID)
			newNote._toggleMove()
			
			numNote += 1
		$Score.text = "Score: " + str(score)
	if(timer > chart.finishBeat && !paused):
		paused = true
		_songEnd()

func _songEnd():
	# Overwriting the record iff the record is beaten
	if(score > record.score):
		record.score = score
		var recordsfile = FileAccess.open(path + "/records.json", FileAccess.WRITE_READ)
		recordsfile.store_string(JSON.stringify(record, "\t"))
		recordsfile.close()
	
	$Vignette.show()
	$FinalScore.show()
	$FinalScore/Miss/Misses.text = str(0)
	$FinalScore/Miss.show()
	await get_tree().create_timer(0.75).timeout
	$FinalScore/Okay/Okays.text = str(hitcounts[2])
	$FinalScore/Okay.show()
	await get_tree().create_timer(0.75).timeout
	$FinalScore/Good/Goods.text = str(hitcounts[1])
	$FinalScore/Good.show()
	await get_tree().create_timer(0.75).timeout
	$FinalScore/Perfect/Perfects.text = str(hitcounts[0])
	$FinalScore/Perfect.show()
	await get_tree().create_timer(0.75).timeout
	$FinalScore/FinalScore.show()
	$FinalScore/FinalScoreText.show()
	$FinalScore/FinalScore.text = str(0)
	scoretimer = 0
	while(scoretimer < 1):
		$FinalScore/FinalScore.text = str(floor(score * scoretimer))
		await get_tree().create_timer(0.05).timeout
	$FinalScore/FinalScore.text = str(score)
	await get_tree().create_timer(0.5).timeout
	$FinalScore/LetterGrade.text = _findRank(score / chart.timings.size())
	$FinalScore/LetterGrade.show()

func _findRank(ratio):
	for i in range(14):
		if(ratio > global.numranks[i]):
			$FinalScore/LetterGrade.add_theme_color_override("font_color", global.coloranks[i])
			return global.ranks[i]
	$FinalScore/LetterGrade.add_theme_color_override("font_color", Color.DIM_GRAY)
	return "F"

func _quit():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")



# -------------------------
# Input handling functions
# -------------------------
func _unhandled_input(event):
	if event is InputEventKey && event.pressed && !event.echo:
		_checkPlayerInput(event.keycode)
		
	if event is InputEventKey:
		_changeNoteHoleSprite(event)

func _checkPlayerInput(key):
	var areas
	var slot = -1
	
	if(key == keys[8] && songstarted):
		_pause()
	
	if(!paused):
		if(key == keys[0] || key == keys[4]):
			areas = $NoteHoles/NoteHole1/Area2D.get_overlapping_areas()
			slot = 0
		elif(key == keys[1] || key == keys[5]):
			areas = $NoteHoles/NoteHole2/Area2D.get_overlapping_areas()
			slot = 1
		elif(key == keys[2] || key == keys[6]):
			areas = $NoteHoles/NoteHole3/Area2D.get_overlapping_areas()
			slot = 2
		elif(key == keys[3] || key == keys[7]):
			areas = $NoteHoles/NoteHole4/Area2D.get_overlapping_areas()
			slot = 3
		
		if areas:
			_processNotes(areas, slot)

func _changeNoteHoleSprite(keyEvent):
	if (!paused):
		var key = keyEvent.keycode
		if keyEvent.pressed && !keyEvent.echo:
			if(key == keys[0] || key == keys[4]):
				$NoteHoles/NoteHole1/noteholesprite.texture = pressed
				$NoteHoles/NoteHole1/noteholesprite.scale = Vector2(.9, .95)
			elif(key == keys[1] || key == keys[5]):
				$NoteHoles/NoteHole2/noteholesprite.texture = pressed
				$NoteHoles/NoteHole2/noteholesprite.scale = Vector2(.9, .95)
			elif(key == keys[2] || key == keys[6]):
				$NoteHoles/NoteHole3/noteholesprite.texture = pressed
				$NoteHoles/NoteHole3/noteholesprite.scale = Vector2(.9, .95)
			elif(key == keys[3] || key == keys[7]):
				$NoteHoles/NoteHole4/noteholesprite.texture = pressed
				$NoteHoles/NoteHole4/noteholesprite.scale = Vector2(.9, .95)
		elif keyEvent.pressed == false:
			if(key == keys[0] || key == keys[4]):
				$NoteHoles/NoteHole1/noteholesprite.texture = unpressed
				$NoteHoles/NoteHole1/noteholesprite.scale = Vector2(1, 1)
			elif(key == keys[1] || key == keys[5]):
				$NoteHoles/NoteHole2/noteholesprite.texture = unpressed
				$NoteHoles/NoteHole2/noteholesprite.scale = Vector2(1, 1)
			elif(key == keys[2] || key == keys[6]):
				$NoteHoles/NoteHole3/noteholesprite.texture = unpressed
				$NoteHoles/NoteHole3/noteholesprite.scale = Vector2(1, 1)
			elif(key == keys[3] || key == keys[7]):
				$NoteHoles/NoteHole4/noteholesprite.texture = unpressed
				$NoteHoles/NoteHole4/noteholesprite.scale = Vector2(1, 1)

func _processNotes(areas, slot):
	$SoundEffects.play()
	var mindist = 9001 # it's over NINE THOUSA-
	var mindex = -1
	for noteint in range(areas.size()):
		var dist = abs(areas[noteint].get_parent().position.y - 90)
		if dist < mindist:
			mindist = dist
			mindex = noteint
	
	# At this point in time, the closest note will be counted only.
	var regmsg = hitmsg.instantiate()
	$HitMessages.add_child(regmsg)
	if(mindist < 40):
		regmsg._prepMove(slot, 0, rng.randf_range(-100, 100))
		score += 1000
		hitcounts[0] += 1
	elif(mindist < 100):
		regmsg._prepMove(slot, 1, rng.randf_range(-100, 100))
		score += 800
		hitcounts[1] += 1
	elif(mindist < 160):
		regmsg._prepMove(slot, 2, rng.randf_range(-100, 100))
		score += 500
		hitcounts[2] += 1
	else:
		regmsg._prepMove(slot, 2, rng.randf_range(-100, 100))
		score += 200
		hitcounts[2] += 1
	score += (200 - floor(mindist))
	areas[mindex].get_parent().queue_free()



func _pause():
	
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
	
	var notes = $Notes.get_children()
	for noteitem in notes:
		noteitem._toggleMove()
	$Music.set_stream_paused(paused)
