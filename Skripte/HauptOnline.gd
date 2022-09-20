extends Control

export var anzahl_schiffe : int = 6
const FELDVERSCHIEBUNG : int = 200

var selected_schiffli
var unselectbar : bool = true
var im_feld : int = 0
var spielphase : int = 1
var spieler2_ist_dran : bool = false
var paratfeld_im_bild : bool = false #Brauchts im Feld script, drum nicht entfernt

var anderer_noch_da : bool = true

var spieler1_punkte : int = 0
var spieler2_punkte : int = 0
var spieler1_versenkte = {"1" : 2, "2" : 2, "3" : 3, "4" : 3, "5" : 4, "6" : 5}
var spieler2_versenkte = {"1" : 2, "2" : 2, "3" : 3, "4" : 3, "5" : 4, "6" : 5}

var aufgedeckte_schiffe = []

func _ready():
	Server.ingame = true
	randomize()
	$"/root/Start/OnlineListe/ColorRect2/AnimationPlayer".play_backwards("InsBild")
	$"/root/Start/OnlineListe/AnfragWeg".visible = false
	$IngameAnfragNode/ColorRect.rect_position.y = Autoload.actual_screen_height - 688
	$IngameMomentNode/ColorRect.rect_position.y = Autoload.actual_screen_height - 344
	
	$Felder.felder_platzieren()
	$EigenschiffControl/EigeneFelder.felder_platzieren()
	$Gewonnen.rect_position.y = -$Gewonnen.rect_size.y
	$Einstellungen.rect_position.y = Autoload.actual_screen_height + 1
	
	#Die Grössen dieser neriven Felder, die sich von selber vergrössern
	$WarteAufControl/Control.rect_size = Vector2(1080, Autoload.actual_screen_height - 100)
	$NotifyRect/Control.rect_size = Vector2(1080, Autoload.actual_screen_height - 100)
	$ZumHauptmenu/Control.rect_size = Vector2(1080, Autoload.actual_screen_height)
	
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
	$ZumHauptmenu/Control/AnimationPlayer.play("open")
	$ZumHauptmenu.visible = true
	$Einstellungen.sonst_okay = false

func _on_FertigButton_pressed():
	$Felder.felderstatus_speichern(spieler2_ist_dran)
	schiffe_fertig_platziert()

func schiffe_fertig_platziert():
	spielphase = 2
	Server.rpc_id(Server.spielpartner_id, "schiffdaten_senden", Autoload.spieler1_felder, Autoload.spieler1_centerfelder, Autoload.spieler2_felder, Autoload.spieler2_centerfelder)
	Server.rpc_id(Server.spielpartner_id, "bin_bereit")

func spielerparatfeld_anzeigen(): #Wird nur so genannt, wegen der Funktion in Feld.gd
	if spielphase != 3:
		$NotifyRect/Control/NamenLabel.set_text(Server.spielpartner_name)
		$NotifyRect/Control/InfoLabel.set_text("is planning")
		$NotifyRect/Control/AnimationPlayer.play("open")
		$NotifyRect.visible = true
		yield($NotifyRect/Control/AnimationPlayer, "animation_finished")
		$Felder/Abdeckung.visible = false

