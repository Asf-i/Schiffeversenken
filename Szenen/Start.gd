extends Control

var local_swipe_pos = Vector2()
var visible_swipedistanz : int = 600
var min_swipe_distanz : int = 100
var aktivbutton_zahl : int = 2
var last_swipe_relative : float
var swipe_verlangsamung : int = 120

var swiping : bool = false

var hsprite_xs = [-956, -1056, -1156]
var next_scene : int = 1

func _ready():
	$NameButton/Spieler1.set_text(Autoload.savegame_data.sp1name)
	$NameButton.set_text(Autoload.savegame_data.sp1name)
	$NameButton/Spieler2.set_text(Autoload.savegame_data.sp2name)
	$Einstellungen.rect_position.y = Autoload.actual_screen_height + 1

func _on_Multiplayer_pressed():
	if not swiping:
		Server.connect_to_server($Einstellungen/LineEdit.text)

func _on_Singleplayer_pressed():
	if not swiping:
		Server.network = null
		next_scene = 1
		$TransitionBlackness.black()

func _on_SwipeDetector_swipe(local_swipe, event_relative):
	swiping = true
	#Spielmodi swipen
	if abs(local_swipe.x) < visible_swipedistanz && abs($SwipeDetector.start_direction.x) > abs($SwipeDetector.start_direction.y) && not $SettingWegButton.visible && get_node_or_null("OnlineListe") == null:
		$HBoxContainer.rect_position.x += event_relative.x / (abs(local_swipe.x) / swipe_verlangsamung + 1)
		get_node("HBoxContainer/" + str(aktivbutton_zahl)).modulate.a = 1 / (0.005 * abs(local_swipe.x) + 1)
		get_node("ModeBeschr/" + str(aktivbutton_zahl)).modulate.a = 1 / (0.002 * abs(local_swipe.x) + 1)

