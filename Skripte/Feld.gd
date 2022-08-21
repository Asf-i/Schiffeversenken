extends Control

const RAKETE = preload("res://Szenen/Rakete.tscn")

var schiffli : bool = false
var sp1_schiffli_name : String = ""
var sp2_schiffli_name : String = ""
var aufgedeckt : bool = false
var sp1_centerfeld_schifflaenge : int = 0
var sp2_centerfeld_schifflaenge : int = 0
var sp1_centerfeld_zweites_schiff : bool = false
var sp2_centerfeld_zweites_schiff : bool = false
var besetzt : int = 0
var coords = Vector2()

var eigene_spieler_beschossene
var anderer_spieler_felder

func _on_Feld_pressed():
	if $"/root/Welt".spielphase == 2 && not aufgedeckt && get_parent().name == "Felder" && not $"/root/Welt".paratfeld_im_bild:
		aufgedeckt = true
#		var eigene_spieler_beschossene
#		var anderer_spieler_felder
		
		if $"/root/Welt".spieler2_ist_dran:
			eigene_spieler_beschossene = Autoload.spieler2_beschossene
			anderer_spieler_felder = Autoload.spieler1_felder
		else:
			eigene_spieler_beschossene = Autoload.spieler1_beschossene
			anderer_spieler_felder = Autoload.spieler2_felder
		
		var rakete = RAKETE.instance()
		$"/root/Welt/Raketen".add_child(rakete)
		rakete.ziel = rect_global_position + rect_size / 2
		rakete.feld = self
		rakete.fliegen($"/root/Welt/EigenschiffControl".rect_global_position)
		if not name in anderer_spieler_felder:
			$"/root/Welt/Felder/Abdeckung".visible = true
		if get_node_or_null("/root/Start") != null:
			Server.rpc_id(Server.spielpartner_id, "rakete_fliegen", name)

func machen():
	var check_schiffli_name = "nix"
	$Particles2D2.emitting = true
	if name in anderer_spieler_felder:
		eigene_spieler_beschossene[name] = true
		if $"/root/Welt".spieler2_ist_dran:
			$"/root/Welt".spieler2_punkte += 1
			$"/root/Welt".spieler1_versenkte[sp1_schiffli_name] -= 1
			check_schiffli_name = sp1_schiffli_name
		else:
			$"/root/Welt".spieler1_punkte += 1
			$"/root/Welt".spieler2_versenkte[sp2_schiffli_name] -= 1
			check_schiffli_name = sp2_schiffli_name
		$Button.modulate = get_parent().trefferfarbe
		$Treffer/Treffplayer.play("erscheinen")
		$Particles2D.emitting = true
		$Explosion.play()
		if Autoload.savegame_data.vibration:
			Input.vibrate_handheld(50)
		$"/root/Welt".vollschiffcheck(check_schiffli_name, name)
		$"/root/Welt".gewinnercheck()
	else:
		eigene_spieler_beschossene[name] = false
		$Button.modulate = get_parent().verfehltfarbe
		$Verfehlt/Verfehltplayer.play("erscheinen")
		$Platschsound.play()
		if get_node_or_null("/root/Start") != null:
			Server.rpc_id(Server.spielpartner_id, "beschossene_senden", Autoload.spieler1_beschossene, Autoload.spieler2_beschossene, true)
			Server.rpc_id(Server.spielpartner_id, "feldanimation", name, false)
		yield(get_tree().create_timer(0.25), "timeout")
		$"/root/Welt".spielerparatfeld_anzeigen()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Schiff"):
		body.get_parent().nahfeld = get_node("/root/Welt/Felder/" + name)
		get_parent().nahfeld = get_node("/root/Welt/Felder/" + name)
