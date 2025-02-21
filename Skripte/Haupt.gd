extends Control

export var anzahl_schiffe : int = 6
const FELDVERSCHIEBUNG : int = 200

var selected_schiffli
var unselectbar : bool = true
var im_feld : int = 0
var spielphase : int = 1
var spieler2_ist_dran : bool = false
var paratfeld_im_bild : bool = false
var revanche : bool = false

var spieler1_punkte : int = 0
var spieler2_punkte : int = 0
var spieler1_versenkte = {"1" : 2, "2" : 2, "3" : 3, "4" : 3, "5" : 4, "6" : 5}
var spieler2_versenkte = {"1" : 2, "2" : 2, "3" : 3, "4" : 3, "5" : 4, "6" : 5}

var s1_aufgedeckte_schiffe = []
var s2_aufgedeckte_schiffe = []

func _ready():
	randomize()
	$Felder.felder_platzieren()
	$EigenschiffControl/EigeneFelder.felder_platzieren()
	$AndererSpielerBitte.rect_position.y = -$AndererSpielerBitte.rect_size.y
	$Gewonnen.rect_position.y = -$Gewonnen.rect_size.y
	
	#Anderes
	$AndererSpielerBitte/Control/Label.set_text(Autoload.savegame_data.sp2name)
	$Einstellungen.rect_position.y = Autoload.actual_screen_height + 1
	$Name.set_text(Autoload.savegame_data.sp1name + " ")
	
	#Die nervigen, sich selbst vergrössernden Felder
	$ZumHauptmenu/Content.rect_size = Vector2(1080, Autoload.actual_screen_height)
	
	#Alle variablen fürs Spiel parat machen
	Autoload.spieler1_felder.clear()
	Autoload.spieler2_felder.clear()
	Autoload.spieler1_beschossene.clear()
	Autoload.spieler2_beschossene.clear()
	Autoload.spieler1_centerfelder.clear()
	Autoload.spieler2_centerfelder.clear()
	
	for schiffnummer in anzahl_schiffe:
		var schiff = $Schiffe.get_node(str(schiffnummer + 1))
		schiff.normale_position = schiff.rect_global_position

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		$Schiffe.rect_position.x = 0
	
	yield(get_tree().create_timer(0.01), "timeout")
	if event is InputEventScreenTouch && event.is_pressed() && unselectbar && spielphase == 1:
		schiffli_selected("nix")

func _on_RotateButton_pressed(mit_centerfeld : bool = true):
	if selected_schiffli.im_feld:
		$Felder.besetztfelder_markieren(true, selected_schiffli.name)
		
		if selected_schiffli.rotiert == false:
			selected_schiffli.rotiert = true
			$Felder.rotiert = true
			if $Felder.ist_moeglich(selected_schiffli.im_feld):
				selected_schiffli.rect_rotation = 90
			else:
				selected_schiffli.rotiert = false
				$Felder.rotiert = false
				if Autoload.savegame_data.vibration:
					Input.vibrate_handheld(50)
		else:
			selected_schiffli.rotiert = false
			$Felder.rotiert = false
			if $Felder.ist_moeglich(selected_schiffli.im_feld):
				selected_schiffli.rect_rotation = 0
			else:
				selected_schiffli.rotiert = true
				$Felder.rotiert = true
				if Autoload.savegame_data.vibration:
					Input.vibrate_handheld(50)
		$Felder.besetztfelder_markieren(false, selected_schiffli.name)
		if mit_centerfeld:
			Autoload.centerfelder_anpassen(selected_schiffli.nahfeld, selected_schiffli.rotiert, selected_schiffli.laenge, selected_schiffli.zweites, true)
	elif selected_schiffli.rotiert:
		selected_schiffli.rotiert = false
		selected_schiffli.rect_rotation = 0
	else:
		selected_schiffli.rotiert = true
		selected_schiffli.rect_rotation = 90

func schiffli_selected(schiffli_name):
	if selected_schiffli != null:
		selected_schiffli.modulate = Color(1, 1, 1)
		if not selected_schiffli.im_feld && schiffli_name != selected_schiffli.name:
			selected_schiffli.rect_rotation = 0
			selected_schiffli.rotiert = false
	
	if schiffli_name != "nix":
		selected_schiffli = get_node("/root/Welt/Schiffe/" + str(schiffli_name))
		selected_schiffli.modulate = Color(0.5, 0.5, 0.5)
	else:
		selected_schiffli = null

