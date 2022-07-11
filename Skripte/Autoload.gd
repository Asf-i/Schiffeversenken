extends Node

var spieler1_felder = []
var spieler2_felder = []

var spieler1_centerfelder = {}
var spieler2_centerfelder = {}

var spieler1_beschossene = {}
var spieler2_beschossene = {}

var actual_screen_height : int

var default_versch_values = [1864, 0, 0, 24, 128, -448]
var versch_namen = ["VersionsLabel", "GradientControl", "NameButton", "SettingButton", "SettingWegButton", "EingebeCover"]

#Zum Saven
const SAVE_PATH = "user://schiffeversenken.save"
var savegame_data = {"sp1name": "Spieler_1", "sp2name": "Spieler_2", "rotier_mode": false, "sound_an" : false, "vibration" : true, "screenshake_value" : 10, "verschiebung" : 0.0}

func _ready():
	load_data()
# warning-ignore:narrowing_conversion
	actual_screen_height = 1919 + (1920 * (OS.window_size.y - ((1920 * OS.window_size.x) / 1080)) / ((1920 * OS.window_size.x) / 1080))
	print(actual_screen_height)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("spieler1_felder: " +  str(spieler1_felder))
		print("\nspieler_2_felder: " + str(spieler2_felder))
# warning-ignore:narrowing_conversion
		actual_screen_height = 1919 + (1920 * (OS.window_size.y - ((1920 * OS.window_size.x) / 1080)) / ((1920 * OS.window_size.x) / 1080))
		print(actual_screen_height)
	
	elif event.is_action_pressed("ui_up"):
		print("spieler1_beschossene: " + str(spieler1_beschossene))
		print("\nspieler2_beschossene: " + str(spieler2_beschossene))
		print("Im Feld: " + str($"/root/Welt".im_feld))
	elif event.is_action_pressed("ui_down"):
		print("spieler1_centerfelder: " + str(spieler1_centerfelder))
		print("\nspieler2_centerfelder: " + str(spieler2_centerfelder))
		print("spieler2_ist_dran: " + str($"/root/Welt".spieler2_ist_dran))
	
	elif event.is_action_pressed("ui_cancel"):
		for i in spieler1_centerfelder.size():
			print(get_node("/root/Welt/Felder/" + spieler1_centerfelder.keys()[i]).name + ": " + get_node("/root/Welt/Felder/" + spieler1_centerfelder.keys()[i]).sp1_schiffli_name)

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
	print("SAVE")
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