func _on_SwipeDetector_swipe_done(start, end, local_swipe):
	if abs($SwipeDetector.start_direction.x) > abs($SwipeDetector.start_direction.y) && not $SettingWegButton.visible && get_node_or_null("OnlineListe") == null:
		$HBoxContainer/Tween.interpolate_property(get_node("HBoxContainer/" + str(aktivbutton_zahl)), "modulate:a", get_node("HBoxContainer/" + str(aktivbutton_zahl)).modulate.a, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		if abs(start.x - end.x) > min_swipe_distanz && aktivbutton_zahl - local_swipe.x / abs(local_swipe.x) < 4 && aktivbutton_zahl - local_swipe.x / abs(local_swipe.x) > 0:
			$HBoxContainer/Tween.interpolate_property(get_node("ModeBeschr/" + str(aktivbutton_zahl)), "modulate:a", get_node("HBoxContainer/" + str(aktivbutton_zahl)).modulate.a, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			aktivbutton_zahl -= local_swipe.x / abs(local_swipe.x)
		$HBoxContainer/Tween.interpolate_property($HBoxContainer, "rect_position:x", $HBoxContainer.rect_position.x, -(get_node("HBoxContainer/" + str(aktivbutton_zahl)).rect_position.x - 256), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$HBoxContainer/Tween.interpolate_property(get_node("HBoxContainer/" + str(aktivbutton_zahl)), "modulate:a", get_node("HBoxContainer/" + str(aktivbutton_zahl)).modulate.a, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$HBoxContainer/Tween.interpolate_property(get_node("ModeBeschr/" + str(aktivbutton_zahl)), "modulate:a", get_node("HBoxContainer/" + str(aktivbutton_zahl)).modulate.a, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		#Hintergrundsprite
		$HBoxContainer/Tween.interpolate_property($Hintergrundsprite, "position:x", $Hintergrundsprite.position.x, hsprite_xs[aktivbutton_zahl - 1], 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$HBoxContainer/Tween.start()
		
		$ModeBeschr/NachLinks.visible = true
		$ModeBeschr/NachRechts.visible = true
		if aktivbutton_zahl == 1:
			$ModeBeschr/NachLinks.visible = false
		elif aktivbutton_zahl == 3:
			$ModeBeschr/NachRechts.visible = false
	
	yield(get_tree().create_timer(0.1), "timeout")
	swiping = false

func _on_NameButton_pressed():
	if $NamenWeg.visible:
		Autoload.save()
	else:
		Autoload.load_data()
	$NamenWeg.visible = not $NamenWeg.visible
	$NameButton/NameHintergrund.visible = $NamenWeg.visible
	$NameButton/Spieler1.visible = $NamenWeg.visible
	$NameButton/Spieler2.visible = $NamenWeg.visible
	$"NameButton/s1h".visible = $NamenWeg.visible
	$"NameButton/s2h".visible = $NamenWeg.visible
	print(Autoload.savegame_data)

func _on_LineEdit_text_changed(new_text):
	#Damit man keine Leerschläge schreiben kann
	for i in new_text.length():
		if new_text[i] == " ":
			new_text.erase(i, 1)
			$NameButton/Spieler1.set_text(new_text)
			$NameButton/Spieler1.set_cursor_position(i)
			break
	#Falls man nichts schreibt
	if new_text == "":
		$NameButton.text = "Spieler_1"
		Autoload.savegame_data.sp1name = "Spieler_1"
	else:
		$NameButton.text = new_text
		Autoload.savegame_data.sp1name = new_text

func _on_Spieler2_text_changed(new_text):
	#Damit man keine Leerschläge schreiben kann
	for i in new_text.length():
		if new_text[i] == " ":
			new_text.erase(i, 1)
			$NameButton/Spieler2.set_text(new_text)
			$NameButton/Spieler2.set_cursor_position(i)
			break
	#Falls man nichts schreibt
	if new_text == "":
		Autoload.savegame_data.sp2name = "Spieler_2"
	else:
		Autoload.savegame_data.sp2name = new_text

func _on_SettingButton_pressed():
	if $SettingWegButton.visible:
		$Einstellungen._on_SettingWegButton_pressed()
	else:
		$SettingWegButton.visible = true
		$Einstellungen/Tween.interpolate_property($Einstellungen, "rect_position:y", $Einstellungen.rect_position.y, Autoload.actual_screen_height - $Einstellungen.rect_size.y, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Einstellungen/Tween.start()
		$Einstellungen.visible = true

func modi_switchen(add_zahl):
	$HBoxContainer/Tween.interpolate_property(get_node("ModeBeschr/" + str(aktivbutton_zahl)), "modulate:a", get_node("HBoxContainer/" + str(aktivbutton_zahl)).modulate.a, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	aktivbutton_zahl += add_zahl
	$HBoxContainer/Tween.interpolate_property($HBoxContainer, "rect_position:x", $HBoxContainer.rect_position.x, -(get_node("HBoxContainer/" + str(aktivbutton_zahl)).rect_position.x - 256), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$HBoxContainer/Tween.interpolate_property(get_node("HBoxContainer/" + str(aktivbutton_zahl)), "modulate:a", get_node("HBoxContainer/" + str(aktivbutton_zahl)).modulate.a, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$HBoxContainer/Tween.interpolate_property(get_node("ModeBeschr/" + str(aktivbutton_zahl)), "modulate:a", get_node("HBoxContainer/" + str(aktivbutton_zahl)).modulate.a, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$HBoxContainer/Tween.interpolate_property($Hintergrundsprite, "position:x", $Hintergrundsprite.position.x, hsprite_xs[aktivbutton_zahl - 1], 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$HBoxContainer/Tween.start()

func _on_NachLinks_pressed():
	modi_switchen(-1)
	$ModeBeschr/NachRechts.visible = true
	if aktivbutton_zahl == 1:
		$ModeBeschr/NachLinks.visible = false

func _on_NachRechts_pressed():
	modi_switchen(1)
	$ModeBeschr/NachLinks.visible = true
	if aktivbutton_zahl == 3:
		$ModeBeschr/NachRechts.visible = false

func _on_TransitionBlackness_end_done(_s2dran):
	match next_scene:
		1:
			# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Szenen/Haupt.tscn")
