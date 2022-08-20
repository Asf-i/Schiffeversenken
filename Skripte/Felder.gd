extends Control

const FELD = preload("res://Szenen/Feld.tscn")
export var separation_faktor : int = 41

var nahfeld
var zahl : int
var zahl2 : int
var rotiert : bool
var bearbeitetes_feld
var laenge : int

var normalfarbe = Color(0.894118, 0.894118, 0.894118)
var herumfarbe = Color(0.85, 0.8, 0.8)
var innenfarbe = Color(0.894118, 0.894118, 0.894118)
var verfehltfarbe = Color(0.894118, 0.894118, 0.894118)
var trefferfarbe = Color(0.894118, 0.894118, 0.894118)

func felder_platzieren():
	var felder_collisions : bool = true
	if name == "EigeneFelder":
		felder_collisions = false
	var feldergroesse = FELD.instance().rect_size
	separation_faktor += feldergroesse.x
	$Area2D/CollisionShape2D.scale = Vector2(10 * feldergroesse + 9 * (Vector2(separation_faktor, separation_faktor) - feldergroesse)) / 2
	for n in 10:
		for i in 10:
			var feld = FELD.instance()
			feld.get_node("Area2D").monitoring = felder_collisions
			feld.name = str(i + 1) + "_" + str(n + 1)
			feld.coords = Vector2(i + 1, n + 1)
			feld.rect_position = Vector2(i * separation_faktor - $Area2D/CollisionShape2D.scale.x, n * separation_faktor - $Area2D/CollisionShape2D.scale.y)
			add_child(feld)
	if name == "Felder":
		move_child($Abdeckung, 102)

func felderstatus_speichern(spieler2_ist_dran):
	var bearbeitfeld
	
	#FELDER DICT
#	for n in 10:
#		for i in 10:
#			bearbeitfeld = get_node(str(i + 1) + "_" + str(n + 1))
#			match spieler2_ist_dran:
#				false: Autoload.spieler1_felder[bearbeitfeld.name] = bearbeitfeld.schiffli
#				true: Autoload.spieler2_felder[bearbeitfeld.name] = bearbeitfeld.schiffli
	
	for n in 10:
		for i in 10:
			bearbeitfeld = get_node(str(i + 1) + "_" + str(n + 1))
			if bearbeitfeld.schiffli:
				match spieler2_ist_dran:
					false: Autoload.spieler1_felder.append(bearbeitfeld.name)
					true: Autoload.spieler2_felder.append(bearbeitfeld.name)

func felder_laden(spieler2_ist_dran):
#	for n in 10:
#		for i in 10:
#			match spieler2_ist_dran:
#				false: get_node(str(i + 1) + "_" + str(n + 1)).schiffli = Autoload.spieler1_felder[str(i + 1) + "_" + str(n + 1)]
#				true: get_node(str(i + 1) + "_" + str(n + 1)).schiffli = Autoload.spieler2_felder[str(i + 1) + "_" + str(n + 1)]
#			if get_node(str(i + 1) + "_" + str(n + 1)).schiffli:
#				get_node(str(i + 1) + "_" + str(n + 1)).modulate = innenfarbe
	
	var check_array
	if spieler2_ist_dran:
		check_array = Autoload.spieler2_felder
	else:
		check_array = Autoload.spieler1_felder
	
	for i in check_array.size():
		get_node(check_array[i]).schiffli = true
		get_node(check_array[i]).get_node("Button").modulate = innenfarbe

func treffer_markieren(spieler2_ist_dran):
	var bearbeit_node
	var check_dict = {}
	
	match spieler2_ist_dran:
		true: check_dict = Autoload.spieler2_beschossene
		false: check_dict = Autoload.spieler1_beschossene
	
	for checkzahl in check_dict.size():
		bearbeit_node = get_node(check_dict.keys()[checkzahl])
		bearbeit_node.aufgedeckt = true
		if check_dict[check_dict.keys()[checkzahl]] == true:
			bearbeit_node.get_node("Button").modulate = trefferfarbe
			bearbeit_node.get_node("Treffer/Treffplayer").play("aufgedeckt")
		else:
			bearbeit_node.get_node("Button").modulate = verfehltfarbe
			bearbeit_node.get_node("Verfehlt/Verfehltplayer").play("aufgedeckt")

