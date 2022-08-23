extends Control

var anfrager_id
var anfrager_name
var angefragter_id

const HAUPTONLINE = preload("res://Szenen/OnlineZeugs/HauptOnline.tscn")

func _ready():
	$anfragNode/ColorRect.rect_position.y = Autoload.actual_screen_height - 688
	$MomentNode/ColorRect.rect_position.y = Autoload.actual_screen_height - 344
	$"/root/Start/VerbindeRect/Control/AnimationPlayer".play("RESET")
	$"/root/Start/Einstellungen".sonst_okay = true

func button_pressed(button_name):
	angefragter_id = int(button_name)
	Server.available = false
	Server.rpc_id(1, "spieler_available_update", false, false, get_tree().get_network_unique_id(), false) #False nach id geadded, unsicher
	$Zufall.set_text("Zufall")
	$Zufall.disabled = false
	Server.rpc_id(int(button_name), "anfrage", get_tree().get_network_unique_id(), Autoload.savegame_data.sp1name)
	$MomentNode/ColorRect/anfragevon.set_text($SuchEdit.text)
	$MomentNode.visible = true
	$AnfragWeg.visible = true
	$ColorRect2/AnimationPlayer.play("InsBild")
	$MomentNode/ColorRect/Tween.interpolate_property($MomentNode/ColorRect, "rect_position:x", $MomentNode/ColorRect.rect_position.x, 53, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$MomentNode/ColorRect/Tween.start()
#	$NochDaCheckTimer.start()

func _on_accept_pressed():
#	$NochDaTimer.stop()
#	$NochDaCheckTimer.stop()
#	$NochDaSchlussTimer.start()
	Server.rpc_id(anfrager_id, "reagiert_auf_anfrage", get_tree().get_network_unique_id(), Autoload.savegame_data.sp1name, true)
	Server.spielpartner_id = anfrager_id
	Server.spielpartner_name = anfrager_name

func _on_deny_pressed(mit_update : bool = true):
	if mit_update:
		Server.rpc_id(anfrager_id, "reagiert_auf_anfrage", 5318008, Autoload.savegame_data.sp1name, false) #Die Ip hier ist total unnötig. BOOBIES
	if $MomentNode.visible == false or $MomentNode/ColorRect/Tween.is_active():
		$ColorRect2/AnimationPlayer.play_backwards("InsBild")
		$AnfragWeg.visible = false
#	$anfragNode/ColorRect/Tween.interpolate_property($anfragNode/ColorRect, "rect_position:y", Autoload.actual_screen_height - 344, Autoload.actual_screen_height, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$anfragNode/ColorRect/Tween.interpolate_property($anfragNode/ColorRect, "rect_position:x", $anfragNode/ColorRect.rect_position.x, -975, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$anfragNode/ColorRect/Tween.start()
	yield($anfragNode/ColorRect/Tween, "tween_completed")
	$anfragNode.visible = false

func _on_Abbrechen_pressed():
	Server.rpc_id(angefragter_id, "anfrage", get_tree().get_network_unique_id(), Autoload.savegame_data.sp1name, false)
#	$MomentNode/ColorRect/Tween.interpolate_property($MomentNode/ColorRect, "rect_position:y", Autoload.actual_screen_height - 344, Autoload.actual_screen_height, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$MomentNode/ColorRect/Tween.interpolate_property($MomentNode/ColorRect, "rect_position:x", $MomentNode/ColorRect.rect_position.x, -975, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$MomentNode/ColorRect/Tween.start()
	if $anfragNode.visible == false or $anfragNode/ColorRect/Tween.is_active():
		$ColorRect2/AnimationPlayer.play_backwards("InsBild")
		$AnfragWeg.visible = false
	yield($MomentNode/ColorRect/Tween, "tween_completed")
	$MomentNode.visible = false

func _on_Button_pressed():
	Server.available = false
	Server.rpc_id(1, "peer_disconnecten", get_tree().get_network_unique_id())
	Server.network.close_connection()
	get_tree().network_peer = null
	$ListPlayer.play_backwards("open")
	yield($ListPlayer, "animation_finished")
	queue_free()

func _on_TransitionBlackness_end_done(s2dran):
	get_parent().get_parent().add_child(HAUPTONLINE.instance())
	$"/root/Welt".spieler2_ist_dran = s2dran
	if not s2dran:
		Server.rpc_id(1, "spielpartner_eingeben", true, get_tree().get_network_unique_id(), Server.spielpartner_id)

#func _on_NochDaTimer_timeout():
#	$NochDaCheckTimer.stop()
#	if $anfragNode.visible:
#		_on_deny_pressed()
#	elif $MomentNode.visible:
#		_on_Abbrechen_pressed()
#
#func _on_NochDaCheckTimer_timeout():
#	if $anfragNode.visible or $MomentNode.visible:
#		var noch_da_id
#		if $anfragNode.visible:
#			noch_da_id = anfrager_id
#		else:
#			noch_da_id = angefragter_id
#
#		Server.rpc_id(noch_da_id, "noch_da", get_tree().get_network_unique_id(), true)
#		$NochDaTimer.start()
#		$NochDaCheckTimer.start()
#
#func _on_NochDaSchlussTimer_timeout():
#	_on_deny_pressed(false)

func _on_Zufall_pressed():
	Server.rpc_id(1, "spieler_available_update", true, false, get_tree().get_network_unique_id(), false)
	$Zufall.set_text("Suche...")
	$Zufall.disabled = true
	Server.available = true
	$ZufallAbbruch.visible = true

func _on_ZufallAbbruch_pressed():
	Server.rpc_id(1, "spieler_available_update", false, false, get_tree().get_network_unique_id(), false)
	$Zufall.set_text("Zufall")
	$Zufall.disabled = false
	Server.available = false
	$ZufallAbbruch.visible = false

func _on_Suche_pressed():
	for i in $ScrollContainer/VBoxContainer.get_child_count():
		if $SuchEdit.text == $ScrollContainer/VBoxContainer.get_children()[i].get_node("Label").text && $ScrollContainer/VBoxContainer.get_children()[i].get_node("Ingame").visible == false:
			button_pressed($ScrollContainer/VBoxContainer.get_children()[i].name)
			break

func _on_AnfragWeg_pressed():
	if $anfragNode.visible:
		_on_deny_pressed()
	if $MomentNode.visible:
		_on_Abbrechen_pressed()

func button_sound():
	$ListSound.play()
