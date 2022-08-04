extends Node

const RAKETE = preload("res://Szenen/Rakete.tscn")
var besuch_feld
var erstes_getroffenes
var letztes_getroffenes
var i_letztes : int = 4
var i_richtig : int = 4
const FELD_NAME_VEKTOREN = [Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(0, 1)]
var start : bool = true
var state : int = 0

signal press()

func _ready():
	besuch_feld = $"/root/Welt/Felder"

func _input(_event):
	if Input.is_action_just_pressed("ui_left"):
		emit_signal("press")

func zug():
	print("state: " + str(state))
	print("i_letztes: " + str(i_letztes))
	print("i_richtig: " + str(i_richtig))
	print("erstes_getroffenes: " + str(erstes_getroffenes))
	print("letztes_getroffenes: " + str(letztes_getroffenes))
	randomize()
	such()
	
	if besuch_feld.name in Autoload.spieler1_felder:
		if state == 1:
			i_richtig = i_letztes
			state = 2
		elif state == 0:
			state = 1
		if i_letztes == 4:
			erstes_getroffenes = besuch_feld
		print("TREFFER")
		letztes_getroffenes = besuch_feld
		Autoload.spieler2_beschossene[besuch_feld.name] = true
		$"/root/Welt".spieler2_punkte += 1
		$"/root/Welt".spieler1_versenkte[besuch_feld.sp1_schiffli_name] -= 1
		
		$"/root/Welt".vollschiffcheck(besuch_feld.sp1_schiffli_name)
		if erstes_getroffenes == null:
			state = 0
	else:
		if state == 2:
			state = 3
		print("VERFEHLT")
		i_letztes = 4
		letztes_getroffenes = null
		Autoload.spieler2_beschossene[besuch_feld.name] = false
	
	#Rakete Abschiessen
	var feld = get_node("/root/Welt/EigenschiffControl/EigeneFelder/" + besuch_feld.name)
	var rakete = RAKETE.instance()
	$"/root/Welt/Raketen".add_child(rakete)
	rakete.ziel = feld.rect_global_position + feld.rect_size / 2
	rakete.nur_schoen = true
	rakete.fliegen($"/root/Welt/Felder".rect_position)
	
	yield(get_tree().create_timer(0.5), "timeout")
	$"/root/Welt/EigenschiffControl/EigeneFelder".treffer_markieren(true)
	if besuch_feld.name in Autoload.spieler1_felder:
		$"/root/Welt".gewinnercheck()
	
	#Zug beenden
	start = false
	if letztes_getroffenes == null:
		$"/root/Welt/NotifyRect/Control/AnimationPlayer".play_backwards("open")
		yield($"/root/Welt/NotifyRect/Control/AnimationPlayer", "animation_finished")
		$"/root/Welt/NotifyRect".visible = false
		
		get_parent().spieler2_ist_dran = false
	else:
		zug()

func such():
	match state:
		0:
			print("RANDOM")
			while besuch_feld.name in Autoload.spieler2_beschossene or besuch_feld.name == "Felder":
				besuch_feld = get_node("/root/Welt/Felder/" + str(int(rand_range(1, 11))) + "_" + str(int(rand_range(1, 11))))
		1:
			print("RUNDHERUM VOM ERSTEN")
			for i in 4:
				if get_node_or_null("/root/Welt/Felder/" + str(erstes_getroffenes.coords.x + FELD_NAME_VEKTOREN[i].x) + "_" + str(erstes_getroffenes.coords.y + FELD_NAME_VEKTOREN[i].y)) != null && get_node("/root/Welt/EigenschiffControl/EigeneFelder/" + str(erstes_getroffenes.coords.x + FELD_NAME_VEKTOREN[i].x) + "_" + str(erstes_getroffenes.coords.y + FELD_NAME_VEKTOREN[i].y)).aufgedeckt == false:
					besuch_feld = get_node("/root/Welt/Felder/" + str(erstes_getroffenes.coords.x + FELD_NAME_VEKTOREN[i].x) + "_" + str(erstes_getroffenes.coords.y + FELD_NAME_VEKTOREN[i].y))
					i_letztes = i
					break
		3:
			print("ANDERE RICHTUNG")
			if get_node_or_null("/root/Welt/Felder/" + str(erstes_getroffenes.coords.x - FELD_NAME_VEKTOREN[i_richtig].x) + "_" + str(erstes_getroffenes.coords.y - FELD_NAME_VEKTOREN[i_richtig].y)) != null && get_node("/root/Welt/EigenschiffControl/EigeneFelder/" + str(erstes_getroffenes.coords.x - FELD_NAME_VEKTOREN[i_richtig].x) + "_" + str(erstes_getroffenes.coords.y - FELD_NAME_VEKTOREN[i_richtig].y)).aufgedeckt == false:
				besuch_feld = get_node("/root/Welt/Felder/" + str(erstes_getroffenes.coords.x - FELD_NAME_VEKTOREN[i_richtig].x) + "_" + str(erstes_getroffenes.coords.y - FELD_NAME_VEKTOREN[i_richtig].y))
				erstes_getroffenes = besuch_feld
			else:
				i_letztes = 4
		2:
			print("AB ZWEI")
			if get_node_or_null("/root/Welt/Felder/" + str(letztes_getroffenes.coords.x + FELD_NAME_VEKTOREN[i_richtig].x) + "_" + str(letztes_getroffenes.coords.y + FELD_NAME_VEKTOREN[i_richtig].y)) != null && get_node("/root/Welt/EigenschiffControl/EigeneFelder/" + str(letztes_getroffenes.coords.x + FELD_NAME_VEKTOREN[i_richtig].x) + "_" + str(letztes_getroffenes.coords.y + FELD_NAME_VEKTOREN[i_richtig].y)).aufgedeckt == false:
				besuch_feld = get_node("/root/Welt/Felder/" + str(letztes_getroffenes.coords.x + FELD_NAME_VEKTOREN[i_richtig].x) + "_" + str(letztes_getroffenes.coords.y + FELD_NAME_VEKTOREN[i_richtig].y))
			else:
				i_letztes = 4
				state = 3
				such()
