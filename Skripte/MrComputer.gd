extends Node

const RAKETE = preload("res://Szenen/Rakete.tscn")
var besuch_feld
var treffer : int = 0
var erstes_getroffenes
var letztes_getroffenes
var i : int = 0
var i_richtig : int = 4
const FELD_NAME_VEKTOREN = [Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(0, 1)]
var start : bool = true

func _ready():
	besuch_feld = $"/root/Welt/Felder"

func zug():
	randomize()
	such()
	
	if besuch_feld.name in Autoload.spieler1_felder:
		if treffer == 0:
			erstes_getroffenes = besuch_feld
		treffer += 1
		i_richtig = i - 1
		letztes_getroffenes = besuch_feld
		Autoload.spieler2_beschossene[besuch_feld.name] = true
		$"/root/Welt".spieler2_punkte += 1
		$"/root/Welt".spieler1_versenkte[besuch_feld.sp1_schiffli_name] -= 1
		
		$"/root/Welt".vollschiffcheck(besuch_feld.sp1_schiffli_name)
		$"/root/Welt".gewinnercheck()
	else:
		treffer = 0
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
	
	#Zug beenden
	start = false
	if treffer == 0:
		$"/root/Welt/NotifyRect/Control/AnimationPlayer".play_backwards("open")
		yield($"/root/Welt/NotifyRect/Control/AnimationPlayer", "animation_finished")
		$"/root/Welt/NotifyRect".visible = false
		
		get_parent().spieler2_ist_dran = false
	else:
		zug()
		pass

func such():
	if erstes_getroffenes != null:
		i = i_richtig
	else:
		i = 0
	while besuch_feld.name in Autoload.spieler2_beschossene or besuch_feld.name == "Felder":
		if treffer == 0 && erstes_getroffenes == null:
			if not start: #Für Testen
				besuch_feld = get_node("/root/Welt/Felder/" + str(int(rand_range(1, 11))) + "_" + str(int(rand_range(1, 11))))
			else:
				besuch_feld = get_node("/root/Welt/Felder/3_3")
		elif treffer != 0 && i_richtig == 4:
			besuch_feld = get_node("/root/Welt/Felder/" + str(letztes_getroffenes.coords.x + FELD_NAME_VEKTOREN[i].x) + "_" + str(letztes_getroffenes.coords.y + FELD_NAME_VEKTOREN[i].y))
			i += 1
			if i > 3:
				treffer = 0
	if i_richtig != 4:
		besuch_feld = get_node("/root/Welt/Felder/" + str(letztes_getroffenes.coords.x - FELD_NAME_VEKTOREN[i_richtig].x) + "_" + str(letztes_getroffenes.coords.y - FELD_NAME_VEKTOREN[i_richtig].y))