func schiff_move(movezahl):
	im_feld += movezahl
	if im_feld == anzahl_schiffe && get_node_or_null("FertigButton"):
		$FertigButton.disabled = false
		$FertigButton/Sprite.modulate = Color(1, 1, 1)
	elif get_node_or_null("FertigButton"):
		$FertigButton.disabled = true
		$FertigButton/Sprite.modulate = Color(0.415686, 0.415686, 0.415686)

func _on_RandomButton_pressed():
	$Felder.clear(true)
	$FertigButton.disabled = false
	$FertigButton/Sprite.modulate = Color(1, 1, 1)
	var random_bool_dingens : int
	var penis : int = anzahl_schiffe
	var zweier : int = 2
	var dreier : int = 2
	var vierer : int = 1
	var fuenfer : int = 1
	var schiffli_name : String
	
	while penis > 0:
		$Felder.nahfeld = get_node("Felder/" + str(int(rand_range(1, 11))) + "_" + str(int(rand_range(1, 11))))
		
		if fuenfer > 0:
			$Felder.laenge = 5
			fuenfer -= 1
			schiffli_name = "6"
		elif vierer > 0:
			$Felder.laenge = 4
			vierer -= 1
			schiffli_name = "5"
		elif dreier > 0:
			$Felder.laenge = 3
			dreier -= 1
			schiffli_name = "4"
		elif zweier > 0:
			$Felder.laenge = 2
			zweier -= 1
			schiffli_name = "2"
		
		random_bool_dingens = int(rand_range(1, 3))
		if random_bool_dingens == 1:
			$Felder.rotiert = true
		else:
			$Felder.rotiert = false
		if $Felder.ist_moeglich(true):
			var zweites : bool = false
			if dreier == 0 && zweier != 1 or zweier == 0 && dreier == 0:
				zweites = true
				match schiffli_name:
					"4": schiffli_name = "3"
					"2": schiffli_name = "1"
			$Felder.besetztfelder_markieren(false, schiffli_name)
			Autoload.centerfelder_anpassen($Felder.nahfeld, $Felder.rotiert, $Felder.laenge, zweites, true)
			$Felder.schiff_in_feld_platzieren($Felder.nahfeld, false, false, $Schiffe)
		else:
			penis += 1
			match $Felder.laenge:
				5: fuenfer += 1
				4: vierer += 1
				3: dreier += 1
				2: zweier += 1
		penis -= 1
	$Felder.nahfeld = null

func clear():
	for schiffnummer in anzahl_schiffe:
		var schiff = get_node("Schiffe/" + str(schiffnummer + 1))
		schiff.rect_position = schiff.normale_position
		schiff.rect_rotation = 0
		schiff.rotiert = false
		$Felder.rotiert = false

func _on_ClearButton_pressed():
	$Schiffe.visible = true
	$Felder.clear(true)
	clear()
	$FertigButton.disabled = true
	$FertigButton/Sprite.modulate = Color(0.415686, 0.415686, 0.415686)

func _on_HauptmenuButton_pressed():
	$ZumHauptmenu/Content/ContentPlayer.play("open")
	$ZumHauptmenu.visible = true
	$Einstellungen.sonst_okay = false

func _on_FertigButton_pressed():
	$Felder.felderstatus_speichern(spieler2_ist_dran)
	$Schiffe.visible = true
	$RandomButton.disabled = false
	$FertigButton.disabled = true
	$FertigButton/Sprite.modulate = Color(0.415686, 0.415686, 0.415686)
	spielerparatfeld_anzeigen()

