extends Node

const LISTE = preload("res://Szenen/OnlineZeugs/OnlineListe.tscn")
const BUTTON = preload("res://Szenen/OnlineZeugs/SpielerButton.tscn")
const RAKETE = preload("res://Szenen/Rakete.tscn")

var network
var localhost_ip = "127.0.0.1"
var port = 9998
var onlinelistnode
var available : bool = false #War vor dem Random Gegner finden true
var ingame : bool = false
var spielpartner_id : int = 1000 #Zahl random gewählt
var spielpartner_name : String

signal data_received

func connect_to_server(ip):
	network = NetworkedMultiplayerENet.new()
	if ip == "":
		ip = localhost_ip
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("Network peer created. IP = " + ip)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed():
	print("Failed to connect")

func _on_connection_succeeded():
	var liste = LISTE.instance()
	print("Succesfully connected")
	rpc_id(1, "spielername_kriegen", get_tree().get_network_unique_id(), Autoload.savegame_data.sp1name)
	get_parent().get_node("Start").add_child(liste)
	onlinelistnode = get_parent().get_node("Start/OnlineListe")
	onlinelistnode.get_node("ListPlayer").play("open")

remote func client_was_gesendet(sendezeugs):
	print(sendezeugs)

remote func spielerbuttons_updaten(momentane_spieler, spieler_namen, spieler_ingame):
	print("SPIELERBUTONS UPDATEN")
	for n in get_parent().get_node("Start/OnlineListe/ScrollContainer/VBoxContainer").get_children():
		onlinelistnode.get_node("ScrollContainer/VBoxContainer").remove_child(n)
		n.queue_free()
	
	if momentane_spieler.size() < 2:
		onlinelistnode.get_node("NiemandHierLabel").set_text("Niemand hier...")
	else:
		onlinelistnode.get_node("NiemandHierLabel").set_text("")
		for i in momentane_spieler.size():
			var button = BUTTON.instance()
			button.get_node("Label").text = str(spieler_namen[momentane_spieler[i]])
			button.name = str(momentane_spieler[i])
			onlinelistnode.get_node("ScrollContainer/VBoxContainer").add_child(button)
			button.get_node("Knopf").connect("pressed", button.get_parent().get_parent().get_parent(), "button_pressed", [button.name])
			if momentane_spieler[i] in spieler_ingame:
				button.get_node("Ingame").visible = true
				button.get_node("Online").visible = false
		onlinelistnode.get_node("ScrollContainer/VBoxContainer/" + str(get_tree().get_network_unique_id())).queue_free()

remote func anfrage(anfrager_id, anfrager_name = "spieler", anfrage : bool = true):
	if anfrage:
		#Anfrage erhalten
		available = false
		rpc_id(1, "spieler_available_update", false, false, get_tree().get_network_unique_id())
		onlinelistnode.get_node("Zufall").set_text("Zufall")
		onlinelistnode.get_node("Zufall").disabled = false
		onlinelistnode.anfrager_id = anfrager_id
		onlinelistnode.anfrager_name = anfrager_name
