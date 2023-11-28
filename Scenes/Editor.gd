extends Node2D

var timer = 10000000
var times = []

func _ready():
	get_tree().get_root().files_dropped.connect(_on_files_dropped)

func _on_files_dropped(files):
	$SongName.text = files[0].get_file()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer > 5:
		times.clear()
		$BPM.text = "BPM: -"

func _beatHit():
	if timer < 5:
		times.push_back(timer)
		if times.size() > 10:
			times.pop_front()
	else:
		times.clear()
	timer = 0
	
	var timeavg = 0
	for i in range(times.size()):
		timeavg += times[i]
	if(times.size() > 0):
		$BPM.text = "BPM: " + str(floor(times.size() * 60 / timeavg))
		


func _showFialog():
	$FileDialog.show()
	#var path = ProjectSettings.globalize_path("res://")
	#OS.shell_open(path)

func _dirSelected(dir):
	print("Directory: " + dir)
	
func _fileSelected(filedir):
	print("File: " + filedir)
