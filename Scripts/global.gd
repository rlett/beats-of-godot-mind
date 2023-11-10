extends Node

# Common path to all charts
var commonchart = "res://Data/Charts/"

# If freeplay is on, songno should stay -1.
# songpath ONLY needs the name of the chart or folder
var songno = -1
var songpath = ""

var gameplay_constants = {
	
}

var ranks = [
	"S++", "S+", "S", 
	"A+", "A", "A-", 
	"B+", "B", "B-", 
	"C+", "C", "C-", 
	"D+", "D", "D-"
]

var numranks = [
	1195, 1175, 1150, 
	1100, 1075, 1050, 
	1000, 975, 950, 
	900, 850, 800, 
	700, 600, 500
]

var coloranks = [
	Color.GOLDENROD, Color.FUCHSIA, Color.FUCHSIA,
	Color.FOREST_GREEN, Color.FOREST_GREEN, Color.FOREST_GREEN,
	Color.GOLD, Color.GOLD, Color.GOLD,
	Color.ORANGE, Color.ORANGE, Color.ORANGE,
	Color.DARK_RED, Color.DARK_RED, Color.DARK_RED,
]

# beykinds
var keybinds = [
	# Four notes
	KEY_A,
	KEY_S,
	KEY_D,
	KEY_F,
	
	# Alternative/extra notes
	KEY_NONE,
	KEY_NONE,
	KEY_NONE,
	KEY_NONE,
	
	# Pause
	KEY_ESCAPE
]

# For silly funny time
var funsettings = {
	# Adds a little craziness to the hitreg messages.
	# Default: 1
	"hitregcrazyfactor" = 1,
	
	# Changes how long the hitreg messages live (in seconds).
	# Default: 1.5
	"hitreglifespan" = 1.5,
}


# This is where we'll be storymoding
# ["Display Name", "folder"]
var songs = [
	
	["Song 1", "Rhythm Heaven - Tambourine"],
	["Song 2", "wndrwll"],
	["Song 3", "Borderline Forever"],
	["Song 4", "Everflow"],
	
]

# I makea deez global for less F-fart
var hitsprites = [
	preload("res://Assets/perfect_msg.png"),
	preload("res://Assets/good_msg.png"),
	preload("res://Assets/okay_msg.png"),
	preload("res://Assets/miss_msg.png")
]