func zu_phase_zwei_wechseln():
# warning-ignore:return_value_discarded
	Server.connect("data_received", self, "wenn_server_data_received")
	$Felder.clear(false)
	for i in anzahl_schiffe:
		get_node("Schiffe/" + str(i + 1)).visible = false
	clear()
	#Felder gehen runter
	$Felder/Tween.interpolate_property($Felder, "rect_position:y", $Felder.rect_position.y, $Felder.rect_position.y + FELDVERSCHIEBUNG, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Felder/Tween.interpolate_property($FelderRaster, "rect_position:y", $FelderRaster.rect_position.y, $FelderRaster.rect_position.y + FELDVERSCHIEBUNG, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Felder/Tween.interpolate_property($FelderHintergrund, "rect_position:y", $FelderHintergrund.rect_position.y, $FelderHintergrund.rect_position.y + FELDVERSCHIEBUNG, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Felder/Tween.interpolate_property($EigenschiffControl, "rect_position:y", Autoload.actual_screen_height - 814.998, 400, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#Mehr
	$EigenschiffControl.visible = true
	$EigenschiffControl/AnimationPlayer.play("shrink")
	$SchriftLabel/AnimationPlayer.play("weg")
	
	$EigenschiffControl/EigeneFelder.clear(false)
	$Felder.clear(false)
	$EigenschiffControl/EigeneFelder.felder_laden(spieler2_ist_dran)
	
	#Hier wegen den Besetzfelder-Namen-Dingern von den Feldern
	var besetzfeld_dinger = []
	var centerfeld_schifflaengen = []
	var centerfeld_zweite_schiffe = []
	for n in 10:
		for i in 10:
			if spieler2_ist_dran:
				besetzfeld_dinger.append(get_node("Felder/" + str(i + 1) + "_" + str(n + 1)).sp2_schiffli_name)
				centerfeld_schifflaengen.append(get_node("Felder/" + str(i + 1) + "_" + str(n + 1)).sp2_centerfeld_schifflaenge)
				centerfeld_zweite_schiffe.append(get_node("Felder/" + str(i + 1) + "_" + str(n + 1)).sp2_centerfeld_zweites_schiff)
			else:
				besetzfeld_dinger.append(get_node("Felder/" + str(i + 1) + "_" + str(n + 1)).sp1_schiffli_name)
				centerfeld_schifflaengen.append(get_node("Felder/" + str(i + 1) + "_" + str(n + 1)).sp1_centerfeld_schifflaenge)
				centerfeld_zweite_schiffe.append(get_node("Felder/" + str(i + 1) + "_" + str(n + 1)).sp1_centerfeld_zweites_schiff)
	Server.rpc_id(Server.spielpartner_id, "besetzdinger_senden", besetzfeld_dinger, centerfeld_schifflaengen, centerfeld_zweite_schiffe)

func wenn_server_data_received():
	$Felder/Tween.start()
	for i in anzahl_schiffe:
		vollschiffcheck(str(i + 1))
	for i in Autoload.spieler1_centerfelder.size(): #Hier könnte auch spieler2_centerfelder stehen, es geht nur um die Länge
		if spieler2_ist_dran:
			$EigenschiffControl/EigeneFelder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler2_centerfelder.keys()[i]), false, true, $EigenschiffControl/EigeneSchiffe)
		else:
			$EigenschiffControl/EigeneFelder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler1_centerfelder.keys()[i]), false, true, $EigenschiffControl/EigeneSchiffe)
	
	yield($Felder/Tween, "tween_completed")
	
	for i in Autoload.spieler1_centerfelder.size():
		if spieler2_ist_dran:
			$Felder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler1_centerfelder.keys()[i]), true, true, $Schiffe)
		else:
			$Felder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler2_centerfelder.keys()[i]), true, true, $Schiffe)

func vollschiffcheck(schiffname, von_feld = null):
	Server.rpc_id(Server.spielpartner_id, "beschossene_senden", Autoload.spieler1_beschossene, Autoload.spieler2_beschossene)
	if von_feld != null:
		Server.rpc_id(Server.spielpartner_id, "feldanimation", von_feld, true)
	if schiffname != "nix":
		if (spieler2_ist_dran && spieler1_versenkte[schiffname] <= 0) or (not spieler2_ist_dran && spieler2_versenkte[schiffname] <= 0):
			get_node("Schiffe/" + schiffname).todesanimation()
			aufgedeckte_schiffe.append(schiffname)
			Server.rpc_id(Server.spielpartner_id, "schiffzerstoer", schiffname)

func gewinnercheck(peimel : bool = true): #peimel ist da, dass, wenn man will, das unten auch ausgeführt wird, wenn die punkte nicht erreicht sind
	if spieler1_punkte == 19 or spieler2_punkte == 19:
		spielphase = 3
		yield(get_tree().create_timer(0.5), "timeout")
		$Gewonnen/Label.set_text("You are the winner!")
		$Gewonnen/Tween.interpolate_property($Gewonnen, "rect_position:y", $Gewonnen.rect_position.y, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Gewonnen/Tween.start()
		Server.rpc_id(Server.spielpartner_id, "spiel_wurde_gewonnen")
		peimel = false
	
	if peimel == false:
		if (spieler2_ist_dran && spieler2_punkte == 19) or (not spieler2_ist_dran && spieler1_punkte == 19):
			$Gewonnen/Revanche.set_text("Play Again")
		
		$Gewonnen.visible = true
		$Gewonnen/Control/FertigFelder.felder_platzieren()
		$Gewonnen/Control/FertigFelder.felder_laden(not spieler2_ist_dran)
		$Gewonnen/Control/FertigFelder.treffer_markieren(spieler2_ist_dran)
		for i in Autoload.spieler1_centerfelder.size():
			match spieler2_ist_dran:
				true:
					$Gewonnen/Control/FertigFelder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler1_centerfelder.keys()[i]), true, false, $Gewonnen/Control/FertigSchiffe)
				false:
					$Gewonnen/Control/FertigFelder.schiff_in_feld_platzieren(get_node("Felder/" + Autoload.spieler2_centerfelder.keys()[i]), true, false, $Gewonnen/Control/FertigSchiffe)
		for schiff in aufgedeckte_schiffe.size():
			get_node("Gewonnen/Control/FertigSchiffe/" + aufgedeckte_schiffe[schiff] + "/Todesplayer").play("Schontot")
		
		yield($Gewonnen/Tween, "tween_completed")
		$Gewonnen/Sprite/AnimationPlayer.play("erscheinen")