func ist_moeglich(selected_schiffli_im_feld):
	if nahfeld && selected_schiffli_im_feld:
		laengencheck()
		var laengen_zahl : int = zahl
		while laengen_zahl >= -zahl2 + 1:
			if rotiert:
				bearbeitetes_feld = get_node_or_null(str(nahfeld.coords.x) + "_" + str(nahfeld.coords.y + laengen_zahl))
			else:
				bearbeitetes_feld = get_node_or_null(str(nahfeld.coords.x + laengen_zahl) + "_" + str(nahfeld.coords.y))
			
			if bearbeitetes_feld == null or bearbeitetes_feld.schiffli or bearbeitetes_feld.besetzt != 0:
				return false
			laengen_zahl -= 1
		return true
	return false

func besetztfelder_markieren(loeschen : bool, schiffli_name : String):
	if nahfeld:
		laengencheck()
		for i in range(-1, 2):
			if i == 0:
				laenge += 2
				laengencheck()
			for laengen_zahl in range(zahl, -zahl2, -1):
				if rotiert:
					bearbeitetes_feld = get_node_or_null(str(nahfeld.coords.x + i) + "_" + str(nahfeld.coords.y + laengen_zahl))
				else:
					bearbeitetes_feld = get_node_or_null(str(nahfeld.coords.x + laengen_zahl) + "_" + str(nahfeld.coords.y + i))
				if bearbeitetes_feld:
					if loeschen:
						bearbeitetes_feld.besetzt -= 1
						if bearbeitetes_feld.besetzt == 0:
							bearbeitetes_feld.get_node("Button").modulate = normalfarbe
					else:
						bearbeitetes_feld.besetzt += 1
						bearbeitetes_feld.get_node("Button").modulate = herumfarbe
			if i == 0:
				laenge -= 2
				laengencheck()
		
		for laengen_zahl in range(zahl, -zahl2, -1):
			if rotiert && laengen_zahl == 0 or rotiert && laengen_zahl != 0:
				bearbeitetes_feld = get_node(str(nahfeld.coords.x) + "_" + str(nahfeld.coords.y + laengen_zahl))
			else:
				bearbeitetes_feld = get_node(str(nahfeld.coords.x + laengen_zahl) + "_" + str(nahfeld.coords.y))
			if loeschen:
				bearbeitetes_feld.schiffli = false #hier Absturz oder so kein Plan -> Es wird immernoch nach Feldern wie '11_8' geschaut. [Ok maybe hab ich das gefixt :0]
				match $"/root/Welt".spieler2_ist_dran:
					true: bearbeitetes_feld.sp2_schiffli_name = ""
					false: bearbeitetes_feld.sp1_schiffli_name = ""
				bearbeitetes_feld.get_node("Button").modulate = normalfarbe
			else:
				bearbeitetes_feld.schiffli = true
				match $"/root/Welt".spieler2_ist_dran:
					true: bearbeitetes_feld.sp2_schiffli_name = schiffli_name
					false: bearbeitetes_feld.sp1_schiffli_name = schiffli_name
				bearbeitetes_feld.get_node("Button").modulate = innenfarbe

