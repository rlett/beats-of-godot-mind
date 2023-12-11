extends Node

# What version are you playing on?
var osvers = ""

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
	1190, 1175, 1150, 
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

var settings = {
	# Note speed. Straightforward, yeah?
	"noteSpeed" = 1.0
}

# For silly funny time
var funsettings = {
	# Adds a little craziness to the hitreg messages.
	# Default: 1
	"hitregcrazyfactor" = 1,
	
	# Changes how long the hitreg messages live (in seconds).
	# Default: 1.5
	"hitreglifespan" = 1.5,
	
	# Show the number of points gained instead of text
	"hitregshowpts" = false,
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
var hitregtext = [
	#preload("res://Assets/perfect_msg.png"),
	#preload("res://Assets/good_msg.png"),
	#preload("res://Assets/okay_msg.png"),
	#preload("res://Assets/miss_msg.png"),
	"Perfect!",
	"Good",
	"Okay",
	"Miss",
]

var hitregcolors = [
	# Primary colors
	0x008000FF,
	0x364FFFFF,
	0xFFBC00FF,
	0xFF0000FF,
	
	# Secondary (shadow) colors
	0x002000FF,
	0x020030FF,
	0x2E1F00FF,
	0x200000FF,
]

# store the previous scene for back button functionality
var prevScene = null;

func _ready():
	# Set whether or not we playing on web
	osvers = OS.get_name() == "Web"

# Will store the records for this instance if on web.
var tempsongnames = []
var tempsongscores = []

# This is how you make a new folder
# DirAccess.make_dir_absolute("res://Data/Charts/FartSong")