func _on_ZurListeButton_pressed():
	if anderer_noch_da:
		Server.rpc_id(Server.spielpartner_id, "anderer_spiel_verlassen")
	$"/root/Start/OnlineListe/anfragNode".visible = false
	$"/root/Start/OnlineListe".anfrager_id = null
	$"/root/Start/OnlineListe/MomentNode".visible = false
	$"/root/Start/OnlineListe".angefragter_id = null
	Server.rpc_id(1, "spieler_available_update", false, false, get_tree().get_network_unique_id()) #Available war vor randomGegner auf true
	$TransitionBlackness.black()
	Server.ingame = false

func _on_Revanche_pressed():
	Server.rpc_id(Server.spielpartner_id, "revanche")
	$IngameMomentNode.visible = true
	$ColorRect2/AnimationPlayer.play("InsBild")
	$AnfragWeg.visible = true
	$IngameMomentNode/ColorRect/Tween.interpolate_property($IngameMomentNode/ColorRect, "rect_position:x", $IngameMomentNode/ColorRect.rect_position.x, 53, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$IngameMomentNode/ColorRect/Tween.start()

func revanche_abbrechen():
	Server.rpc_id(Server.spielpartner_id, "revanche", false)
	if $IngameAnfragNode.visible == false or $IngameAnfragNode/ColorRect/Tween.is_active():
		$ColorRect2/AnimationPlayer.play_backwards("InsBild")
		$AnfragWeg.visible = false
	$IngameMomentNode/ColorRect/Tween.interpolate_property($IngameMomentNode/ColorRect, "rect_position:x", $IngameMomentNode/ColorRect.rect_position.x, -975, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$IngameMomentNode/ColorRect/Tween.start()
	yield($IngameMomentNode/ColorRect/Tween, "tween_completed")
	$IngameMomentNode.visible = false

func revanche_akzeptieren():
	Server.rpc_id(Server.spielpartner_id, "reagiert_auf_revanche")
	name = "NichtWelt"
	$TransitionBlackness.black()

func anfrage_ablehnen():
	Server.rpc_id(Server.spielpartner_id, "reagiert_auf_revanche", false)
	if $IngameMomentNode.visible == false or $IngameMomentNode/ColorRect/Tween.is_active():
		$ColorRect2/AnimationPlayer.play_backwards("InsBild")
		$AnfragWeg.visible = false
	$IngameAnfragNode/ColorRect/Tween.interpolate_property($IngameAnfragNode/ColorRect, "rect_position:x", $IngameAnfragNode/ColorRect.rect_position.x, -975, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$IngameAnfragNode/ColorRect/Tween.start()
	yield($IngameAnfragNode/ColorRect/Tween, "tween_completed")
	$IngameAnfragNode.visible = false

func _on_TransitionBlackness_end_done(_s2dran):
	if name == "NichtWelt":
		get_parent().add_child($"/root/Start/OnlineListe".HAUPTONLINE.instance())
		$"/root/Welt".spieler2_ist_dran = spieler2_ist_dran
		$"/root/Welt".im_feld = 6
	else:
		get_parent().get_node("Start/OnlineListe/TransitionBlackness").black_reverse()
		if not spieler2_ist_dran:
			Server.rpc_id(1, "spielpartner_eingeben", false, get_tree().get_network_unique_id(), Server.spielpartner_id)
	queue_free()

func _on_AnimationPlayer_animation_finished(_anim_name):
	$RandomButton.queue_free()
	$ClearButton.queue_free()
	$FertigButton.queue_free()

func _on_nein_pressed():
	$ZumHauptmenu/Control/AnimationPlayer.play_backwards("open")
	yield($ZumHauptmenu/Control/AnimationPlayer, "animation_finished")
	$ZumHauptmenu.visible = false
	$Einstellungen.sonst_okay = true

func _on_SchriftLabel_AnimationPlayer_animation_finished(_anim_name):
	$SchriftLabel.visible = false

func _on_AnfragWeg_pressed():
	if $IngameAnfragNode.visible:
		anfrage_ablehnen()
	if $IngameMomentNode.visible:
		revanche_abbrechen()

func button_sound():
	$ButtonSound.play()
