extends Control

export var laenge : int = 2

var normale_position = Vector2()
var jetzige_position = Vector2()
var jetzige_touch_position = Vector2()
var button_pressed : bool = false
var rotiert : bool = false
var im_feld : bool = false
var nur_tippend : bool = false
var zweites : bool = false
var nahfeld
var jetziges_nahfeld
var s1_gesehen : bool = false
var s2_gesehen : bool = false

onready var felder_node = get_node("/root/Welt/Felder")

func _ready():
	if name == "1" or name == "3":
		zweites = true
		$Button.modulate = Color(0, 0, 1)

func _input(event):
	if event is InputEventScreenTouch && event.is_pressed():
		jetzige_touch_position = get_global_mouse_position()

func _process(_delta):
	if button_pressed:
		rect_global_position = get_global_mouse_position()

func einrasten():
	if felder_node.ist_moeglich(im_feld):
		rect_position = nahfeld.rect_position + nahfeld.rect_size / 2 + felder_node.rect_position
		felder_node.besetztfelder_markieren(false, name)
		Autoload.centerfelder_anpassen(nahfeld, rotiert, laenge, zweites, true)
	
	else:
		rect_position = normale_position
		rotiert = false
		rect_rotation = 0
		nahfeld = null
		felder_node.nahfeld = null

func _on_Button_mouse_entered():
	$"/root/Welt".unselectbar = false

func _on_Button_mouse_exited():
	$"/root/Welt".unselectbar = true

func _on_Button_pressed():
	if $"/root/Welt".spielphase == 1 && not get_parent().get_parent().get_node("SettingWegButton").visible:
		button_pressed = true
		get_parent().get_parent().get_node("Einstellungen").sonst_okay = false
		jetzige_position = rect_position
		jetziges_nahfeld = nahfeld
		felder_node.laenge = laenge
		felder_node.rotiert = rotiert
		felder_node.nahfeld = nahfeld
		if im_feld:
			felder_node.besetztfelder_markieren(true, name)
			Autoload.centerfelder_anpassen(nahfeld, rotiert, laenge, zweites, false)
		get_parent().move_child(get_node("/root/Welt/Schiffe/" + str(name)), $"/root/Welt".anzahl_schiffe)
		$"/root/Welt".schiffli_selected(name)
		get_parent().get_parent().unselectbar = false
		
		nur_tippend = true
		$NurtippTimer.start()
		yield(get_tree().create_timer(0.01), "timeout")

func _on_Button_released():
	if $"/root/Welt".spielphase == 1 && not get_parent().get_parent().get_node("SettingWegButton").visible:
		if (get_global_mouse_position() - jetzige_touch_position).length() > 50:
			nur_tippend = false
		if nur_tippend:
			rect_position = jetzige_position
			nahfeld = jetziges_nahfeld
			felder_node.nahfeld = jetziges_nahfeld
			if im_feld:
				einrasten()
			get_parent().get_parent()._on_RotateButton_pressed()
		else:
			einrasten()
		get_parent().get_parent().unselectbar = true
		button_pressed = false
		
		yield(get_tree().create_timer(0.1), "timeout")
		get_parent().get_parent().get_node("Einstellungen").sonst_okay = true

func _on_NurtippTimer_timeout():
	nur_tippend = false

func todesanimation():
	if not (s1_gesehen && $"/root/Welt".spieler2_ist_dran == false) && not (s2_gesehen && $"/root/Welt".spieler2_ist_dran):
		$Todesplayer.play("Tod")
		$Schiffkaputt.play()
		if get_parent().name == "EigeneSchiffe":
			$KaputtSprite.modulate = Color(1, 0.4, 0.4)
		if Autoload.savegame_data.vibration:
			Input.vibrate_handheld(70)
		$"/root/Welt/Camera2D"._screen_shake(0.6, laenge * Autoload.savegame_data.screenshake_value)
	
	if $"/root/Welt".spieler2_ist_dran:
		s2_gesehen = true
	else:
		s1_gesehen = true
