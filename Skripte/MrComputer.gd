extends Node

const RAKETE = preload("res://Szenen/Rakete.tscn")
var besuch_feld

func _ready():
	besuch_feld = $"/root/Welt/Felder"

func such():
	randomize()
	print("-------------")
	while besuch_feld.name in Autoload.spieler2_beschossene or besuch_feld.name == "Felder":
		besuch_feld = get_node("/root/Welt/Felder/" + str(int(rand_range(1, 11))) + "_" + str(int(rand_range(1, 11))))
		print("try")

	if besuch_feld.name in Autoload.spieler1_felder:
		Autoload.spieler2_beschossene[besuch_feld.name] = true
		$"/root/Welt".spieler2_punkte += 1
		$"/root/Welt".spieler1_versenkte[besuch_feld.sp1_schiffli_name] -= 1
		
		$"/root/Welt".vollschiffcheck(besuch_feld.sp1_schiffli_name)
		$"/root/Welt".gewinnercheck()
	else:
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
	
	#Zug Beenden
	$"/root/Welt/NotifyRect/Control/AnimationPlayer".play_backwards("open")
	yield($"/root/Welt/NotifyRect/Control/AnimationPlayer", "animation_finished")
	$"/root/Welt/NotifyRect".visible = false
	
	get_parent().spieler2_ist_dran = false