func spielerparatfeld_anzeigen():
	if not Autoload.offline_schneller_mode or (spielphase == 1 && not spieler2_ist_dran):
		paratfeld_im_bild = true
		$AndererSpielerBitte.visible = true
		$AndererSpielerBitte/Tween.interpolate_property($AndererSpielerBitte, "rect_position:y", $AndererSpielerBitte.rect_position.y, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$AndererSpielerBitte/Tween.start()
	
	if spielphase != 1 && Autoload.offline_schneller_mode && (not Autoload.savegame_data.rotier_mode or (not spieler2_ist_dran && $Camera2D.rotation_degrees == 180) or (spieler2_ist_dran && $Camera2D.rotation_degrees == 0)):
		$FelderwackelPlayer.play("wackel")
		$SchnellclearPlayer.play("nurname")
		yield(get_tree().create_timer(0.195), "timeout")
	elif spieler2_ist_dran && Autoload.savegame_data.rotier_mode && $Camera2D.rotation_degrees != 0:
		if Autoload.offline_schneller_mode:
			$Camera2D/Tween.interpolate_property($Camera2D, "rotation_degrees", 180, 0, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Camera2D/Tween.interpolate_property($Camera2D, "position", Vector2(1080, Autoload.actual_screen_height), Vector2(0, 0), 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Camera2D/Tween.start()
			yield(get_tree().create_timer(0.2), "timeout")
		else:
			$AndererSpielerBitte/Control.rect_rotation = 180
		$Einstellungen.richtunganders = 1
		$Schiffe.rect_position.x = 0
	elif Autoload.savegame_data.rotier_mode:
		if Autoload.offline_schneller_mode && spielphase != 1 && $Camera2D.rotation_degrees != 180:
			$Camera2D/Tween.interpolate_property($Camera2D, "rotation_degrees", 0, 180, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Camera2D/Tween.interpolate_property($Camera2D, "position", Vector2(0, 0), Vector2(1080, Autoload.actual_screen_height), 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Camera2D/Tween.start()
			yield(get_tree().create_timer(0.2), "timeout")
		else:
			$AndererSpielerBitte/Control.rect_rotation = 180
		$Einstellungen.richtunganders = -1
		$Schiffe.rect_position.x = 0
	
	if Autoload.offline_schneller_mode && not (spielphase == 1 && not spieler2_ist_dran):
		$Felder/Abdeckung.visible = false
		$Felder.clear(false)
		clear()
		if spieler2_ist_dran:
			$Name.set_text(Autoload.savegame_data.sp1name)
		else:
			$Name.set_text(Autoload.savegame_data.sp2name)
		#Ab jetzt quasi anderer_spieler_parat
		spieler2_ist_dran = not spieler2_ist_dran
		if not spieler2_ist_dran && spielphase == 1:
			spielphase = 2
			zu_phase_zwei_wechseln()
			for i in anzahl_schiffe:
				get_node("Schiffe/" + str(i + 1)).visible = false
		elif spielphase == 2:
			$Felder.treffer_markieren(spieler2_ist_dran)
			for i in anzahl_schiffe:
				get_node("Schiffe/" + str(i + 1)).visible = false
				vollschiffcheck(str(i + 1), null, true)
		for i in Autoload.spieler1_centerfelder.size():
			if spieler2_ist_dran:
				$Felder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler1_centerfelder.keys()[i]), true, true, $Schiffe)
			else:
				$Felder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler2_centerfelder.keys()[i]), true, true, $Schiffe)
	else:
		yield($AndererSpielerBitte/Tween, "tween_all_completed")
		$Felder/Abdeckung.visible = false
		$Felder.clear(false)
		clear()
		if spieler2_ist_dran:
			$Name.set_text(Autoload.savegame_data.sp1name)
			if Autoload.savegame_data.rotier_mode:
				$Camera2D.rotation_degrees = 0
				$Camera2D.position = Vector2(0, 0)
				$AndererSpielerBitte/Control.rect_rotation = 0
			if spielphase == 1:
				$Felder.rect_position.y += FELDVERSCHIEBUNG
		else:
			$Name.set_text(Autoload.savegame_data.sp2name)
			if Autoload.savegame_data.rotier_mode:
				$Camera2D.rotation_degrees = 180
				$Camera2D.position = Vector2(1080, Autoload.actual_screen_height)
				$AndererSpielerBitte/Control.rect_rotation = 0

func anderer_spieler_parat():
	if spieler2_ist_dran && spielphase == 1:
		spielphase = 2
		zu_phase_zwei_wechseln()
	
	spieler2_ist_dran = not spieler2_ist_dran

	if spielphase == 2:
		if not Autoload.offline_schneller_mode:
			$EigenschiffControl/EigeneFelder.clear(false)
			$EigenschiffControl/EigeneFelder.felder_laden(spieler2_ist_dran)
			$EigenschiffControl/EigeneFelder.treffer_markieren(not spieler2_ist_dran)
		$Felder.clear(false)
		$Felder.treffer_markieren(spieler2_ist_dran)
		
		for i in anzahl_schiffe:
			get_node("Schiffe/" + str(i + 1)).visible = false
			vollschiffcheck(str(i + 1), null, true)
			if not Autoload.offline_schneller_mode:
				get_node("EigenschiffControl/EigeneSchiffe/" + str(i + 1)).modulate = Color(1, 1, 1)
		for i in Autoload.spieler1_centerfelder.size(): #Hier könnte auch spieler2_centerfelder stehen, es geht nur um die Länge
			match spieler2_ist_dran:
				true:
					$Felder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler1_centerfelder.keys()[i]), true, true, $Schiffe)
					if not Autoload.offline_schneller_mode:
						$EigenschiffControl/EigeneFelder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler2_centerfelder.keys()[i]), false, true, $EigenschiffControl/EigeneSchiffe)
				false:
					$Felder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler2_centerfelder.keys()[i]), true, true, $Schiffe)
					if not Autoload.offline_schneller_mode:
						$EigenschiffControl/EigeneFelder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler1_centerfelder.keys()[i]), false, true, $EigenschiffControl/EigeneSchiffe)
	
	$AndererSpielerBitte/Tween.interpolate_property($AndererSpielerBitte, "rect_position:y", $AndererSpielerBitte.rect_position.y, -$AndererSpielerBitte.rect_size.y, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$AndererSpielerBitte/Tween.start()
	
	yield($AndererSpielerBitte/Tween, "tween_completed")
	match spieler2_ist_dran:
		true: $AndererSpielerBitte/Control/Label.set_text(Autoload.savegame_data.sp1name)
		false: $AndererSpielerBitte/Control/Label.set_text(Autoload.savegame_data.sp2name)
	paratfeld_im_bild = false
	$AndererSpielerBitte.visible = false

func zu_phase_zwei_wechseln():
	if not Autoload.offline_schneller_mode:
		$EigenschiffControl.visible = true
	else:
		$EigenschiffControl.rect_position.y = 0
		$SchnellclearPlayer.play("schnellclear")
		yield($SchnellclearPlayer, "animation_finished")
	$RandomButton.queue_free()
	$ClearButton.queue_free()
	$FertigButton.queue_free()
	$SchriftLabel.visible = false

func vollschiffcheck(schiffname, _von_feld = null, schontot : bool = false):
	if schiffname != "nix":
		if (spieler2_ist_dran && spieler1_versenkte[schiffname] <= 0) or (not spieler2_ist_dran && spieler2_versenkte[schiffname] <= 0):
			if schontot:
				get_node("Schiffe/" + schiffname + "/Todesplayer").play("Schontot")
				get_node("Schiffe/" + schiffname).visible = true
			else:
				get_node("Schiffe/" + schiffname).todesanimation()
			if spieler2_ist_dran:
				s2_aufgedeckte_schiffe.append(schiffname)
			else:
				s1_aufgedeckte_schiffe.append(schiffname)
		if schontot && ((spieler2_ist_dran && spieler2_versenkte[schiffname] <= 0) or (not spieler2_ist_dran && spieler1_versenkte[schiffname] <= 0)):
			get_node("EigenschiffControl/EigeneSchiffe/" + schiffname).modulate = Color(1, 0.4, 0.4)

func gewinnercheck():
	if spieler1_punkte == 19 or spieler2_punkte == 19:
		spielphase = 3
		spieler2_ist_dran = false
		$Gewonnen.visible = true
		$Gewonnen/Gewinner1/GewinnerFelder1.felder_platzieren()
		$Gewonnen/Gewinner2/GewinnerFelder2.felder_platzieren()
		if spieler1_punkte == 19:
			yield(get_tree().create_timer(0.5), "timeout")
			$Gewonnen/Label.set_text(Autoload.savegame_data.sp1name)
			$Gewonnen/Label3.set_text(Autoload.savegame_data.sp2name + ":")
			$Gewonnen/Gewinner1/GewinnerFelder1.felder_laden(false)
			$Gewonnen/Gewinner1/GewinnerFelder1.treffer_markieren(true)
			$Gewonnen/Gewinner2/GewinnerFelder2.felder_laden(true)
			$Gewonnen/Gewinner2/GewinnerFelder2.treffer_markieren(false)
			for i in Autoload.spieler1_centerfelder.size():
				$Gewonnen/Gewinner2/GewinnerFelder2.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler2_centerfelder.keys()[i]), true, true, $Gewonnen/Gewinner2/GewinnerSchiffe2)
				$Gewonnen/Gewinner1/GewinnerFelder1.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler1_centerfelder.keys()[i]), false, true, $Gewonnen/Gewinner1/GewinnerSchiffe1)
			for schiff in s1_aufgedeckte_schiffe.size():
				get_node("Gewonnen/Gewinner2/GewinnerSchiffe2/" + s1_aufgedeckte_schiffe[schiff] + "/Todesplayer").play("Schontot")
			for schiff in s2_aufgedeckte_schiffe.size():
				get_node("Gewonnen/Gewinner1/GewinnerSchiffe1/" + s2_aufgedeckte_schiffe[schiff] + "/Todesplayer").play("Schontot")
		elif spieler2_punkte == 19:
			yield(get_tree().create_timer(0.5), "timeout")
			$Gewonnen/Label.set_text(Autoload.savegame_data.sp2name)
			$Gewonnen/Label3.set_text(Autoload.savegame_data.sp1name + ":")
			$Gewonnen/Gewinner1/GewinnerFelder1.felder_laden(true)
			$Gewonnen/Gewinner1/GewinnerFelder1.treffer_markieren(false)
			$Gewonnen/Gewinner2/GewinnerFelder2.felder_laden(false)
			$Gewonnen/Gewinner2/GewinnerFelder2.treffer_markieren(true)
			for i in Autoload.spieler1_centerfelder.size():
				$Gewonnen/Gewinner2/GewinnerFelder2.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler1_centerfelder.keys()[i]), false, true, $Gewonnen/Gewinner2/GewinnerSchiffe2)
				$Gewonnen/Gewinner1/GewinnerFelder1.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler2_centerfelder.keys()[i]), true, true, $Gewonnen/Gewinner1/GewinnerSchiffe1)
			for schiff in s1_aufgedeckte_schiffe.size():
				get_node("Gewonnen/Gewinner1/GewinnerSchiffe1/" + s1_aufgedeckte_schiffe[schiff] + "/Todesplayer").play("Schontot")
			for schiff in s2_aufgedeckte_schiffe.size():
				get_node("Gewonnen/Gewinner2/GewinnerSchiffe2/" + s2_aufgedeckte_schiffe[schiff] + "/Todesplayer").play("Schontot")
		$Gewonnen/Tween.interpolate_property($Gewonnen, "rect_position:y", $Gewonnen.rect_position.y, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Gewonnen/Tween.start()
		yield($Gewonnen/Tween, "tween_completed")
		$Gewonnen/Sprite/AnimationPlayer.play("erscheinen")

func _on_AndererOkButton_pressed():
	anderer_spieler_parat()

func _on_ja_pressed():
	$TransitionBlackness.black()

func _on_nein_pressed():
	$ZumHauptmenu/Content/ContentPlayer.play_backwards("open")
	yield($ZumHauptmenu/Content/ContentPlayer, "animation_finished")
	$ZumHauptmenu.visible = false
	$Einstellungen.sonst_okay = true

func _on_TransitionBlackness_end_done(_s2dran):
	if revanche:
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
	else:
	# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Szenen/Start.tscn")

func _on_Revanche_pressed():
	revanche = true
	$TransitionBlackness.black()

func button_sound():
	$ButtonSound.play()

func _on_SchnellclearPlayer_animation_finished(anim_name):
	if anim_name == "schnellclear" or anim_name == "nurname":
		$SchnellclearPlayer.play("finish")