func schiff_in_feld_platzieren(centerfeld, gegenteil : bool = false, mit_centerfeld_wegen_random : bool = true, schiffcontainer_node = null):
	print("EIGENE SCHIFFE: " + str(schiffcontainer_node))
	$"/root/Welt/Schiffe".visible = true
	var spieler_centerfelder
	var centerfeld_schifflaenge
	var centerfeld_zweites_schiff
	if $"/root/Welt".spieler2_ist_dran && not gegenteil:
		spieler_centerfelder = Autoload.spieler2_centerfelder
		centerfeld_schifflaenge = centerfeld.sp2_centerfeld_schifflaenge
		centerfeld_zweites_schiff = centerfeld.sp2_centerfeld_zweites_schiff
	elif not gegenteil:
		spieler_centerfelder = Autoload.spieler1_centerfelder
		centerfeld_schifflaenge = centerfeld.sp1_centerfeld_schifflaenge
		centerfeld_zweites_schiff = centerfeld.sp1_centerfeld_zweites_schiff
	
	elif $"/root/Welt".spieler2_ist_dran && gegenteil:
		spieler_centerfelder = Autoload.spieler1_centerfelder
		centerfeld_schifflaenge = centerfeld.sp1_centerfeld_schifflaenge
		centerfeld_zweites_schiff = centerfeld.sp1_centerfeld_zweites_schiff
	elif gegenteil:
		spieler_centerfelder = Autoload.spieler2_centerfelder
		centerfeld_schifflaenge = centerfeld.sp2_centerfeld_schifflaenge
		centerfeld_zweites_schiff = centerfeld.sp2_centerfeld_zweites_schiff
	
	match centerfeld_schifflaenge:
		5:
			$"/root/Welt".selected_schiffli = schiffcontainer_node.get_node("6")
		4:
			$"/root/Welt".selected_schiffli = schiffcontainer_node.get_node("5")
		3:
			if not centerfeld_zweites_schiff:
				$"/root/Welt".selected_schiffli = schiffcontainer_node.get_node("4")
			else:
				$"/root/Welt".selected_schiffli = schiffcontainer_node.get_node("3")
		2:
			if not centerfeld_zweites_schiff:
				$"/root/Welt".selected_schiffli = schiffcontainer_node.get_node("2")
			else:
				$"/root/Welt".selected_schiffli = schiffcontainer_node.get_node("1")
	
	$"/root/Welt".selected_schiffli.rect_position = centerfeld.rect_position + centerfeld.rect_size / 2 + rect_position
	$"/root/Welt".selected_schiffli.rotiert = not spieler_centerfelder[centerfeld.name]
	if $"/root/Welt".spielphase == 1:
		$"/root/Welt"._on_RotateButton_pressed(mit_centerfeld_wegen_random)
	else:
		schiff_nur_so_rotieren($"/root/Welt".selected_schiffli)

func schiff_nur_so_rotieren(rotierschiff):
	if rotierschiff.rotiert:
		rotierschiff.rect_rotation = 0
	else:
		rotierschiff.rect_rotation = 90

func laengencheck():
	if laenge % 2 == 0:
# warning-ignore:integer_division
		zahl = laenge / 2
		zahl2 = zahl
	else:
# warning-ignore:integer_division
		zahl = (laenge - 1) / 2
		zahl2 = zahl + 1

func clear(mit_centerfeld : bool):
	if mit_centerfeld && $"/root/Welt".spieler2_ist_dran:
		Autoload.spieler2_centerfelder.clear()
	elif mit_centerfeld:
		Autoload.spieler1_centerfelder.clear()
	
	for n in 10:
		for i in 10:
			bearbeitetes_feld = get_node(str(i + 1) + "_" + str(n + 1))
			bearbeitetes_feld.get_node("Button").modulate = normalfarbe
			bearbeitetes_feld.get_node("Verfehlt/Verfehltplayer").play("RESET")
			bearbeitetes_feld.get_node("Treffer/Treffplayer").play("RESET")
			bearbeitetes_feld.schiffli = false
			if mit_centerfeld:
				match $"/root/Welt".spieler2_ist_dran:
					true: bearbeitetes_feld.sp2_schiffli_name = ""
					false: bearbeitetes_feld.sp1_schiffli_name = ""
			bearbeitetes_feld.besetzt = 0
			bearbeitetes_feld.aufgedeckt = false

func _on_Area2D_body_entered(body):
	if body.is_in_group("Schiff") && name == "Felder" && body.get_parent().get_parent().name == "Schiffe":
		body.get_parent().im_feld = true
		$"/root/Welt".schiff_move(1)

func _on_Area2D_body_exited(body):
	if body.is_in_group("Schiff") && name == "Felder" && body.get_parent().get_parent().name == "Schiffe":
		body.get_parent().im_feld = false
		$"/root/Welt".schiff_move(-1)