#		onlinelistnode.anfrager_name = anfrager_name
		onlinelistnode.get_node("anfragNode").visible = true
		onlinelistnode.get_node("anfragNode/ColorRect/Label").set_text(str(anfrager_name))
		onlinelistnode.get_node("anfragNode/ColorRect/AnimationPlayer").play("InsBild")
		onlinelistnode.get_node("anfragNode/ColorRect/Tween").interpolate_property(onlinelistnode.get_node("anfragNode/ColorRect"), "rect_position:y", Autoload.actual_screen_height, Autoload.actual_screen_height - 344, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		onlinelistnode.get_node("anfragNode/ColorRect/Tween").start()
		onlinelistnode.get_node("NochDaCheckTimer").start()
	else:
#		rpc_id(1, "spieler_available_update", true, get_tree().get_network_unique_id())
		onlinelistnode.get_node("anfragNode/ColorRect/AnimationPlayer").play_backwards("InsBild")
		onlinelistnode.get_node("anfragNode/ColorRect/Tween").interpolate_property(onlinelistnode.get_node("anfragNode/ColorRect"), "rect_position:y", Autoload.actual_screen_height - 344, Autoload.actual_screen_height, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		onlinelistnode.get_node("anfragNode/ColorRect/Tween").start()
		yield(onlinelistnode.get_node("anfragNode/ColorRect/Tween"), "tween_completed")
		onlinelistnode.get_node("anfragNode").visible = false

remote func reagiert_auf_anfrage(anderer_id, anderer_name, accepted : bool, returned : bool = false):
	if accepted:
# warning-ignore:return_value_discarded
#		get_parent().add_child($"/root/Start/OnlineListe".HAUPTONLINE.instance())
		if not returned:
			rpc_id(1, "spieler_available_update", false, true, get_tree().get_network_unique_id(), true)
			get_parent().get_node("Start/OnlineListe/TransitionBlackness").black(false)
			spielpartner_id = anderer_id
			spielpartner_name = anderer_name
			onlinelistnode.get_node("NochDaTimer").stop()
			onlinelistnode.get_node("NochDaCheckTimer").stop()
			rpc_id(anderer_id, "reagiert_auf_anfrage", get_tree().get_network_unique_id(), Autoload.savegame_data.sp1name, true, true)
		else:
			onlinelistnode.anfrager_id = null
			rpc_id(1, "spieler_available_update", false, true, get_tree().get_network_unique_id(), true)
			onlinelistnode.get_node("TransitionBlackness").black()
	else:
		onlinelistnode.get_node("MomentNode/ColorRect/AnimationPlayer").play_backwards("InsBild")
		onlinelistnode.get_node("MomentNode/ColorRect/Tween").interpolate_property(onlinelistnode.get_node("MomentNode/ColorRect"), "rect_position:y", Autoload.actual_screen_height - 344, Autoload.actual_screen_height, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		onlinelistnode.get_node("MomentNode/ColorRect/Tween").start()
		yield(onlinelistnode.get_node("MomentNode/ColorRect/Tween"), "tween_completed")
		onlinelistnode.get_node("MomentNode").visible = false
		print("Anfrage wurde abgelehnt")

remote func random_verbinden(anderer_id : int, anderer_name : String, spieler2 : bool):
	available = false
	onlinelistnode.get_node("Zufall").set_text("Zufall")
	onlinelistnode.get_node("Zufall").disabled = false
	rpc_id(1, "spieler_available_update", false, true, get_tree().get_network_unique_id(), true)
	spielpartner_id = anderer_id
	spielpartner_name = anderer_name
	onlinelistnode.get_node("NochDaTimer").stop()
	onlinelistnode.get_node("NochDaCheckTimer").stop()
	onlinelistnode.anfrager_id = null
	onlinelistnode.get_node("TransitionBlackness").black(spieler2)

# Ab hier kommen sachen, die das Spiel an sich betreffen
remote func bin_bereit(antwort : bool = false, noch_nicht_ready : bool = false):
	if not antwort:
		if $"/root/Welt".spielphase == 2:
			rpc_id(spielpartner_id, "bin_bereit", true)
			$"/root/Welt".zu_phase_zwei_wechseln()
			if $"/root/Welt/WarteAufControl".visible:
				$"/root/Welt/WarteAufControl/Control/AnimationPlayer".play_backwards("open")
				yield($"/root/Welt/WarteAufControl/Control/AnimationPlayer", "animation_finished")
				$"/root/Welt/WarteAufControl".visible = false
			if $"/root/Welt".spieler2_ist_dran:
				$"/root/Welt/NotifyRect/Control/NamenLabel".set_text(spielpartner_name)
				$"/root/Welt/NotifyRect/Control/InfoLabel".set_text("ist dran")
				$"/root/Welt/NotifyRect/Control/AnimationPlayer".play("open")
				$"/root/Welt/NotifyRect".visible = true
				$"/root/Welt/NochDaCheckTimer".start()
		#Hier neu dazu geschrieben:
		else:
			rpc_id(spielpartner_id, "bin_bereit", true, true)
	elif not noch_nicht_ready:
		$"/root/Welt".zu_phase_zwei_wechseln()
		$"/root/Welt/WarteAufControl".visible = false
		if $"/root/Welt".spieler2_ist_dran:
			$"/root/Welt/NotifyRect/Control/NamenLabel".set_text(spielpartner_name)
			$"/root/Welt/NotifyRect/Control/InfoLabel".set_text("ist dran")
			$"/root/Welt/NotifyRect/Control/AnimationPlayer".play("open")
			$"/root/Welt/NotifyRect".visible = true
			$"/root/Welt/NochDaCheckTimer".start()
	
	#Das hier mit vorherigem neu dazu geschrieben:
	else:
		$"/root/Welt/WarteAufControl/Control/AnimationPlayer".play("open")
		$"/root/Welt/WarteAufControl/Control/WarteAufLabel".set_text(Server.spielpartner_name)
		$"/root/Welt/WarteAufControl".visible = true

remote func schiffdaten_senden(sp1_felder, sp1_centerfelder, sp2_felder, sp2_centerfelder):
	if $"/root/Welt".spieler2_ist_dran:
		Autoload.spieler1_felder = sp1_felder
		Autoload.spieler1_centerfelder = sp1_centerfelder
	else:
		Autoload.spieler2_felder = sp2_felder
		Autoload.spieler2_centerfelder = sp2_centerfelder

remote func beschossene_senden(sp1_beschossene, sp2_beschossene, spielerwechseln : bool = false):
	if $"/root/Welt".spieler2_ist_dran:
		Autoload.spieler1_beschossene = sp1_beschossene
	else:
		Autoload.spieler2_beschossene = sp2_beschossene
	$"/root/Welt/EigenschiffControl/EigeneFelder".treffer_markieren(not $"/root/Welt".spieler2_ist_dran)
	
	if spielerwechseln:
		$"/root/Welt/NotifyRect/Control/AnimationPlayer".play_backwards("open")
		yield($"/root/Welt/NotifyRect/Control/AnimationPlayer", "animation_finished")
		$"/root/Welt/NotifyRect".visible = false

remote func rakete_fliegen(feldname):
	var feld = get_node("/root/Welt/EigenschiffControl/EigeneFelder/" + feldname)
	var rakete = RAKETE.instance()
	$"/root/Welt/Raketen".add_child(rakete)
	rakete.ziel = feld.rect_global_position + feld.rect_size / 2
	rakete.nur_schoen = true
	rakete.fliegen($"/root/Welt/Felder".rect_position)

remote func besetzdinger_senden(besetzdinger_array, schifflaengen_array, zweitschiffe_array):
	# Die Besetzfeld-Dinger-Schiff-Namen werden in den Feldern des anderen Spielers gespeichert.
	for n in 10:
		for i in 10:
			if $"/root/Welt".spieler2_ist_dran:
				get_node("/root/Welt/Felder/" + str(i + 1) + "_" + str(n + 1)).sp1_schiffli_name = besetzdinger_array[10 * n + i]
				get_node("/root/Welt/Felder/" + str(i + 1) + "_" + str(n + 1)).sp1_centerfeld_schifflaenge = schifflaengen_array[10 * n + i]
				get_node("/root/Welt/Felder/" + str(i + 1) + "_" + str(n + 1)).sp1_centerfeld_zweites_schiff = zweitschiffe_array[10 * n + i]
			else:
				get_node("/root/Welt/Felder/" + str(i + 1) + "_" + str(n + 1)).sp2_schiffli_name = besetzdinger_array[10 * n + i]
				get_node("/root/Welt/Felder/" + str(i + 1) + "_" + str(n + 1)).sp2_centerfeld_schifflaenge = schifflaengen_array[10 * n + i]
				get_node("/root/Welt/Felder/" + str(i + 1) + "_" + str(n + 1)).sp2_centerfeld_zweites_schiff = zweitschiffe_array[10 * n + i]
	emit_signal("data_received")

remote func spiel_wurde_gewonnen():
	$"/root/Welt/NotifyRect".visible = false
	$"/root/Welt/Gewonnen/Label".set_text("Spiel verloren")
	$"/root/Welt/Gewonnen/Tween".interpolate_property($"/root/Welt/Gewonnen", "rect_position:y", $"/root/Welt/Gewonnen".rect_position.y, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$"/root/Welt/Gewonnen/Tween".start()
	$"/root/Welt".spielphase = 3
	$"/root/Welt".gewinnercheck(false)

remote func anderer_spiel_verlassen():
	$"/root/Welt".anderer_noch_da = false
	if $"/root/Welt".spielphase == 3:
		$"/root/Welt/Gewonnen/Revanche".disabled = true
	else:
		$"/root/Welt".spielphase = 2
		$"/root/Welt/WarteAufControl".visible = false
		$"/root/Welt/NotifyRect/Control/NamenLabel".set_text(spielpartner_name)
		$"/root/Welt/NotifyRect/Control/InfoLabel".set_text("hat das Spiel verlassen")
		$"/root/Welt/NotifyRect/Control/ListenButton".visible = true
		$"/root/Welt/NotifyRect/Control/HintergrundButton".visible = false
		$"/root/Welt/NotifyRect/Control/HintergrundButton2".visible = true
		$"/root/Welt/NotifyRect/Control/AnimationPlayer".play("open")
		$"/root/Welt/NotifyRect".visible = true
		$"/root/Welt/NochDaCheckTimer".stop()

remote func noch_da(frager_id, frage : bool = false):
	if frage && ((get_node_or_null("/root/Welt") && spielpartner_id == frager_id) or (get_node_or_null("/root/Start/OnlineListe") && not ingame)):
		rpc_id(frager_id, "noch_da", 5318008) #Id wieder unnötig, BOOBIES
	elif get_node_or_null("/root/Welt") != null:
		$"/root/Welt/NochDaTimer".stop()
	else:
		print("NochDaTimer gestoppt")
		$"/root/Start/OnlineListe/NochDaTimer".stop()

remote func revanche(anfrage : bool = true):
	if anfrage:
		$"/root/Welt/IngameAnfragNode".visible = true
		$"/root/Welt/IngameAnfragNode/ColorRect/AnimationPlayer".play("InsBild")
		$"/root/Welt/IngameAnfragNode/ColorRect/Tween".interpolate_property($"/root/Welt/IngameAnfragNode/ColorRect", "rect_position:y", Autoload.actual_screen_height, Autoload.actual_screen_height - 344, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$"/root/Welt/IngameAnfragNode/ColorRect/Tween".start()
	else:
		$"/root/Welt/IngameAnfragNode/ColorRect/AnimationPlayer".play_backwards("InsBild")
		$"/root/Welt/IngameAnfragNode/ColorRect/Tween".interpolate_property($"/root/Welt/IngameAnfragNode/ColorRect", "rect_position:y", Autoload.actual_screen_height - 344, Autoload.actual_screen_height, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$"/root/Welt/IngameAnfragNode/ColorRect/Tween".start()
		yield($"/root/Welt/IngameAnfragNode/ColorRect/Tween", "tween_completed")
		$"/root/Welt/IngameAnfragNode".visible = false

remote func reagiert_auf_revanche(accepted : bool = true):
	if accepted:
		$"/root/Welt".name = "NichtWelt"
		$"/root/NichtWelt/TransitionBlackness".black()
	else:
		$"/root/Welt/IngameMomentNode/ColorRect/AnimationPlayer".play_backwards("InsBild")
		$"/root/Welt/IngameMomentNode/ColorRect/Tween".interpolate_property($"/root/Welt/IngameMomentNode/ColorRect", "rect_position:y", Autoload.actual_screen_height - 344, Autoload.actual_screen_height, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$"/root/Welt/IngameMomentNode/ColorRect/Tween".start()
		yield($"/root/Welt/IngameMomentNode/ColorRect/Tween", "tween_completed")
		$"/root/Welt/IngameMomentNode".visible = false

remote func server_da_check():
	rpc_id(1, "spieler_da_check", get_tree().get_network_unique_id(), available, Autoload.savegame_data.sp1name, ingame)
