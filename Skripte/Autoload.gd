extends Node
var x : int = 0
var spieler1_felder = []
var spieler2_felder = []

var spieler1_centerfelder = {}
var spieler2_centerfelder = {}

var spieler1_beschossene = {}
var spieler2_beschossene = {}

var actual_screen_height : int

var default_versch_values = [1864, 0, 0, 24, 128, -448]
var versch_namen = ["VersionsLabel", "GradientControl", "NameButton", "SettingButton", "SettingWegButton", "EingebeCover"]
var offline_schneller_mode : bool = true

#Zum Saven
const SAVE_PATH = "user://schiffeversenken.save"
var savegame_data = {
	"sp1name": "Player_1", "sp2name": "Player_2",
	"rotier_mode": false, "sound_an" : true, "ui_sound_an" : true, "vibration" : true,
	"screenshake_value" : 16, "verschiebung" : 0.0, "musiklautstaerke" : 26
	}

func _ready():
	load_data()
# warning-ignore:narrowing_conversion
	actual_screen_height = 1919 + (1920 * (OS.window_size.y - ((1920 * OS.window_size.x) / 1080)) / ((1920 * OS.window_size.x) / 1080))

func centerfelder_anpassen(centerfeld, rotiert : bool, laenge : int, zweites : bool, adden : bool):
	var becenterte_felder
	match $"/root/Welt".spieler2_ist_dran:
			true:
				becenterte_felder = spieler2_centerfelder
				centerfeld.sp2_centerfeld_schifflaenge = laenge
				centerfeld.sp2_centerfeld_zweites_schiff = zweites
			false:
				becenterte_felder = spieler1_centerfelder
				centerfeld.sp1_centerfeld_schifflaenge = laenge
				centerfeld.sp1_centerfeld_zweites_schiff = zweites
	if adden:
		becenterte_felder[centerfeld.name] = rotiert
	else:
		becenterte_felder.erase(centerfeld.name)

func save():
	var save_game = File.new()
	save_game.open(SAVE_PATH, File.WRITE)
	save_game.store_line(to_json(savegame_data))
	save_game.close()

func load_data():
	var save_game = File.new()
	if not save_game.file_exists(SAVE_PATH):
		save()
		return
	
	save_game.open(SAVE_PATH, File.READ)
	savegame_data = parse_json(save_game.get_line())

func musik_restart():
	$"/root/Musik".play()
